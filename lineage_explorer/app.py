"""
Supply Chain Warehouse — Lineage Explorer
==========================================
Tab 1: Interactive DAG (React SVG)
Tab 2: ETL Flow by Table
Tab 3: View Definitions
"""

import json
import csv
import os
import streamlit as st
import streamlit.components.v1 as components
from pathlib import Path

st.set_page_config(page_title="SC Lineage Explorer", layout="wide", initial_sidebar_state="collapsed")

# ── Authentication ──
DEFAULT_USER = "admin123"
DEFAULT_PASS = "admin123"

def check_login():
    if st.session_state.get("authenticated"):
        return True
    st.markdown("""<style>[data-testid="stAppViewContainer"] {background: #0a0f1a;}</style>""", unsafe_allow_html=True)
    col1, col2, col3 = st.columns([1, 1, 1])
    with col2:
        st.markdown("<h2 style='text-align:center; margin-top:20vh; color:#e2e8f0;'>🔗 Lineage Explorer</h2>", unsafe_allow_html=True)
        st.markdown("<p style='text-align:center; color:#64748b; margin-bottom:2rem;'>Supply Chain Warehouse — Hybrid Medallion</p>", unsafe_allow_html=True)
        with st.form("login_form"):
            username = st.text_input("Username")
            password = st.text_input("Password", type="password")
            submitted = st.form_submit_button("Login", use_container_width=True)
        if submitted:
            valid_user = st.secrets.get("LOGIN_USER", DEFAULT_USER)
            valid_pass = st.secrets.get("LOGIN_PASS", DEFAULT_PASS)
            if username == valid_user and password == valid_pass:
                st.session_state["authenticated"] = True
                st.rerun()
            else:
                st.error("Invalid username or password.")
    return False

if not check_login():
    st.stop()

DATA_DIR = Path(__file__).parent / "data"

@st.cache_data(ttl=60)
def load_csv(filename):
    path = DATA_DIR / filename
    if not path.exists():
        return []
    with open(path, newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))

def parse_json_array(raw_value):
    if not raw_value or raw_value in ("nan", "None"):
        return []
    try:
        parsed = json.loads(raw_value)
        return parsed if isinstance(parsed, list) else []
    except Exception:
        return []

def load_augmented_lineage_rows():
    """
    Base lineage comes from the exported CSV snapshot.
    Supplement it with the documented SupplyChain_Lakehouse -> _edw bridge
    for the four temporary EDW-backed bronze/ref tables.
    """
    lineage_rows = list(load_csv("lineage.csv"))
    registry_rows = load_csv("registry.csv")
    supplemental = []
    seen = set()

    for reg in registry_rows:
        target_schema = (reg.get("target_schema", "") or "").strip()
        target_table = (reg.get("target_table", "") or "").strip()
        for src_obj in parse_json_array(reg.get("source_objects", "")):
            src_obj = (src_obj or "").strip()
            if not src_obj.startswith("bronze.") or not src_obj.endswith("_edw"):
                continue

            src_table = src_obj.split(".", 1)[1]
            base_table = src_table[:-4]  # strip trailing "_edw"
            lakehouse_source = f"SupplyChain_Lakehouse.dbo.{base_table}_ver2"
            key = (lakehouse_source, "bronze", src_table, target_schema, target_table)
            if key in seen:
                continue
            seen.add(key)

            supplemental.append({
                "lineage_id": "",
                "source_schema": "SupplyChain_Lakehouse",
                "source_table": f"dbo.{base_table}_ver2",
                "target_schema": "bronze",
                "target_table": src_table,
                "relationship_type": "direct",
                "sp_name": "bronze.usp_refresh_edw_tables",
            })

    return lineage_rows + supplemental

def lineage_node_id(source_schema, source_table):
    schema = (source_schema or "").strip()
    table = (source_table or "").strip()
    if "Enterprise_Lakehouse" in schema or "SupplyChain_Lakehouse" in schema:
        return f"{schema}.{table}"
    return table

