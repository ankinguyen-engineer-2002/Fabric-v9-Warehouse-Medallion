# 50 — Semantic Model

> **Status (updated 2026-05-22):** LIVE post-cleanup. TMDL + DAX measures simplified. Schema = `InventoryHealth_DW`. DirectLake binding pointing to `SupplyChain_Gold_Warehouse.InventoryHealth_DW`.
>
> **2026-05-22 change**: Removed `DimRuleVersion` table + 2 relationships + simplified `Active Rule Version` DAX measure (hardcoded "InventoryHealth_BRD_v1"). Versioning approach: when BRD updates → create new semantic model `sc_inventory_health_control_tower_v2` rather than versioning via dim. RuleVersionKey columns also removed from both Fact tables.

## Model

| Item | Value |
|---|---|
| Model name | `sc_inventory_health_control_tower` |
| Workspace | `SupplyChain Dev` (`c8d9fc83-...`) |
| Mode | Direct Lake on OneLake |
| Source warehouse | `SupplyChain_Gold_Warehouse` (`98e2a911-...`) |
| Source schema | `InventoryHealth_DW` |
| Culture | en-US |
| User-facing tables | **6** (4 Dims + 2 Facts) — was 7 pre-cleanup |
| Hidden tables | 1 (`CogsRollingHelper`) |
| Measures | 30 DAX |

## Tables (TMDL bindings, all `schemaName: InventoryHealth_DW`)

| TMDL table | DirectLake → Gold table | Role |
|---|---|---|
| `DimCalendar` | **`ForecastAccuracy_DW.DimCalendar`** (cross-schema, **single shared dim**) | Date dim. **2026-05-22**: rebind from `InventoryHealth_DW.DimDate` (dropped) → ForecastAccuracy_DW.DimCalendar with TMDL column aliases (DateKey→DateSK, FiscalMonth→FSCMonthNum, etc.). DAX unchanged. |
| `DimItem` | `InventoryHealth_DW.DimItem` | Item dim + LifecycleStatus |
| `DimWarehouse` | `InventoryHealth_DW.DimWarehouse` | Warehouse dim + B3 flags |
| `DimVendor` | `InventoryHealth_DW.DimVendor` | Vendor dim (Phase 1: 2 cols) |
| ~~`DimRuleVersion`~~ | ~~`InventoryHealth_DW.DimRuleVersion`~~ | **REMOVED 2026-05-22** — versioning via new model when BRD changes |
| `CogsRollingHelper` | `InventoryHealth_DW.CogsRollingHelper` | Hidden — joined to FactInventoryHealthSnapshot internally |
| `FactInventoryHealthSnapshot` | `InventoryHealth_DW.FactInventoryHealthSnapshot` | Primary fact (current + weekly snapshots) |
| `FactInventoryRiskForward` | `InventoryHealth_DW.FactInventoryRiskForward` | Forward-looking fact (Week 1-4) |

## Relationships (7 active, was 9 pre-cleanup)

```
DimCalendar.DateKey            → FactInventoryHealthSnapshot.DateKey
DimCalendar.DateKey            → FactInventoryRiskForward.DateKey
DimItem.ItemSku            → FactInventoryHealthSnapshot.ItemSku
DimItem.ItemSku            → FactInventoryRiskForward.ItemSku
DimWarehouse.WarehouseCode → FactInventoryHealthSnapshot.WarehouseCode
DimWarehouse.WarehouseCode → FactInventoryRiskForward.WarehouseCode
DimVendor.VendorNumber     → DimItem.PrimaryVendorNumber  (snowflake)
// DimRuleVersion → FactInventoryHealthSnapshot   [REMOVED 2026-05-22]
// DimRuleVersion → FactInventoryRiskForward      [REMOVED 2026-05-22]
```

## DAX measures (30 total — see [semantic/Measures_DAX.dax](semantic/Measures_DAX.dax))

Coverage: 26 of 30 BRD KPIs (4 Phase 2 deferred — Used Storage Cube physical, Total Available WH Cube, etc.).

| Group | Measures (KPI ref) |
|---|---|
| Base supply | Total On Hand Qty, Transfer InTransit Qty, PO In Transit Qty, PO On Order Qty, MO On Order Qty (KPI #1–5) |
| Demand & coverage | Allocated Demand Qty, Forecast Demand Qty 13W, AWD (M5 fix — COUNTROWS SUMMARIZE), Weeks Of Supply (KPI #6–8) |
| Financial | Inventory Value at Cost, Weighted Standard Cost, Std Selling Price Avg, Total COGS, COGS 52M Trailing (M3 fix), Inventory Turns (KPI #9–12, 22) |
| Physical | Used Storage Cube, Total Available WH Cube (Phase 2 KPI #13–14) |
| Safety/Inactive/SLOB | Safety Stock Target, Inactive Item Count, SLOB Item Count, SLOB Value (M4 fix) (KPI #16–18) |
| Risk forward | Revenue at Risk W4 (H5 fix), ATP In Stock Rate (Week 2), Shippable In Stock Rate (KPI #19, 23–24) |
| Other | Safety Stock Multiple, Obsolete Ratio (KPI #25–30) |

## Schema rewrite applied (deliverable v1 → v10)

All 7 `partition <table>-prt = entity { schemaName: gold }` declarations rewritten to `schemaName: InventoryHealth_DW`. Verify:
```bash
grep -c "schemaName: gold" semantic/SemanticModel.tmdl              # → 0
grep -c "schemaName: InventoryHealth_DW" semantic/SemanticModel.tmdl # → 7
```

DAX measure expressions reference table names (not schemas) → no DAX rewrite required.

## Deploy

1. Open Power BI Desktop → "New report" → "Direct Lake on OneLake"
2. Point to workspace `SupplyChain Dev` → warehouse `SupplyChain_Gold_Warehouse`
3. Select 8 tables from `InventoryHealth_DW` schema
4. Apply TMDL via Tabular Editor (preferred) OR define manually mirroring `SemanticModel.tmdl`
5. Paste 30 measures from `Measures_DAX.dax`
6. Refresh dataset — should complete in seconds (Direct Lake, no row import)
7. Smoke test: render 7 critical KPIs (Total On Hand, IVC, AWD, Revenue at Risk W4, ATP rate, SLOB Value, Inventory Turns)
