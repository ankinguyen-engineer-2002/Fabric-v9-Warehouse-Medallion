# Open Questions for Bob — `inventory_health` mart

> **Status:** Draft — to be folded into next email round once scoping clearer.

## Q1 — Source data location *(scoped via internal mapping 2026-05-12)*

**Partially resolved** — see `InventoryHealth_Source_KPI_Mapping.xlsx` sheet `EDW_vs_Lakehouse` (46 rows): source EDW tables already mapped to Lakehouse equivalents (`Mapped` / `Renamed` / `Missing` status).

Still pending Bob:
- Confirm whether the Lakehouse sources are in `Source_Data.SupplyChain_Enh_1.*` shortcut form OR require EDW supplement (Staging_Wrk pattern same as forecast)
- For `Missing` rows in the spreadsheet — does hub have them or do we add via shortcut/supplement?

Tag: source-discovery · Partially scoped, still needs Bob confirmation per-row for `Missing` items.

## Q2 — Shared Dims promote pattern

`inventory_health` will reuse `DimProduct` / `DimWarehouse` / `DimCalendar` from `forecast/ForecastAccuracy_DW`. Three options:
- **a)** Duplicate physical copy in `InventoryHealth_DW` (Direct Lake friendly, no cross-DB latency)
- **b)** Cross-DB query from `forecast` Gold (composite model, NOT Direct Lake)
- **c)** Promote shared Dims to `EnterpriseData-Dev.MasterData_DW` (Bob's pattern, both marts read from hub)

Bob's preference?

Tag: architecture-decision · Cross-mart concern.

## Q3 — Stockout definition

What's the canonical stockout definition Ashley uses?
- Zero on-hand only?
- Zero on-hand AND open demand exists?
- On-hand below safety stock threshold?

Cherry's existing v8 SCP_Core may have this — need to inspect (FORBIDDEN to touch per Aric scope rule, so via Cherry's review).

Tag: business-logic · Owner: Cherry + Bob.

## Q4 — Movement event grain

Hub data — is movement at:
- Header level (1 row per transfer document) → join header+detail
- Detail line level (1 row per item per movement) → direct use

Affects Silver schema design.

Tag: data-modeling.

## Next step

Once Q1-Q4 answered (or scoped via Cherry's intel on v8 patterns), proceed to:
1. Update 10_bronze.md / 20_silver.md with concrete table names
2. Generate DDL in etl/
3. Add rows to Meta.AssetRegistry
4. First end-to-end run