def build_recursive_mini_dag(lineage_rows, selected_schema, selected_table):
    by_target = {}
    for row in lineage_rows:
        key = (row.get("target_schema", "").strip(), row.get("target_table", "").strip())
        by_target.setdefault(key, []).append(row)

    mini_nodes, mini_edges, mini_seen = [], [], set()
    visited_targets = set()

    def add_node(schema, table, selected=False):
        node_id = lineage_node_id(schema, table)
        if node_id not in mini_seen:
            mini_seen.add(node_id)
            mini_nodes.append({
                "id": node_id,
                "layer": "gld" if selected else "other",
                "load_type": "",
                "status": "",
                "last_load_date": "",
                "rows_loaded": 0
            })
        return node_id

    def walk(schema, table, selected=False):
        key = (schema, table)
        if key in visited_targets:
            return
        visited_targets.add(key)

        target_id = add_node(schema, table, selected=selected)
        for row in by_target.get(key, []):
            src_schema = row.get("source_schema", "").strip()
            src_table = row.get("source_table", "").strip()
            src_id = add_node(src_schema, src_table, selected=False)
            mini_edges.append({"source": src_id, "target": target_id})
            walk(src_schema, src_table, selected=False)

    walk(selected_schema, selected_table, selected=True)
    return {"nodes": mini_nodes, "edges": mini_edges}

@st.cache_data(ttl=60)
def build_dag_data():
    rows = load_augmented_lineage_rows()
    registry = {r.get("target_table", ""): r for r in load_csv("registry.csv")}
    nodes, edges, seen = [], [], set()

    # Build layer lookup from registry (v10 uses DomainSilver, ReferenceMaster, etc.)
    layer_map = {}  # target_table -> layer
    for tbl, reg in registry.items():
        layer_map[tbl] = (reg.get("layer", "") or "").strip()

    # Compute silver waves from depends_on
    slv_waves = {}
    slv_regs = [r for r in registry.values() if r.get("layer", "").strip() == "DomainSilver"]
    # Build set of Silver table names for dependency matching
    slv_table_set = set(r.get("target_table", "") for r in slv_regs)

    # Wave 0: no Silver dependencies in depends_on
    for r in slv_regs:
        deps = r.get("depends_on", "") or ""
        if not deps or deps in ("nan", "None"):
            slv_waves[r.get("target_table", "")] = 0
        else:
            try:
                dep_list = json.loads(deps)
                # Check if any dependency is a Silver table (by physical name match)
                has_slv_dep = any(d.split(".")[-1] in slv_table_set for d in dep_list)
                if not has_slv_dep:
                    slv_waves[r.get("target_table", "")] = 0
            except:
                slv_waves[r.get("target_table", "")] = 0

    # Wave 1..N: iterative assignment
    for wave in range(1, 30):
        newly_assigned = {}
        for r in slv_regs:
            tbl = r.get("target_table", "")
            if tbl in slv_waves: continue
            deps = r.get("depends_on", "") or ""
            try:
                dep_list = json.loads(deps)
                dep_tables = [d.split(".")[-1] for d in dep_list if d.split(".")[-1] in slv_table_set]
                if dep_tables and all(dt in slv_waves for dt in dep_tables):
                    newly_assigned[tbl] = wave
            except: pass
        if not newly_assigned: break
        slv_waves.update(newly_assigned)

    # Build reverse lookup: snake_case node ID → PascalCase registry key
    # e.g. slv_actual_demand_monthly → ActualDemandMonthly
    node_to_registry = {}
    for tbl in registry:
        node_to_registry[tbl] = tbl
        node_to_registry[tbl.lower()] = tbl
        # PascalCase → snake_case: InvoiceDetailLineLevel → invoice_detail_line_level
        snake = "".join(f"_{c.lower()}" if c.isupper() else c for c in tbl).lstrip("_")
        node_to_registry[f"slv_{snake}"] = tbl
        node_to_registry[f"gld_{snake}"] = tbl
        node_to_registry[snake] = tbl

    # Build schema→tier lookup from registry
    schema_tier = {}
    for tbl, reg in registry.items():
        schema = reg.get("target_schema", "")
        layer = (reg.get("layer", "") or "").strip()
        if layer == "DomainSilver": schema_tier[schema] = "slv"
        elif layer == "Staging": schema_tier[schema] = "stg"
        elif layer == "ReferenceMaster": schema_tier[schema] = "brz"
        elif layer == "Gold": schema_tier[schema] = "gld"

    def get_tier(name):
        """Tier assignment using physical schema names."""
        n = name.lower()
        # External sources → Bronze
        if "enterprise_lakehouse" in n or "supplychain_lakehouse" in n or "manual" in n:
            return "other"

        # Semantic models (downstream from Gold)
        if name.startswith("SemanticModel.") or "semanticmodel" in n:
            return "sem"

        # Extract table name (after last dot)
        tbl = name.split(".")[-1] if "." in name else name
        schema = name.split(".")[0] if "." in name else ""

        # Direct registry match
        layer = layer_map.get(tbl, "")
        if layer == "DomainSilver":
            return f"slv{slv_waves.get(tbl, 0)}"
        if layer == "Staging":
            return "stg"
        if layer == "ReferenceMaster":
            return "brz"
        if layer == "Gold":
            return "gld"

        # Schema-based fallback
        if schema in schema_tier:
            tier = schema_tier[schema]
            return f"slv{slv_waves.get(tbl, 0)}" if tier == "slv" else tier

        # Name-based fallback (case-insensitive — handles both legacy _ENH/_WRK and Bob-aligned _Enh/_Wrk)
        if "Edw" in name: return "stg"
        schema_lower = schema.lower()
        if schema_lower.endswith("_enh"): return f"slv{slv_waves.get(tbl, 0)}"
        if schema_lower.endswith("_wrk"): return "stg"
        if schema_lower.endswith("_dw"): return "gld"
        return "other"

    for row in rows:
        src_schema = row.get("source_schema", "").strip()
        src_table = row.get("source_table", "").strip()
        tgt_schema = row.get("target_schema", "").strip()
        tgt_table = row.get("target_table", "").strip()

        # Source node ID: full path for external/semantic, table name for internal
        if "Enterprise_Lakehouse" in src_schema or "SupplyChain_Lakehouse" in src_schema:
            src_id = f"{src_schema}.{src_table}"
        elif src_schema == "SemanticModel":
            src_id = f"{src_schema}.{src_table}"
        else:
            src_id = src_table

        # Target node ID: full path for SemanticModel target, table name for internal
        if tgt_schema == "SemanticModel":
            tgt_id = f"{tgt_schema}.{tgt_table}"
        else:
            tgt_id = tgt_table
        if src_id not in seen:
            seen.add(src_id)
            nodes.append({"id": src_id, "layer": get_tier(src_id), "load_type": "", "status": "", "last_load_date": "", "rows_loaded": 0})
        if tgt_id not in seen:
            seen.add(tgt_id)
            reg = registry.get(tgt_table, {})
            nodes.append({"id": tgt_id, "layer": get_tier(tgt_id), "load_type": reg.get("load_type", ""), "status": "", "last_load_date": "", "rows_loaded": 0})
        edges.append({"source": src_id, "target": tgt_id})
    return {"nodes": nodes, "edges": edges}

