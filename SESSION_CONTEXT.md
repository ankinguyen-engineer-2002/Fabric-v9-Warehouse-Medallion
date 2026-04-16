# Session Context — Claude Code Chat History
> Lưu lại toàn bộ ngữ cảnh, kỹ năng, quyết định, và kiến thức từ session 2026-04-13 → 2026-04-15
> Để AI tương lai đọc file này sẽ hiểu toàn bộ dự án mà không cần đọc lại chat

---

## 1. Dự án là gì

Chuyển đổi kiến trúc data warehouse từ **v8** (Notebook + Lakehouse + PySpark) sang **v9** (Warehouse + T-SQL + Stored Procedures) trên Microsoft Fabric. Chạy song song v8, không xóa v8.

- **Tổ chức**: Ashley Furniture Industries
- **Team**: DataHub VN (Aric Nguyen) — Global Supply Chain Analytics
- **Platform**: Microsoft Fabric F256
- **Workspace**: DEV (c8d9fc83-18b6-4e1d-8264-0b49eed36fe0)
- **Warehouse**: SupplyChain_Warehouse (e146ffe2-d907-46a7-9b7e-3e739a31b24e)
- **SQL Endpoint**: 7woj2wroypauvkpn72b56t46ju-qp6ntsfwdaou5atebne65u3p4a.datawarehouse.fabric.microsoft.com

---

## 2. Kết nối Warehouse từ local machine

```python
import pyodbc, struct, subprocess

# Lấy Azure token
result = subprocess.run(
    ['az', 'account', 'get-access-token', '--resource',
     'https://database.windows.net/', '--query', 'accessToken', '-o', 'tsv'],
    capture_output=True, text=True)
token = result.stdout.strip()
token_bytes = token.encode('UTF-16-LE')
token_struct = struct.pack(f'<I{len(token_bytes)}s', len(token_bytes), token_bytes)

server = '7woj2wroypauvkpn72b56t46ju-qp6ntsfwdaou5atebne65u3p4a.datawarehouse.fabric.microsoft.com'
conn = pyodbc.connect(
    f'DRIVER={{ODBC Driver 18 for SQL Server}};SERVER={server};'
    f'DATABASE=SupplyChain_Warehouse;Encrypt=yes;TrustServerCertificate=no;',
    attrs_before={1256: token_struct})
conn.autocommit = True
cursor = conn.cursor()
```

**Token hết hạn**: `az logout && az login --tenant "5a9d9cfd-c32e-4ac1-a9ed-fe83df4f9e4d"`

**Fabric API token**: `az account get-access-token --resource https://api.fabric.microsoft.com`

**Power BI API token**: `az account get-access-token --resource https://analysis.windows.net/powerbi/api`

---

## 3. Kiến trúc v9 hiện tại (sau tất cả thay đổi)

### 4 Schemas, 75 objects

```
SupplyChain_Warehouse/
├── bronze/  (18 tables + 18 views + 0 SPs = 36)
├── silver/  (8 tables + 8 views + 0 SPs = 16)
├── gold/    (2 tables + 2 views + 0 SPs = 4)
└── meta/    (7 tables + 2 views + 9 SPs + 1 fn = 19)
                                        TOTAL: 75 (was 100 before generic SP)
```

### Per-table SPs đã XÓA — thay bằng 1 generic SP

28 SPs cũ (bronze.usp_load_*, silver.usp_load_*, gold.usp_load_*) đã bị xóa.
Tất cả 28 tables giờ load bằng `meta.usp_generic_load(@target_schema, @target_table)`.

### 5 Pipelines (tên mới từ 2026-04-16, naming: `pl_{layer}_{project}`)

