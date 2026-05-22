# 20 — Silver Layer

> **Status (updated 2026-05-19):** CODE-AUTHORED + source-path migration applied. 1 NEW in ReferenceMaster_Enh + 24 NEW in InventoryHistory_Enh. Naming: PascalCase, view prefix `v_*`, all per ADR-008 Bob alignment. **3 source switches** post-Dhivya load: `v_PurchaseOrder` LEFT JOIN → EL.PoMaster; `v_LogilityItemStatus` FROM → EL.Logility + new dedupe heuristic; `v_LogilityItemStatusSnapshotWeekly` SourceSystem updated.

## Schemas

| Schema | Layer | New for inventory_health? | Count |
|---|---|---|---:|
| `ReferenceMaster_Enh` | ReferenceMaster | +1 NEW (Vendor) | 1 |
| `InventoryHistory_Enh` | DomainSilver | NEW SCHEMA | 24 |

Total: 25 new Silver assets.

## §A. ReferenceMaster_Enh — 1 NEW

| Asset | View | Load type | Source |
|---|---|---|---|
| `Vendor` | `v_Vendor` | overwrite (monthly) | `Enterprise_Lakehouse.Purchasing_AFI.VendorMaster` (51 cols, 86.6K rows) |

REUSED from existing ReferenceMaster_Enh (do NOT recreate):
- `ItemMaster` (sources `MasterData_DW.DimItemMaster`)
- `Warehouse` (sources `SupplyChain_DW.DimAFIWarehouses`)
- `Calendar` (sources `MasterData_DW.DimDate`)

## §B. InventoryHistory_Enh — Master extensions (2 NEW views over existing reuses)

| Asset | View | Load type | Base reuse | Extensions added |
|---|---|---|---|---|
| `ItemMasterExt` | `v_ItemMasterExt` | overwrite (monthly) | `ReferenceMaster_Enh.ItemMaster` | `PrimaryVendorName` (JOIN VendorMaster) + `UnavailableFlag` (MAX MFPUS='U' from ITBEXT) |
| `WarehouseExt` | `v_WarehouseExt` | overwrite (monthly) | `ReferenceMaster_Enh.Warehouse` | B3 fix flags: `IsExcludedDirectCustomerRP`, `IsNetworkInventoryWarehouse`, `TotalAvailableWarehouseCube` |

## §C. InventoryHistory_Enh — Tier 1 base (12 views)

| Asset | View | Load type | Watermark / Key | Source(s) | Track A fix |
|---|---|---|---|---|---|
| `CostCurrent` | `v_CostCurrent` | overwrite (daily) | PK: ItemSku | ITMRVA (STID='000') | — |
| `InventoryCurrent` | `v_InventoryCurrent` | datekey (daily) | PK: (ItemSku,WarehouseCode,SnapshotDate) | ITEMBL | **H3** (FG-only) + **B3** (WH exclusion) |
| `SupplyPlan` | `v_SupplyPlan` | overwrite (daily) | PK: composite | SupplyPlanDetail | — |
| `SalesShipment` | `v_SalesShipment` | incremental | wm: InvoiceDate · PK: (InvoiceNumber,ItemSequence) | InvoiceDetail | — |
| `PurchaseOrder` | `v_PurchaseOrder` | overwrite (daily) | PK: (PoNumber,PoLine,**VendorNumber**) | EL.PoDetail (21.95M) + EL.PoMaster (5.69M) | **B1** (EL PoDetail) + **B1.2** (EL PoMaster, switched 2026-05-19) + **B3** (WH exclusion); 1 true-row-dup handled by ROW_NUMBER; **D3.2 (2026-05-19)**: PK includes VendorNumber — source reuses (PoNumber,PoLine) across vendors (1 real PO + 1 SAMPLE PO) |
| `ManufacturingOrder` | `v_ManufacturingOrder` | overwrite (daily) | PK: (MoNumber,ItemSku,WarehouseCode) | MOMAST | — (L3 pending Robert) |
| `LogilityItemStatus` | `v_LogilityItemStatus` | overwrite (weekly) | PK: composite | EL.SupplyChain_Enh.DemandFulfillmentCommonContainer_Logility (38.36M, switched 2026-05-19) | **A3** RESOLVED + **D1** dedupe (9,128 grain-conflict groups handled by demand-bearing prefer heuristic) |
| `HoldingTransfer` | `v_HoldingTransfer` | overwrite (daily) | PK: (TransferNumber,ItemSku) | TFRDTL + TFRHDR | — |
| `AtpWeekEnding` | `v_AtpWeekEnding` | overwrite (daily) | PK: (ItemSku,WarehouseCode,WeekNumber) | ATPSUM (UNPIVOT APAT01-43) | **H2** |
| `MovementHistory` | `v_MovementHistory` | incremental | wm: TransactionDate · PK: composite | IMHIST + DimDate | — |
| `AllocatedDemandCandidate` | `v_AllocatedDemandCandidate` | overwrite (daily) | PK: (OrderNumber,OrderLine) | OpenOrderDetail + OpenOrderHeader | **H1** (Robert pending) |
| `ForecastCurrent` | `v_ForecastCurrent` | overwrite (daily) | PK: (ItemSku,WarehouseCode,FiscalMonthYear) | DemandForecast (channel SUM) | **B2** |

