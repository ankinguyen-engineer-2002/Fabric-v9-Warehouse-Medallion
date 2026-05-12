# 30 — Gold Layer

> **Status:** Skeleton — Fact/Dim count TBD during scoping.

## Pattern (same as forecast)

Dedicated Gold serving in `SupplyChain_Gold_Warehouse` (Direct Lake target). New schema `InventoryHealth_DW`. Cross-DB CTAS from Silver via `usp_GenericLoad` Gold pipeline.

## Planned star schema

### Fact tables

| Table | Grain | Key dims | Source Silver |
|-------|-------|----------|---------------|
| `FactInventorySnapshot` | item × warehouse × snapshot_date | DimProduct, DimWarehouse, DimCalendar | `InventoryHistory_Enh.InventoryDailySnapshot` |
| `FactInventoryMovement` | movement event | DimProduct, DimWarehouse, DimCalendar, DimMovementType | `InventoryMovementHistory_Enh.MovementEventLevel` |
| `FactStockoutEvent` | item × warehouse × stockout_date | DimProduct, DimWarehouse, DimCalendar, DimCustomerGrouping | `StockoutHistory_Enh.StockoutEvents` |

### Dim tables (mostly reuse from `ForecastAccuracy_DW`)

| Dim | Reuse from forecast? | Notes |
|-----|----------------------|-------|
| `DimCalendar` | ✅ Reuse (75 cols, 21,551 rows) | Cross-DB read from `ForecastAccuracy_DW` OR duplicate (decide based on Bob Q2) |
| `DimProduct` | ✅ Reuse (89 cols, 379K rows) | Same as DimCalendar — share or copy |
| `DimWarehouse` | ✅ Reuse (8 cols, 55 rows) | Same |
| `DimCustomerGrouping` | ✅ Reuse (1 col, 35K rows) | Only needed for FactStockoutEvent |
| `DimMovementType` | NEW — small lookup (5-10 rows) | New table for this mart |

## Cross-DB Gold pipeline (reuse)

Existing `pl_sc_gold` is registry-driven — no code change needed. Add rows to `Meta.AssetRegistry` with:
- `project = 'inventory_health'`
- `canonical_layer = 'Gold'`
- `physical_workspace = c8d9fc83-...`
- `physical_item = SupplyChain_Gold_Warehouse`
- `physical_schema = InventoryHealth_DW`
- `source_objects` = JSON array of Silver source views

Pipeline ForEach DISTINCT project auto-picks `inventory_health` next run.

## TBD

- [ ] Decide DimCalendar/DimProduct: share via cross-DB query, or duplicate physical copy (latency vs simplicity tradeoff)
- [ ] Cross-mart Dim shared schema name: keep `ForecastAccuracy_DW.Dim*` or promote to `SharedDims_DW`?
- [ ] Direct Lake compatibility check (no view-on-view chains in Gold per Bob standards)
- [ ] Star schema lint per `tools/stability_scan_gold.py`
