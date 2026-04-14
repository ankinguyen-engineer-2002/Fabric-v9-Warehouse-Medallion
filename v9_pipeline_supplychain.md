# Pipeline Deep Dive -- Execution Trace
> What happens step-by-step when pl_sc_master is triggered
> SupplyChain_Warehouse v9 | Microsoft Fabric F256

This document is a complete execution walkthrough of the master pipeline. It traces every activity, every SQL call, every data flow from start to finish. Read this to understand exactly what happens at runtime.

---

## Trigger: pl_sc_master Starts

When `pl_sc_master` (ID: 319a8160) is triggered (manually or on schedule), it executes 3 child pipelines sequentially:

```mermaid
flowchart LR
    T["Trigger\n(manual or schedule)"]
    B["Step 1: pl_sc_bronze\n(1bdbaebb)"]
    S["Step 2: pl_sc_silver\n(46437ae6)"]
    G["Step 3: pl_sc_gold\n(94fc130e)"]

    T --> B -->|"on success"| S -->|"on success"| G
```

If any child pipeline fails, execution stops. Silver does not run if bronze fails. Gold does not run if silver fails.

---

## Step 1: pl_sc_bronze Executes

### 1.1 Lookup Activity: Get Bronze SP List

The Lookup activity connects to the **Lakehouse SQL endpoint** (not the Warehouse directly) and runs a cross-database query:

```sql
-- Executed on: SupplyChain_Lakehouse SQL endpoint
-- Connection: b4311980 (LakehouseTableSource)
SELECT sp_name
FROM SupplyChain_Warehouse.meta.sp_registry
WHERE layer IN ('BRZ', 'REF')
  AND is_active = 1
```

**Returns 18 rows** (7 BRZ + 11 REF):

| # | sp_name | Layer |
|---|---------|-------|
| 1 | bronze.usp_load_brz_saleshistory_afi__invoicedetail | BRZ |
| 2 | bronze.usp_load_brz_saleshistory_afi__invoiceheader | BRZ |
| 3 | bronze.usp_load_brz_supplychain_enh_1__demandforecastsnapshotdaily | BRZ |
| 4 | bronze.usp_load_brz_wholesale_codis_afi__codatan | BRZ |
| 5 | bronze.usp_load_brz_wholesale_codis_afi__comast | BRZ |
| 6 | bronze.usp_load_brz_wholesale_codis_afi__extord | BRZ |
| 7 | bronze.usp_load_brz_wholesale_codis_afi__extorit | BRZ |
| 8 | bronze.usp_load_ref_calendar | REF |
| 9 | bronze.usp_load_ref_customer_account | REF |
| 10 | bronze.usp_load_ref_customer_account_group | REF |
| 11 | bronze.usp_load_ref_customer_grouping | REF |
| 12 | bronze.usp_load_ref_customer_shipping_location | REF |
| 13 | bronze.usp_load_ref_forecast_cycle | REF |
| 14 | bronze.usp_load_ref_forecast_horizon | REF |
| 15 | bronze.usp_load_ref_item_master | REF |
| 16 | bronze.usp_load_ref_order_type | REF |
| 17 | bronze.usp_load_ref_product | REF |
| 18 | bronze.usp_load_ref_warehouse | REF |

### 1.2 ForEach Activity: Execute SPs in Parallel

The ForEach activity iterates over the 18 SP names with `batch=8` and `isSequential=false`. This means up to **8 SPs run in parallel** at any time.

Each SP is executed via `SqlServerStoredProcedure` activity:
- **Connection**: DataWarehouse linkedService (endpoint: 7woj2w...datawarehouse.fabric.microsoft.com, artifactId: e146ffe2)
- **Retry policy**: retry=2, interval=30 seconds
- **Command**: `EXEC @item().sp_name`

### 1.3 Inside Each Bronze SP (Overwrite Pattern -- 17 of 18 SPs)

Every overwrite bronze SP follows this exact sequence:

