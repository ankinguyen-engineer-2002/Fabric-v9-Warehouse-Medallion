# 60 — Lineage

> **Status:** Skeleton — lineage auto-builds from `Meta.AssetRegistry.source_objects` once registry rows added.

## Pattern (reuse from forecast)

Lineage = directed graph of `(source_asset → target_asset, edge_type)` stored in `Meta.LineageEdge`. Auto-built via `Meta.usp_BuildLineage`:

```sql
-- 1. DELETE direct + derived edges (semantic edges preserved)
DELETE FROM Meta.LineageEdge WHERE edge_type IN ('direct','derived');

-- 2. INSERT from registry.source_objects (JSON array)
INSERT INTO Meta.LineageEdge
SELECT
  CONCAT('lineage::', ROW_NUMBER() OVER (...)),
  TRIM(src.value),  -- source from JSON
  r.asset_id,       -- target from registry
  'direct',
  r.load_type,
  0, SYSUTCDATETIME()
FROM Meta.AssetRegistry r
CROSS APPLY STRING_SPLIT(r.source_objects, ',') src;
```

## Estimated edges (TBD)

When `inventory_health` is fully registered:
- ~10-15 direct edges (per Silver/Gold asset source mapping)
- ~3-5 semantic edges (Gold → `sc_inventory_health` model)
- Total estimated: **+15-20 edges** on top of current 60 (forecast).

## Cross-mart edges

`StockoutHistory_Enh.StockoutEvents` will have multi-source `source_objects`:

```json
[
  "InventoryHistory_Enh.InventoryDailySnapshot",
  "OpenOrderHistory_Enh.OpenOrderLineLevel",
  "SalesHistory_Enh.ActualDemandMonthly"
]
```

This creates cross-mart edges visible in Streamlit lineage app — important for impact analysis (if `ActualDemandMonthly` fails, both forecast + inventory_health affected).

## Bridge edges (EDW supplement, if applicable)

If `Staging_Wrk.InventorySnapshotEdw` is used (vs direct shortcut), add render-time bridge edge `SupplyChain_Lakehouse._edw → Staging_Wrk.*` (same pattern as 4 existing forecast EDW bridges, defined in `lineage_explorer/app.py` `load_augmented_lineage_rows`).

## TBD

- [ ] Confirm final source_objects per asset (depends on Silver design)
- [ ] Cross-mart dependency graph diagram (Mermaid)
- [ ] Update Streamlit app `load_augmented_lineage_rows` if new EDW supplements added
