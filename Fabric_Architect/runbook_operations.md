# Runbook — Pipeline Operations & Troubleshooting
> For anyone operating the SupplyChain_Warehouse pipeline
> Last updated: 2026-04-18

---

## 1. Pipeline Overview

```
pl_sc_master (daily 2:00 AM UTC+7, concurrency=1)
├── log_start
├── pl_bronze_forecast (batch=6) — 18 tables parallel
├── pl_dq_check (bronze) — DQ gate
├── pl_silver_wave_forecast (DAG waves, batch=8) — 8 tables
├── pl_dq_check (silver) — DQ gate
├── pl_gold_forecast (batch=2) — 2 tables
├── pl_dq_check (gold) — DQ gate
├── finalize (build lineage + log)
└── refresh_sm (Direct Lake semantic model)
```

**Normal runtime**: ~19 minutes (full run, 28 tables)

---

## 2. Daily Health Check (2 minutes)

### Quick check — run on Fabric Portal SQL editor:

```sql
-- 1. Last pipeline run status
SELECT TOP 1 pipeline_run_id, status, start_time, end_time
FROM meta.pipeline_run_log
ORDER BY start_time DESC;

-- 2. Any failed tables in last 24h?
SELECT sp_name, status, error_message, start_time
FROM meta.sp_run_history
WHERE status = 'failed' AND start_time > DATEADD(HOUR, -24, GETUTCDATE())
ORDER BY start_time DESC;

-- 3. DQ results — any failures?
SELECT r.rule_name, r.target_table, r.check_type, r.severity, 
       d.status, d.actual_value, d.expected_value
FROM meta.dq_results d
JOIN meta.dq_rules r ON d.rule_id = r.rule_id
WHERE d.status = 'FAIL'
  AND d.check_time > DATEADD(HOUR, -24, GETUTCDATE());

-- 4. All tables loaded today?
SELECT COUNT(*) as loaded_today
FROM meta.sp_run_history
WHERE status = 'success' AND start_time > CAST(GETUTCDATE() AS DATE);
-- Expected: 18 (daily) or 28 (if monthly tables due)
```

### What "healthy" looks like:
- Pipeline status = `success`
- 0 failed tables
- 0 DQ failures
- 18+ tables loaded today

---

## 3. Common Errors & How to Fix

### 3.1 Snapshot isolation conflict

```
Error: "Snapshot isolation transaction aborted due to update conflict"
```

**Cause**: Multiple tables writing to sp_run_history simultaneously (parallel ForEach).

**Fix**: Usually **auto-resolved** by 3-layer retry:
1. usp_log_run retries 3x with 2s delay
2. Pipeline activity retries 3x with 60s interval

**If still failing**:
- Check if another pipeline run is active (concurrency should be 1)
- Re-run the pipeline manually — next attempt usually succeeds

**Action**: No action needed unless it happens 3+ consecutive runs.

---

### 3.2 Deadlock

```
Error: "Transaction was deadlocked on lock resources with another process"
```

**Cause**: Two SPs trying to read/write the same table simultaneously.

**Fix**: Same as snapshot conflict — retry handles it. If persistent:
1. Check which tables are involved (look at sp_name in error)
2. If silver tables: verify DAG waves are correct (tables in same wave should NOT depend on each other)

```sql
-- Check wave assignments
SELECT sp_name, wave FROM meta.slv_dag_waves_runtime ORDER BY wave, sp_name;
```

---

### 3.3 View reference error

```
Error: "Invalid object name 'Enterprise_Lakehouse.Schema.Table'"
```

**Cause**: Source table renamed, removed, or Lakehouse shortcut broken.

**Fix**:
1. Check if source exists:
```sql
SELECT * FROM Enterprise_Lakehouse.INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'TheTableName';
```
2. If missing: check Lakehouse shortcuts in Fabric Portal
3. If renamed: update the view definition

---

### 3.4 DQ CRITICAL failure — pipeline stopped

