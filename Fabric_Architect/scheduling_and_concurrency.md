# Scheduling & Concurrency Guide
> Pipeline trigger, table frequency, cron scheduling, smart skip, concurrency control
> Current architecture + multi data mart

---

## 1. Current Scheduling Mechanism -- Cron + Smart Skip ACTIVATED

### Overview

The Pipeline Lookup already has a **schedule filter** -- it only loads tables that are DUE to run. Monthly tables automatically skip when their period has not arrived.

**Cron expression** in `sp_registry.cron_expression` determines the frequency for each table.
**next_run_time** is automatically SET by `usp_log_run` after each run.
**Pipeline Lookup** checks: `next_run_time IS NULL OR next_run_time <= GETUTCDATE()` -- only tables that are due will run.

```
Pipeline trigger (manual or scheduled)
    |
Lookup: SELECT target_schema, target_table
        FROM sp_registry WHERE is_active = 1
    |
ForEach: EXEC meta.usp_generic_load for ALL tables
    |
generic SP: DROP + CTAS (overwrite) or INSERT (incremental)
    |
usp_log_run: SET next_run_time = DATEADD(frequency)
```

**Result**: trigger once -- all 28 tables RUN -- monthly tables also get overwritten every day if the pipeline triggers daily.

### Current sp_registry (28 tables)

| Frequency | Table count | Type | What actually happens |
|-----------|------------|------|----------------------|
| `daily` | 18 | BRZ (7), SLV (8), GLD (2), REF (1) | Runs every trigger -- correct |
| `monthly` | 10 | REF (10) | Runs every trigger -- wastes CU |

### `ufn_should_run` -- exists but NOT IN USE

```sql
-- This function was created but the pipeline Lookup does NOT call it
CREATE FUNCTION meta.ufn_should_run(@sp_name VARCHAR(200))
RETURNS INT
AS
BEGIN
    RETURN CASE
        WHEN is_active = 0 THEN 0
        WHEN next_run_time IS NULL THEN 1
        WHEN next_run_time <= GETUTCDATE() THEN 1
        ELSE 0
    END
END
```

### `next_run_time` -- is SET but NOBODY CHECKS it

When the SP finishes running, `usp_log_run` calculates next_run_time:
```sql
next_run_time = CASE
    WHEN frequency = 'daily'   -> tomorrow 00:00 UTC
    WHEN frequency = 'hourly'  -> +1 hour
    WHEN frequency = 'weekly'  -> +1 week
    WHEN frequency = 'monthly' -> +1 month
END
```

Currently: monthly tables have `next_run_time = 2026-05-15` but the pipeline does NOT check -- still loads every trigger.

---

## 2. Two Scheduling Tiers -- Pipeline vs Table

```
+-----------------------------------------------------------+
|  TIER 1: PIPELINE SCHEDULE (Fabric level)                 |
|  "When does the master pipeline trigger?"                 |
|  -> Fabric Pipeline Schedule: daily 2AM / hourly / cron   |
|  -> Or manual Run                                         |
|  -> Config: Fabric Portal -> Pipeline -> Schedule tab     |
|  -> NOT related to sp_registry                            |
+-----------------------------+-----------------------------+
                              | trigger
+-----------------------------------------------------------+
|  TIER 2: TABLE FREQUENCY (application level)              |
|  "Which tables ACTUALLY need to run in this trigger?"     |
|  -> sp_registry.frequency + next_run_time                 |
|  -> ufn_should_run gate                                   |
|  -> Pipeline triggers 10 times but monthly skips 9 times  |
|  -> CURRENTLY NOT ACTIVATED (pipeline does not call gate) |
+-----------------------------------------------------------+
```

---

## 3. How to Activate Smart Skip (change pipeline Lookup)

### Current (runs ALL):
```sql
SELECT target_schema, target_table
FROM SupplyChain_Warehouse.meta.sp_registry
WHERE layer IN ('BRZ','REF') AND is_active = 1
```

### After activation (smart skip):
```sql
SELECT target_schema, target_table
FROM SupplyChain_Warehouse.meta.sp_registry
WHERE layer IN ('BRZ','REF') AND is_active = 1
  AND (next_run_time IS NULL OR next_run_time <= GETUTCDATE())
```

**Add 1 WHERE clause** -- monthly tables automatically skip when their period has not arrived.

### Impact:
- daily tables: `next_run_time = tomorrow` -- each daily trigger passes
- monthly tables: `next_run_time = next month` -- skips 29/30 days
- hourly tables: `next_run_time = +1h` -- each hourly trigger passes
- First run (`next_run_time = NULL`): always runs

