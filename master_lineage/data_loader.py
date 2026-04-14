"""
Data loader for Fabric Warehouse lineage data.
Auto-refreshes every 10 minutes via Streamlit cache.
"""
import streamlit as st
import pandas as pd
import json
import os

# For Streamlit Cloud: use secrets or CSV fallback
# For local: use pyodbc + az token

DATA_DIR = os.path.dirname(os.path.abspath(__file__))

@st.cache_data(ttl=600)  # Refresh every 10 minutes
def load_lineage() -> pd.DataFrame:
    """Load lineage data from CSV (exported from Warehouse)."""
    path = os.path.join(DATA_DIR, "data", "lineage.csv")
    if os.path.exists(path):
        return pd.read_csv(path)
    return pd.DataFrame(columns=["lineage_id", "source_schema", "source_table",
                                  "target_schema", "target_table", "relationship_type", "sp_name"])

@st.cache_data(ttl=600)
def load_registry() -> pd.DataFrame:
    """Load SP registry from CSV."""
    path = os.path.join(DATA_DIR, "data", "registry.csv")
    if os.path.exists(path):
        return pd.read_csv(path)
    return pd.DataFrame()

@st.cache_data(ttl=600)
def load_views() -> pd.DataFrame:
    """Load view definitions from CSV."""
    path = os.path.join(DATA_DIR, "data", "views.csv")
    if os.path.exists(path):
        return pd.read_csv(path)
    return pd.DataFrame()

@st.cache_data(ttl=600)
def load_run_history() -> pd.DataFrame:
    """Load SP run history from CSV."""
    path = os.path.join(DATA_DIR, "data", "run_history.csv")
    if os.path.exists(path):
        return pd.read_csv(path)
    return pd.DataFrame()

def get_upstream(df_lineage: pd.DataFrame, schema: str, table: str) -> pd.DataFrame:
    """Trace all upstream sources recursively."""
    visited = set()
    result = []
    queue = [(schema, table, 0)]

    while queue:
        s, t, depth = queue.pop(0)
        key = f"{s}.{t}"
        if key in visited:
            continue
        visited.add(key)

        sources = df_lineage[(df_lineage["target_schema"] == s) & (df_lineage["target_table"] == t)]
        for _, row in sources.iterrows():
            result.append({
                "depth": depth + 1,
                "source_schema": row["source_schema"],
                "source_table": row["source_table"],
                "target_schema": s,
                "target_table": t,
                "relationship_type": row.get("relationship_type", "direct"),
                "sp_name": row.get("sp_name", "")
            })
            queue.append((row["source_schema"], row["source_table"], depth + 1))

    return pd.DataFrame(result)

def get_downstream(df_lineage: pd.DataFrame, schema: str, table: str) -> pd.DataFrame:
    """Trace all downstream targets recursively."""
    visited = set()
    result = []
    queue = [(schema, table, 0)]

    while queue:
        s, t, depth = queue.pop(0)
        key = f"{s}.{t}"
        if key in visited:
            continue
        visited.add(key)

        targets = df_lineage[(df_lineage["source_schema"] == s) & (df_lineage["source_table"] == t)]
        for _, row in targets.iterrows():
            result.append({
                "depth": depth + 1,
                "source_schema": s,
                "source_table": t,
                "target_schema": row["target_schema"],
                "target_table": row["target_table"],
                "relationship_type": row.get("relationship_type", "direct"),
                "sp_name": row.get("sp_name", "")
            })
            queue.append((row["target_schema"], row["target_table"], depth + 1))

    return pd.DataFrame(result)