| Pipeline | ID | Vai trò |
|----------|-----|---------|
| pl_sc_master | 319a8160-3f3a-4b87-8ad6-75ac4f3ec184 | log_start → bronze → silver → gold → finalize → refresh_sm |
| pl_bronze_forecast | 1bdbaebb-7222-4e9c-a45d-3e632bba846d | Lookup → ForEach(**6**) → EXEC meta.usp_generic_load |
| pl_silver_forecast | 46437ae6-3a15-4697-957d-f1f44ba10633 | compute_waves → ForEach wave → InvokePipeline child |
| pl_silver_wave_forecast | 57a09720-21a2-49b5-a472-1e19abd14f76 | Lookup wave SPs → ForEach(8) → EXEC meta.usp_generic_load |
| pl_gold_forecast | 94fc130e-f327-46a9-b7ba-cd2aa328c0da | Lookup → ForEach(2) → EXEC meta.usp_generic_load |

> Master invoke child bằng GUID → đổi tên không ảnh hưởng. Bronze batch giảm 8→6 để giảm snapshot conflict.

### Semantic Model

| Item | Value |
|------|-------|
| Name | SC_Control_Tower |
| ID | a52841ee-d853-46df-b2f7-2a2cc4493d60 |
| Mode | Direct Lake |
| Refresh | Auto (PBISemanticModelRefresh in master pipeline) |

### Lineage App

- URL: https://vn-engineer-lineage.streamlit.app
- Login: admin123 / admin123
- Source: master_lineage/ folder in repo

---

## 4. Meta Schema — 9 SPs + 1 Function

| SP | Vai trò |
|----|---------|
| `meta.usp_generic_load` | ★ CORE: 8 load patterns (overwrite, incremental, upsert, datekey, daterange, identity, cdc, scd2) |
| `meta.usp_log_run` | Log SP start/end vào sp_run_history |
| `meta.usp_log_pipeline_run` | Log pipeline start vào pipeline_run_log |
| `meta.usp_finalize_pipeline` | Build lineage + update pipeline_run_log |
| `meta.usp_compute_slv_waves` | Tính DAG waves từ depends_on (iterative, max 30) |
| `meta.usp_run_silver_dag` | SP orchestrator backup (sequential) |
| `meta.usp_check_dq` | DQ engine (có bug WHILE loop — chạy từ Python) |
| `meta.usp_build_lineage` | Parse source_objects → sp_lineage |
| `meta.usp_debug_loop` | Debug utility |
| `meta.ufn_should_run` | Check scheduling gate (1/0) |

### 2 Views

| View | Vai trò |
|------|---------|
| `meta.vw_table_dictionary` | Map sp_registry (22 cols) → Enterprise TableDictionary (63/63 cols + 6 v9 extras = 69 cols) |
| `meta.vw_slv_dag_waves` | Legacy DAG view (3 CTE cố định, thay bằng SP iterative) |

### 7 Tables

| Table | Auto/Manual | Vai trò |
|-------|-------------|---------|
| sp_registry (22 cols, 28 rows) | Manual INSERT khi thêm table | Config: SP nào, load kiểu gì, depends_on |
| sp_run_history | Auto (usp_log_run) | Log mỗi SP chạy |
| dq_rules (30 rows) | Manual INSERT khi thêm rules | DQ config |
| dq_results (30 rows) | Auto (DQ engine) | DQ results |
| sp_lineage (52 edges) | Auto (usp_build_lineage trong finalize) | Data flow map |
| pipeline_run_log | Auto (log_start + finalize) | Pipeline level log |
| slv_dag_waves_runtime (8 rows) | Auto (usp_compute_slv_waves) | Wave computation results |

---

## 5. Fabric Warehouse Constraints (phát hiện trong quá trình build)

