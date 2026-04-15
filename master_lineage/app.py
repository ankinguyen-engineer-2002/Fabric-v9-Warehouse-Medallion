"""
Supply Chain Warehouse v9 — Lineage Explorer
=============================================
Tab 1: Interactive DAG (React SVG)
Tab 2: Stored Procedure Lineage
Tab 3: View Definitions
"""

import json
import csv
import os
import streamlit as st
import streamlit.components.v1 as components
from pathlib import Path

st.set_page_config(page_title="SC Lineage Explorer", layout="wide", initial_sidebar_state="collapsed")

DATA_DIR = Path(__file__).parent / "data"


@st.cache_data(ttl=600)
def load_csv(filename):
    path = DATA_DIR / filename
    if not path.exists():
        return []
    with open(path, newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


@st.cache_data(ttl=600)
def build_dag_data():
    """Build {nodes, edges} for React DAG from lineage CSV."""
    rows = load_csv("lineage.csv")
    registry = {r.get("target_table", ""): r for r in load_csv("registry.csv")}

    nodes, edges, seen = [], [], set()

    # Build SLV wave map from depends_on (simple topological assignment)
    slv_waves = {}
    slv_regs = [r for r in registry.values() if r.get("layer", "").upper() == "SLV"]
    # Wave 0: no silver deps
    for r in slv_regs:
        deps = r.get("depends_on", "") or ""
        if not deps or deps in ("nan", "None") or "silver" not in deps:
            slv_waves[r.get("target_table", "")] = 0
    # Wave 1+: deps all in previous waves
    for wave in range(1, 10):
        for r in slv_regs:
            tbl = r.get("target_table", "")
            if tbl in slv_waves:
                continue
            deps = r.get("depends_on", "") or ""
            try:
                dep_list = json.loads(deps)
                dep_tables = [d.split(".")[-1].replace("usp_load_", "") for d in dep_list if "silver" in d]
                if all(dt in slv_waves for dt in dep_tables):
                    slv_waves[tbl] = wave
            except:
                pass

    for row in rows:
        src_schema = row.get("source_schema", "").strip()
        src_table = row.get("source_table", "").strip()
        tgt_schema = row.get("target_schema", "").strip()
        tgt_table = row.get("target_table", "").strip()

        if "Enterprise_Lakehouse" in src_schema or "SupplyChain_Lakehouse" in src_schema:
            src_id = f"{src_schema}.{src_table}"
            src_layer = "other"
        else:
            src_id = src_table
            # Determine source layer with wave
            src_layer = src_schema
            if src_table in slv_waves:
                src_layer = f"slv{slv_waves[src_table]}"
            elif "brz" in src_table or "ref" in src_table:
                src_layer = "brz"

        tgt_id = tgt_table

        if src_id not in seen:
            seen.add(src_id)
            nodes.append({"id": src_id, "layer": src_layer, "load_type": "", "status": "", "last_load_date": "", "rows_loaded": 0})

        if tgt_id not in seen:
            seen.add(tgt_id)
            reg = registry.get(tgt_table, {})
            layer_raw = (reg.get("layer", tgt_schema) or tgt_schema).upper()
            if layer_raw == "SLV" and tgt_table in slv_waves:
                layer = f"slv{slv_waves[tgt_table]}"
            elif layer_raw == "BRZ" or layer_raw == "REF":
                layer = "brz"
            elif layer_raw == "GLD":
                layer = "gld"
            else:
                layer = "other"
            nodes.append({"id": tgt_id, "layer": layer, "load_type": reg.get("load_type", ""), "status": "", "last_load_date": "", "rows_loaded": 0})

        edges.append({"source": src_id, "target": tgt_id})

    return {"nodes": nodes, "edges": edges}


@st.cache_data(ttl=600)
def build_sp_dag_data():
    """Build {nodes, edges} for SP/View ETL flow from registry + lineage.

    Flow: source_tables → [VIEW] → [SP] → target_table
    Uses sp_lineage edges + sp_registry metadata to build full ETL DAG.
    """
    registry = load_csv("registry.csv")
    lineage = load_csv("lineage.csv")

    nodes, edges = [], []
    seen = set()
    layer_map = {"BRZ": "brz", "REF": "ref", "SLV": "slv", "GLD": "gld"}

    # Build nodes from registry: each SP as a node, each target table as a node
    for r in registry:
        sp = r.get("sp_name", "")
        view = r.get("view_name", "")
        target = r.get("target_table", "")
        layer = r.get("layer", "")
        layer_code = layer_map.get(layer.upper(), "other")

        # SP node
        if sp and sp not in seen:
            seen.add(sp)
            # Short name for display
            short = sp.split(".")[-1] if "." in sp else sp
            nodes.append({"id": sp, "layer": layer_code, "load_type": r.get("load_type", ""),
                          "status": "", "last_load_date": "", "rows_loaded": 0})

        # Target table node
        tgt_full = f"{r.get('target_schema','')}.{target}" if r.get('target_schema') else target
        if tgt_full and tgt_full not in seen:
            seen.add(tgt_full)
            nodes.append({"id": tgt_full, "layer": layer_code, "load_type": "",
                          "status": "", "last_load_date": "", "rows_loaded": 0})

        # Edge: SP → target table
        if sp and tgt_full:
            edges.append({"source": sp, "target": tgt_full})

        # Edges from source_objects → SP
        src = r.get("source_objects", "")
        if src and src not in ("nan", "None", ""):
            try:
                src_list = json.loads(src)
                for s in src_list:
                    s = s.strip().strip('"')
                    if not s:
                        continue
                    if s not in seen:
                        seen.add(s)
                        if "Enterprise" in s or "Lakehouse" in s:
                            sl = "other"
                        else:
                            sl = "brz" if "brz" in s or "ref" in s else ("slv" if "slv" in s else "other")
                        nodes.append({"id": s, "layer": sl, "load_type": "",
                                      "status": "", "last_load_date": "", "rows_loaded": 0})
                    edges.append({"source": s, "target": sp})
            except:
                pass

    return {"nodes": nodes, "edges": edges}


# ── Shared ──
html_path = Path(__file__).parent / "templates" / "lineage.html"

# ── Tabs ──
tab1, tab2, tab3 = st.tabs(["📊 Table Lineage DAG", "⚙️ Stored Procedure Lineage", "👁️ View Definitions"])

# ════════════════════════════════════════════════════════════════════════════════
# TAB 1: Interactive DAG (React SVG)
# ════════════════════════════════════════════════════════════════════════════════
with tab1:
    dag_data = build_dag_data()
    html_content = html_path.read_text(encoding="utf-8")

    if dag_data and dag_data["nodes"]:
        html_content = html_content.replace(
            "window.__LINEAGE_API_DATA__ = null;",
            f"window.__LINEAGE_API_DATA__ = {json.dumps(dag_data)};",
        )

    components.html(html_content, height=700, scrolling=False)

# ════════════════════════════════════════════════════════════════════════════════
# TAB 2: Stored Procedure Lineage
# ════════════════════════════════════════════════════════════════════════════════
with tab2:
    st.header("⚙️ Stored Procedure & View Lineage")
    st.caption("Select an SP to see its ETL flow: source tables → view → SP → target table")

    registry = load_csv("registry.csv")
    lineage = load_csv("lineage.csv")

    if registry:
        sp_list = sorted([r["sp_name"] for r in registry])
        selected_sp = st.selectbox("Select a Stored Procedure", sp_list)

        if selected_sp:
            sp_row = next((r for r in registry if r["sp_name"] == selected_sp), {})

            col1, col2, col3, col4 = st.columns(4)
            col1.metric("Layer", sp_row.get("layer", ""))
            col2.metric("Load Type", sp_row.get("load_type", ""))
            col3.metric("Frequency", sp_row.get("frequency", ""))
            col4.metric("Target", f"{sp_row.get('target_schema', '')}.{sp_row.get('target_table', '')}")

            # Dependencies
            deps = sp_row.get("depends_on", "")
            if deps and deps != "nan" and deps != "" and deps != "None":
                st.markdown("**Depends on:**")
                try:
                    dep_list = json.loads(deps)
                    for d in dep_list:
                        st.markdown(f"- `{d}`")
                except:
                    st.code(deps)

            # Source objects
            src = sp_row.get("source_objects", "")
            if src and src != "nan" and src != "" and src != "None":
                st.markdown("**Source objects:**")
                try:
                    src_list = json.loads(src)
                    for s in src_list:
                        st.markdown(f"- `{s}`")
                except:
                    st.code(src)

            # Lineage edges for this SP — show as mini DAG
            sp_edges = [r for r in lineage if r.get("sp_name", "") == selected_sp]
            if sp_edges:
                st.markdown("**ETL Flow (source → SP → target):**")

                # Build mini DAG for this SP only
                mini_nodes, mini_edges, mini_seen = [], [], set()
                tgt = f"{sp_row.get('target_schema','')}.{sp_row.get('target_table','')}"
                layer_map = {"BRZ": "brz", "REF": "ref", "SLV": "slv", "GLD": "gld"}
                sp_layer = layer_map.get(sp_row.get("layer", "").upper(), "other")

                # Force horizontal layout: sources = "other" (layer 0), target = "gld" (layer 4)
                # This ensures DAG layout puts sources LEFT, target RIGHT
                for r in sp_edges:
                    src_s = r.get("source_schema", "").strip()
                    src_t = r.get("source_table", "").strip()
                    src_id = f"{src_s}.{src_t}" if src_s else src_t

                    if src_id not in mini_seen:
                        mini_seen.add(src_id)
                        mini_nodes.append({"id": src_id, "layer": "other", "load_type": "", "status": "", "last_load_date": "", "rows_loaded": 0})

                    if tgt not in mini_seen:
                        mini_seen.add(tgt)
                        mini_nodes.append({"id": tgt, "layer": "gld", "load_type": sp_row.get("load_type", ""), "status": "", "last_load_date": "", "rows_loaded": 0})

                    mini_edges.append({"source": src_id, "target": tgt})

                mini_data = {"nodes": mini_nodes, "edges": mini_edges}
                html_mini = html_path.read_text(encoding="utf-8")
                html_mini = html_mini.replace(
                    "window.__LINEAGE_API_DATA__ = null;",
                    f"window.__LINEAGE_API_DATA__ = {json.dumps(mini_data)};",
                )
                components.html(html_mini, height=350, scrolling=False)

                import pandas as pd
                df = pd.DataFrame(sp_edges)[["source_schema", "source_table", "target_schema", "target_table", "relationship_type"]]
                st.dataframe(df, use_container_width=True)

            # View definition
            views = load_csv("views.csv")
            view_name = sp_row.get("view_name", "")
            if view_name and view_name != "nan" and views:
                vparts = view_name.split(".")
                if len(vparts) == 2:
                    vschema, vname = vparts
                    match = [v for v in views if v.get("schema") == vschema and v.get("view_name") == vname]
                    if match:
                        with st.expander(f"📝 View: {view_name}", expanded=False):
                            st.code(match[0].get("definition", ""), language="sql")

        # Full table
        st.markdown("---")
        with st.expander("📋 All registered SPs", expanded=False):
            import pandas as pd
            display_cols = ["sp_name", "layer", "target_schema", "target_table", "load_type", "frequency", "depends_on"]
            df = pd.DataFrame(registry)
            available = [c for c in display_cols if c in df.columns]
            st.dataframe(df[available], use_container_width=True)
    else:
        st.warning("No SP registry data loaded.")

# ════════════════════════════════════════════════════════════════════════════════
# TAB 3: View Definitions
# ════════════════════════════════════════════════════════════════════════════════
with tab3:
    st.header("👁️ View Definitions")
    st.caption("SQL source code of all ETL views (bronze / silver / gold)")

    views = load_csv("views.csv")
    if views:
        schemas = sorted(set(v.get("schema", "") for v in views))
        selected_schema = st.selectbox("Filter by schema", ["All"] + schemas)

        filtered = views if selected_schema == "All" else [v for v in views if v.get("schema") == selected_schema]

        for v in filtered:
            full_name = f"{v.get('schema', '')}.{v.get('view_name', '')}"
            with st.expander(f"📝 {full_name}", expanded=False):
                st.code(v.get("definition", ""), language="sql")

        st.info(f"Total: {len(filtered)} views")
    else:
        st.warning("No view definitions loaded.")

# ── Footer ──
st.markdown("---")
st.caption("Supply Chain Warehouse v9 — Lineage Explorer | Auto-refresh: 10 min | Data: meta.sp_lineage + meta.sp_registry")
