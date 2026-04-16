# Generic SP Migration Plan
> Adopt Enterprise ETL pattern vào v9 mà không phá kiến trúc hiện tại
> Status: PLANNING → sẽ test trước khi commit

---

## 1. v9 hiện tại đang có gì

### Load engine
- **28 SPs riêng** (1 per table) copy từ template
- 2 load patterns active: overwrite (DROP+CTAS), incremental (INSERT WHERE watermark)
- Mỗi SP hardcode: tên view, tên table, logic load
- Thêm table mới = tạo VIEW + copy SP template + INSERT sp_registry

### Meta tables
- `meta.sp_registry` (20 columns, 28 rows)
- `meta.sp_run_history` — log mỗi SP chạy
- `meta.dq_rules` / `meta.dq_results` — DQ config + results
- `meta.sp_lineage` — auto-built lineage
- `meta.pipeline_run_log` — pipeline level log
- `meta.slv_dag_waves_runtime` — DAG wave computation

### Pipeline flow
```
pl_sc_master:
  log_start → pl_bronze_forecast → pl_silver_forecast → pl_gold_forecast → finalize → refresh_sm

pl_bronze_forecast: Lookup sp_registry → ForEach → EXEC @item().sp_name
pl_silver_forecast: compute_waves → ForEach wave → InvokePipeline child
pl_silver_wave_forecast: Lookup wave SPs → ForEach → EXEC @item().sp_name
pl_gold_forecast: Lookup sp_registry → ForEach → EXEC @item().sp_name
```

### Views (ETL logic)
- 17 bronze views: SELECT + column mapping FROM Enterprise_Lakehouse
- 8 silver views: JOINs, CTEs, transforms FROM bronze/silver
- 2 gold views: UNION ALL, aggregation FROM silver

---

## 2. Enterprise đang có gì (ETL_Framework)

### Load engine
- **1 generic SP** (`usp_IncrementalTableLoad`, 33KB) xử lý MỌI table
- 8 load patterns: CDC, DELINSERT, Upsert, DateKey, DateRange, Identity, Insert/Append, SCD2
- SP đọc config từ `TableDictionary` → route logic tự động
- Thêm table mới = INSERT TableDictionary + tạo view, KHÔNG cần tạo SP

### Metadata
- `TableDictionary` (59 columns) — config MỌI table enterprise-wide
  - Load config: UpdateMethod, PrimaryKey, AlternateKey, DateKey, DateRangeDays
  - Source mapping: SourceSystem, SourceServer, SourceDatabase, SourceObject, SourcePlatform
  - Storage: StorageType, DataLake, DataLakeFolder
  - Scheduling: JobName, RefreshRate
  - Statistics: RowCount, ColumnCount, ColumnStatsCount
  - Fabric: DataBricksClusterVersion, DataBricksNodeType
- `AuditLog` — detailed operation log (DateTime, User, Description, Command)
- `EnvironmentControl` — Dev/Prod config
- `TableDictionary_Security` — RBAC permissions
- `TableDictionary_UpdateLog` — timestamp per table update
- `fn_GetDate` — UTC → EST/CST/PST (DST aware)

### SPs khác
- `usp_SCD2_TableLoad` — SCD Type 2
- `usp_RefreshCuratedTableFromView` — full refresh view → table
- `usp_UpdateCuratedTableFromView_DateRange` — date-range refresh
- `usp_DataWarehouseDataFeedAlert_Fabric` — SLA alert + email
- `usp_Audit_FABRIC_Tables` — auto-discover new tables

---

## 3. Có thể lấy gì từ Enterprise

### Lấy ngay (Phase 1 — hôm nay)

| Feature | Cách lấy | Impact v9 |
|---------|---------|-----------|
| **Generic load SP** | Tạo `meta.usp_generic_load` đọc sp_registry → route logic | Zero — SP mới, SPs cũ giữ nguyên |
| **Mở rộng sp_registry** | ALTER TABLE thêm columns từ TableDictionary | Zero — columns mới nullable |

### Lấy sau (khi generic SP ổn định)

| Feature | Cách lấy | Impact v9 |
|---------|---------|-----------|
| **fn_GetDate timezone** | Tạo function mới trong meta | Zero |
| **SCD2 pattern** | Thêm vào generic SP (IF load_type = 'scd2') | Zero |
| **DateRange pattern** | Thêm vào generic SP | Zero |
| **SLA alert + email** | Tạo SPs + tables mới | Zero |
| **EnvironmentControl** | Tạo bảng mới | Zero |

### KHÔNG lấy

