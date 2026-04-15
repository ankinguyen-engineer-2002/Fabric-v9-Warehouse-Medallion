"""
Supply Chain Warehouse v9 — Lineage Explorer
=============================================
Reads lineage + registry data from CSV files (exported from Fabric Warehouse).
Renders the React DAG visualization in an iframe via st.components.
"""

import json
import csv
import os
import streamlit as st
import streamlit.components.v1 as components
from pathlib import Path

st.set_page_config(page_title="SC Lineage Explorer", layout="wide", initial_sidebar_state="collapsed")

# Hide Streamlit chrome for full-screen DAG experience
st.markdown("""<style>
    #MainMenu, header, footer, .stDeployButton, [data-testid="stToolbar"],
    [data-testid="stStatusWidget"] {display:none !important;}
    .stAppViewContainer, .stMainBlockContainer, [data-testid="stVerticalBlock"],
    .stElementContainer {padding:0 !important; margin:0 !important; max-width:100% !important;}
    .stMainBlockContainer {padding-top:0 !important; padding-bottom:0 !important;}
    .stApp {margin:0 !important;}
    .stMain {padding:0 !important;}
    iframe {border:none !important; width:100vw !important; height:100vh !important; position:fixed !important; top:0 !important; left:0 !important;}
</style>""", unsafe_allow_html=True)

DATA_DIR = Path(__file__).parent / "data"


@st.cache_data(ttl=600)
def load_lineage_data():
    """Load CSV data and convert to {nodes, edges} format for React DAG."""
    lineage_path = DATA_DIR / "lineage.csv"
    registry_path = DATA_DIR / "registry.csv"

    nodes = []
    edges = []
    seen = set()

    # Load registry for node metadata
    registry = {}
    if registry_path.exists():
        with open(registry_path, newline="", encoding="utf-8") as f:
            for row in csv.DictReader(f):
                registry[row.get("target_table", "")] = row

    # Load lineage edges
    if lineage_path.exists():
        with open(lineage_path, newline="", encoding="utf-8") as f:
            for row in csv.DictReader(f):
                src_schema = row.get("source_schema", "").strip()
                src_table = row.get("source_table", "").strip()
                tgt_schema = row.get("target_schema", "").strip()
                tgt_table = row.get("target_table", "").strip()

                # Build source ID
                if "Enterprise_Lakehouse" in src_schema or "SupplyChain_Lakehouse" in src_schema:
                    src_id = f"{src_schema}.{src_table}"
                    src_layer = "external"
                else:
                    src_id = src_table
                    src_layer = src_schema

                tgt_id = tgt_table

                # Add source node
                if src_id not in seen:
                    seen.add(src_id)
                    nodes.append({
                        "id": src_id,
                        "layer": src_layer,
                        "load_type": "",
                        "status": "",
                        "last_load_date": "",
                        "rows_loaded": 0,
                    })

                # Add target node with metadata from registry
                if tgt_id not in seen:
                    seen.add(tgt_id)
                    reg = registry.get(tgt_table, {})
                    layer = reg.get("layer", tgt_schema) or tgt_schema
                    # Map layer names for visualization
                    layer_map = {"BRZ": "brz", "REF": "ref", "SLV": "slv", "GLD": "gld"}
                    layer = layer_map.get(layer.upper(), layer.lower()) if layer else tgt_schema

                    nodes.append({
                        "id": tgt_id,
                        "layer": layer,
                        "load_type": reg.get("load_type", ""),
                        "status": "",
                        "last_load_date": "",
                        "rows_loaded": 0,
                    })

                edges.append({"source": src_id, "target": tgt_id})

    return {"nodes": nodes, "edges": edges}


# Load data
lineage_data = load_lineage_data()

# Load HTML template
html_path = Path(__file__).parent / "templates" / "lineage.html"
html_content = html_path.read_text(encoding="utf-8")

# Inject data into HTML
if lineage_data and lineage_data["nodes"]:
    html_content = html_content.replace(
        "window.__LINEAGE_API_DATA__ = null;",
        f"window.__LINEAGE_API_DATA__ = {json.dumps(lineage_data)};",
    )

# Render full-screen
components.html(html_content, height=0, scrolling=False)
