# inventory_health — Inventory Health Mart

> **Status:** PLANNED (skeleton scaffold created 2026-05-12) · **Gold schema:** `InventoryHealth_DW` (planned)

## What

End-to-end Inventory Health analytics mart on Microsoft Fabric. Will combine on-hand inventory snapshots, in-transit, safety stock, slow/excess thresholds, and stockout signals into a unified Gold serving layer for Power BI Direct Lake reporting.

> Layout mirrors `forecast/` project exactly. Files currently scaffold-only — concrete data fills in during build phase.

## Planned infrastructure (target)

| Item | Value |
|------|-------|
| Workspace DEV | `c8d9fc83-18b6-4e1d-8264-0b49eed36fe0` (same as `forecast/`) |
| Processing WH | `c0262cef-b8a7-495f-bccc-53b098c7948c` (extend with new Silver schemas) |
| Gold WH | `98e2a911-5af9-442e-9cc8-5d8dadb8b762` (add `InventoryHealth_DW` schema) |
| New Silver schemas (planned) | `InventoryHistory_Enh`, `InventoryMovementHistory_Enh`, `StockoutHistory_Enh` |
| Gold schema | `InventoryHealth_DW` (Fact + Dim — count TBD) |
| Semantic model | TBD — naming proposal: `sc_inventory_health` |
| Naming convention | Bob-aligned per ADR-008: `_Enh`/`_Wrk` (PascalCase), `v_*` view prefix, `_DW` ALL CAPS for Gold |
| Control plane | Reuse existing `Meta.*` (TableDictionary, AssetRegistry, AuditLog, RunLog) |

## Quick links (skeleton — content TBD)

| Section | Doc |
|---------|-----|
| Workspace + IDs | [00_workspace.md](00_workspace.md) |
| Bronze layer | [10_bronze.md](10_bronze.md) |
| Silver layer (per schema) | [20_silver.md](20_silver.md) |
| Gold layer | [30_gold.md](30_gold.md) |
| Pipelines (IDs + DAG) | [40_pipelines.md](40_pipelines.md) |
| Semantic model | [50_semantic.md](50_semantic.md) |
| Lineage | [60_lineage.md](60_lineage.md) |
| ETL DDL | [etl/](etl/) |
| Open questions for Bob | [_open_questions_for_bob.md](_open_questions_for_bob.md) |

## Build phases (planned)

| Phase | Goal | Status |
|-------|------|--------|
| 1. Scope + source mapping | Identify EDW / Enterprise Lakehouse source tables for inventory snapshots | Not started |
| 2. Bronze surface | Add 4 EDW supplement tables OR shortcut from `Enterprise_Lakehouse.SupplyChain_DW` | Not started |
| 3. Silver schemas | DDL + CTAS views in 3 new domain schemas | Not started |
| 4. Gold star schema | Fact + Dim in `InventoryHealth_DW` | Not started |
| 5. Pipeline wiring | Register assets in `Meta.AssetRegistry` (project=`inventory_health`) — multi-mart ForEach auto-picks | Not started |
| 6. Semantic model | TMDL + Direct Lake deploy | Not started |
| 7. Lineage refresh | `usp_BuildLineage` regenerates edges from registry | Not started |
| 8. Pipeline run + DQ | First end-to-end + DQ gates active | Not started |

## Dependencies

- Same control plane (`Meta.*`) as `forecast/` — no new SP needed (registry-driven generic load handles all 8 patterns)
- Multi-mart routing in `pl_sc_master` ForEach picks up `project='inventory_health'` automatically once registry rows added
- May need new EDW supplement tables in `Staging_Wrk` if source not in Enterprise_Lakehouse shortcut

## References

- Parent index: [../README.md](../README.md)
- Sibling project: [`forecast/`](../forecast/) — LIVE reference implementation
- v10 architecture: [ADR-001](../../../docs/decisions/ADR-001-v10-hybrid-medallion.md)
- Bob alignment: [ADR-008](../../../docs/decisions/ADR-008-bob-alignment-naming-and-integration.md)
