# 50 — Semantic Model

> **Status:** Skeleton — semantic model design TBD post-Gold.

## Planned model

| Attribute | Value |
|-----------|-------|
| Name (proposed) | `sc_inventory_health` |
| Mode | Direct Lake (per ADR-001) |
| Source WH | `SupplyChain_Gold_Warehouse` (`98e2a911-...`) |
| Source schema | `InventoryHealth_DW` |
| Tables exposed (planned) | 3 Fact + 4-5 Dim + 1 measure table |
| Storage format | TMDL (per ADR-008) |

## Measures (TBD — proposed)

| Measure | Definition (rough) | Use case |
|---------|--------------------|----------|
| `On-Hand Qty` | SUM(FactInventorySnapshot[OnHandQty]) | Current stock level |
| `Days of Supply` | OnHand / AvgDailyDemand | Coverage indicator |
| `Stockout Days` | COUNT(StockoutEvent) per item | Stockout frequency |
| `Inventory Turnover` | COGS / AvgInventory | Operating efficiency |
| `Excess Stock %` | (OnHand - SafetyStock) / OnHand WHERE OnHand > Reorder | Excess flag |
| `Slow Moving Flag` | MovementCount last 90d < threshold | Slow-mover detection |

## Cross-model relationship (if Dims shared)

If `DimCalendar` / `DimProduct` / `DimWarehouse` are physically shared with `sc_forecast_control_tower`:
- Composite model (cross-source group) — not Direct Lake compatible
- OR duplicate dim in `InventoryHealth_DW` (Direct Lake compatible, simpler)

Bob standards prefer dedicated star per mart → likely **duplicate dim**.

## RLS (TBD)

Same `All_Permission` role pattern as `sc_forecast_control_tower`, or restrict by `DimWarehouse.Region` for regional teams.

## TBD

- [ ] Confirm cross-model strategy (composite vs duplicate dim)
- [ ] Final measure list — work with BI consumer (Cherry's team)
- [ ] RLS scope
- [ ] Deploy via Fabric `createSemanticModel` API (same pattern as forecast)
- [ ] Refresh schedule