```mermaid
flowchart TD
    S1["1. DECLARE @run_id = CONVERT(VARCHAR(36), NEWID())"]
    S2["2. EXEC meta.usp_log_run @run_id, sp_name, 'running'\n-> INSERT INTO meta.sp_run_history\n   (run_id, sp_name, start_time, status='running')"]
    S3["3. DROP TABLE IF EXISTS bronze.{table}\n-> Removes existing Parquet files"]
    S4["4. CREATE TABLE bronze.{table} AS\n   SELECT *, CAST(GETUTCDATE() AS DATETIME2(6)) AS _load_dt\n   FROM bronze.vw_{table}\n-> View reads from Enterprise_Lakehouse.{schema}.{source}\n   via 3-part naming\n-> Data materialized as Parquet in Warehouse"]
    S5["5. SELECT @rows = COUNT(*) FROM bronze.{table}"]
    S6["6. EXEC meta.usp_log_run @run_id, sp_name, 'success',\n   @rows_affected = @rows\n-> UPDATE sp_run_history (end_time, duration, rows, status)\n-> UPDATE sp_registry (last_load_date, rows_loaded, next_run_time)"]

    S1 --> S2 --> S3 --> S4 --> S5 --> S6
```

**If an error occurs** (TRY/CATCH):
1. `DECLARE @err = ERROR_MESSAGE()`
2. `EXEC meta.usp_log_run @run_id, sp_name, 'failed', @error_message = @err`
3. `THROW` (re-raises error to pipeline, triggering retry)

### 1.4 Inside the Incremental SP (demandforecast -- 1 of 18 SPs)

`bronze.usp_load_brz_supplychain_enh_1__demandforecastsnapshotdaily` uses the incremental pattern:

```mermaid
flowchart TD
    S1["1. Generate run_id, log 'running'"]
    S2["2. Check table exists:\n   SELECT COUNT(*) FROM sys.tables WHERE name = '{table}'"]
    S3["3. Get last watermark:\n   SELECT last_watermark_value FROM meta.sp_registry"]
    D{Table exists AND\nwatermark NOT NULL?}

    FULL["FIRST RUN:\nDROP TABLE + CTAS\nWHERE ts_snapshot >= '2023-01-01'\nRows = COUNT(*)"]
    INCR["SUBSEQUENT RUN:\nINSERT INTO ... SELECT\nWHERE ts_snapshot > @last_watermark\nRows = @@ROWCOUNT"]

    WM["Update watermark:\nUPDATE sp_registry SET last_watermark_value\n= MAX(ts_snapshot)"]
    LOG["Log 'success' with row count"]

    S1 --> S2 --> S3 --> D
    D -->|No| FULL --> WM --> LOG
    D -->|Yes| INCR --> WM --> LOG
```

**On the successful pipeline run #3**: This SP returned 0 new rows because no new data had arrived since the last manual load. This is expected behavior, not an error.

### 1.5 Snapshot Conflict and Retry

When 8 bronze SPs run in parallel, they all do DROP TABLE + CTAS. If two SPs operate on Parquet files that share the same underlying storage segments, a **snapshot isolation conflict** occurs:

```
Error: "Snapshot isolation transaction aborted due to update conflict.
The transaction was aborted because another concurrent operation modified or deleted
the same resource."
```

**How it is handled**: The pipeline retry policy (retry=2, interval=30s) automatically retries the failed SP. After a 30-second wait, the conflicting transaction has completed, and the retry succeeds.

**Observed in Run #3**: 3 SPs required 1 retry each (brz_invoicedetail, brz_demandforecast, ref_warehouse). All succeeded on retry.

### 1.6 Bronze Execution Results (Run #3)

| SP | Rows | Duration | Retries |
|----|------|----------|---------|
| brz_saleshistory_afi__invoicedetail | 35,671,179 | 31s | 1 |
| brz_saleshistory_afi__invoiceheader | 4,074,633 | 31s | 0 |
| brz_supplychain_enh_1__demandforecastsnapshotdaily | 0 (incremental) | 4s | 1 |
| brz_wholesale_codis_afi__codatan | 918,213 | 14s | 0 |
| brz_wholesale_codis_afi__comast | 224,272 | 3s | 0 |
| brz_wholesale_codis_afi__extord | 223,617 | 8s | 0 |
| brz_wholesale_codis_afi__extorit | 912,132 | 15s | 0 |
| ref_calendar | 21,551 | 1s | 0 |
| ref_customer_account | 35,585 | 3s | 0 |
| ref_customer_account_group | 35,454 | 1s | 0 |
| ref_customer_grouping | 9 | 1s | 0 |
| ref_customer_shipping_location | 127,526 | 14s | 0 |
| ref_forecast_cycle | 43 | 6s | 0 |
| ref_forecast_horizon | 8 | 1s | 0 |
| ref_item_master | 379,339 | 24s | 0 |
| ref_order_type | 29 | 1s | 0 |
| ref_product | 373,326 | 11s | 0 |
| ref_warehouse | 55 | 1s | 1 |