html_path = Path(__file__).parent / "templates" / "lineage.html"

@st.cache_data(ttl=60)
def build_node_mart_lookup() -> dict:
    """Build {bare_table_name: target_schema} from both lineage and registry.
    lineage.csv provides schema for every DAG node (most complete source).
    registry.csv is a secondary fallback.
    """
    lookup = {}
    # Primary: lineage.csv (every target node has target_schema)
    for e in load_csv("lineage.csv"):
        tbl = (e.get("target_table") or "").strip()
        schema = (e.get("target_schema") or "").strip()
        if tbl and schema:
            lookup[tbl] = schema
    # Secondary: registry.csv (catches assets without inbound edges)
    for r in load_csv("registry.csv"):
        tbl = (r.get("target_table") or "").strip()
        schema = (r.get("target_schema") or "").strip()
        if tbl and schema and tbl not in lookup:
            lookup[tbl] = schema
    return lookup


def _classify_by_schema(schema_or_nid: str) -> str:
    """Schema string → mart bucket. Pure pattern match, no I/O."""
    s = schema_or_nid or ""
    # Truly shared sources — Bronze EL/SC_LH + RefMaster (used by both marts)
    if any(k in s for k in [
        "Enterprise_Lakehouse", "SupplyChain_Lakehouse",
        "ReferenceMaster_Enh",
    ]):
        return "shared"
    # Staging_Wrk wrapper views — only consumed by forecast.v_OpenOrderLineLevel
    # → classify as forecast (not shared) so inventory mart filter doesn't show them
    if "Staging_Wrk" in s:
        return "forecast"
    # Forecast project schemas
    if any(k in s for k in [
        "SalesHistory_Enh", "ForecastHistory_Enh", "OpenOrderHistory_Enh",
        "ForecastAccuracy_DW", "sc_forecast_control_tower",
    ]):
        return "forecast"
    # Inventory Health schemas
    if any(k in s for k in [
        "InventoryHistory_Enh", "InventoryHealth_DW", "sc_inventory_health_control_tower",
    ]):
        return "inventory_health"
    return "other"


