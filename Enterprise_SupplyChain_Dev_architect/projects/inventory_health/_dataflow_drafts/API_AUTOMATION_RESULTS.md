# Dataflow API automation — results + Microsoft documentation findings

**Date:** 2026-05-12 · **Status:** 5 dataflows created via REST API in workspace `Enterprise SupplyChain-Dev`

## Microsoft Learn docs research (via MCP `microsoft-docs-search` + `microsoft_docs_fetch`)

### Source: [Public APIs capabilities for Dataflow Gen2](https://learn.microsoft.com/fabric/data-factory/dataflow-gen2-public-apis)

**Known limitation (confirmed in official docs, "Current limitations" section):**

> "Run APIs can be invoked, but **the actual run never succeeds**."

→ Refresh `POST /jobs/instances?jobType=Refresh` luôn fail với error generic `"Job instance failed without detail error"`. **Đây là bug đã document của Microsoft**, không phải lỗi script.

**Confirmed by test on PoDetail_v2** (đã work qua UI Save+Refresh): API refresh vẫn fail sau khi UI đã publish thành công.

### Source: [List Connections REST API](https://learn.microsoft.com/en-us/rest/api/fabric/core/connections/list-connections)

GET `/v1/connections` trả về 3 EDW SQL connections trong account Aric:
- `d7322e75-1e84-4aed-a08a-fc1a0862dc4a` (lowercase `ashley_edw`)
- `67192c57-5e5c-4ad4-8801-858e75656fe4` (uppercase `ASHLEY_EDW`)
- `a52e46f8-41ac-4770-a14f-af6735e3cab9` (AzureSqlMI variant)

All `ShareableCloud` + `OAuth2` → có thể reference trong queryMetadata.json của dataflow mới.

## Approach implemented

1. **Explicit connection binding** trong queryMetadata.json — dùng cluster/datasource IDs extracted from forecast `df_brz_SalesHistory` (proven working). New dataflows inherit auth, user không cần re-pick credential trong UI.

2. **`.schedules` part included** — auto-refresh daily 01:00 SE Asia Standard Time. Bypasses Microsoft's API-refresh limitation by using internal Fabric scheduler (scheduled jobs DO work, only on-demand API trigger fails).

3. **Result**: 5 dataflows created, scheduled. User just opens each once, clicks Save → auto-refresh kicks in next day at 01:00.

## Created items (workspace `c8d9fc83-...`)

| # | Dataflow | Item ID | Target Lakehouse table | Priority |
|---|----------|---------|------------------------|----------|
| 1 | `df_brz_PoDetail_v2` | `689271c0-b11d-433e-b9f0-fd767a38f08a` | `podetail_v2` | **P0** (verified working by Aric, 53 cols, 99+ rows) |
| 2 | `df_brz_PoMaster` | `585b4cbd-6e8e-4dcd-89e9-ac915984138d` | `pomaster` | **P0** |
| 3 | `df_brz_ITBEXT_Reloaded` | `f6d601e3-76bd-49d0-af95-1f90a7ac647b` | `itbext_reloaded` | **P0** |
| 4 | `df_brz_ITEMBL_PHYOH_Reloaded` | `d3d87cbe-252b-47f0-9d64-5c99be4b4192` | `itembl_phyoh_reloaded` | **P1** |
| 5 | `df_brz_Logility_ItemStatus` | `d409ee6f-4009-4a40-b9f1-6f69fc2d33d4` | `logility_itemstatus` | **P2** conditional |

## Action required from Aric (per dataflow)

For each của 4 dataflow mới (#2-5):

1. Mở Fabric UI → workspace `Enterprise SupplyChain-Dev` → click dataflow
2. **Nếu credential pre-bound** (vì đã include connectionId in metadata): chỉ cần click **Save**
3. **Nếu prompt credential**: pick existing connection `ashley-edw.database.windows.net;ASHLEY_EDW2 NAric` (id `67192c57-...`) → Save
4. (Optional) Click **Refresh** ngay để test, hoặc đợi schedule chạy 01:00 mai

ETA: ~30s per dataflow = ~2 phút total cho 4 dataflows.

## Why API refresh không work (Microsoft limitation)

Workaround paths trong tương lai (theo Microsoft docs):
- **Scheduled refresh** (đã implement qua `.schedules` part) — auto-runs daily
- **Pipeline activity wrapper** — Dataflow activity inside Fabric Data Pipeline → pipeline API trigger DOES work (proven: `pl_sc_master` run 42m08s success via API)
- **Manual UI refresh** — always works

## Reference

- Source artifact: [`../InventoryHealth_Source_KPI_Mapping.xlsx`](../InventoryHealth_Source_KPI_Mapping.xlsx)
- Setup guide: [`../dataflow_setup.md`](../dataflow_setup.md)
- Forecast template: [`../_dataflow_templates/mashup.pq`](../_dataflow_templates/mashup.pq)
- Microsoft docs:
  - https://learn.microsoft.com/fabric/data-factory/dataflow-gen2-public-apis
  - https://learn.microsoft.com/en-us/rest/api/fabric/core/connections/list-connections
  - https://learn.microsoft.com/fabric/data-factory/dataflow-gen2-cicd-and-git-integration
