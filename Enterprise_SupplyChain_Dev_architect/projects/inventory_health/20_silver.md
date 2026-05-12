# 20 — Silver Layer

> **Status:** Skeleton — schema + table list TBD during scoping.

## Planned schemas

3 new domain schemas in `SupplyChain_Processing_Warehouse`, following Bob-aligned naming (`_Enh` PascalCase per ADR-008).

### `InventoryHistory_Enh`

Daily inventory snapshot enrichment.

| Table | Pattern | Source | Notes |
|-------|---------|--------|-------|
| `InventoryDailySnapshot` | `daterange` (30-day window) | `Staging_Wrk.InventorySnapshotEdw` or shortcut | One row per item × warehouse × date |
| `InventoryWeeklyAgg` | `overwrite` (derived) | `vw_InventoryDailySnapshot` | Weekly rollup for reporting |

### `InventoryMovementHistory_Enh`

Stock movement events.

| Table | Pattern | Source | Notes |
|-------|---------|--------|-------|
| `MovementEventLevel` | `incremental` (watermark: MovementTS) | `Staging_Wrk.InventoryMovementEdw` | Append-only |
| `MovementMonthlyAgg` | `overwrite` | `vw_MovementEventLevel` | Monthly net change per item/location |

### `StockoutHistory_Enh`

Derived stockout / backorder signals.

| Table | Pattern | Source | Notes |
|-------|---------|--------|-------|
| `StockoutEvents` | `overwrite` | join(`InventoryDailySnapshot`, `OpenOrderLineLevel`, `ActualDemandMonthly`) | Cross-mart join (forecast SalesHistory + this) |

## Cross-mart dependency

`StockoutHistory_Enh.StockoutEvents` reads from `forecast/`'s `SalesHistory_Enh.ActualDemandMonthly` + `OpenOrderHistory_Enh.OpenOrderLineLevel`. This creates a cross-mart edge in lineage — needs `depends_on` set in `Meta.AssetRegistry`.

## Naming convention (ADR-008 reminder)

- Tables: PascalCase (`InventoryDailySnapshot`, `MovementEventLevel`)
- Columns: PascalCase (`ItemSKU`, `WarehouseCode`, `OnHandQty`, `InTransitQty`, `SnapshotDT`, `LoadDT`)
- Views: `v_*` prefix (e.g., `v_InventoryDailySnapshot`)
- All tables get mandatory `LoadDT DATETIME2(6)` column

## TBD

- [ ] Confirm `MovementType` enum (Receipt / Shipment / Transfer / Adjust / Cycle)
- [ ] Stockout definition (zero on-hand AND open demand? Or include safety stock threshold?)
- [ ] Reusable Dims from `ForecastAccuracy_DW` (DimProduct, DimCalendar, DimWarehouse) — share or separate copy?
- [ ] Watermark column for incremental on `MovementEventLevel`
