# Pipeline Run Log
> pl_sc_master — End-to-end execution log

---

## Run #3 — SUCCESS (2026-04-14)

| Item | Value |
|------|-------|
| Run ID | c41c1240-ae81-4377-8835-f0644ac4681c |
| Status | **COMPLETED** |
| Start | 2026-04-14 14:18:18 UTC |
| End | 2026-04-14 14:34:40 UTC |
| Duration | **~16 minutes** |
| Tables refreshed | **28/28** |
| Total rows | **1,472,804,014** (~1.47 billion) |

### Layer Summary

| Layer | Tables | Rows | Duration | Parallel |
|-------|--------|------|----------|----------|
| Bronze | 18/18 | 1,349,457,255 | ~3 min | batch=8 |
| Silver | 8/8 | 67,490,512 | ~6 min | wave 0-2, batch=8 per wave |
| Gold | 2/2 | 55,856,247 | ~1 min | batch=2 |

### Bronze SPs (18 success, 3 retried due to snapshot conflict)

| SP | Rows | Duration | Note |
|----|------|----------|------|
| brz_saleshistory_afi__invoicedetail | 35,671,179 | 31s | Failed once (snapshot conflict), retry OK |
| brz_saleshistory_afi__invoiceheader | 4,074,633 | 31s | |
| brz_supplychain_enh_1__demandforecast... | 0 (incremental, no new) | 4s | Failed once, retry OK |
| brz_wholesale_codis_afi__codatan | 918,213 | 14s | |
| brz_wholesale_codis_afi__comast | 224,272 | 3s | |
| brz_wholesale_codis_afi__extord | 223,617 | 8s | |
| brz_wholesale_codis_afi__extorit | 912,132 | 15s | |
| ref_calendar | 21,551 | 1s | |
| ref_customer_account | 35,585 | 3s | |
| ref_customer_account_group | 35,454 | 1s | |
| ref_customer_grouping | 9 | 1s | |
| ref_customer_shipping_location | 127,526 | 14s | |
| ref_forecast_cycle | 43 | 6s | |
| ref_forecast_horizon | 8 | 1s | |
| ref_item_master | 379,339 | 24s | |
| ref_order_type | 29 | 1s | |
| ref_product | 373,326 | 11s | |
| ref_warehouse | 55 | 1s | Failed once, retry OK |

### Silver SPs (8 success, DAG wave order)

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

### Gold SPs (2 success)

| SP | Rows | Duration |
|----|------|----------|
| gld_fact_flat_forecast_actual | 14,801,199 | 15s |
| gld_fact_forecast_kpi | 41,055,048 | 43s |

---

## Run #2 — FAILED (2026-04-14 14:07)

| Item | Value |
|------|-------|
| Status | **FAILED** at pl_sc_silver |
| Error | `BadRequest` — Until activity not supported in Fabric Pipeline |
| Fix | Replaced Until loop with 10 sequential Lookup+ForEach wave stages |

## Run #1 — FAILED (2026-04-14 13:56)

| Item | Value |
|------|-------|
| Status | **FAILED** at pl_sc_silver |
| Error | `BadRequest` — SqlServerStoredProcedure calling usp_run_silver_dag (nested dynamic EXEC) |
| Fix | Changed silver pipeline from single SP orchestrator to Lookup+ForEach pattern |
| Note | Bronze completed successfully (18/18 SPs) |

---

## Issues Encountered & Fixes

### 1. Silver Until loop — BadRequest
**Problem**: Fabric Pipeline does not support `Until` activity (or has issues with SetVariable inside Until).
**Attempted**: Until + Lookup + ForEach + 2 SetVariables (next_wave, current_wave).
**Result**: Pipeline fails immediately with BadRequest on start.
**Fix**: Replace Until with **10 pre-built sequential Lookup+ForEach stages** (wave 0-9). Empty waves (no SPs) → Lookup returns empty → ForEach skips. Supports up to 10 waves without pipeline change.

### 2. Silver SP orchestrator — BadRequest
**Problem**: `meta.usp_run_silver_dag` uses `sp_executesql` to dynamically EXEC silver SPs. When called from Pipeline SqlServerStoredProcedure activity, the nested EXEC causes BadRequest.
**Fix**: Don't use SP orchestrator from pipeline. Use Lookup+ForEach pattern instead (pipeline directly calls each silver SP).

### 3. Bronze snapshot conflict — auto-retry
**Problem**: Some bronze SPs fail with "Snapshot isolation transaction aborted due to update conflict" when multiple SPs run in parallel (batch=8) and DROP+CTAS on overlapping Parquet files.
**Fix**: Pipeline retry policy (retry=2, 30s interval) handles this automatically. All SPs eventually succeed after 1-2 retries.

### 4. Demandforecast incremental — 0 new rows
**Problem**: `brz_supplychain_enh_1__demandforecastsnapshotdaily` returned 0 rows on pipeline run.
**Reason**: Incremental load checks `ts_snapshot > last_watermark`. No new data since last manual load. Expected behavior — not an error.

---

## Final Silver Pipeline Architecture (after fixes)

```
pl_sc_silver (21 activities):
  [1] SP: EXEC meta.usp_compute_slv_waves
  [2] Lookup wave 0 → ForEach batch=8 (PARALLEL)
  [3] Lookup wave 1 → ForEach batch=8 (PARALLEL)
  [4] Lookup wave 2 → ForEach batch=8 (PARALLEL)
  [5-11] Lookup wave 3-9 → ForEach (empty, skip)

  Total: 1 SP + 10 Lookup + 10 ForEach = 21 activities
  Sequential between waves. Parallel within waves.
  Scales to 10 DAG waves. Beyond 10: add more stages.
```
