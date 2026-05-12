# Dataflow Gen2 setup — pull EDW sources → `SupplyChain_Lakehouse.dbo.*`

> **Status:** Build-ready setup guide · **Created:** 2026-05-12 · **Source artifact:** [`InventoryHealth_Source_KPI_Mapping.xlsx`](InventoryHealth_Source_KPI_Mapping.xlsx) sheet `EDW_vs_Lakehouse`

## Overview

Của 31 EDW sources cần cho 30 KPIs inventory_health, **24 đã có trên Enterprise_Lakehouse** (13 Mapped + 11 Renamed) → dùng shortcut trực tiếp.

**7 sources cần Dataflow Gen2** kéo từ EDW lên `SupplyChain_Lakehouse.dbo.*`:

| # | Priority | Source EDW | Target Lakehouse | Reason | KPIs ảnh hưởng |
|---|----------|-----------|------------------|--------|----------------|
| 1 | **P0** | `Wholesale_ProductSourcing_AFI.PoDetail` | `dbo.PoDetail` | Schema có 53 cols nhưng 0 rows (dead) | #2, #3, #4, #15, #17 |
| 2 | **P0** | `Wholesale_ProductSourcing_AFI.PoMaster` | `dbo.PoMaster` | Không có trên lake — confirm tên upstream | #2, #3, #17 |
| 3 | **P1** | `ItemMaster_AFI.ITBEXT` (cols CRHLD/DLHLD/TOHLD/ATPQT) | `dbo.ITBEXT_Reloaded` | Cột tồn tại nhưng = 0 toàn 3.39M rows | #20e, #27, #23b |
| 4 | **P1** | `ItemMaster_AFI.ITEMBL` (col PHYOH) | `dbo.ITEMBL_PHYOH_Reloaded` | Cột PHYOH = 0 toàn 3.40M rows | #1 fallback |
| 5 | **P2** | `DemandFulfilmentCommonContain_Logility.ItemStatus` | `dbo.Logility_ItemStatus` | Logility raw chưa load (conditional — chờ Robert chốt cần past tracking) | #17, #18, #20a past |
| 6 | _Optional_ | (Reload ITBEXT + ITEMBL nếu EDW không có data → workaround đã dùng MOMAST/ATPSUM) | — | — | — |
| 7 | _Phase 2_ | `SS vs Capacity Projections.xlsx` (Excel file) | — | Out of scope phase 1 | #14, #29 |

---

## Prereq — connect to EDW

Dataflow Gen2 cần kết nối EDW (legacy SQL Server). Theo memory `reference_fabric_connections.md`:

- **Server (TBD)** — gating: lookup từ existing dataflow `df_brz_SalesHistory_AFI_InvoiceDetail` trong workspace để clone connection string
- **Database (TBD)** — likely `ASHLEY_EDW_DEV` hoặc `ASHLEY_EDW` (per ADRs nhắc tới)
- **Auth** — Service Principal (cùng SPN dùng bởi pipelines hiện tại) hoặc Entra user delegate
- **Privacy level** — Organizational (Lakehouse target ở cùng tenant)

**Action**: anh open Fabric workspace `Enterprise SupplyChain-Dev` → Dataflows → mở 1 dataflow existing (vd `df_brz_SalesHistory_AFI_InvoiceDetail`) → copy connection string + auth profile để reuse.

---

## Query templates

### P0-1 · `dbo.PoDetail` (Wholesale PO line detail)

**Power Query M** (paste vào Dataflow Gen2 Advanced Editor):

```m
let
    Source = Sql.Database("<EDW_SERVER>", "<EDW_DATABASE>",
        [Query="
            SELECT *
            FROM Wholesale_ProductSourcing_AFI.PoDetail
            -- Filter to last 3 years if too large (PO_CreatedDate column TBD)
            -- WHERE PO_CreatedDate >= DATEADD(YEAR, -3, GETDATE())
        ", CreateNavigationProperties=false])
in
    Source
```

**Native SQL** (nếu prefer SQL passthrough):
```sql
SELECT *
FROM Wholesale_ProductSourcing_AFI.PoDetail
-- Optional date filter for incremental:
-- WHERE LastModifiedTS >= ?
```

**Destination**: Lakehouse `SupplyChain_Lakehouse` → Table `PoDetail` (schema = `dbo`, default)  
**Refresh**: Full load lần đầu · Incremental sau (watermark column = `LastModifiedTS` nếu có, hoặc `PO_CreatedDate`)  
**Verify**: `SELECT COUNT(*) FROM SupplyChain_Lakehouse.dbo.PoDetail` — kỳ vọng vài trăm K rows (so với 0 rows hiện tại trên Enterprise_Lakehouse)

