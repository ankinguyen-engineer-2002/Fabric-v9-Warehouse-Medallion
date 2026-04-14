"""
Supply Chain Warehouse — Master Lineage Explorer
Interactive data lineage visualization for v9 Warehouse-Native Medallion Architecture.
"""
import streamlit as st
import pandas as pd
import json
from streamlit_agraph import agraph, Node, Edge, Config
from data_loader import (
    load_lineage, load_registry, load_views, load_run_history,
    get_upstream, get_downstream
)

# ── Page config ──
st.set_page_config(
    page_title="SC Lineage Explorer",
    page_icon="🔗",
    layout="wide",
    initial_sidebar_state="expanded"
)

# ── Color scheme ──
COLORS = {
    "external": "#6C757D",
    "bronze": "#CD7F32",
    "silver": "#C0C0C0",
    "gold": "#FFD700",
    "meta": "#0078D4",
    "unknown": "#888888",
}

def get_color(schema):
    s = str(schema).lower().strip().replace('"', '')
    if "enterprise" in s or "supplychain_lakehouse" in s:
        return COLORS["external"]
    return COLORS.get(s, COLORS["unknown"])

def get_layer(schema):
    s = str(schema).lower().strip().replace('"', '')
    if "enterprise" in s or "supplychain_lakehouse" in s:
        return "External"
    return s.capitalize()

# ── Load data ──
df_lineage = load_lineage()
df_registry = load_registry()
df_views = load_views()
df_history = load_run_history()

# ── Sidebar ──
st.sidebar.title("🔗 Lineage Explorer")
st.sidebar.caption("SupplyChain Warehouse v9")
st.sidebar.markdown("---")
st.sidebar.metric("Lineage Edges", len(df_lineage))
st.sidebar.metric("Registered SPs", len(df_registry))
st.sidebar.metric("Views", len(df_views))
st.sidebar.markdown("---")
st.sidebar.caption("Auto-refresh: every 10 minutes")

# ── Tabs ──
tab1, tab2, tab3 = st.tabs([
    "📊 Table Lineage Overview",
    "⚙️ Stored Procedure Lineage",
    "👁️ View Definitions"
])

