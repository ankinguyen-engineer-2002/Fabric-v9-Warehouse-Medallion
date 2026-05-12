# Dataflow Drafts — ready-to-paste M code

Pre-built Power Query M files for inventory_health dataflows. Drop-in templates: copy entire file content → paste vào Fabric Dataflow Gen2 Advanced Editor → Save & Refresh.

## Status

| # | File | Priority | Status |
|---|------|----------|--------|
| 1 | `df_brz_PoDetail.pq` | **P0** | ✅ Ready — anh test trước |
| 2 | `df_brz_PoMaster.pq` | **P0** | ⏳ Will generate after #1 verified |
| 3 | `df_brz_ITBEXT_Reloaded.pq` | **P0** | ⏳ Will generate after #1 verified |
| 4 | `df_brz_ITEMBL_PHYOH_Reloaded.pq` | **P1** | ⏳ Will generate after #1 verified |
| 5 | `df_brz_Logility_ItemStatus.pq` | **P2** | ⏳ Will generate when Robert confirms |

## How to test `df_brz_PoDetail.pq`

1. **Open** Fabric workspace `Enterprise SupplyChain-Dev` (`c8d9fc83-...`)
2. **+ New item** → **Dataflow Gen2**
3. **Name**: `df_brz_PoDetail` (match file name)
4. **Advanced editor** (top-right toolbar) → clear default content → **paste entire `df_brz_PoDetail.pq` content**
5. **Save** — should validate without errors (auth uses existing connection per `queryMetadata.json` of forecast dataflows)
6. **Refresh** (manual trigger button)
7. **Monitor** refresh status — first run should complete in 2-10 minutes depending on EDW PoDetail size
8. **Verify** on Lakehouse SQL endpoint:
   ```sql
   SELECT COUNT(*) FROM SupplyChain_Lakehouse.dbo.PoDetail;
   ```
   Expect > 0 rows (currently 0 on Enterprise_Lakehouse mirror)

## What to check during test

| Check | Pass criteria | Action if fail |
|-------|--------------|----------------|
| M syntax | Save button works, no editor error | Re-copy file, check no truncation |
| Auth | Refresh starts (not auth prompt) | Pick existing `ashley-edw.database.windows.net;ASHLEY_EDW` connection |
| SQL passthrough | Refresh progresses past "Connecting" stage | Verify SELECT * trên `Wholesale_ProductSourcing_AFI.PoDetail` is valid EDW table — confirm với Cherry |
| Destination | New table `podetail` appears in `SupplyChain_Lakehouse` | Confirm Lakehouse ID `62a3081e-...` đúng |
| Row count | > 0 in target table | EDW upstream cũng = 0 → reload không cứu được, dùng workaround |

## Sau khi PoDetail verified

Báo lại tôi (paste row count + sample 5 rows) → tôi generate 4 file còn lại bằng cùng pattern:
- `df_brz_PoMaster.pq` (cần confirm upstream tên POMAST / PoHeader / PurchaseOrderMaster)
- `df_brz_ITBEXT_Reloaded.pq` (cover CRHLD/DLHLD/TOHLD/ATPQT)
- `df_brz_ITEMBL_PHYOH_Reloaded.pq` (cover PHYOH + other columns)
- `df_brz_Logility_ItemStatus.pq` (chờ Robert confirm)

## References

- Setup guide: [../dataflow_setup.md](../dataflow_setup.md)
- Reference template (forecast example, working): [../_dataflow_templates/mashup.pq](../_dataflow_templates/mashup.pq)
- Source mapping: [../InventoryHealth_Source_KPI_Mapping.xlsx](../InventoryHealth_Source_KPI_Mapping.xlsx)