def classify_mart(node_id: str) -> str:
    """Map a node ID to its owning mart.
    Strategy:
      (1) If node_id contains a schema prefix → classify by that schema.
      (2) Else bare name → look up target_schema in registry, classify by it.
      (3) Fallback → 'other'.
    """
    nid = node_id or ""
    # Direct schema pattern match (works for both prefixed and the bare cases where schema name is in the string)
    primary = _classify_by_schema(nid)
    if primary != "other":
        return primary
    # Bare name fallback — look up its schema in registry
    bare = nid.split(".")[-1] if "." in nid else nid
    lookup = build_node_mart_lookup()
    schema = lookup.get(bare, "")
    if schema:
        return _classify_by_schema(schema)
    return "other"


def filter_dag_by_mart(dag_data: dict, mart: str) -> dict:
    """Filter DAG nodes and edges to only those belonging to the given mart.
    'all' = no filter. 'shared' includes bronze sources used by every mart.
    """
    if mart == "all":
        return dag_data
    nodes = dag_data.get("nodes", [])
    edges = dag_data.get("edges", [])
    # Keep nodes where mart matches OR shared (bronze / refmaster surface in every mart view)
    keep_ids = set()
    for n in nodes:
        nid = n.get("id", "")
        node_mart = classify_mart(nid)
        if node_mart == mart or node_mart == "shared":
            keep_ids.add(nid)
    # Also keep shared sources that connect to selected mart targets via edges
    for e in edges:
        if e.get("target") in keep_ids and e.get("source") not in keep_ids:
            # only keep upstream source if it's shared (avoid pulling in other marts)
            if classify_mart(e.get("source", "")) == "shared":
                keep_ids.add(e.get("source"))
    filtered_nodes = [n for n in nodes if n.get("id") in keep_ids]
    filtered_edges = [e for e in edges if e.get("source") in keep_ids and e.get("target") in keep_ids]
    return {"nodes": filtered_nodes, "edges": filtered_edges}


tab1, tab2, tab3 = st.tabs(["📊 Table Lineage DAG", "🔄 ETL Flow by Table", "👁️ View Definitions"])

# ══ TAB 1: DAG ══
with tab1:
    # Mart filter (project bucket)
    mart_col, _, _ = st.columns([2, 4, 2])
    with mart_col:
        mart_filter = st.selectbox(
            "🎯 Filter by Mart",
            options=["all", "forecast", "inventory_health"],
            format_func=lambda m: {
                "all": "All marts (everything)",
                "forecast": "Forecast Accuracy (supplychain)",
                "inventory_health": "Inventory Health",
            }[m],
            key="mart_filter_selectbox",
        )
    dag_data = build_dag_data()
    if mart_filter != "all":
        dag_data = filter_dag_by_mart(dag_data, mart_filter)
    # Per-layer counts for visibility (helps confirm cleaner layered view)
    layer_counts = {}
    for n in dag_data.get("nodes", []):
        layer_counts[n.get("layer","other")] = layer_counts.get(n.get("layer","other"),0) + 1
    layer_summary = " · ".join(f"{k}: {v}" for k,v in sorted(layer_counts.items()))
    st.caption(f"Showing {len(dag_data.get('nodes', []))} nodes · {len(dag_data.get('edges', []))} edges  |  {layer_summary}")
    html_content = html_path.read_text(encoding="utf-8")
    if dag_data and dag_data["nodes"]:
        html_content = html_content.replace("window.__LINEAGE_API_DATA__ = null;", f"window.__LINEAGE_API_DATA__ = {json.dumps(dag_data)};")
    # Inject mart_filter so HTML layer labels show correct Gold/Semantic for the selected mart
    html_content = html_content.replace("window.__LINEAGE_API_DATA__ = null;", "window.__LINEAGE_API_DATA__ = null;")  # noop guard
    html_content = html_content.replace("<body>", f"<body><script>window.__MART_FILTER__ = {json.dumps(mart_filter)};</script>")
    components.html(html_content, height=700, scrolling=False)