# ════════════════════════════════════════════════════════════════════════════════
# TAB 1: Table Lineage Overview
# ════════════════════════════════════════════════════════════════════════════════
with tab1:
    st.header("Table Lineage Overview")
    st.caption("Trace where each table's data comes from and where it flows to")

    col1, col2 = st.columns([1, 3])

    with col1:
        # Build table list
        all_tables = set()
        for _, r in df_lineage.iterrows():
            all_tables.add(f"{r['source_schema']}.{r['source_table']}")
            all_tables.add(f"{r['target_schema']}.{r['target_table']}")
        all_tables = sorted(all_tables)

        selected_table = st.selectbox("Select a table", all_tables, index=0)

        if selected_table:
            parts = selected_table.split(".", 1)
            sel_schema, sel_table = parts[0], parts[1] if len(parts) > 1 else parts[0]

            direction = st.radio("Direction", ["Upstream (sources)", "Downstream (targets)", "Both"])

    with col2:
        if selected_table and not df_lineage.empty:
            # Build graph
            nodes = []
            edges = []
            node_ids = set()

            def add_node(schema, table, is_selected=False):
                nid = f"{schema}.{table}"
                if nid not in node_ids:
                    node_ids.add(nid)
                    color = get_color(schema)
                    size = 30 if is_selected else 20
                    label = table if len(table) < 35 else table[:32] + "..."
                    nodes.append(Node(
                        id=nid, label=label, size=size, color=color,
                        font={"color": "#FFFFFF", "size": 11},
                        borderWidth=3 if is_selected else 1,
                        borderWidthSelected=4,
                        title=f"{schema}.{table}\nLayer: {get_layer(schema)}"
                    ))

            # Add selected node
            add_node(sel_schema, sel_table, is_selected=True)

            if direction in ["Upstream (sources)", "Both"]:
                upstream = get_upstream(df_lineage, sel_schema, sel_table)
                for _, r in upstream.iterrows():
                    add_node(r["source_schema"], r["source_table"])
                    add_node(r["target_schema"], r["target_table"])
                    edges.append(Edge(
                        source=f"{r['source_schema']}.{r['source_table']}",
                        target=f"{r['target_schema']}.{r['target_table']}",
                        color="#4CAF50", width=2,
                        title=r.get("sp_name", "")
                    ))

            if direction in ["Downstream (targets)", "Both"]:
                downstream = get_downstream(df_lineage, sel_schema, sel_table)
                for _, r in downstream.iterrows():
                    add_node(r["source_schema"], r["source_table"])
                    add_node(r["target_schema"], r["target_table"])
                    edges.append(Edge(
                        source=f"{r['source_schema']}.{r['source_table']}",
                        target=f"{r['target_schema']}.{r['target_table']}",
                        color="#FF9800", width=2,
                        title=r.get("sp_name", "")
                    ))

            config = Config(
                width=900, height=500,
                directed=True,
                hierarchical=True,
                nodeHighlightBehavior=True,
                highlightColor="#F7A7A6",
                collapsible=False,
                physics=False,
                node={"labelProperty": "label"},
                link={"labelProperty": "label", "renderLabel": False}
            )

            if nodes:
                agraph(nodes=nodes, edges=edges, config=config)
            else:
                st.info("No lineage edges found for this table.")

            # Detail table
            st.subheader("Lineage Detail")
            if direction in ["Upstream (sources)", "Both"] and not upstream.empty:
                st.markdown("**Upstream (data comes FROM):**")
                st.dataframe(upstream[["depth", "source_schema", "source_table", "target_schema", "target_table", "sp_name"]], use_container_width=True)
            if direction in ["Downstream (targets)", "Both"] and not downstream.empty:
                st.markdown("**Downstream (data flows TO):**")
                st.dataframe(downstream[["depth", "source_schema", "source_table", "target_schema", "target_table", "sp_name"]], use_container_width=True)

    # Full lineage graph
    st.markdown("---")
    with st.expander("🗺️ Full Lineage Map (all 52 edges)", expanded=False):
        all_nodes = []
        all_edges = []
        all_nids = set()

        for _, r in df_lineage.iterrows():
            for schema, table in [(r["source_schema"], r["source_table"]),
                                   (r["target_schema"], r["target_table"])]:
                nid = f"{schema}.{table}"
                if nid not in all_nids:
                    all_nids.add(nid)
                    all_nodes.append(Node(
                        id=nid, label=table[:30], size=15,
                        color=get_color(schema),
                        font={"color": "#FFFFFF", "size": 9},
                        title=f"{schema}.{table}"
                    ))
            all_edges.append(Edge(
                source=f"{r['source_schema']}.{r['source_table']}",
                target=f"{r['target_schema']}.{r['target_table']}",
                color="#555555", width=1
            ))

        full_config = Config(
            width=1200, height=700, directed=True, hierarchical=True,
            physics=False,
            node={"labelProperty": "label"},
        )
        agraph(nodes=all_nodes, edges=all_edges, config=full_config)

