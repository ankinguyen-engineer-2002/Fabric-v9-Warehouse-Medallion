# 10 — Bronze Layer

> **Status:** Skeleton — Bronze source mapping TBD during scoping phase.

## Pattern (same as forecast)

Logical Bronze = OneLake shortcuts in `Enterprise_Lakehouse` aggregator pointing to `EnterpriseData-Dev` (hub) source data. Zero storage cost, no duplication.

Exception: 4 EDW supplement tables may also be needed (similar to `forecast/Staging_Wrk` pattern) if inventory source data is not yet in shortcut form.

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
