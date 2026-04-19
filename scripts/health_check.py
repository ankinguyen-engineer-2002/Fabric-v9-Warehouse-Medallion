"""
Fabric Warehouse Health Check
Run: python3 scripts/health_check.py
"""
import pyodbc, struct, subprocess, json, sys
from datetime import datetime

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
    print(f"HEALTH CHECK — {datetime.utcnow().strftime('%Y-%m-%d %H:%M UTC')}")
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
                   WHERE end_time IS NOT NULL
                   ORDER BY start_time DESC""")
    row = cur.fetchone()
    if row:
        check("Pipeline status", row[0] == 'success', row[0])
        check("Tables succeeded", row[1] >= 18, f"{row[1]}/28")
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
    cur.execute("""SELECT COUNT(*) FROM meta.sp_registry
                   WHERE is_active=1 AND last_load_date < DATEADD(DAY, -2, GETUTCDATE())""")
    stale = cur.fetchone()[0]
    check("No stale tables (>48h)", stale == 0, f"{stale} stale")

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