**Total**: 18/18 success, ~1.35 billion rows, ~3 minutes elapsed time.

---

## Step 2: pl_sc_silver Executes

### 2.1 Step 1 of Silver: Compute DAG Waves

The first activity in pl_sc_silver is a SqlServerStoredProcedure that calls:

```sql
EXEC meta.usp_compute_slv_waves
```

This SP does the following:

1. **DELETE** all rows from `meta.slv_dag_waves_runtime` (clean slate)
2. **Wave 0**: Find all SLV SPs where `depends_on` does not reference any silver SP:
   ```sql
   INSERT INTO slv_dag_waves_runtime (sp_name, wave)
   SELECT sp_name, 0 FROM sp_registry
   WHERE layer = 'SLV' AND is_active = 1
   AND (depends_on IS NULL OR depends_on NOT LIKE '%silver.usp_%')
   ```
   **Result**: 3 SPs assigned to wave 0
3. **Wave 1**: Find SLV SPs where ALL silver dependencies are already assigned:
   ```sql
   INSERT INTO slv_dag_waves_runtime (sp_name, wave)
   SELECT r.sp_name, 1 FROM sp_registry r
   WHERE r.layer = 'SLV' AND r.is_active = 1
   AND r.sp_name NOT IN (SELECT sp_name FROM slv_dag_waves_runtime)
   AND NOT EXISTS (
       SELECT 1 FROM sp_registry dep
       WHERE dep.layer = 'SLV' AND dep.is_active = 1
       AND r.depends_on LIKE '%' + dep.sp_name + '%'
       AND dep.sp_name NOT IN (SELECT sp_name FROM slv_dag_waves_runtime)
   )
   ```
   **Result**: 4 SPs assigned to wave 1
4. **Wave 2**: Same logic, next iteration. **Result**: 1 SP assigned to wave 2
5. All 8 SPs assigned. Loop exits.

**Final content of `meta.slv_dag_waves_runtime` (8 rows)**:

| sp_name | wave |
|---------|------|
| silver.usp_load_slv_invoice_detail_line_level | 0 |
| silver.usp_load_slv_forecast_demand_monthly | 0 |
| silver.usp_load_slv_open_order_line_level | 0 |
| silver.usp_load_slv_actual_demand_monthly | 1 |
| silver.usp_load_slv_actual_demand_weekly | 1 |
| silver.usp_load_slv_invoice_weekly | 1 |
| silver.usp_load_slv_open_order_monthly | 1 |
| silver.usp_load_slv_naive_forecast_monthly | 2 |

### 2.2 Steps 2-11 of Silver: Sequential Wave Execution

The silver pipeline has 10 pre-built Lookup+ForEach stages (wave 0 through wave 9), connected sequentially. Each stage:

1. **Lookup**: Queries the Lakehouse SQL endpoint with cross-DB:
   ```sql
   SELECT sp_name
   FROM SupplyChain_Warehouse.meta.slv_dag_waves_runtime
   WHERE wave = {N}
   ```
2. **ForEach** (batch=8, PARALLEL): Executes each returned SP via SqlServerStoredProcedure.

For waves where the Lookup returns no rows (waves 3-9 in current state), the ForEach receives an empty array and skips execution entirely. No error, no delay.

### 2.3 Wave 0 Execution (3 SPs in Parallel)

```mermaid
flowchart LR
    L0["Lookup: wave 0\nReturns 3 SPs"]
    F0["ForEach batch=8\n(3 SPs run PARALLEL)"]

    subgraph Parallel["Running simultaneously"]
        SP1["EXEC silver.usp_load_slv_invoice_detail_line_level\n35.7M rows, 19s"]
        SP2["EXEC silver.usp_load_slv_forecast_demand_monthly\n13.9M rows, 110s"]
        SP3["EXEC silver.usp_load_slv_open_order_line_level\n251K rows, 5s"]
    end

    L0 --> F0 --> Parallel
```

Each SP follows the same overwrite pattern as bronze:
1. Generate run_id
2. Log 'running' to sp_run_history
3. DROP TABLE IF EXISTS silver.{table}
4. CTAS from silver.vw_{table} (view reads from bronze tables, applies JOINs/CTEs/transforms)
5. COUNT rows
6. Log 'success', update sp_registry