### CU Savings:
- 10 monthly tables x ~5s each = 50s/trigger wasted
- 30 triggers/month x 50s = 25 minutes of wasted CU/month
- Small but accumulates when scaling N marts x N tables

---

## 4. Concurrency Control

### 4.1 Pipeline-level concurrency

```
pl_sc_master: concurrency = 1
  -> Only 1 instance runs at a time
  -> If triggered a 2nd time while the 1st is still running -> queue (wait)
  -> Prevents: 2 pipelines simultaneously DROP + CTAS on the same table
```

**Config**: already set `"concurrency": 1` in the pipeline definition.

### 4.2 ForEach-level concurrency

```
pl_bronze_forecast: ForEach batchCount = 8
  -> 8 tables load in parallel simultaneously
  -> Fabric WH dual compute pool: READ (view) + WRITE (CTAS) separated
  -> Snapshot conflict when 8 DROP+CTAS run concurrently -> retry 3x60s handles it
```

### 4.3 Mart-level concurrency (future multi-mart)

```
pl_sc_master: ForEach marts isSequential=false, batch=10
  -> 10 marts run in parallel
  -> Each mart is independent: its own bronze/silver/gold
  -> Cross-mart deps run AFTER all marts complete
```

### 4.4 Snapshot conflict -- cause + solution

```
Cause:
  Table A: DROP -> CREATE TABLE AS SELECT... (writing)
  Table B: DROP -> CREATE TABLE AS SELECT FROM Table A (reading Table A)
  -> Conflict: Table A is being modified while Table B is reading it

Current solution:
  Pipeline retry = 3 times, interval = 60 seconds
  -> 1st attempt fails -> wait 60s -> retry -> Table A already done -> success

Optimal solution (future):
  Bronze batch = 8 (smaller -> fewer conflicts)
  Silver: parent-child DAG -> wave-by-wave (tables in the same wave do not depend on each other)
  Gold: batch = 2 (few tables)
```

### 4.5 Semantic Model refresh concurrency

```
SM refresh: 1 time at the end of the pipeline
  -> Direct Lake mode: only syncs metadata (~1-2s), does not import data
  -> No conflict with table load (already finished before SM refresh)
  -> If N SMs: ForEach parallel batch=N
```

---

## 5. Trigger Scenarios and Impact

### Scenario A: Daily 2AM (recommended for current production)

```
Schedule: daily 02:00 UTC
Duration: ~20 minutes
Tables run: 28/28 (currently, without smart skip)
            18/28 (after smart skip -- 10 monthly skip)
CU estimate: ~50 CU/day
SM refresh: 1 time/day
```

### Scenario B: Hourly (when fresher data is needed)

```
Schedule: every 1 hour (6AM-10PM = 16 triggers/day)
Duration: ~20 minutes per trigger
Tables run (with smart skip):
  - hourly tables: every trigger
  - daily tables: 1/16 triggers (skip 15)
  - monthly tables: ~0/16 (skip all except on schedule)
CU estimate: 16 x ~10 CU (mostly skip) = ~160 CU/day
  Compared to daily: 3x cost but data is 16x fresher
```

### Scenario C: Every 15 minutes

```
Schedule: */15 * * * * (96 triggers/day)
Risk: pipeline overlap if duration > 15 minutes
Solution: concurrency=1 -> queue
CU estimate: 96 x ~5 CU (mostly skip) = ~480 CU/day
Only makes sense when: there are tables with frequency='realtime' (5-10 minutes)
```

### Scenario D: Multi-schedule (recommended for multi-mart production)

```
Pipeline 1: pl_sc_master_batch (daily 2AM)
  -> ALL tables, ALL marts
  -> Full run: bronze -> silver -> gold -> SM

Pipeline 2: pl_sc_master_hot (every 1 hour, 7AM-9PM)
  -> ONLY tables with frequency='hourly'
  -> Lookup adds: WHERE frequency = 'hourly'
  -> Light run: only a few tables -> fast

Pipeline 3: pl_sc_master_realtime (every 15 min) [future]
  -> ONLY tables with frequency='realtime'
  -> 1-2 incremental tables
  -> Ultra-light: ~30s per run
```

---

## 6. How to Set Up a Schedule on Fabric