```
Error: "DQ CRITICAL FAIL: rule_name ... actual: X expected: Y"
```

**Cause**: A CRITICAL DQ rule failed (e.g., key column >1% NULL). Pipeline intentionally stopped.

**Fix**:
1. Check which rule failed:
```sql
SELECT r.rule_name, r.target_table, r.check_type, r.column_name,
       d.actual_value, d.expected_value, d.error_detail
FROM meta.dq_results d
JOIN meta.dq_rules r ON d.rule_id = r.rule_id
WHERE d.status = 'FAIL'
ORDER BY d.check_time DESC;
```
2. Investigate the data:
```sql
-- If completeness fail (NULL check):
SELECT COUNT(*) as total, 
       SUM(CASE WHEN column_name IS NULL THEN 1 ELSE 0 END) as nulls
FROM schema.table_name;
```
3. Fix the source data or adjust the threshold if it's a known data quality issue
4. Re-run the pipeline

**DO NOT** disable the DQ rule to work around it — fix the data.

---

### 3.5 Pipeline timeout

**Cause**: Table taking too long (usually `brz_supplychain_enh_1__demandforecastsnapshotdaily` — 1.3B rows).

**Fix**:
1. Check duration:
```sql
SELECT sp_name, duration_seconds, rows_affected, start_time
FROM meta.sp_run_history
WHERE sp_name = 'bronze.brz_supplychain_enh_1__demandforecastsnapshotdaily'
ORDER BY start_time DESC;
```
2. Normal: ~5-8 minutes. If >15 minutes: possible Fabric capacity throttling
3. Check Fabric capacity utilization in Admin Portal → Capacity metrics

---

### 3.6 Semantic Model refresh failed

**Cause**: Power BI API token expired or SM definition changed.

**Fix**:
1. Check token: `az account get-access-token --resource https://analysis.windows.net/powerbi/api`
2. If expired: `az login`
3. Manual refresh: Fabric Portal → Semantic Model → Refresh now
4. If SM definition changed: re-deploy TMDL via REST API

---

## 4. How to Re-run the Pipeline

### Option A: Full re-run (recommended)
1. Fabric Portal → Workspace → pl_sc_master → Run
2. Wait ~19 minutes
3. Check: `SELECT * FROM meta.pipeline_run_log ORDER BY start_time DESC`

### Option B: Re-run single table
```sql
-- Run on Fabric Portal SQL editor:
DECLARE @run_id VARCHAR(36) = NEWID();
EXEC meta.usp_generic_load
    @target_schema = 'bronze',
    @target_table = 'brz_saleshistory_afi__invoicedetail',
    @pipeline_run_id = 'manual-rerun',
    @run_id = @run_id;
```

### Option C: Re-run single layer
1. Fabric Portal → Workspace → pl_bronze_forecast → Run
2. Or pl_silver_wave_forecast / pl_gold_forecast

### Smart skip note
Monthly tables auto-skip if `next_run_time > now`. To force re-run a monthly table:
```sql
UPDATE meta.sp_registry SET next_run_time = NULL WHERE target_table = 'ref_calendar';
-- Then run pipeline — it will pick up this table
```

---

## 5. Key Tables to Check

| Table | What it tells you | Key columns |
|-------|-------------------|-------------|
| `meta.sp_run_history` | Per-table execution log | sp_name, status, error_message, duration_seconds |
| `meta.pipeline_run_log` | Per-pipeline execution log | pipeline_run_id, status, start_time, end_time |
| `meta.dq_results` | DQ check outcomes | rule_id, status (PASS/FAIL), actual_value |
| `meta.dq_rules` | DQ rule config | rule_name, check_type, severity, threshold |
| `meta.sp_registry` | Table config (28 rows) | sp_name, load_type, frequency, next_run_time, is_active |
| `meta.sp_lineage` | Data flow edges (52 rows) | source_object, target_object |

---

## 6. Useful Queries