**Wave 0 completes when all 3 SPs finish**. The slowest SP (slv_forecast_demand_monthly at 110s) determines the wave duration.

### 2.4 Wave 1 Execution (4 SPs in Parallel)

Wave 1 starts only after wave 0 completes (sequential between waves).

```mermaid
flowchart LR
    L1["Lookup: wave 1\nReturns 4 SPs"]
    F1["ForEach batch=8\n(4 SPs run PARALLEL)"]

    subgraph Parallel["Running simultaneously"]
        SP1["slv_actual_demand_monthly\n574K rows, 13s"]
        SP2["slv_actual_demand_weekly\n1.1M rows, 18s"]
        SP3["slv_invoice_weekly\n15.5M rows, 144s"]
        SP4["slv_open_order_monthly\n117K rows, 4s"]
    end

    L1 --> F1 --> Parallel
```

These SPs depend on wave 0 outputs. For example, `slv_actual_demand_monthly`'s view reads from `silver.slv_invoice_detail_line_level` and `silver.slv_open_order_line_level` (both wave 0 tables that are now materialized).

### 2.5 Wave 2 Execution (1 SP)

```mermaid
flowchart LR
    L2["Lookup: wave 2\nReturns 1 SP"]
    F2["ForEach batch=8\n(1 SP runs)"]
    SP["slv_naive_forecast_monthly\n350K rows, 5s"]

    L2 --> F2 --> SP
```

This SP depends on `slv_actual_demand_monthly` (wave 1), which is why it runs in wave 2.

### 2.6 Waves 3-9: Skip

Lookups for waves 3 through 9 return empty result sets. The ForEach activities receive empty arrays and complete immediately (no-op).

### 2.7 Silver Execution Results (Run #3)

| Wave | SP | Rows | Duration |
|------|----|------|----------|
| 0 | slv_invoice_detail_line_level | 35,671,179 | 19s |
| 0 | slv_forecast_demand_monthly | 13,876,949 | 110s |
| 0 | slv_open_order_line_level | 250,667 | 5s |
| 1 | slv_actual_demand_monthly | 574,253 | 13s |
| 1 | slv_actual_demand_weekly | 1,112,585 | 18s |
| 1 | slv_invoice_weekly | 15,537,894 | 144s |
| 1 | slv_open_order_monthly | 116,988 | 4s |
| 2 | slv_naive_forecast_monthly | 349,997 | 5s |

**Total**: 8/8 success, ~67.5 million rows, ~6 minutes elapsed time.

---

## Step 3: pl_sc_gold Executes

### 3.1 Lookup Activity: Get Gold SP List

```sql
-- Executed on: SupplyChain_Lakehouse SQL endpoint (cross-DB)
SELECT sp_name
FROM SupplyChain_Warehouse.meta.sp_registry
WHERE layer = 'GLD'
  AND is_active = 1
```

**Returns 2 rows**:

| sp_name |
|---------|
| gold.usp_load_gld_fact_flat_forecast_actual |
| gold.usp_load_gld_fact_forecast_kpi |

### 3.2 ForEach Activity: Execute Gold SPs

ForEach with `batch=2` and `isSequential=false`. Both SPs run in parallel.

```mermaid
flowchart LR
    L["Lookup: 2 gold SPs"]
    F["ForEach batch=2\nPARALLEL"]

    subgraph Parallel["Running simultaneously"]
        SP1["gld_fact_flat_forecast_actual\n14.8M rows, 15s\n\nView: UNION ALL of\nslv_actual_demand_monthly\n+ slv_forecast_demand_monthly\n+ slv_naive_forecast_monthly"]
        SP2["gld_fact_forecast_kpi\n41.1M rows, 43s\n\nView: CTE chain of\nforecast x horizon\nLEFT JOIN actuals + naive"]
    end

    L --> F --> Parallel
```

### 3.3 Gold Execution Results (Run #3)

| SP | Rows | Duration |
|----|------|----------|
| gld_fact_flat_forecast_actual | 14,801,199 | 15s |
| gld_fact_forecast_kpi | 41,055,048 | 43s |

**Total**: 2/2 success, ~55.9 million rows, ~1 minute elapsed time.

---