# ══ TAB 2: ETL Flow by Table ══
with tab2:
    st.header("🔄 ETL Flow by Table")
    st.caption("Select a table to see: sources → view → load pattern → target")

    registry = load_csv("registry.csv")
    lineage = load_augmented_lineage_rows()
    views = load_csv("views.csv")

    if registry:
        table_list = sorted([f"{r['target_schema']}.{r['target_table']}" for r in registry])
        selected = st.selectbox("Select a table", table_list)

        if selected:
            schema, table = selected.split(".", 1)
            row = next((r for r in registry if r["target_schema"] == schema and r["target_table"] == table), {})

            col1, col2, col3, col4 = st.columns(4)
            col1.metric("Layer", row.get("layer", ""))
            col2.metric("Load Type", row.get("load_type", ""))
            col3.metric("Frequency", row.get("frequency", ""))
            col4.metric("View", (row.get("view_name", "") or "—").split(".")[-1])

            src = row.get("source_objects", "")
            if src and src not in ("nan", "None", ""):
                st.markdown("**Source tables:**")
                try:
                    for s in json.loads(src): st.markdown(f"- `{s}`")
                except: st.code(src)

            deps = row.get("depends_on", "")
            if deps and deps not in ("nan", "None", ""):
                st.markdown("**Depends on:**")
                try:
                    for d in json.loads(deps): st.markdown(f"- `{d}`")
                except: st.code(deps)

            # Mini-DAG
            mini_dag = build_recursive_mini_dag(lineage, schema, table)
            if mini_dag["nodes"]:
                st.markdown("**ETL Flow:**")
                html_mini = html_path.read_text(encoding="utf-8")
                html_mini = html_mini.replace("window.__LINEAGE_API_DATA__ = null;", f"window.__LINEAGE_API_DATA__ = {json.dumps(mini_dag)};")
                components.html(html_mini, height=300, scrolling=False)

            view_name = row.get("view_name", "")
            if view_name and view_name not in ("nan", "None") and views:
                vparts = view_name.split(".")
                if len(vparts) == 2:
                    match = [v for v in views if v.get("schema") == vparts[0] and v.get("view_name") == vparts[1]]
                    if match:
                        with st.expander(f"📝 View SQL: {view_name}", expanded=False):
                            st.code(match[0].get("definition", ""), language="sql")

        st.markdown("---")
        with st.expander("📋 All tables", expanded=False):
            import pandas as pd
            df = pd.DataFrame(registry)
            cols = ["target_schema", "target_table", "layer", "load_type", "frequency", "view_name", "depends_on"]
            st.dataframe(df[[c for c in cols if c in df.columns]], use_container_width=True)

# ══ TAB 3: View Definitions ══
with tab3:
    st.header("👁️ View Definitions")
    st.caption("SQL source code of all ETL views across Silver (SupplyChain_Processing_Warehouse) and Gold (SupplyChain_Gold_Warehouse)")
    views = load_csv("views.csv")
    if views:
        warehouses = sorted(set(v.get("warehouse", "") for v in views if v.get("warehouse")))
        schemas = sorted(set(v.get("schema", "") for v in views))
        col_wh, col_sc = st.columns(2)
        with col_wh:
            wh_options = ["All"] + warehouses if warehouses else ["All"]
            selected_wh = st.selectbox("Filter by warehouse", wh_options)
        with col_sc:
            selected_schema = st.selectbox("Filter by schema", ["All"] + schemas)
        filtered = views
        if selected_wh != "All":
            filtered = [v for v in filtered if v.get("warehouse") == selected_wh]
        if selected_schema != "All":
            filtered = [v for v in filtered if v.get("schema") == selected_schema]
        for v in filtered:
            wh_prefix = f"[{v.get('warehouse','')}] " if v.get("warehouse") else ""
            with st.expander(f"📝 {wh_prefix}{v.get('schema','')}.{v.get('view_name','')}", expanded=False):
                st.code(v.get("definition", ""), language="sql")
        st.info(f"Total: {len(filtered)} views")

st.markdown("---")
st.caption("Fabric Lineage Flow — Supply Chain | Hybrid Medallion v10 (Bob Standards) | Data auto-refreshed via GitHub Actions")
