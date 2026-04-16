"""
Supply Chain Warehouse v9 — Lineage Explorer
=============================================
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
        st.markdown("<p style='text-align:center; color:#64748b; margin-bottom:2rem;'>Supply Chain Warehouse v9</p>", unsafe_allow_html=True)
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

@st.cache_data(ttl=600)
def build_dag_data():
    rows = load_csv("lineage.csv")
    registry = {r.get("target_table", ""): r for r in load_csv("registry.csv")}
    nodes, edges, seen = [], [], set()

    # Compute silver waves from depends_on (correct: collect-then-assign per wave)
    slv_waves = {}
    slv_regs = [r for r in registry.values() if r.get("layer", "").upper() == "SLV"]
    # Wave 0: no silver dependencies
    for r in slv_regs:
        deps = r.get("depends_on", "") or ""
        if not deps or deps in ("nan", "None") or "silver" not in deps:
            slv_waves[r.get("target_table", "")] = 0
    # Wave 1..N: collect all candidates per wave THEN assign (not during iteration)
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
                        name = d.split(".")[-1].replace("usp_load_", "")
                        dep_tables.append(name)
                if dep_tables and all(dt in slv_waves for dt in dep_tables):
                    newly_assigned[tbl] = wave
            except: pass
        if not newly_assigned: break  # no more tables to assign → done
        slv_waves.update(newly_assigned)

    def get_tier(name):
        """Strict tier assignment by name prefix — never misplace a node."""
        n = name.lower()
        if "enterprise_lakehouse" in n or "supplychain_lakehouse" in n:
            return "other"
        if n.startswith("brz_"):
            return "brz"
        if n.startswith("ref_"):
            return "brz"  # ref_ in same column as brz
        if n.startswith("slv_"):
            return f"slv{slv_waves.get(name, 0)}"
        if n.startswith("gld_"):
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
    lineage = load_csv("lineage.csv")
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
            table_edges = [r for r in lineage if r.get("target_table", "") == table and r.get("target_schema", "") == schema]
            if table_edges:
                st.markdown("**ETL Flow:**")
                mini_nodes, mini_edges, mini_seen = [], [], set()
                for r in table_edges:
                    src_s = r.get("source_schema", "").strip()
                    src_t = r.get("source_table", "").strip()
                    src_id = f"{src_s}.{src_t}" if src_s else src_t
                    if src_id not in mini_seen:
                        mini_seen.add(src_id)
                        mini_nodes.append({"id": src_id, "layer": "other", "load_type": "", "status": "", "last_load_date": "", "rows_loaded": 0})
                    if selected not in mini_seen:
                        mini_seen.add(selected)
                        mini_nodes.append({"id": selected, "layer": "gld", "load_type": row.get("load_type", ""), "status": "", "last_load_date": "", "rows_loaded": 0})
                    mini_edges.append({"source": src_id, "target": selected})

                html_mini = html_path.read_text(encoding="utf-8")
                html_mini = html_mini.replace("window.__LINEAGE_API_DATA__ = null;", f"window.__LINEAGE_API_DATA__ = {json.dumps({'nodes': mini_nodes, 'edges': mini_edges})};")
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
st.caption("Supply Chain Warehouse v9 — Lineage Explorer | Data auto-refreshed via GitHub Actions")