### Via Fabric Portal (UI):
```
1. Fabric Portal -> Workspace -> pl_sc_master
2. Click "Schedule" tab
3. Scheduled run: ON
4. Repeat: Daily
5. Time: 02:00 AM
6. Timezone: SE Asia Standard Time (UTC+7) or UTC
7. Start: today
8. End: No end date
```

### Via REST API:
```bash
# Get pipeline schedule
curl -X GET "https://api.fabric.microsoft.com/v1/workspaces/{ws}/items/{pipeline}/schedules" \
  -H "Authorization: Bearer $TOKEN"

# Create/Update schedule
curl -X POST "https://api.fabric.microsoft.com/v1/workspaces/{ws}/items/{pipeline}/schedules" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "enabled": true,
    "configuration": {
      "type": "Cron",
      "startDateTime": "2026-04-16T02:00:00",
      "interval": 1440,
      "localTimeZoneId": "SE Asia Standard Time"
    }
  }'
```

---

## 7. Implementation Status -- COMPLETED

### Created:

| Object | Type | Details |
|--------|------|---------|
| `sp_registry.cron_expression` | Column | VARCHAR(100), cron syntax per table |
| `meta.ufn_cron_is_due(@cron)` | Function | Parses cron -> returns 1 if now matches |

### Configured:

| Tables | Cron | Meaning |
|--------|------|---------|
| 18 daily (BRZ+SLV+GLD+REF) | `0 2 * * *` | 2:00 AM UTC every day |
| 10 monthly (REF) | `0 2 1 * *` | 2:00 AM UTC on the 1st of every month |

### Pipeline modified (new names as of 2026-04-16):

| Pipeline | Previous name | Additional Lookup filter |
|----------|--------------|--------------------------|
| pl_bronze_forecast | pl_bronze_forecast | `AND (r.cron_expression IS NULL OR r.next_run_time IS NULL OR r.next_run_time <= GETUTCDATE())` |
| pl_gold_forecast | pl_gold_forecast | Same as above |
| pl_silver_wave_forecast | pl_silver_wave_forecast | Silver uses DAG waves (does not filter cron directly) |

> **Naming convention**: `pl_{layer}_{project}`. Master keeps `pl_sc_master` (unique). Child pipelines change the suffix by project (forecast, inventory, ...).

### Concurrency:
- `pl_sc_master`: **concurrency = 1** (only 1 instance runs, next trigger -> queue)
- ForEach bronze: **batch = 6** (reduced from 8 -> 6, reduces snapshot conflicts)
- ForEach gold: **batch = 2**
- ForEach silver wave: **batch = 8**

### Snapshot conflict mitigation (2026-04-16):

**Problem**: 8 bronze tables loading in parallel -> all INSERT/UPDATE into `sp_run_history` simultaneously -> snapshot isolation conflict -> table reports failed even though data was already loaded.

**3-layer solution**:
1. **Reduce batchCount 8 -> 6**: fewer concurrent writes -> lower probability of conflict
2. **Retry inside `usp_log_run`**: WHILE retry < 3 + TRY/CATCH + WAITFOR DELAY 2s between each retry. If INSERT/UPDATE conflicts -> auto retry, SP does not crash.
3. **Pipeline retry**: `exec_generic` activity already has retry=3, interval=60s -> if SP still fails then pipeline auto retries

```sql
-- usp_log_run retry logic (simplified):
WHILE @retry < 3 AND @done = 0
BEGIN
    BEGIN TRY
        INSERT/UPDATE sp_run_history ...
        SET @done = 1;
    END TRY
    BEGIN CATCH
        SET @retry = @retry + 1;
        WAITFOR DELAY '00:00:02';
    END CATCH
END
```

### Changing the frequency of a single table:
```sql
-- Example: change ref_warehouse to weekly
UPDATE meta.sp_registry
SET cron_expression = '0 2 * * 1',  -- 2AM Monday
    frequency = 'weekly'
WHERE target_table = 'ref_warehouse';
```

### Cron cheat sheet:
```
*/15 * * * *          every 15 minutes
0 * * * *             every hour on the hour
0 */5 * * *           every 5 hours
0 2 * * *             2AM every day
0 8,14 * * *          8AM + 2PM every day
0 2 * * 1             2AM every Monday
0 2 * * 1-5           2AM weekdays
0 2 1 * *             2AM on the 1st of every month
0 2 15 * *            2AM on the 15th of every month
*/15 6-22 * * 1-5     every 15 min, 6AM-10PM, weekdays
```
| usp_generic_load | Frequency-agnostic |
| Views | Not related to scheduling |
| Meta tables | All columns are present |