| Constraint | Workaround |
|-----------|------------|
| No DEFAULT | Set values in SP |
| No IDENTITY | ROW_NUMBER() or MAX(id)+1 |
| No PRIMARY KEY (trước đây) | ALTER TABLE ADD ... NOT ENFORCED (giờ có) |
| No CURSOR / @@FETCH_STATUS | WHILE + MIN(id) pattern |
| No recursive CTE | SP iterative WHILE loop |
| No temp tables (trước đây) | Giờ hỗ trợ #temp tables |
| DATETIME2 cần precision | Luôn dùng DATETIME2(6) |
| datetime type trong CTAS | CAST(GETUTCDATE() AS DATETIME2(6)) |
| BIT type không ổn định | Dùng INT (0/1) |
| TRIM(numeric) fail | CAST VARCHAR trước |
| nvarchar(4000) trong CTAS | CAST VARCHAR(n) |
| CAST AS NVARCHAR (no length) | Default 30 chars → luôn specify (200) |
| SetVariable self-reference | 2 variables (next + current) |
| ForEach inside Until | Parent-child pipeline pattern |
| Variables in distributed queries | sp_executesql with @parameters |
| Warehouse Lookup trong Pipeline | LakehouseTableSource + cross-DB query |
| MERGE | GA từ Jan 2026 — hoạt động |
| ALTER TABLE ADD COLUMN | Giờ hỗ trợ (nullable columns) |
| sp_executesql trong Pipeline SP | Hoạt động — dùng cho generic SP |

---

## 6. Pipeline Connection Topology

```
Lookup activities:
  → LakehouseTableSource
  → connectionSettings.type = Lakehouse
  → artifactId = SupplyChain_Lakehouse (62a3081e)
  → externalReferences.connection = b4311980 (Lakehouse connection)
  → sqlReaderQuery: cross-DB → SupplyChain_Warehouse.meta.*

SP activities:
  → SqlServerStoredProcedure
  → linkedService.type = DataWarehouse
  → endpoint = 7woj2w...datawarehouse.fabric.microsoft.com
  → artifactId = SupplyChain_Warehouse (e146ffe2)

Pipeline invoke:
  → InvokeFabricPipeline
  → externalReferences.connection = 3bee8b0e (pipeline connection)

SM refresh:
  → PBISemanticModelRefresh
  → externalReferences.connection = 0f1e7cd1 (SM connection)
  → groupId = workspace_id, datasetId = SM id
```

---

## 7. Enterprise Architecture (US team)

Clone: `Enterprise_Architect/data-edw-fabric/` (2578 files, private repo afi-migration-pilot)

### Key framework: ETL_Framework
- `TableDictionary` (63 cols) — config MỌI table enterprise-wide
- `usp_IncrementalTableLoad` (33KB) — generic SP, 8 load patterns
- `usp_SCD2_TableLoad` — SCD Type 2
- `usp_RefreshCuratedTableFromView` — full refresh view → table
- `fn_GetDate` — UTC → EST/CST/PST (DST aware)
- `usp_DataWarehouseDataFeedAlert_Fabric` — SLA alert + email

### v9 mapping status
- ✅ Generic SP 8/8 patterns mapped
- ✅ TableDictionary view 63/63 columns
- ✅ AuditLog → sp_run_history
- ❌ SqlCmdVariable $(…) — chưa cần (chỉ có DEV)
- ❌ .sqlproj build validation — Fabric Git auto-export
- ❌ Alert/email system — chưa implement
- ❌ fn_GetDate timezone — chưa implement

---

## 8. Các quyết định kỹ thuật quan trọng

### Silver DAG — 4 lần thử

| Approach | Kết quả | Lý do |
|----------|---------|-------|
| SP orchestrator (sequential) | ✅ Hoạt động | Nhưng không parallel trong wave |
| Until loop | ❌ BadRequest | ForEach không được nest trong Until |
| 10 wave stages | ✅ Hoạt động | Nhưng cồng kềnh (21 activities) |
| **Parent-child pipeline** | ✅ **Chốt** | MS recommended, parallel + auto-scale |

### Generic SP — 2 lần thử

| Approach | Kết quả | Lý do |
|----------|---------|-------|
| Variables in WHERE | ❌ Fail | "Variables not supported in distributed mode" |
| **sp_executesql @parameters** | ✅ **Chốt** | Parameterized query OK trong Fabric WH |

### Gold table naming