# ════════════════════════════════════════════════════════════════════════════════
# TAB 2: Stored Procedure Lineage
# ════════════════════════════════════════════════════════════════════════════════
with tab2:
    st.header("Stored Procedure Lineage")
    st.caption("Each SP: what it reads, what it writes, dependencies")

    if not df_registry.empty:
        # SP selector
        sp_list = sorted(df_registry["sp_name"].tolist())
        selected_sp = st.selectbox("Select a Stored Procedure", sp_list)

        if selected_sp:
            sp_row = df_registry[df_registry["sp_name"] == selected_sp].iloc[0]

            col1, col2, col3, col4 = st.columns(4)
            col1.metric("Layer", sp_row.get("layer", ""))
            col2.metric("Load Type", sp_row.get("load_type", ""))
            col3.metric("Frequency", sp_row.get("frequency", ""))
            col4.metric("Target", f"{sp_row.get('target_schema','')}.{sp_row.get('target_table','')}")

            # Dependencies
            deps = sp_row.get("depends_on", "")
            if deps and str(deps) != "nan" and str(deps) != "None":
                st.markdown("**Depends on:**")
                try:
                    dep_list = json.loads(str(deps))
                    for d in dep_list:
                        st.markdown(f"  - `{d}`")
                except:
                    st.code(str(deps))

            # Source objects
            src = sp_row.get("source_objects", "")
            if src and str(src) != "nan" and str(src) != "None":
                st.markdown("**Source objects:**")
                try:
                    src_list = json.loads(str(src))
                    for s in src_list:
                        st.markdown(f"  - `{s}`")
                except:
                    st.code(str(src))

            # Lineage edges for this SP
            sp_edges = df_lineage[df_lineage["sp_name"] == selected_sp]
            if not sp_edges.empty:
                st.markdown("**Lineage edges:**")

                sp_nodes = []
                sp_edge_list = []
                sp_nids = set()

                target_nid = f"{sp_row.get('target_schema','')}.{sp_row.get('target_table','')}"

                for _, r in sp_edges.iterrows():
                    for schema, table in [(r["source_schema"], r["source_table"]),
                                           (r["target_schema"], r["target_table"])]:
                        nid = f"{schema}.{table}"
                        if nid not in sp_nids:
                            sp_nids.add(nid)
                            is_target = (nid == target_nid)
                            sp_nodes.append(Node(
                                id=nid, label=table[:30],
                                size=25 if is_target else 18,
                                color=get_color(schema),
                                font={"color": "#FFFFFF", "size": 11},
                                borderWidth=3 if is_target else 1,
                                title=f"{schema}.{table}"
                            ))
                    sp_edge_list.append(Edge(
                        source=f"{r['source_schema']}.{r['source_table']}",
                        target=f"{r['target_schema']}.{r['target_table']}",
                        color="#4CAF50", width=2
                    ))

                sp_config = Config(
                    width=800, height=350, directed=True, hierarchical=True,
                    physics=False
                )
                agraph(nodes=sp_nodes, edges=sp_edge_list, config=sp_config)

                st.dataframe(sp_edges[["source_schema", "source_table", "target_schema", "target_table", "relationship_type"]], use_container_width=True)

            # View definition if available
            view_name = sp_row.get("view_name", "")
            if view_name and str(view_name) != "nan" and not df_views.empty:
                vparts = str(view_name).split(".")
                if len(vparts) == 2:
                    vschema, vname = vparts
                    view_match = df_views[(df_views["schema"] == vschema) & (df_views["view_name"] == vname)]
                    if not view_match.empty:
                        with st.expander(f"📝 View definition: {view_name}", expanded=False):
                            st.code(view_match.iloc[0]["definition"], language="sql")

        # Full SP table
        st.markdown("---")
        with st.expander("📋 All registered SPs", expanded=False):
            display_cols = ["sp_name", "layer", "target_schema", "target_table", "load_type", "frequency", "depends_on"]
            available = [c for c in display_cols if c in df_registry.columns]
            st.dataframe(df_registry[available], use_container_width=True)
    else:
        st.warning("No SP registry data loaded.")

# ════════════════════════════════════════════════════════════════════════════════
# TAB 3: View Definitions
# ════════════════════════════════════════════════════════════════════════════════
with tab3:
    st.header("View Definitions")
    st.caption("SQL source code of all ETL views (bronze/silver/gold)")

    if not df_views.empty:
        # Group by schema
        schemas = sorted(df_views["schema"].unique())
        selected_schema = st.selectbox("Filter by schema", ["All"] + list(schemas))

        filtered = df_views if selected_schema == "All" else df_views[df_views["schema"] == selected_schema]

        for _, row in filtered.iterrows():
            full_name = f"{row['schema']}.{row['view_name']}"
            with st.expander(f"📝 {full_name}", expanded=False):
                st.code(row["definition"], language="sql")

        st.info(f"Total: {len(filtered)} views")
    else:
        st.warning("No view definitions loaded.")

# ── Footer ──
st.markdown("---")
st.caption("Supply Chain Warehouse v9 — Lineage Explorer | Auto-refresh: 10 min | Data source: meta.sp_lineage + meta.sp_registry")
