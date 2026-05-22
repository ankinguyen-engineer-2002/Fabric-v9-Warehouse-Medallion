# 40 — Pipelines

> **Status:** No new pipelines required. Inventory Health is fully orchestrated by the existing 7 v10 pipelines via registry-driven multi-mart ForEach.

## How inventory_health joins the multi-mart flow

`pl_sc_master` runs `SELECT DISTINCT project FROM Meta.AssetRegistry WHERE is_active=1` → ForEach project → invoke `pl_sc_mart(project_name)`. After inserting 33 rows with `project='inventory_health'` into the registry, `pl_sc_master` automatically picks `inventory_health` alongside `forecast` on next trigger.

## Existing 7 pipelines (reused as-is)

| # | Pipeline | ID | Role for inventory_health |
|---|----------|----|---|
| 1 | `pl_sc_master` | `f36f56b8-5668-4a0c-b991-2c28302f1710` | Master orchestrator — auto-picks `inventory_health` via ForEach |
| 2 | `pl_sc_mart` | `20db5725-80e3-4081-9ef5-01700acdf3b3` | Per-project router — runs Staging→Silver→Gold sequentially per project |
| 3 | `pl_sc_staging` | `10221fb2-6e30-4911-9d95-d8dd67440d84` | Staging + ReferenceMaster load — runs `Meta.usp_GenericLoad` for `Vendor` |
| 4 | `pl_sc_silver` | `7dc6ecda-56cc-4797-893c-1c502863323f` | Silver DAG dispatcher — invokes wave executor 3-4 times |
| 5 | `pl_sc_silver_wave` | `797b1a02-f973-4584-bd27-bb0151549d4b` | Parallel batch=8 executor per wave |
| 6 | `pl_sc_gold` | `50ff6263-659d-4b09-9e45-b42a3434e093` | Cross-DB CTAS for 8 InventoryHealth_DW tables |
| 7 | `pl_dq_check` | `3c7c61f6-c184-41e5-8309-f9ac3260d38d` | DQ rule gate (run separately or on-demand) |

## Expected runtime (estimated, post-deploy)

Based on forecast's ~31 min for ~420M rows and similar data volume:

| Stage | Estimated duration | Notes |
|---|---:|---|
| Staging (Vendor REF) | ~1 min | small master |
| Silver Wave 0 (12 base + 2 master ext) | ~10-15 min | parallel batch=8 |
| Silver Wave 1 (2 weekly snapshots) | ~5-8 min | depends on ItemBalance availability |
| Silver Wave 2 (4 helpers) | ~3-5 min | parallel; CROSS JOIN AsOfDate × Item×WH |
| Silver Wave 3 (4 self-snapshots) | ~2 min | datekey insert-today only |
| Gold cross-DB CTAS (8 InventoryHealth_DW) | ~5-8 min | FactInventoryHealthSnapshot largest |
| **Total inventory_health window** | **~25-40 min** | sequential after forecast (~31 min) |

## DAG topology (in pl_sc_silver_wave)

`Meta.usp_ComputeSilverWaves` reads `depends_on` from registry rows. Expected DAG for inventory_health:

```
Wave 0 (3 active post-cleanup): ForecastSnapshotWeekly, ItemBalanceHistorical, SalesShipment
Wave 1 (8 active): AwdHelper, HoldingTransferSnapshotDaily, InventorySnapshotWeekly,
        LastInvoiceHelper, LogilityItemStatusSnapshotWeekly ⏸ (deactivated 2026-05-22),
        ManufacturingOrderSnapshotDaily, MovementFlagHelper, PurchaseOrderSnapshotDaily
Wave 2 (1 active): SafetyStockHelper
```

**2026-05-22 cleanup**:
- DROPPED `MovementHistory`, `ForecastCurrent` (Wave 0, view-only, orphan)
- DEACTIVATED `LogilityItemStatusSnapshotWeekly` (Wave 1, Phase 2 conditional — pl_sc_master skips when is_active=0)

(Authoritative wave assignments from `Meta.SilverDagWaveRuntime` — see live snapshot.)

## Smart skip + scheduling

Per-asset `cron_expression` in registry:
- Daily masters / base / snapshots: `0 2 * * *` (02:00 UTC)
- Monthly masters (Vendor): `0 3 1 * *`
- Weekly snapshots (Logility, weekly forecasts): `0 6 * * 6` (Saturday)
- Helpers: `0 3 * * *`
- Self-snapshots: `0 4 * * *`
- Gold: `0 5 * * *`
- Monthly Gold dims (DimDate, DimItem, DimWarehouse, DimVendor): `0 3 1 * *`

`Meta.ufn_should_run(asset_id)` evaluates `cron_expression` vs UTC now; out-of-window assets are skipped.

## Deploy sequence (when ready)

1. `silver_views.sql` → Processing WH
2. `gold_views.sql` → Gold WH
3. `registry_inserts.sql` → Processing WH (Meta schema)
4. `dq_rules_inserts.sql` → Processing WH (Meta schema)
5. `EXEC Meta.usp_ComputeSilverWaves;`
6. `EXEC Meta.usp_BuildLineage;`
7. Manually trigger `pl_sc_master` via Fabric portal → verify both `forecast` + `inventory_health` runs.