Ban đầu: `gold.fact_forecast_kpi` → trùng tên với `dbo.fact_forecast_kpi` (v8) → Portal crash
Chốt: `gold.gld_fact_forecast_kpi` (prefix gld_)

### Semantic Model source remapping

Table display name giữ nguyên (dim_calendar, fact_forecast_kpi) → report copy visual không lỗi.
Source reference thay đổi: sourceLineageTag + partition entityName/schemaName trỏ vào v9 schemas.

---

## 9. GitHub Repo

**Public**: https://github.com/ankinguyen-engineer-2002/Fabric-v9-Warehouse-Medallion

```
Fabric-v9-Warehouse-Medallion/
├── README.md
├── .python-version (3.11)
├── runtime.txt
├── Enterprise_vs_Fabric_comparison.md
├── generic_sp_migration_plan.md
├── Fabric_Architect/
│   ├── master_lineage/          (Streamlit lineage app)
│   ├── template_*.md            (3 generic templates)
│   ├── v9_*_supplychain.md      (3 project-specific docs)
│   └── *.docx                   (original architecture docs)
└── Enterprise_Architect/
    └── data-edw-fabric/         (2578 files, Enterprise .sqlproj)
```

### Git auth cho Enterprise org

Enterprise repo yêu cầu SAML SSO:
```bash
gh auth refresh -h github.com  # Re-authorize OAuth
gh repo clone afi-migration-pilot/data-edw-fabric  # Dùng gh CLI (không dùng git clone)
```

---

## 10. Streamlit Lineage App

- URL: https://vn-engineer-lineage.streamlit.app
- Login: admin123 / admin123 (override via Streamlit secrets)
- Tech: Streamlit + React SVG DAG (from tieuybui/lineage_app pattern)
- Data: CSV exports từ Warehouse (auto-refresh TTL=600s)
- 3 tabs: Table Lineage DAG, SP Lineage, View Definitions
- Silver tables chia wave: slv0 (light blue), slv1 (blue), slv2 (dark blue)

### Deploy issues
- Python 3.14 → crash. Fix: `.python-version = 3.11` ở repo root
- pyodbc → không install được trên Streamlit Cloud. Fix: bỏ pyodbc, dùng CSV
- streamlit-agraph → thay bằng React SVG DAG (đẹp hơn, nhẹ hơn)

---

## 11. Fabric MCP Server

MCP tools dùng trong session:
- `mcp__fabric-dynamic__health_check` — verify connection
- `mcp__fabric-dynamic__scan_workspace` — list all items
- `mcp__fabric-dynamic__get_pipeline_def` — read pipeline JSON
- `mcp__fabric-dynamic__trigger_pipeline` — trigger pipeline run
- `mcp__fabric-dynamic__get_pipeline_status` — check run status
- `mcp__fabric-dynamic__get_pipeline_history` — recent runs
- `mcp__fabric-dynamic__get_notebook_list` — list notebooks
- `mcp__fabric-dynamic__get_metadata` — read metadata tables
- `mcp__fabric-dynamic__get_lineage` — read lineage

### Fabric REST API endpoints used
- Create pipeline: `POST /v1/workspaces/{ws}/items` (type=DataPipeline)
- Update pipeline def: `POST /v1/workspaces/{ws}/items/{id}/updateDefinition`
- Create SM: `POST /v1/workspaces/{ws}/semanticModels`
- Get SM def: `POST /v1/workspaces/{ws}/semanticModels/{id}/getDefinition` (async 202)
- Refresh SM: `POST https://api.powerbi.com/v1.0/myorg/groups/{ws}/datasets/{id}/refreshes`
- List items: `GET /v1/workspaces/{ws}/items?type=DataPipeline`

---

## 12. Skills & Tools cần thiết

### Python
- pyodbc + Azure token (struct.pack) cho Warehouse connection
- urllib.request cho Fabric REST API calls
- base64 encode/decode cho pipeline definitions + SM TMDL
- json parse cho API responses
- csv read/write cho Streamlit data

