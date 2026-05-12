# 10 — Bronze Layer

> **Status:** Skeleton — Bronze source mapping TBD during scoping phase.

## Pattern (same as forecast)

Logical Bronze = OneLake shortcuts in `Enterprise_Lakehouse` aggregator pointing to `EnterpriseData-Dev` (hub) source data. Zero storage cost, no duplication.

Exception: **6 logical entries (5 physical dataflows)** pull EDW data into `SupplyChain_Lakehouse.dbo.*` because hub source is missing or dead-column. Full setup guide: [dataflow_setup.md](dataflow_setup.md).

## Source mapping summary (from `InventoryHealth_Source_KPI_Mapping.xlsx`)

| Status | Count | Action |
|--------|------:|--------|
| Mapped (trùng tên xi) | 13 | Direct shortcut from `Enterprise_Lakehouse` |
| Renamed (cột y chang) | 11 | Map alias in Silver view |
| Schema có / data thiếu | 4 | **Dataflow reload** to `SupplyChain_Lakehouse.dbo.*` |
| Chưa có | 2 | **Dataflow load mới** to `SupplyChain_Lakehouse.dbo.*` |
| Out of scope | 1 | Phase 2 (Excel `SS vs Capacity Projections.xlsx`) |
| **Total** | **31** | **6 logical / 5 physical dataflows** (3 P0 + 2 P1 + 1 P2) |

## Candidate sources (TBD — verify with Bob/Cherry)

| Hub source (planned) | Schema | Type | Use |
|---------------------|--------|------|-----|
| `Source_Data.SupplyChain_Enh_1.InventorySnapshotDaily` | Bronze | shortcut | Daily on-hand inventory |
| `Source_Data.SupplyChain_Enh_1.InventoryMovement` | Bronze | shortcut | Stock movement events |
| `Source_Data.Wholesale_Codis_AFI.COMAST` (reuse) | Bronze | shortcut | Customer master for stockout context |
| `Source_Data.Wholesale_Codis_AFI.WAREHOUSE` | Bronze | shortcut | Warehouse master (reuse from forecast) |
| `EnterpriseData-Dev.SupplyChain_Warehouse.InventoryHistory_AFI` (if Bob creates) | Silver-shared | shortcut | Possible promote target |

## EDW supplement (if needed)

If hub doesn't have current inventory in shortcut form, create temporary Staging_Wrk tables:

| Table | Source EDW | Pattern | Notes |
|-------|------------|---------|-------|
| `Staging_Wrk.InventorySnapshotEdw` | TBD | `overwrite` initially → `incremental` when stable | Daily snapshot, large |
| `Staging_Wrk.InventoryMovementEdw` | TBD | `incremental` | Append-only event log |

ADR-002 (EDW Supplement Exit Strategy) covers retirement path when Enterprise_Lakehouse data becomes complete.

## TBD

- [ ] Confirm source location with Cherry (legacy v8 inventory pipelines may exist already)
- [ ] Check if `EnterpriseData-Dev.SupplyChain_Warehouse` proposal (Bob Q3 pending) will include inventory
- [ ] Decide shortcut vs EDW supplement for each candidate source