## Meta Tables: What Gets Written During a Pipeline Run

### Auto-populated Tables

```mermaid
flowchart TD
    subgraph During["During Each SP Execution"]
        RH["meta.sp_run_history\n\nINSERT at start (status='running')\nUPDATE at end (status, rows, duration)\n\nWritten by: usp_log_run\nFrequency: 2 writes per SP (56 writes for 28 SPs)"]
        SR["meta.sp_registry\n\nUPDATE last_load_date\nUPDATE rows_loaded\nUPDATE next_run_time\n\nWritten by: usp_log_run\nFrequency: 1 update per SP (28 updates)"]
    end

    subgraph BeforeSilver["Before Silver Wave Execution"]
        DW["meta.slv_dag_waves_runtime\n\nDELETE all rows\nINSERT 8 rows (1 per silver SP)\n\nWritten by: usp_compute_slv_waves\nFrequency: 1 full refresh per pipeline run"]
    end
```

| Table | Writes per Pipeline Run | Written by |
|-------|------------------------|------------|
| sp_run_history | 56 (2 per SP x 28 SPs) | usp_log_run |
| sp_registry | 28 (1 update per SP) | usp_log_run |
| slv_dag_waves_runtime | 1 DELETE + 8 INSERTs | usp_compute_slv_waves |

### Tables Requiring Manual Input

| Table | When to Write | What to Write |
|-------|--------------|---------------|
| sp_registry | When adding a new table | INSERT 1 row with sp_name, layer, load_type, depends_on, source_objects, etc. |
| dq_rules | When adding DQ checks | INSERT 1 row per rule with check_type, target table, threshold, severity |
| sp_lineage | After adding tables | Run `EXEC meta.usp_build_lineage` to auto-rebuild (or INSERT manually) |

### Tables Not Written During Pipeline Run

| Table | Status | Notes |
|-------|--------|-------|
| pipeline_run_log | 0 rows | Placeholder for future pipeline-level logging |
| dq_rules | Read-only during run | Config table, manual maintenance |
| dq_results | Not written by pipeline | Written by DQ engine (run separately) |
| sp_lineage | Not written by pipeline | Written by usp_build_lineage (run separately) |

---

## Adding a New Table: Impact on Pipeline Flow

### Adding a Bronze Table

```mermaid
flowchart TD
    A["1. CREATE VIEW bronze.vw_brz_new_table\n   SELECT ... FROM Enterprise_Lakehouse.{schema}.{source}"]
    B["2. CREATE PROCEDURE bronze.usp_load_brz_new_table\n   (copy overwrite template, change names)"]
    C["3. INSERT INTO meta.sp_registry\n   sp_name='bronze.usp_load_brz_new_table'\n   layer='BRZ', is_active=1, ..."]
    D["4. INSERT INTO meta.dq_rules\n   (completeness + row_count rules)"]
    E["5. Next pipeline run:\n   Lookup returns 19 SPs (was 18)\n   ForEach includes new SP\n   No pipeline JSON change needed"]

    A --> B --> C --> D --> E
```

**What changes in the pipeline**: Nothing. The Lookup dynamically reads sp_registry. The ForEach iterates over whatever the Lookup returns. Adding a row to sp_registry is sufficient.

### Adding a Silver Table

```mermaid
flowchart TD
    A["1. CREATE VIEW silver.vw_slv_new_table\n   SELECT ... FROM bronze/silver tables"]
    B["2. CREATE PROCEDURE silver.usp_load_slv_new_table\n   (copy overwrite template)"]
    C["3. INSERT INTO meta.sp_registry\n   layer='SLV', depends_on='[\"silver.usp_load_slv_xxx\"]'"]
    D["4. Next pipeline run:\n   usp_compute_slv_waves recalculates\n   New SP auto-assigned to correct wave\n   If new wave needed, pipeline already has\n   stages 0-9 pre-built"]
    E["5. ForEach for that wave\n   includes the new SP\n   No pipeline change needed"]

    A --> B --> C --> D --> E
```

**What changes in the pipeline**: Nothing. The wave computation is dynamic. The 10 pre-built wave stages handle up to 10 waves. The new SP is automatically placed in the correct wave based on its `depends_on` declaration.

**Example**: If you add `slv_new_table` with `depends_on = '["silver.usp_load_slv_naive_forecast_monthly"]'`, it would be auto-assigned to wave 3 (because slv_naive_forecast_monthly is in wave 2). The wave 3 Lookup+ForEach stage, which previously returned empty results, would now pick up this SP.