### T-SQL (Fabric WH)
- CREATE TABLE AS SELECT (CTAS) — core load pattern
- sp_executesql với parameterized queries — bypass distributed mode restriction
- Dynamic SQL build (NVARCHAR concatenation) — generic SP
- MERGE (GA Jan 2026) — upsert pattern
- 3-part naming cross-database queries
- VIEW definitions cho ETL logic
- SP với TRY/CATCH error handling

### Fabric Pipeline (JSON API)
- LakehouseTableSource + connectionSettings (Lookup)
- SqlServerStoredProcedure + linkedService (SP execution)
- InvokeFabricPipeline + externalReferences (pipeline invoke)
- PBISemanticModelRefresh (SM refresh)
- ForEach (isSequential, batchCount)
- SetVariable (2 vars pattern for increment)
- Parent-child pipeline pattern (ForEach → InvokePipeline)

### Streamlit
- streamlit.components.v1.html (embed React app)
- st.cache_data(ttl=600) (auto-refresh)
- st.session_state (login persistence)
- React SVG DAG visualization (lineage.html template)

---

## 13. Thứ tự build (nếu cần rebuild từ đầu)

1. **Phase 0**: CREATE SCHEMA meta → 7 tables → 9 SPs + 1 function
2. **Phase 1**: 18 bronze views → EXEC meta.usp_generic_load cho mỗi table
3. **Phase 1.5**: Seed sp_registry (18 rows) + dq_rules + run DQ
4. **Phase 2**: 8 silver views → EXEC meta.usp_generic_load (DAG order)
5. **Phase 2.5**: Seed sp_registry (8 rows) + dq_rules + run DQ
6. **Phase 3**: 2 gold views → EXEC meta.usp_generic_load
7. **Phase 3.5**: Seed sp_registry (2 rows) + dq_rules + run DQ
8. **Phase 4**: EXEC meta.usp_build_lineage
9. **Phase 5**: Create 5 pipelines via Fabric REST API
10. **Phase 6**: Create SC_Control_Tower semantic model via API
11. **Phase 7**: Deploy Streamlit lineage app

---

## 14. Những lỗi đã gặp và cách fix (reference)

| Lỗi | Nguyên nhân | Fix |
|-----|-------------|-----|
| `datetime not supported in CTAS` | GETUTCDATE() trả datetime | `CAST(GETUTCDATE() AS DATETIME2(6))` |
| `TRIM requires string` | TRIM numeric column | Bỏ TRIM hoặc CAST VARCHAR trước |
| `Variables not supported in distributed` | WHERE col = @variable | sp_executesql with @parameter |
| `NVARCHAR default 30 chars` | CAST AS NVARCHAR truncate | CAST AS NVARCHAR(200) |
| `ForEach inside Until = BadRequest` | MS docs: cannot nest ForEach in Until | Parent-child pipeline pattern |
| `Snapshot isolation conflict` | Parallel DROP+CTAS | Pipeline retry=3, interval=60s |
| `Pipeline "Failed to open resource"` | Wrong connection ID trong Lookup | LakehouseTableSource + Lakehouse connection |
| `SP "ReferenceName null"` | Script activity format wrong | SqlServerStoredProcedure + linkedService |
| `Gold table name collision` | dbo.fact_* trùng gold.fact_* | Prefix gld_ |
| `SM warning icons` | Direct Lake chưa refresh | Refresh SM via Power BI API |
| `DECIMAL(10,4) overflow` | threshold=1000000 | Recreate table DECIMAL(18,2) |
| `usp_check_dq loop 1 iteration` | WHILE + sp_executesql trong Fabric | Chạy DQ từ Python (workaround) |
| `ref_forecast_horizon no view` | Hardcoded 8 rows, generic SP cần view | Tạo view SELECT UNION ALL |
| `SAML SSO block git clone` | Enterprise org auth | gh auth refresh + gh repo clone |
| `Streamlit Python 3.14 crash` | streamlit-agraph incompatible | .python-version = 3.11 |