| Feature | Lý do |
|---------|-------|
| PascalCase naming | v9 đã dùng snake_case xuyên suốt |
| SqlCmdVariable | v9 dùng 3-part naming trực tiếp |
| usp_DropConstraints | Fabric WH không có constraints |
| Radar sync | Không dùng Radar |
| usp_CreateTableFromParquet | v9 đọc trực tiếp qua 3-part naming |

---

## 4. Implementation Plan — Generic SP

### Step 1: Mở rộng sp_registry (thêm columns)

Thêm columns **nullable** để khớp với TableDictionary:
```sql
-- Columns mới (tất cả nullable, không phá code cũ):
alternate_key       VARCHAR(500)   -- AlternateKey (for upsert/merge)
date_key            VARCHAR(100)   -- DateKey column (for DateKey pattern)
date_range_days     INT            -- Number of days for DateRange pattern
source_platform     VARCHAR(100)   -- DB2, SQL, Fabric, Databricks
storage_type        VARCHAR(25)    -- Delta, Parquet, Heap
extract_query       VARCHAR(4000)  -- Custom SELECT override
update_query        VARCHAR(4000)  -- Custom UPDATE override
```

### Step 2: Tạo meta.usp_generic_load

```sql
CREATE PROCEDURE meta.usp_generic_load
    @target_schema  VARCHAR(50),
    @target_table   VARCHAR(200)
AS
BEGIN
    -- 1. Đọc config từ sp_registry
    -- 2. Route theo load_type:
    --    'overwrite'    → DROP + CTAS FROM view
    --    'incremental'  → INSERT WHERE watermark > last_wm
    --    'upsert'       → MERGE ON primary_key
    --    'scd2'         → SCD2 logic (future)
    --    'daterange'    → DELETE N days + INSERT (future)
    -- 3. Log run via usp_log_run
    -- 4. Update sp_registry (rows_loaded, last_load_date, watermark)
END
```

### Step 3: Test 1 table (ref_warehouse, 55 rows)
```sql
-- Test generic SP
EXEC meta.usp_generic_load 'bronze', 'ref_warehouse';

-- So sánh kết quả với SP cũ
EXEC bronze.usp_load_ref_warehouse;

-- Compare: row count, column count, sample data
```

### Step 4: Test all 28 tables
```sql
-- Chạy generic SP cho mỗi table
-- So sánh row counts trước/sau
-- Verify sp_run_history logs đúng
```

### Step 5: Đổi pipeline (khi đã test OK)
```
Lookup query đổi:
  TRƯỚC: SELECT sp_name FROM meta.sp_registry
  SAU:   SELECT target_schema, target_table FROM meta.sp_registry

ForEach activity đổi:
  TRƯỚC: SqlServerStoredProcedure: @item().sp_name
  SAU:   SqlServerStoredProcedure: [meta].[usp_generic_load]
         Parameters: @target_schema = @item().target_schema
                     @target_table = @item().target_table
```

---

## 5. Rollback Plan

Nếu generic SP có vấn đề:
1. Pipeline đổi lại Lookup: `SELECT sp_name FROM meta.sp_registry`
2. ForEach đổi lại: `EXEC @item().sp_name`
3. 28 SPs cũ vẫn tồn tại → chạy ngay

**Không có gì bị xóa** → rollback = 2 phút đổi pipeline.

---

## 6. So sánh trước/sau

### Thêm table mới — TRƯỚC (v9 hiện tại)
```
1. CREATE VIEW bronze.vw_brz_new_table (ETL logic)
2. CREATE PROCEDURE bronze.usp_load_brz_new_table (copy template, sửa tên)
3. INSERT INTO meta.sp_registry (sp_name, view_name, ...)
4. INSERT INTO meta.dq_rules (...)
→ 4 bước, 2 objects mới (view + SP)
```

### Thêm table mới — SAU (generic SP)
```
1. CREATE VIEW bronze.vw_brz_new_table (ETL logic)
2. INSERT INTO meta.sp_registry (target_schema, target_table, view_name, load_type, ...)
3. INSERT INTO meta.dq_rules (...)
→ 3 bước, 1 object mới (view only), KHÔNG cần tạo SP
```

### Giữ nguyên (không đổi)
- 27 views — ETL logic không thay đổi
- 28 data tables — data không thay đổi
- DAG depends_on — vẫn hoạt động
- DQ rules — vẫn hoạt động
- Lineage — vẫn hoạt động
- Semantic model — vẫn hoạt động
- Lineage web app — vẫn hoạt động
