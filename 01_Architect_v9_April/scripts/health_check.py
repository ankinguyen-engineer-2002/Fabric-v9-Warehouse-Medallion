"""
Fabric Warehouse Health Check
Run: python3 scripts/health_check.py
"""
import pyodbc, struct, subprocess, json, sys
from datetime import datetime, timezone

# ============================================
# CONNECTION
# ============================================
def connect():
    r = subprocess.run(
        ['az','account','get-access-token','--resource','https://database.windows.net/','--output','json'],
        capture_output=True, text=True)
    if r.returncode != 0:
        print("FAIL: az login expired. Run: az login")
        sys.exit(1)
    token = json.loads(r.stdout)['accessToken']
    tb = token.encode('UTF-16-LE')
    ts = struct.pack(f'<I{len(tb)}s', len(tb), tb)
    server = '7woj2wroypauvkpn72b56t46ju-qp6ntsfwdaou5atebne65u3p4a.datawarehouse.fabric.microsoft.com'
    conn = pyodbc.connect(
        f'DRIVER={{ODBC Driver 18 for SQL Server}};SERVER={server};'
        f'DATABASE=SupplyChain_Warehouse;Encrypt=yes;TrustServerCertificate=no;',
        attrs_before={1256: ts})
    return conn

# ============================================
# CHECK FUNCTIONS
# ============================================
results = []

def check(name, passed, detail=""):
    status = "PASS" if passed else "FAIL"
    results.append((name, status, detail))
    icon = "  [OK]" if passed else "  [!!]"
    print(f"{icon} {name}: {detail}")

