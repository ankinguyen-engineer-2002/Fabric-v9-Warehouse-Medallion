# 30 — Gold Layer

> **Status:** CODE-AUTHORED. 8 NEW assets in `InventoryHealth_DW` (Gold WH). Self-contained schema matching deliverable v1 TMDL semantic model.

## Schema

`InventoryHealth_DW` in `SupplyChain_Gold_Warehouse` (`98e2a911-...`).

Pattern: cross-DB CTAS via `pl_sc_gold` pipeline (registry-driven). Each Gold view reads Silver physical tables via 3-part name `[SupplyChain_Processing_Warehouse].[<schema>].[<table>]`.

## Star schema (matches deliverable v1)

```
                  DimDate ────┐
                  DimItem ────┤
              DimWarehouse ───┼── FactInventoryHealthSnapshot
                DimVendor ────┤        │
            DimRuleVersion ───┘        │
                                       │
                                       └─→ CogsRollingHelper (hidden, JOIN at view-time)

                  DimDate ────┐
                  DimItem ────┼── FactInventoryRiskForward
              DimWarehouse ───┤
            DimRuleVersion ───┘
```

## Assets (8 total)

### Dims (5)

| Asset | View | Source | Notes |
|---|---|---|---|
| `DimDate` | `v_DimDate` | `ReferenceMaster_Enh.Calendar` + IsCurrent flags computed | Subset of 80+ cols for inventory_health usage |
| `DimItem` | `v_DimItem` | `InventoryHistory_Enh.ItemMasterExt` + LifecycleStatus computed | LifecycleStatus = Active/Inactive/New/Discontinued |
| `DimWarehouse` | `v_DimWarehouse` | `InventoryHistory_Enh.WarehouseExt` | Includes B3 fix flags |
| `DimVendor` | `v_DimVendor` | `ReferenceMaster_Enh.Vendor` (NEW master) | 2-col Phase 1 (VendorNumber, VendorName) |
| `DimRuleVersion` | `v_DimRuleVersion` | manual seed | 1 row Phase 1: BRD v1 rule snapshot |

### Helper (1, hidden from semantic model)

| Asset | View | Notes |
|---|---|---|
| `CogsRollingHelper` | `v_CogsRollingHelper` | Monthly grain; 12M + 52M rolling sums. **H4 fix** (ORDER BY FiscalMonthYear) + **M3 fix** (Cogs52W → Cogs52M rename). Robert sign-off pending on weekly vs monthly grain. |

### Facts (2)

| Asset | View | Grain | Notes |
|---|---|---|---|
| `FactInventoryHealthSnapshot` | `v_FactInventoryHealthSnapshot` | `(ItemSku, WarehouseCode, SnapshotDate, SnapshotType)` where SnapshotType ∈ {Current, Weekly} | Pass 1 (base) + Pass 2 (rolling COGS) collapsed into single CTE-driven view (since `usp_GenericLoad` does CTAS only). **M4 fix** (SLOB NULL guard). |
| `FactInventoryRiskForward` | `v_FactInventoryRiskForward` | `(ItemSku, WarehouseCode, WeekEndingDate)` | Forward 4-week supply plan view. **H5 fix** (WeekFourFlag exact week). Robert sign-off pending. |

## Cross-mart reuse decisions

- **Source level**: REUSE `ReferenceMaster_Enh.ItemMaster/Warehouse/Calendar` (extension via `v_*Ext` views in Silver layer).
- **Semantic level**: DO NOT bind DirectLake to `ForecastAccuracy_DW.Dim*` because deliverable v1 designed DAX measures against inventory-specific column schemas. Keep Gold self-contained.
- Bob Q2 (DimCalendar/DimProduct cross-mart) — flagged in `_open_questions_for_bob.md`.

## Load orchestration

Gold tables get populated via `pl_sc_gold` pipeline (existing, registry-driven):

```sql
-- pl_sc_gold logic (excerpt)
SELECT physical_schema, physical_object, legacy_view_name
FROM Meta.AssetRegistry
WHERE canonical_layer='Gold' AND project=@project AND is_active=1
-- ForEach: DROP TABLE IF EXISTS [Gold].<schema>.<table>
--          CREATE TABLE [Gold].<schema>.<table> AS SELECT * FROM <legacy_view_name>
```

No code change needed in pipeline. After registry insert, next run picks `inventory_health` rows automatically.

## Track A fix carry-over (Gold-side)

| Fix | Location in v_* |
|---|---|
| **H4** ORDER BY FiscalMonthYear | `v_CogsRollingHelper` window OVER clauses |
| **H5** WeekFourFlag exact week | `v_FactInventoryRiskForward` WeekFourFlag column |
| **M3** Cogs52W → Cogs52M rename | `v_CogsRollingHelper` + propagated to TMDL/DAX |
| **M4** SLOB + ObsoleteValue NULL guard | `v_FactInventoryHealthSnapshot` SlobFlag + ObsoleteValue cases |

## File reference

- [etl/gold_views.sql](etl/gold_views.sql) — 8 CREATE VIEW statements
- [etl/registry_inserts.sql](etl/registry_inserts.sql) — 8 Gold registry rows
- [etl/dq_rules_inserts.sql](etl/dq_rules_inserts.sql) — 7 Gold DQ rules
- [semantic/SemanticModel.tmdl](semantic/SemanticModel.tmdl) — DirectLake binding (`schemaName: InventoryHealth_DW`)
