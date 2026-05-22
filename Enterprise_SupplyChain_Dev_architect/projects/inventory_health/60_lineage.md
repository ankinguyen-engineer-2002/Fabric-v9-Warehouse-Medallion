# 60 — Lineage

> **Status:** Lineage edges auto-built from `Meta.AssetRegistry.source_objects` after registry insert + `EXEC Meta.usp_BuildLineage`.

## How lineage works in v10

Each row in `Meta.AssetRegistry` carries a `source_objects` JSON array listing upstream entities. `Meta.usp_BuildLineage` runs `STRING_SPLIT` on each row to produce direct lineage edges in `Meta.LineageEdge`:

```sql
INSERT INTO Meta.LineageEdge (source_asset, target_asset, edge_type, transform_type, ...)
SELECT TRIM(src.value), r.asset_id, 'direct', r.load_type, ...
FROM Meta.AssetRegistry r
CROSS APPLY STRING_SPLIT(REPLACE(REPLACE(r.source_objects,'[',''),']',''), ',') src
WHERE r.source_objects IS NOT NULL
```

## Expected lineage edges for inventory_health (post `usp_BuildLineage`)

Approximate counts based on the 33 registry rows authored:

| Source asset (upstream) | Target asset (inventory_health) | Count |
|---|---|---:|
| `Enterprise_Lakehouse.*` (Bronze shortcuts) | `ReferenceMaster_Enh.Vendor` + 12 Tier-1 silver views | ~25 |
| `SupplyChain_Lakehouse.*` (workaround) | v_PurchaseOrder + v_LogilityItemStatus | ~3 |
| `ReferenceMaster_Enh.ItemMaster/Warehouse/Calendar` (REUSED) | `InventoryHistory_Enh.ItemMasterExt/WarehouseExt` + Gold dims | ~6 |
| `InventoryHistory_Enh.*` (intra-mart) | helpers + self-snapshots + Gold facts | ~30 |
| `InventoryHealth_DW.CogsRollingHelper` | `InventoryHealth_DW.FactInventoryHealthSnapshot` | 1 |

**Estimated total: ~65 new edges** for inventory_health (forecast has 60 edges currently).

## Cross-mart edges

Lineage will show inventory_health depends on forecast's masters:
- `ReferenceMaster_Enh.ItemMaster` → `InventoryHistory_Enh.ItemMasterExt`
- `ReferenceMaster_Enh.Warehouse` → `InventoryHistory_Enh.WarehouseExt`
- `ReferenceMaster_Enh.Calendar` → `InventoryHealth_DW.DimDate`

This is intentional — `ReferenceMaster_Enh` is shared infrastructure.

NO cross-mart edge from forecast's `ForecastAccuracy_DW.Dim*` to inventory_health (decision per `30_gold.md`: inventory_health has its own self-contained Gold dims).

## Visualization

Lineage edges are consumed by `lineage_explorer` Streamlit app (in repo root). After deploy + `usp_BuildLineage`, run:
- `lineage_explorer/scripts/refresh_lineage_data.py` (or wait for GitHub Action `refresh_lineage_data.yml`)
- Open Streamlit app → toggle `project='inventory_health'` filter

## Rebuild trigger

`usp_BuildLineage` runs automatically at end of `pl_sc_master` (in `usp_FinalizePipeline`). Manual rebuild:
```sql
EXEC Meta.usp_BuildLineage;
```

This deletes all `edge_type IN ('direct','derived')` rows and recomputes from registry. `edge_type='semantic'` rows (TMDL-derived) are preserved (managed by `build_semantic_model_lineage.py`).