### Pipeline run summary (last 7 days)
```sql
SELECT CAST(start_time AS DATE) as run_date,
       COUNT(*) as total_runs,
       SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) as success,
       SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed,
       AVG(duration_seconds) as avg_duration_s
FROM meta.sp_run_history
WHERE start_time > DATEADD(DAY, -7, GETUTCDATE())
GROUP BY CAST(start_time AS DATE)
ORDER BY run_date DESC;
```

### Slowest tables (performance check)
```sql
SELECT sp_name, 
       AVG(duration_seconds) as avg_s, 
       MAX(duration_seconds) as max_s,
       AVG(rows_affected) as avg_rows
FROM meta.sp_run_history
WHERE status = 'success'
GROUP BY sp_name
ORDER BY avg_s DESC;
```

### Tables not loaded in 48h (stale data check)
```sql
SELECT r.sp_name, r.frequency, r.next_run_time,
       MAX(h.start_time) as last_run
FROM meta.sp_registry r
LEFT JOIN meta.sp_run_history h ON r.sp_name = h.sp_name AND h.status = 'success'
WHERE r.is_active = 1
GROUP BY r.sp_name, r.frequency, r.next_run_time
HAVING MAX(h.start_time) < DATEADD(HOUR, -48, GETUTCDATE())
    OR MAX(h.start_time) IS NULL
ORDER BY last_run;
```

### DQ pass rate
```sql
SELECT r.layer,
       COUNT(*) as total_checks,
       SUM(CASE WHEN d.status = 'PASS' THEN 1 ELSE 0 END) as passed,
       CAST(SUM(CASE WHEN d.status = 'PASS' THEN 1.0 ELSE 0 END) / COUNT(*) * 100 AS DECIMAL(5,1)) as pass_pct
FROM meta.dq_results d
JOIN meta.dq_rules r ON d.rule_id = r.rule_id
WHERE d.check_time > DATEADD(HOUR, -24, GETUTCDATE())
GROUP BY r.layer;
```

---

## 7. Escalation Path

| Severity | Symptom | Action | Who |
|----------|---------|--------|-----|
| **Low** | 1 table failed, retry succeeded | No action needed | Auto-resolved |
| **Medium** | 1-2 tables failed after retry | Re-run pipeline manually. Check error in sp_run_history | On-call DE |
| **High** | Pipeline failed (DQ CRITICAL or >5 tables failed) | Investigate root cause. Check source data. Fix and re-run | DE lead |
| **Critical** | Pipeline not running (schedule missed, capacity down) | Check Fabric Portal → Pipeline → Monitor. Check capacity | DE lead + admin |

---

## 8. Maintenance Tasks

### Weekly
- Review sp_run_history for trends (any table getting slower?)
- Check DQ results for WARNING patterns

### Monthly
- Verify monthly ref tables loaded correctly (10 tables)
- Review Fabric capacity utilization
- Check if any new source tables need onboarding (see [new_table_onboarding_guide.md](new_table_onboarding_guide.md))

### Quarterly
- Review [future_roadmap.md](future_roadmap.md) for pending improvements
- Assess if architecture changes needed (new mart, new data sources)

---

## 9. Quick Reference

| What | Where |
|------|-------|
| Pipeline schedule | Daily 2:00 AM UTC+7 (Bangkok/Hanoi) |
| Pipeline name | pl_sc_master |
| Warehouse | SupplyChain_Warehouse |
| Total tables | 28 (18 daily + 10 monthly) |
| Normal runtime | ~19 minutes |
| DQ rules | 30 (8 CRITICAL, 22 WARNING) |
| Concurrency | Master: 1, Bronze: 6, Silver: 8, Gold: 2 |
| Retry | SP-level: 3x/2s, Pipeline-level: 3x/60s |
| Add new table | [new_table_onboarding_guide.md](new_table_onboarding_guide.md) |
| Architecture docs | [README.md](../README.md) |
