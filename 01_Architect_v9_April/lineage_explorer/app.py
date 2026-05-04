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

@st.cache_data(ttl=600)
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

@st.cache_data(ttl=600)
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
    # Wave 0: no silver dependencies
    for r in slv_regs:
        deps = r.get("depends_on", "") or ""
        if not deps or deps in ("nan", "None") or "silver" not in deps:
            slv_waves[r.get("target_table", "")] = 0
    # Build snake_case → PascalCase lookup for dependency resolution
    snake_to_pascal = {}
    for tbl, reg in registry.items():
        # slv_invoice_detail_line_level → InvoiceDetailLineLevel
        snake_name = tbl[0].lower() + "".join(f"_{c.lower()}" if c.isupper() else c for c in tbl[1:])
        snake_to_pascal[f"slv_{snake_name}"] = tbl
        snake_to_pascal[tbl.lower()] = tbl
        snake_to_pascal[tbl] = tbl

    # Wave 1..N: collect all candidates per wave THEN assign
    for wave in range(1, 30):
        newly_assigned = {}
        for r in slv_regs:
            tbl = r.get("target_table", "")
            if tbl in slv_waves: continue
            deps = r.get("depends_on", "") or ""
            try:
                dep_list = json.loads(deps)
                dep_tables = []
                for d in dep_list:
                    if "silver" in d or "slv" in d:
                        raw_name = d.split(".")[-1]
                        resolved = snake_to_pascal.get(raw_name, raw_name)
                        dep_tables.append(resolved)
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

    def get_tier(name):
        """Tier assignment using registry layer + wave computation."""
        n = name.lower()
        if "enterprise_lakehouse" in n or "supplychain_lakehouse" in n:
            return "other"

        # Resolve snake_case node name to PascalCase registry key
        reg_key = node_to_registry.get(name) or node_to_registry.get(n, name)

        # Check registry layer (v10 format)
        layer = layer_map.get(reg_key, "")
        if layer == "DomainSilver":
            return f"slv{slv_waves.get(reg_key, 0)}"
        if layer == "Staging":
            return "stg"
        if layer in ("ReferenceMaster", "LogicalBronze"):
            return "brz"
        if layer == "Gold":
            return "gld"

        # EDW supplement staging tables — separate tier between Source and Bronze
        if n.endswith("_edw") or n.endswith("Edw"):
            return "stg"

        # Fallback: schema-based (physical names from v10 Bob Standards)
        schema = name.split(".")[0] if "." in name else ""
        if schema.endswith("_ENH"):
            return f"slv{slv_waves.get(reg_key, 0)}"
        if schema.endswith("_WRK") or schema == "Staging_WRK":
            return "stg"
        if schema.endswith("_DW") or schema == "ForecastAccuracy_DW":
            return "gld"
        if schema == "ReferenceMaster_ENH":
            return "brz"

        # Legacy fallback: prefix-based (canonical names)
        if n.startswith("brz_") or n.startswith("ref_"):
            return "brz"
        if n.startswith("slv_"):
            return f"slv{slv_waves.get(reg_key, 0)}"
        if n.startswith("gld_") or n.startswith("dim_") or n.startswith("Dim") or n.startswith("Fact"):
            return "gld"
        return "other"

    for row in rows:
        src_schema = row.get("source_schema", "").strip()
        src_table = row.get("source_table", "").strip()
        tgt_schema = row.get("target_schema", "").strip()
        tgt_table = row.get("target_table", "").strip()

        # Source node ID: full path for external, table name for internal
        if "Enterprise_Lakehouse" in src_schema or "SupplyChain_Lakehouse" in src_schema:
            src_id = f"{src_schema}.{src_table}"
        else:
            src_id = src_table

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

tab1, tab2, tab3 = st.tabs(["📊 Table Lineage DAG", "🔄 ETL Flow by Table", "👁️ View Definitions"])

# ══ TAB 1: DAG ══
with tab1:
    dag_data = build_dag_data()
    html_content = html_path.read_text(encoding="utf-8")
    if dag_data and dag_data["nodes"]:
        html_content = html_content.replace("window.__LINEAGE_API_DATA__ = null;", f"window.__LINEAGE_API_DATA__ = {json.dumps(dag_data)};")
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
    st.caption("SQL source code of all ETL views (bronze / silver / gold)")
    views = load_csv("views.csv")
    if views:
        schemas = sorted(set(v.get("schema", "") for v in views))
        selected_schema = st.selectbox("Filter by schema", ["All"] + schemas)
        filtered = views if selected_schema == "All" else [v for v in views if v.get("schema") == selected_schema]
        for v in filtered:
            with st.expander(f"📝 {v.get('schema','')}.{v.get('view_name','')}", expanded=False):
                st.code(v.get("definition", ""), language="sql")
        st.info(f"Total: {len(filtered)} views")

st.markdown("---")
st.caption("Fabric Lineage Flow — Supply Chain | Data auto-refreshed via GitHub Actions")