## §D. InventoryHistory_Enh — Tier 2 snapshot history (2 views, incremental)

| Asset | View | Watermark | Source |
|---|---|---|---|
| `InventorySnapshotWeekly` | `v_InventorySnapshotWeekly` | SnapshotDate | EL.SupplyChain_Enh_1.DemandInventorySnapshotWeekly (stale 10w accepted Phase 1; ItemBalance promote pending Phase 2 — `df_brz_ItemBalance` workaround ready) |
| `ForecastSnapshotWeekly` | `v_ForecastSnapshotWeekly` | WeekEndingDate | DemandForecastSnapshotWeekly |

## §E. InventoryHistory_Enh — Tier 3 helpers (4 views, overwrite daily)

Grain: `(ItemSku, WarehouseCode, AsOfDate)` where AsOfDate = InventoryCurrent.SnapshotDate (last 7d) ∪ InventorySnapshotWeekly.SnapshotDate (last 104w).

| Asset | View | Purpose | Depends on |
|---|---|---|---|
| `AwdHelper` | `v_AwdHelper` | AWD = SUM(forecast 13W fwd)/13; fallback historical | InventoryCurrent, InventorySnapshotWeekly, ForecastSnapshotWeekly, SalesShipment |
| `LastInvoiceHelper` | `v_LastInvoiceHelper` | MAX(InvoiceDate) ≤ AsOfDate | SalesShipment |
| `MovementFlagHelper` | `v_MovementFlagHelper` | HasMovementLast17W boolean | SalesShipment |
| `SafetyStockHelper` | `v_SafetyStockHelper` | Carry SafetyStockTarget at AsOfDate | InventorySnapshotWeekly |

## §F. InventoryHistory_Enh — Tier 4 self-snapshots (4 views, datekey)

| Asset | View | Date key | Cron | Notes |
|---|---|---|---|---|
| `PurchaseOrderSnapshotDaily` | `v_PurchaseOrderSnapshotDaily` | SnapshotDate | daily 04:00 | depends on PurchaseOrder |
| `ManufacturingOrderSnapshotDaily` | `v_ManufacturingOrderSnapshotDaily` | SnapshotDate | daily 04:00 | depends on ManufacturingOrder |
| `HoldingTransferSnapshotDaily` | `v_HoldingTransferSnapshotDaily` | SnapshotDate | daily 04:00 | depends on HoldingTransfer |
| `LogilityItemStatusSnapshotWeekly` | `v_LogilityItemStatusSnapshotWeekly` | WeekEndingDate | weekly Sat 06:00 | depends on LogilityItemStatus |

## DAG (Silver) — wave computation

After registry insert, run `EXEC Meta.usp_ComputeSilverWaves`. Expected waves (computed from `depends_on`):

- **Wave 0** — masters + 12 Tier-1 bases (read directly from Bronze, no Silver deps)
- **Wave 1** — Tier-2 snapshots (depend only on Bronze)
- **Wave 2** — Tier-3 helpers (depend on Tier-1 + Tier-2)
- **Wave 3** — Tier-4 self-snapshots (depend on Tier-1 base tables)

Each wave runs sequentially; assets within a wave run in parallel (batch=8).

## Track A fix carry-over

All Silver-side Track A fixes preserved as inline comments in `etl/silver_views.sql`. Search the file for `H[0-9] FIX`, `M[0-9] FIX`, or `B[0-9] FIX` to verify.

## File reference

- [etl/silver_views.sql](etl/silver_views.sql) — 25 CREATE VIEW statements
- [etl/registry_inserts.sql](etl/registry_inserts.sql) — 25 Silver registry rows
- [etl/dq_rules_inserts.sql](etl/dq_rules_inserts.sql) — 20+ Silver DQ rules