---

### P0-2 · `dbo.PoMaster` (Wholesale PO header)

```m
let
    Source = Sql.Database("<EDW_SERVER>", "<EDW_DATABASE>",
        [Query="
            SELECT *
            FROM Wholesale_ProductSourcing_AFI.PoMaster
            -- Tên upstream cần confirm — có thể là PoHeader hoặc PurchaseOrderMaster
        ", CreateNavigationProperties=false])
in
    Source
```

**Destination**: `SupplyChain_Lakehouse.dbo.PoMaster`  
**Refresh**: Full load — table này không có trên lake, lần đầu kéo full  
**Action trước khi chạy**: confirm tên thực tế bên EDW (`PoMaster` vs `PoHeader`). Thường có Status column quan trọng:
- `Firm Status` (cho KPI #4 PO On Order)
- `Document Date`

**Verify**: row count + có column `Status`/`OrderStatus` không (cần cho join với PoDetail)

---

### P1-3 · `dbo.ITBEXT_Reloaded` (Item hold flags — CRHLD/DLHLD/TOHLD + ATPQT)

Phương án: reload toàn bảng ITBEXT với mapping đầy đủ. Nếu EDW có data nhưng cột dead = 0 trên lake hiện tại, dataflow này thay thế.

```m
let
    Source = Sql.Database("<EDW_SERVER>", "<EDW_DATABASE>",
        [Query="
            SELECT
                ITNBR,        -- Item number (PK)
                CRHLD,        -- Credit hold flag
                DLHLD,        -- Delivery hold flag
                TOHLD,        -- Total/Type-on hold flag
                ATPQT,        -- Available-to-promise quantity
                -- Add other columns from ITBEXT that hiện ENH side mất data
                *             -- Lấy all để diff với existing
            FROM ItemMaster_AFI.ITBEXT
        ", CreateNavigationProperties=false])
in
    Source
```

**Destination**: `SupplyChain_Lakehouse.dbo.ITBEXT_Reloaded` (suffix `_Reloaded` để không clash với existing shortcut)  
**Refresh**: Full daily (3.39M rows — manageable)  
**Verify trước khi consume**: `SELECT TOP 100 ITNBR, CRHLD, DLHLD, TOHLD, ATPQT FROM dbo.ITBEXT_Reloaded WHERE CRHLD<>0 OR DLHLD<>0 OR TOHLD<>0` — kỳ vọng > 0 rows (chứng tỏ EDW có data, không phải dead trên upstream)

**Fallback nếu EDW cũng dead**: dùng workaround đã document — `ExtendedOrder` + `Item_ENV` cho hold KPI #20e (KPI mapping sheet `Source_to_KPI`).

---

### P1-4 · `dbo.ITEMBL_PHYOH_Reloaded` (Physical on-hand quantity)

```m
let
    Source = Sql.Database("<EDW_SERVER>", "<EDW_DATABASE>",
        [Query="
            SELECT
                ITNBR, BLDIV, WHSEC,  -- Composite key (Item × Division × Warehouse)
                PHYOH,                 -- Physical on-hand (currently 0 in lake)
                MOHTQ,                 -- Move-on hand total quantity (verified non-zero)
                ITCLS,
                *
            FROM ItemMaster_AFI.ITEMBL
        ", CreateNavigationProperties=false])
in
    Source
```

**Destination**: `SupplyChain_Lakehouse.dbo.ITEMBL_PHYOH_Reloaded`  
**Refresh**: Full daily (3.40M rows)  
**Critical verify**: `SELECT SUM(PHYOH) FROM dbo.ITEMBL_PHYOH_Reloaded` — phải > 0 (hiện trên lake = 0 toàn bộ)

**Fallback**: nếu EDW PHYOH cũng = 0, dùng MOHTQ (đã work) — không cần dataflow này.

---

### P2-5 · `dbo.Logility_ItemStatus` (past lifecycle tracking)

⚠️ **Conditional** — chỉ load nếu Robert (Demand Planning lead) confirm cần past tracking. Hiện tại workaround dùng `DimItemMaster.AFIItemStatus` (current state only).

```m
let
    Source = Sql.Database("<EDW_SERVER>", "<EDW_DATABASE>",
        [Query="
            SELECT *
            FROM DemandFulfilmentCommonContain_Logility.ItemStatus
            -- Confirm Logility schema exists in EDW
            -- Có thể tên khác — e.g., Logility_Stage.ItemStatus
            WHERE 1=1
            -- AND ChangeDate >= DATEADD(YEAR, -2, GETDATE())  -- Limit history if huge
        ", CreateNavigationProperties=false])
in
    Source
```

**Destination**: `SupplyChain_Lakehouse.dbo.Logility_ItemStatus`  
**Refresh**: Incremental (watermark = `ChangeDate` hoặc `EffectiveStartDate`)  
**Action**: confirm với Robert trước khi build; confirm tên schema thực tế trên EDW.

---

## Dataflow Gen2 — setup steps

Per source:

1. **Open** Fabric workspace `Enterprise SupplyChain-Dev` → `+ New item` → `Dataflow Gen2`
2. **Name** dataflow theo convention: `df_brz_<schema>__<table>` (vd `df_brz_Wholesale_ProductSourcing_AFI__PoDetail`) — đồng bộ với existing pattern
3. **Get data** → SQL Server → paste connection từ existing dataflow (re-use auth)
4. **Advanced editor** → paste M query template ở trên
5. **Configure data destination**:
   - Type: Lakehouse
   - Workspace: `Enterprise SupplyChain-Dev`
   - Lakehouse: `SupplyChain_Lakehouse`
   - Table name: `<target_table>` (default schema = `dbo`)
   - Update method: **Replace** (full refresh) lần đầu · sau đổi sang **Append** + watermark nếu incremental
6. **Schedule**: daily 1:00 AM UTC (chạy trước `pl_sc_master` 2:00 AM để đảm bảo data ready)
7. **Validate**: chạy thử lần đầu → check row count target Lakehouse table

---

## Sau khi Dataflow chạy thành công

1. **Verify counts trên Lakehouse**:
   ```sql
   SELECT 'PoDetail' AS tbl, COUNT(*) AS n FROM SupplyChain_Lakehouse.dbo.PoDetail
   UNION ALL SELECT 'PoMaster', COUNT(*) FROM SupplyChain_Lakehouse.dbo.PoMaster
   UNION ALL SELECT 'ITBEXT_Reloaded', COUNT(*) FROM SupplyChain_Lakehouse.dbo.ITBEXT_Reloaded
   UNION ALL SELECT 'ITEMBL_PHYOH_Reloaded', COUNT(*) FROM SupplyChain_Lakehouse.dbo.ITEMBL_PHYOH_Reloaded;
   ```

2. **Quality check** — đảm bảo các cột "dead" giờ có data:
   ```sql
   SELECT COUNT(*) AS rows_with_hold
   FROM SupplyChain_Lakehouse.dbo.ITBEXT_Reloaded
   WHERE CRHLD <> 0 OR DLHLD <> 0 OR TOHLD <> 0;
   -- Expect > 0
   ```

3. **Update [10_bronze.md](10_bronze.md)** với:
   - Bảng cập nhật status cho 7 sources từ "Cần Dataflow" → "Loaded via df_brz_*"
   - Row count baseline mỗi table

4. **Cross-reference vào `Meta.AssetRegistry`** (khi build Silver):
   ```sql
   -- Example: PoDetail source registration
   INSERT INTO Meta.SourceFeed (...) VALUES (
     'SupplyChain_Lakehouse.dbo.PoDetail',
     '<asset_id_consumer>',  -- e.g., InventoryHistory_Enh.SomeSilverTable
     ...
   );
   ```

---

## Open items trước khi chạy

| # | Item | Owner | Status |
|---|------|-------|--------|
| 1 | Confirm EDW server + database name | Cherry / Aric | Pending |
| 2 | Confirm `PoMaster` upstream tên thực tế | Cherry | Pending |
| 3 | Confirm Logility schema exists + tên | Robert | Pending P2 |
| 4 | Verify ITBEXT + ITEMBL EDW có data (không phải dead toàn upstream) | Aric (test query) | Pending |
| 5 | Setup auth — reuse SPN từ existing dataflow | Aric | Pending |

---

## References

- Source artifact: [`InventoryHealth_Source_KPI_Mapping.xlsx`](InventoryHealth_Source_KPI_Mapping.xlsx)
- Bronze design: [10_bronze.md](10_bronze.md)
- Open questions: [_open_questions_for_bob.md](_open_questions_for_bob.md)
- Existing dataflow patterns (workspace scan): 18 dataflows incl. `df_brz_SalesHistory_AFI_InvoiceDetail`, `df_brz_SupplyChain_Enh_1_DemandForecastSnapshotDaily_copy1` (per memory `project_workspace_topology.md`)
