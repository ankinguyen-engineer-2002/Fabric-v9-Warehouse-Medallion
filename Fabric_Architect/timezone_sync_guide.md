# Timezone Sync Guide — Time Synchronization with US Team
> UTC (core) + CST (Enterprise/US) + VN (UTC+7)
> Accurate mapping with Enterprise fn_GetDate + TableDictionary

---

## Overview

| Team | Timezone | Offset | Used for |
|------|----------|--------|----------|
| **VN team** | UTC+7 (Vietnam) | Always +7 | Viewing daily logs |
| **US team** | CST/CDT (Central) | -6 (winter) / -5 (DST summer) | Enterprise TableDictionary, audit |
| **Core** | UTC | 0 | Source of truth, stored in database |

The Enterprise team (US) uses `fn_GetDate` in 30+ SPs to convert UTC to CST before writing logs. v9 needs to do the same so that `vw_table_dictionary` maps correctly with Enterprise.

---

## Already Implemented (2026-04-16)

### 1. Scalar function: `meta.ufn_utc_to_cst`

```sql
-- Equivalent to Enterprise fn_GetDate but as a scalar (Fabric WH does not support table-valued functions)
-- Automatically handles DST: Mar-Nov = UTC-5 (CDT), Nov-Mar = UTC-6 (CST)
SELECT meta.ufn_utc_to_cst(GETUTCDATE())  -- → CST time
```

DST logic: checks whether the date falls between the 2nd Sunday of March and the 1st Sunday of November.

### 2. CST columns in log tables

| Table | New column | Written by |
|-------|------------|------------|
| `sp_run_history` | `start_cst`, `end_cst` | `usp_log_run` (automatic) |
| `pipeline_run_log` | `start_cst`, `end_cst` | `usp_log_pipeline_run` (automatic) |

Historical data has been backfilled (325 rows in sp_run_history, 5 rows in pipeline_run_log).

### 3. View `vw_table_dictionary` — [Modified] outputs CST

| Enterprise column | Before | After |
|-------------------|--------|-------|
| `[Modified]` | `last_load_date` (UTC) | `ufn_utc_to_cst(last_load_date)` **(CST)** |
| `[LastAudit]` | NULL | `ufn_utc_to_cst(last_load_date)` **(CST)** |
| `[LastBatchStartDate]` | NULL | `ufn_utc_to_cst(last_load_date)` **(CST)** |

> US team queries `vw_table_dictionary` and sees CST times matching Enterprise.

### 4. View `vw_run_history_tz` — view all 3 timezones

```sql
SELECT sp_name, start_utc, start_cst, start_vn
FROM meta.vw_run_history_tz
ORDER BY start_utc DESC;

-- Result:
-- gld_fact_forecast_kpi | 17:12 UTC | 12:12 CST | 00:12 VN
```

| Column | Timezone | Intended audience |
|--------|----------|-------------------|
| `start_utc` / `end_utc` | UTC | Core, cross-system comparison |
| `start_cst` / `end_cst` | CST/CDT | US team |
| `start_vn` / `end_vn` | UTC+7 | VN team |

---

## Mapping with Enterprise fn_GetDate

| Enterprise | v9 | Match? |
|-----------|-----|--------|
| `DW_Developer.fn_GetDate(@dt)` returns TABLE (CSTDateValue, ESTDateValue, PSTDateValue) | `meta.ufn_utc_to_cst(@dt)` returns scalar DATETIME2(6) | CST logic is identical |
| DST: Mar 2nd Sunday to Nov 1st Sunday | DST: same | DST logic is identical |
| Table-valued function | Scalar function | Fabric WH does not support TVF, so scalar is used |
| Called in 30+ SPs | Called in 2 SPs (usp_log_run, usp_log_pipeline_run) + 1 view | Sufficient coverage |

### What about EST and PST?

Enterprise returns 3 timezones (CST, EST, PST). v9 only implements **CST** because:
- Ashley HQ = Wisconsin = Central Time
- `[Modified]` in TableDictionary records CST
- If EST/PST are needed later, add:

```sql
-- Easy to add but not yet needed:
-- CREATE FUNCTION meta.ufn_utc_to_est(...) -- CST logic + offset +1h
-- CREATE FUNCTION meta.ufn_utc_to_pst(...) -- CST logic + offset -2h
```

---

## Newly Created Objects

| Object | Type | Purpose |
|--------|------|---------|
| `meta.ufn_utc_to_cst` | Scalar Function | UTC to CST/CDT (DST aware) |
| `meta.vw_run_history_tz` | View | Logs with 3 timezones (UTC, CST, VN) |
| `sp_run_history.start_cst` | Column | CST start time |
| `sp_run_history.end_cst` | Column | CST end time |
| `pipeline_run_log.start_cst` | Column | CST start time |
| `pipeline_run_log.end_cst` | Column | CST end time |

### Modified SPs

| SP | Change |
|----|--------|
| `usp_log_run` | Writes `start_cst`, `end_cst` on INSERT/UPDATE |
| `usp_log_pipeline_run` | Writes `start_cst`, `end_cst` on INSERT/UPDATE |

### Modified Views

| View | Change |
|------|--------|
| `vw_table_dictionary` | `[Modified]`, `[LastAudit]`, `[LastBatchStartDate]` converted to CST |