### Adding a Gold Table

```mermaid
flowchart TD
    A["1. CREATE VIEW gold.vw_gld_new_table\n   SELECT ... FROM silver tables"]
    B["2. CREATE PROCEDURE gold.usp_load_gld_new_table\n   (copy overwrite template)"]
    C["3. INSERT INTO meta.sp_registry\n   layer='GLD', is_active=1"]
    D["4. Next pipeline run:\n   Lookup returns 3 SPs (was 2)\n   ForEach includes new SP\n   May need to increase batch from 2"]

    A --> B --> C --> D
```

**What changes in the pipeline**: Nothing in the pipeline definition. The Lookup dynamically picks up the new SP. Consider increasing the ForEach batch size if the number of gold tables grows significantly.

---

## End-to-End Timeline (Complete Trace)

```
T+00:00  pl_sc_master triggers
T+00:00  -> Invokes pl_sc_bronze (1bdbaebb)
T+00:01    -> Lookup: SELECT 18 sp_names from sp_registry (via Lakehouse cross-DB)
T+00:02    -> ForEach batch=8: first 8 SPs start in parallel
T+00:10    ->   8 more SPs start as slots free up
T+00:20    ->   remaining 2 SPs start
T+03:00    -> All 18 bronze SPs complete (3 retried once for snapshot conflicts)
T+03:00  -> pl_sc_bronze completes, master invokes pl_sc_silver (46437ae6)
T+03:01    -> SP: EXEC meta.usp_compute_slv_waves (computes 3 waves, writes 8 rows)
T+03:02    -> Lookup wave 0: returns 3 SPs
T+03:02    -> ForEach wave 0: 3 SPs start in parallel
T+04:52    -> Wave 0 completes (slowest: forecast_demand_monthly at 110s)
T+04:53    -> Lookup wave 1: returns 4 SPs
T+04:53    -> ForEach wave 1: 4 SPs start in parallel
T+07:17    -> Wave 1 completes (slowest: invoice_weekly at 144s)
T+07:18    -> Lookup wave 2: returns 1 SP
T+07:18    -> ForEach wave 2: 1 SP runs
T+07:23    -> Wave 2 completes (naive_forecast_monthly at 5s)
T+07:24    -> Lookups wave 3-9: all return empty, ForEach skips
T+09:00    -> pl_sc_silver completes, master invokes pl_sc_gold (94fc130e)
T+09:01    -> Lookup: returns 2 sp_names
T+09:01    -> ForEach batch=2: both SPs start in parallel
T+09:44    -> Both gold SPs complete (slowest: forecast_kpi at 43s)
T+10:00  pl_sc_master completes successfully

Total: ~16 minutes for 1.47 billion rows across 28 tables
```

---

## Error Scenarios and Recovery

### Scenario 1: Bronze SP Fails After All Retries

If a bronze SP fails after 2 retries:
- The ForEach marks that iteration as failed
- **Other SPs in the ForEach continue** (ForEach does not abort on individual failure by default)
- pl_sc_bronze marks as failed after ForEach completes
- pl_sc_master stops -- silver and gold do NOT run
- **sp_run_history** shows the failed run with error_message
- **Fix**: Investigate error, fix issue, re-trigger pl_sc_master (all bronze re-runs, silver/gold follow)

### Scenario 2: Silver SP Fails

If a silver SP fails within a wave:
- Other SPs in the same wave continue (parallel ForEach)
- The wave's ForEach marks as failed
- Subsequent waves do NOT run (sequential between waves)
- pl_sc_silver fails, pl_sc_gold does not run
- **Impact**: Any SP in a later wave that depends on the failed SP would also fail if it ran, so stopping is correct behavior

### Scenario 3: Wave Computation Produces Unexpected Results

If `usp_compute_slv_waves` assigns SPs to wrong waves (e.g., due to incorrect depends_on):
- SPs will run but may read stale data from upstream silver tables
- No runtime error (tables exist from prior run), but data may be incorrect
- **Detection**: Check slv_dag_waves_runtime after compute, verify wave assignments match expected DAG
- **Fix**: Update depends_on in sp_registry, re-run pipeline

---

*This document reflects the production state as of 2026-04-14, based on successful pipeline Run #3.*
