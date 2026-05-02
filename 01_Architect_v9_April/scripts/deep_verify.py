"""
Deep verification for v9 vs v8 baseline and semantic model sync.
Read-only.
"""
import json
import os
import struct
import subprocess
import sys
import urllib.request
from collections import OrderedDict

import pyodbc


WAREHOUSE_SERVER = "7woj2wroypauvkpn72b56t46ju-qp6ntsfwdaou5atebne65u3p4a.datawarehouse.fabric.microsoft.com"
WAREHOUSE_DB = "SupplyChain_Warehouse"
WORKSPACE_ID = "c8d9fc83-18b6-4e1d-8264-0b49eed36fe0"
SEMANTIC_MODEL_ID = "a52841ee-d853-46df-b2f7-2a2cc4493d60"

EXPECTED = OrderedDict([
    ("bronze", OrderedDict([
        ("brz_saleshistory_afi__invoicedetail", 35798317),
        ("brz_saleshistory_afi__invoiceheader", 4044847),
        ("brz_supplychain_enh_1__demandforecastsnapshotdaily", 1306460284),
        ("brz_wholesale_codis_afi__codatan", 918213),
        ("brz_wholesale_codis_afi__comast", 229461),
        ("brz_wholesale_codis_afi__extord", 229736),
        ("brz_wholesale_codis_afi__extorit", 912132),
        ("ref_calendar", 21551),
        ("ref_customer_account", 35581),
        ("ref_customer_account_group", 35454),
        ("ref_customer_grouping", 9),
        ("ref_customer_shipping_location", 127515),
        ("ref_forecast_cycle", 43),
        ("ref_forecast_horizon", 8),
        ("ref_item_master", 379331),
        ("ref_order_type", 29),
        ("ref_product", 373326),
        ("ref_warehouse", 55),
    ])),
    ("silver", OrderedDict([
        ("slv_invoice_detail_line_level", 35798317),
        ("slv_forecast_demand_monthly", 13876949),
        ("slv_open_order_line_level", 258197),
        ("slv_actual_demand_monthly", 571822),
        ("slv_actual_demand_weekly", 1102162),
        ("slv_invoice_weekly", 15571003),
        ("slv_open_order_monthly", 119575),
        ("slv_naive_forecast_monthly", 346792),
    ])),
    ("gold", OrderedDict([
        ("gld_fact_flat_forecast_actual", 14795563),
        ("gld_fact_forecast_kpi", 41055048),
    ])),
])

SM_ROWCOUNT_SOURCES = OrderedDict([
    ("dim_calendar", ("bronze", "ref_calendar")),
    ("dim_customer", ("bronze", "ref_customer_account")),
    ("dim_customer_group", ("bronze", "ref_customer_grouping")),
    ("dim_product", ("bronze", "ref_product")),
    ("dim_warehouse", ("bronze", "ref_warehouse")),
    ("fact_flat_forecast_actual", ("gold", "gld_fact_flat_forecast_actual")),
    ("fact_forecast_kpi", ("gold", "gld_fact_forecast_kpi")),
])


def get_token(resource: str) -> str:
    r = subprocess.run(
        ["az", "account", "get-access-token", "--resource", resource, "--output", "json"],
        capture_output=True,
        text=True,
    )
    if r.returncode != 0:
        raise RuntimeError(r.stderr.strip() or r.stdout.strip())
    return json.loads(r.stdout)["accessToken"]