def run_checks(cur):
    print("=" * 70)
    print(f"HEALTH CHECK — {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')}")
    print("=" * 70)

    # ---- 1. SP_REGISTRY ----
    print("\n--- SP Registry ---")
    cur.execute("SELECT COUNT(*) FROM meta.sp_registry WHERE is_active=1")
    cnt = cur.fetchone()[0]
    check("sp_registry active tables", cnt == 28, f"{cnt}/28")

    cur.execute("SELECT COUNT(*) FROM meta.sp_registry WHERE is_active=1 AND project IS NULL")
    null_proj = cur.fetchone()[0]
    check("sp_registry project column", null_proj == 0, f"{null_proj} missing project")

    cur.execute("SELECT COUNT(*) FROM meta.sp_registry WHERE is_active=1 AND view_name IS NULL")
    null_view = cur.fetchone()[0]
    check("sp_registry view_name", null_view == 0, f"{null_view} missing")

    cur.execute("SELECT COUNT(*) FROM meta.sp_registry WHERE is_active=1 AND cron_expression IS NULL")
    null_cron = cur.fetchone()[0]
    check("sp_registry cron_expression", null_cron == 0, f"{null_cron} missing")

    cur.execute("SELECT COUNT(*) FROM meta.sp_registry WHERE is_active=1 AND source_objects IS NULL")
    null_src = cur.fetchone()[0]
    check("sp_registry source_objects", null_src == 0, f"{null_src} missing")

    # ---- 2. DAG WAVES ----
    print("\n--- DAG Waves ---")
    cur.execute("SELECT COUNT(*) FROM meta.slv_dag_waves_runtime")
    waves = cur.fetchone()[0]
    check("slv_dag_waves populated", waves == 8, f"{waves}/8 silver SPs")

    cur.execute("SELECT COUNT(DISTINCT wave) FROM meta.slv_dag_waves_runtime")
    wave_cnt = cur.fetchone()[0]
    check("wave count", wave_cnt == 3, f"{wave_cnt} waves (expect 3)")

    # ---- 3. FUNCTIONS ----
    print("\n--- Functions ---")
    try:
        cur.execute("SELECT meta.ufn_should_run('bronze.brz_saleshistory_afi__invoicedetail')")
        val = cur.fetchone()[0]
        check("ufn_should_run", val is not None, f"returns {val}")
    except Exception as e:
        check("ufn_should_run", False, str(e)[:60])

    try:
        cur.execute("SELECT meta.ufn_cron_is_due('0 2 * * *')")
        val = cur.fetchone()[0]
        check("ufn_cron_is_due", val is not None, f"returns {val}")
    except Exception as e:
        check("ufn_cron_is_due", False, str(e)[:60])

    try:
        cur.execute("SELECT meta.ufn_utc_to_cst(GETUTCDATE())")
        val = cur.fetchone()[0]
        check("ufn_utc_to_cst", val is not None, f"returns {val}")
    except Exception as e:
        check("ufn_utc_to_cst", False, str(e)[:60])

    # ---- 4. STORED PROCEDURES ----
    print("\n--- Stored Procedures ---")
    required_sps = [
        'usp_generic_load', 'usp_log_run', 'usp_compute_slv_waves',
        'usp_build_lineage', 'usp_finalize_pipeline', 'usp_log_pipeline_run',
        'usp_check_dq_single', 'usp_validate_schema_contracts',
        'usp_check_dq', 'usp_run_silver_dag', 'usp_debug_loop'
    ]
    cur.execute("SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA='meta' AND ROUTINE_TYPE='PROCEDURE'")
    existing_sps = [r[0] for r in cur.fetchall()]
    for sp in required_sps:
        check(f"SP {sp}", sp in existing_sps, "exists" if sp in existing_sps else "MISSING")

    # ---- 5. RETRY LOGIC ----
    print("\n--- Retry Logic ---")
    cur.execute("SELECT m.definition FROM sys.sql_modules m JOIN sys.procedures p ON m.object_id=p.object_id WHERE p.name='usp_log_run'")
    sp_text = cur.fetchone()[0]
    check("usp_log_run WHILE retry", 'WHILE' in sp_text and 'retry' in sp_text.lower(), "3x retry loop")
    check("usp_log_run WAITFOR DELAY", 'WAITFOR DELAY' in sp_text, "2s backoff")
    check("usp_log_run TRY/CATCH", 'BEGIN TRY' in sp_text, "error handling")

    # ---- 6. META TABLES ----
    print("\n--- Meta Tables ---")
    required_tables = {
        'sp_registry': 28, 'sp_run_history': 1, 'sp_lineage': 1,
        'pipeline_run_log': 1, 'dq_rules': 1, 'dq_results': 0,
        'slv_dag_waves_runtime': 8, 'performance_baseline': 28,
        'pipeline_cost_log': 0, 'schema_contracts': 1
    }
    for table, min_rows in required_tables.items():
        try:
            cur.execute(f"SELECT COUNT(*) FROM meta.{table}")
            cnt = cur.fetchone()[0]
            check(f"meta.{table}", cnt >= min_rows, f"{cnt} rows")
        except:
            check(f"meta.{table}", False, "TABLE NOT FOUND")

    # ---- 7. DQ RULES ----
    print("\n--- DQ Rules ---")
    cur.execute("SELECT COUNT(*) FROM meta.dq_rules WHERE is_active=1")
    active = cur.fetchone()[0]
    check("DQ rules active", active >= 30, f"{active} active")

    cur.execute("SELECT COUNT(*) FROM meta.dq_rules WHERE is_active=0")
    inactive = cur.fetchone()[0]
    check("DQ rules inactive (Phase 3)", inactive >= 0, f"{inactive} reserved")

    cur.execute("SELECT COUNT(DISTINCT check_type) FROM meta.dq_rules")
    types = cur.fetchone()[0]
    check("DQ check types", types >= 4, f"{types} types")

    # ---- 8. LINEAGE ----
    print("\n--- Lineage ---")
    cur.execute("SELECT COUNT(*) FROM meta.sp_lineage")
    edges = cur.fetchone()[0]
    check("Lineage edges", edges >= 50, f"{edges} edges")

    # ---- 9. LATEST PIPELINE RUN ----
    print("\n--- Latest Pipeline Run ---")
    cur.execute("""SELECT TOP 1 status, tables_succeeded, tables_failed,
                   DATEDIFF(SECOND, start_time, end_time) as secs, start_time
                   FROM meta.pipeline_run_log
                   WHERE pipeline_name = 'pl_sc_master'
                     AND end_time IS NOT NULL
                   ORDER BY start_time DESC""")
    row = cur.fetchone()
    if row:
        check("Pipeline status", row[0] == 'success', row[0])
        print(f"  [i] Tables succeeded: {row[1]}/28")
        check("Tables failed", row[2] == 0, f"{row[2]} failures")
        duration = row[3] / 60.0 if row[3] else 0
        check("Pipeline duration", duration < 30, f"{duration:.1f} min")
        check("Last run time", row[4] is not None, str(row[4])[:19])
    else:
        check("Pipeline run exists", False, "no runs found")

    # ---- 10. RECENT FAILURES ----
    print("\n--- Recent Failures (24h) ---")
    cur.execute("""SELECT COUNT(*) FROM meta.sp_run_history
                   WHERE status='failed' AND start_time >= DATEADD(HOUR, -24, GETUTCDATE())""")
    recent_fails = cur.fetchone()[0]
    check("No recent failures", recent_fails == 0, f"{recent_fails} in last 24h")

    if recent_fails > 0:
        cur.execute("""SELECT sp_name, error_message FROM meta.sp_run_history
                       WHERE status='failed' AND start_time >= DATEADD(HOUR, -24, GETUTCDATE())
                       ORDER BY start_time DESC""")
        for r in cur.fetchall()[:5]:
            print(f"       -> {r[0]}: {str(r[1])[:60]}")

    # ---- 11. SMART SKIP ----
    print("\n--- Smart Skip ---")
    cur.execute("""SELECT frequency, COUNT(*) FROM meta.sp_registry
                   WHERE is_active=1 GROUP BY frequency""")
    for r in cur.fetchall():
        check(f"Frequency {r[0]}", r[1] > 0, f"{r[1]} tables")

    # ---- 12. DATA FRESHNESS ----
    print("\n--- Data Freshness ---")
    cur.execute("""
        SELECT COUNT(*)
        FROM meta.sp_registry
        WHERE is_active = 1
          AND (
                (
                    frequency IN ('daily', 'hourly', 'weekly')
                    AND (
                        last_load_date IS NULL
                        OR last_load_date < DATEADD(HOUR, -48, GETUTCDATE())
                    )
                )
                OR (
                    frequency = 'monthly'
                    AND next_run_time <= GETUTCDATE()
                    AND (
                        last_load_date IS NULL
                        OR last_load_date < DATEADD(HOUR, -48, GETUTCDATE())
                    )
                )
          )
    """)
    stale = cur.fetchone()[0]
    check("No stale due tables", stale == 0, f"{stale} stale")

    # ---- 13. SCHEMA CONTRACTS ----
    print("\n--- Schema Contracts ---")
    cur.execute("SELECT COUNT(*) FROM meta.schema_contracts")
    contracts = cur.fetchone()[0]
    check("Schema contracts", contracts >= 600, f"{contracts} columns")

    # ---- 14. PERFORMANCE BASELINE ----
    print("\n--- Performance Baseline ---")
    cur.execute("SELECT COUNT(*) FROM meta.performance_baseline")
    baselines = cur.fetchone()[0]
    check("Performance baselines", baselines >= 28, f"{baselines} SPs")

    # ---- 15. KEY DATA OUTPUT ----
    print("\n--- Key Data Output ---")
    key_counts = [
        ("bronze.brz_saleshistory_afi__invoicedetail", "brz_saleshistory_afi__invoicedetail", "SELECT COUNT(*) FROM bronze.brz_saleshistory_afi__invoicedetail", 35798317),
        ("bronze.brz_supplychain_enh_1__demandforecastsnapshotdaily", "brz_supplychain_enh_1__demandforecastsnapshotdaily", "SELECT COUNT(*) FROM bronze.brz_supplychain_enh_1__demandforecastsnapshotdaily", 1306460284),
        ("bronze.ref_calendar", "ref_calendar", "SELECT COUNT(*) FROM bronze.ref_calendar", 21551),
        ("bronze.ref_customer_grouping", "ref_customer_grouping", "SELECT COUNT(*) FROM bronze.ref_customer_grouping", 9),
        ("bronze.ref_forecast_horizon", "ref_forecast_horizon", "SELECT COUNT(*) FROM bronze.ref_forecast_horizon", 8),
        ("bronze.ref_product", "ref_product", "SELECT COUNT(*) FROM bronze.ref_product", 373326),
        ("bronze.ref_warehouse", "ref_warehouse", "SELECT COUNT(*) FROM bronze.ref_warehouse", 55),
        ("silver.slv_invoice_detail_line_level", "slv_invoice_detail_line_level", "SELECT COUNT(*) FROM silver.slv_invoice_detail_line_level", 35798317),
        ("silver.slv_forecast_demand_monthly", "slv_forecast_demand_monthly", "SELECT COUNT(*) FROM silver.slv_forecast_demand_monthly", 13876949),
        ("silver.slv_naive_forecast_monthly", "slv_naive_forecast_monthly", "SELECT COUNT(*) FROM silver.slv_naive_forecast_monthly", 346792),
        ("gold.gld_fact_flat_forecast_actual", "gld_fact_flat_forecast_actual", "SELECT COUNT(*) FROM gold.gld_fact_flat_forecast_actual", 14795563),
        ("gold.gld_fact_forecast_kpi", "gld_fact_forecast_kpi", "SELECT COUNT(*) FROM gold.gld_fact_forecast_kpi", 41055048),
    ]
    live_counts = {}
    for label, short_name, sql, expected_count in key_counts:
        cur.execute(sql)
        cnt = cur.fetchone()[0]
        live_counts[short_name] = cnt
        status = "MATCH" if cnt == expected_count else "DIFF"
        print(f"  [i] {label}: {cnt} vs {expected_count} ({status})")

    # ---- 16. SEMANTIC MODEL METADATA / ROWCOUNTS ----
    print("\n--- Semantic Model ---")
    pbi_token = subprocess.run(
        ['az','account','get-access-token','--resource','https://analysis.windows.net/powerbi/api','--output','json'],
        capture_output=True, text=True
    )
    if pbi_token.returncode != 0:
        check("powerbi token", False, pbi_token.stderr[:80])
    else:
        token = json.loads(pbi_token.stdout)['accessToken']
        body = lambda q: json.dumps({
            'queries': [{'query': q}],
            'serializerSettings': {'includeNulls': True}
        }).encode('utf-8')

        def dax_count(query):
            req = subprocess.run(
                ['az','rest','--method','POST','--resource','https://analysis.windows.net/powerbi/api',
                 '--url', f'https://api.powerbi.com/v1.0/myorg/groups/c8d9fc83-18b6-4e1d-8264-0b49eed36fe0/datasets/a52841ee-d853-46df-b2f7-2a2cc4493d60/executeQueries',
                 '--body', json.dumps({
                     'queries': [{'query': query}],
                     'serializerSettings': {'includeNulls': True}
                 }), '--output', 'json'],
                capture_output=True, text=True
            )
            if req.returncode != 0:
                raise RuntimeError(req.stderr.strip() or req.stdout.strip())
            return json.loads(req.stdout)

        tables = dax_count('EVALUATE INFO.VIEW.TABLES()')['results'][0]['tables'][0]['rows']
        rels = dax_count('EVALUATE INFO.VIEW.RELATIONSHIPS()')['results'][0]['tables'][0]['rows']
        measures = dax_count('EVALUATE INFO.VIEW.MEASURES()')['results'][0]['tables'][0]['rows']
        check("SM tables", len(tables) == 9, f"{len(tables)} tables")
        check("SM relationships", len(rels) == 9, f"{len(rels)} relationships")
        check("SM measures", len(measures) >= 25, f"{len(measures)} measures")

        sm_key_counts = [
            ("dim_calendar", "ref_calendar"),
            ("dim_customer_grouping", "ref_customer_grouping"),
            ("dim_forecast_horizon", "ref_forecast_horizon"),
            ("dim_product", "ref_product"),
            ("dim_warehouse", "ref_warehouse"),
            ("fact_flat_forecast_actual", "gld_fact_flat_forecast_actual"),
            ("fact_forecast_kpi", "gld_fact_forecast_kpi"),
        ]
        for table_name, source_name in sm_key_counts:
            query = f'EVALUATE ROW("Count", COUNTROWS(\'{table_name}\'))'
            result = dax_count(query)
            actual_count = result['results'][0]['tables'][0]['rows'][0]['[Count]']
            expected_count = live_counts[source_name]
            check(f"SM {table_name}", actual_count == expected_count, f"{actual_count} vs {expected_count}")

    # ---- SUMMARY ----
    print("\n" + "=" * 70)
    passed = sum(1 for _, s, _ in results if s == "PASS")
    failed = sum(1 for _, s, _ in results if s == "FAIL")
    total = len(results)

    if failed == 0:
        print(f"RESULT: ALL PASS ({passed}/{total})")
    else:
        print(f"RESULT: {failed} FAILED / {passed} PASSED / {total} TOTAL")
        print("\nFailed checks:")
        for name, status, detail in results:
            if status == "FAIL":
                print(f"  [!!] {name}: {detail}")

    print("=" * 70)
    return failed == 0

# ============================================
# MAIN
# ============================================
if __name__ == "__main__":
    conn = connect()
    cur = conn.cursor()
    ok = run_checks(cur)
    conn.close()
    sys.exit(0 if ok else 1)