def warehouse_counts():
    token = get_token("https://database.windows.net/")
    token_bytes = token.encode("UTF-16-LE")
    token_struct = struct.pack(f"<I{len(token_bytes)}s", len(token_bytes), token_bytes)
    conn = pyodbc.connect(
        f"DRIVER={{ODBC Driver 18 for SQL Server}};SERVER={WAREHOUSE_SERVER};DATABASE={WAREHOUSE_DB};Encrypt=yes;TrustServerCertificate=no;",
        attrs_before={1256: token_struct},
        timeout=30,
    )
    cur = conn.cursor()
    cur.execute(
        """
        SELECT s.name AS schema_name, t.name AS table_name, SUM(p.rows) AS row_count
        FROM sys.tables t
        JOIN sys.schemas s ON t.schema_id = s.schema_id
        JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0,1)
        WHERE s.name IN ('bronze','silver','gold')
        GROUP BY s.name, t.name
        ORDER BY CASE s.name WHEN 'bronze' THEN 1 WHEN 'silver' THEN 2 ELSE 3 END, t.name
        """
    )
    counts = {(r.schema_name, r.table_name): int(r.row_count or 0) for r in cur.fetchall()}
    cur.execute(
        """
        SELECT
          (SELECT COUNT(*) FROM meta.sp_registry WHERE is_active = 1) AS active_tables,
          (SELECT COUNT(*) FROM meta.sp_run_history) AS sp_run_history_rows,
          (SELECT COUNT(*) FROM meta.sp_run_history WHERE pipeline_run_id IS NULL) AS sp_run_history_null_pipeline_run_id,
          (SELECT COUNT(*) FROM meta.sp_lineage) AS lineage_edges,
          (SELECT COUNT(*) FROM meta.pipeline_run_log WHERE pipeline_name = 'pl_sc_master') AS master_run_log_rows,
          (SELECT TOP 1 status FROM meta.pipeline_run_log WHERE pipeline_name = 'pl_sc_master' AND end_time IS NOT NULL ORDER BY start_time DESC) AS master_status,
          (SELECT TOP 1 tables_succeeded FROM meta.pipeline_run_log WHERE pipeline_name = 'pl_sc_master' AND end_time IS NOT NULL ORDER BY start_time DESC) AS master_tables_succeeded,
          (SELECT TOP 1 tables_failed FROM meta.pipeline_run_log WHERE pipeline_name = 'pl_sc_master' AND end_time IS NOT NULL ORDER BY start_time DESC) AS master_tables_failed
        """
    )
    meta = cur.fetchone()
    conn.close()
    return counts, meta


def execute_dax(query: str):
    token = get_token("https://analysis.windows.net/powerbi/api")
    body = json.dumps(
        {"queries": [{"query": query}], "serializerSettings": {"includeNulls": True}}
    ).encode("utf-8")
    req = urllib.request.Request(
        f"https://api.powerbi.com/v1.0/myorg/groups/{WORKSPACE_ID}/datasets/{SEMANTIC_MODEL_ID}/executeQueries",
        data=body,
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.loads(resp.read().decode("utf-8"))


def main():
    counts, meta = warehouse_counts()
    print("WAREHOUSE_BASELINE")
    for tier, tables in EXPECTED.items():
        ok = 0
        print(f"[{tier}]")
        for table, exp in tables.items():
            live = counts[(tier, table)]
            if live == exp:
                ok += 1
            print(f"{table}\t{exp}\t{live}\t{live - exp}\t{'OK' if live == exp else 'DIFF'}")
        print(f"{tier}_match\t{ok}/{len(tables)}")

    print("META")
    print(f"active_tables\t{meta.active_tables}")
    print(f"sp_run_history_rows\t{meta.sp_run_history_rows}")
    print(f"sp_run_history_null_pipeline_run_id\t{meta.sp_run_history_null_pipeline_run_id}")
    print(f"lineage_edges\t{meta.lineage_edges}")
    print(f"master_run_log_rows\t{meta.master_run_log_rows}")
    print(f"master_status\t{meta.master_status}")
    print(f"master_tables_succeeded\t{meta.master_tables_succeeded}")
    print(f"master_tables_failed\t{meta.master_tables_failed}")

    print("SEMANTIC_MODEL_METADATA")
    for key, query in {
        "tables": "EVALUATE INFO.VIEW.TABLES()",
        "relationships": "EVALUATE INFO.VIEW.RELATIONSHIPS()",
        "measures": "EVALUATE INFO.VIEW.MEASURES()",
    }.items():
        rows = execute_dax(query)["results"][0]["tables"][0]["rows"]
        print(f"{key}\t{len(rows)}")
        if key == "tables":
            names = sorted(r.get("Name") for r in rows)
            print("table_names\t" + "|".join(names))

    print("SEMANTIC_MODEL_COUNTS")
    sm_counts = {}
    for name in SM_ROWCOUNT_SOURCES:
        sm_query = f"EVALUATE ROW(\"rows\", COUNTROWS('{name}'))"
        sm_counts[name] = execute_dax(sm_query)["results"][0]["tables"][0]["rows"][0]["rows"]
        print(f"{name}\t{sm_counts[name]}")

    print("SEMANTIC_MODEL_COMPARE")
    for sm_table, (tier, source_table) in SM_ROWCOUNT_SOURCES.items():
        live = counts[(tier, source_table)]
        sm = sm_counts[sm_table]
        print(f"{sm_table}\twarehouse={live}\tsemantic={sm}\tmatch={live == sm}")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        sys.exit(1)
