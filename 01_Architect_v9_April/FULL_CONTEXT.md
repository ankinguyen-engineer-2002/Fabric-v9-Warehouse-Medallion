# FULL PROJECT CONTEXT — Read This File = Understand Everything
> **Mục đích**: File duy nhất chứa TOÀN BỘ context, architecture, decisions, bugs, fixes, connections, pipeline details, SP logic, constraints, và session history.
> **Cách dùng**: Bảo AI "đọc file FULL_CONTEXT.md" → AI hiểu mọi thứ, không cần hỏi thêm.
> **Last updated**: 2026-04-23
> **Author**: Aric Nguyen + Claude Code

---

## TABLE OF CONTENTS

1. [Người dùng & Team](#1-người-dùng--team)
2. [Dự án là gì](#2-dự-án-là-gì)
3. [Tất cả IDs & Connections](#3-tất-cả-ids--connections)
4. [Kiến trúc tổng quan](#4-kiến-trúc-tổng-quan)
5. [Warehouse Structure — 78 Objects](#5-warehouse-structure--78-objects)
6. [sp_registry — 22 columns, 28 rows](#6-sp_registry--22-columns-28-rows)
7. [Meta Schema — 10 SPs + 3 Functions + 2 Views + 7 Tables](#7-meta-schema--10-sps--3-functions--2-views--7-tables)
8. [Generic SP — 8 Load Patterns](#8-generic-sp--8-load-patterns)
9. [Silver DAG System](#9-silver-dag-system)
10. [6 Pipelines — Full Detail](#10-6-pipelines--full-detail)
11. [Pipeline Connection Topology](#11-pipeline-connection-topology)
12. [Pipeline Execution Trace](#12-pipeline-execution-trace)
13. [Semantic Model — SC_Control_Tower](#13-semantic-model--sc_control_tower)
14. [DQ System](#14-dq-system)
15. [Lineage System — 52 Edges](#15-lineage-system--52-edges)
16. [Naming Convention](#16-naming-convention)
17. [Scheduling & Concurrency](#17-scheduling--concurrency)
18. [Snapshot Conflict Mitigation — 3 Layers](#18-snapshot-conflict-mitigation--3-layers)
19. [Timezone Sync — CST](#19-timezone-sync--cst)
20. [Enterprise Architecture — US Team](#20-enterprise-architecture--us-team)
21. [Enterprise Mapping Status](#21-enterprise-mapping-status)
22. [Fabric Warehouse Constraints — 18 Workarounds](#22-fabric-warehouse-constraints--18-workarounds)
23. [Spark SQL → T-SQL Conversion](#23-spark-sql--t-sql-conversion)
24. [All Bugs Encountered & Fixes](#24-all-bugs-encountered--fixes)
25. [Key Technical Decisions — All Iterations](#25-key-technical-decisions--all-iterations)
26. [Streamlit Lineage App](#26-streamlit-lineage-app)
27. [GitHub Repo Structure](#27-github-repo-structure)
28. [GitHub Actions Workflow](#28-github-actions-workflow)
29. [Fabric MCP Server & REST API](#29-fabric-mcp-server--rest-api)
30. [Build Timeline — Session History](#30-build-timeline--session-history)
31. [Rebuild Order — Phase by Phase](#31-rebuild-order--phase-by-phase)
32. [What's Remaining / TODO](#32-whats-remaining--todo)
33. [File Index — Tất cả docs trong repo](#33-file-index--tất-cả-docs-trong-repo)

---

## 1. Người dùng & Team

| Field | Value |
|-------|-------|
| **Name** | Aric Nguyen |
| **GitHub** | ankinguyen-engineer-2002 |
| **Role** | Data Engineer — DataHub VN |
| **Org** | Ashley Furniture Industries |
| **Division** | Global Supply Chain Analytics |
| **Language** | Vietnamese (chính), English (docs/code) |
| **Skills** | T-SQL, PySpark, Microsoft Fabric, Azure, Pipeline Orchestration, Data Warehouse Architecture |
| **Working style** | Iterative build — deploy → hit constraints → fix → redeploy. Dùng Claude Code + Fabric MCP |

---

## 2. Dự án là gì

**Chuyển đổi kiến trúc data warehouse** từ **v8** (Notebook + Lakehouse + PySpark) sang **v9** (Warehouse + T-SQL + Stored Procedures) trên Microsoft Fabric. Chạy song song v8, không xóa v8.

| Aspect | v8 (Legacy) | v9 (Current) |
|--------|-------------|--------------|
| Storage | SupplyChain_Lakehouse (Delta) | SupplyChain_Warehouse (native Parquet) |
| Compute | PySpark Notebooks | T-SQL Stored Procedures |
| ETL logic | Python variables (COLUMN_SQL, SQL_TRANSFORM) | CREATE VIEW statements |
| Orchestration | Pipeline → ForEach → Notebook | Pipeline → ForEach → EXEC SP |
| Metadata | utl_pipeline_metadata (1 table) | meta schema (8 tables + 10 SPs) |
| DAG | execution_order (static integer) | depends_on + auto wave computation |
| DQ | Python nb_dq_engine (hardcoded) | Config-driven dq_rules table |
| Cold start | 30-60s Spark init per notebook | 0s — warehouse always warm |
| Version control | Notebook JSON (hard to diff) | .sql files (clean diff) |
| Enterprise alignment | Disconnected | Same T-SQL, same patterns |

**Tại sao v9?**
1. Zero Spark cold-start → faster pipeline
2. Enterprise alignment (same T-SQL patterns as US team)
3. Clean deployment (SQL DDL, deterministic)
4. Version-controllable SQL (not notebook JSON)
5. Single generic SP → zero per-table maintenance

---

## 3. Tất cả IDs & Connections

### Azure / Fabric IDs

| Item | ID |
|------|------|
| **Tenant** | `5a9d9cfd-c32e-4ac1-a9ed-fe83df4f9e4d` |
| **DEV Workspace** | `c8d9fc83-18b6-4e1d-8264-0b49eed36fe0` |
| **Warehouse** (SupplyChain_Warehouse) | `e146ffe2-d907-46a7-9b7e-3e739a31b24e` |
| **SQL Endpoint** | `7woj2wroypauvkpn72b56t46ju-qp6ntsfwdaou5atebne65u3p4a.datawarehouse.fabric.microsoft.com` |
| **Lakehouse** (SupplyChain_Lakehouse) | `62a3081e-...` |
| **Semantic Model** (SC_Control_Tower) | `a52841ee-d853-46df-b2f7-2a2cc4493d60` |

### Pipeline IDs

| Pipeline | ID |
|----------|------|
| pl_sc_master | `319a8160-3f3a-4b87-8ad6-75ac4f3ec184` |
| pl_sc_mart (NEW) | `9a1e7a12-30ab-465c-a45d-b051619193ac` |
| pl_sc_bronze | `1bdbaebb-7222-4e9c-a45d-3e632bba846d` |
| pl_sc_silver | `46437ae6-3a15-4697-957d-f1f44ba10633` |
| pl_sc_silver_wave | `57a09720-21a2-49b5-a472-1e19abd14f76` |
| pl_sc_gold | `94fc130e-f327-46a9-b7ba-cd2aa328c0da` |

### Connection IDs (used in pipeline JSON)

| Connection | ID | Type |
|-----------|------|------|
| Lakehouse connection | `b4311980` | connectionSettings (Lookup) |
| Pipeline connection | `3bee8b0e` | externalReferences (InvokePipeline) |
| SM connection | `0f1e7cd1-737b-44f3-a630-29c73a5e40cd` | externalReferences (SM refresh) |
| Warehouse linkedService | endpoint-based | DataWarehouse (SP execution) |

### Python Connection Code

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

### Token Commands

| Token | Command |
|-------|---------|
| **Token hết hạn** | `az logout && az login --tenant "5a9d9cfd-c32e-4ac1-a9ed-fe83df4f9e4d"` |
| **Fabric API** | `az account get-access-token --resource https://api.fabric.microsoft.com` |
| **Power BI API** | `az account get-access-token --resource https://analysis.windows.net/powerbi/api` |
| **Warehouse** | `az account get-access-token --resource https://database.windows.net/` |

---

## 4. Kiến trúc tổng quan

```
Source Systems (Enterprise_Lakehouse via 3-part naming + 4 _edw tables from SC_Lakehouse)
    |
    v
[Bronze Layer — 22 tables (18 + 4 _edw), 18 views, 1 SP]
    Raw mirror from source
    7 transactional + 11 reference/dimension tables
    Load type: mostly overwrite, 1 incremental (demandforecast 1.3B rows)
    |
    v
[Silver Layer — 8 tables, 8 views, 3 DAG waves]
    Joins, transforms, business rules
    Wave 0 (3 tables, no deps) → Wave 1 (4 tables) → Wave 2 (1 table)
    Auto-computed DAG from depends_on metadata
    |
    v
[Gold Layer — 2 tables, 2 views]
    BI-ready facts & KPI aggregations
    gld_fact_flat_forecast_actual (UNION ALL pattern)
    gld_fact_forecast_kpi (CTE chain, LEFT JOINs)
    |
    v
[Meta Layer — 8 tables, 10 SPs, 3 functions, 2 views]
    Config (sp_registry) + Log (sp_run_history) + DQ + DAG + Lineage + Timezone
    |
    v
[Semantic Model — Direct Lake, SC_Control_Tower]
    7 tables (5 dims + 2 facts), 9 relationships, ~30 DAX measures
    Auto-refreshed at end of pipeline
    |
    v
[Power BI Reports & Dashboards]
```

### Design Principles

1. **Pure T-SQL** — No Notebooks, no PySpark, no Lakehouse ETL
2. **Generic SP + 2-file-per-table** — VIEW (ETL logic) + TABLE (data). 1 SP for all tables
3. **Metadata-driven** — Adding table = CREATE VIEW + INSERT 1 row. No pipeline changes
4. **DAG orchestration** — depends_on → auto wave computation → parallel within wave
5. **Config-driven DQ** — Rules in table, 7 check types
6. **Auto-built lineage** — source_objects JSON → 52 edges, rebuilt every run

---

## 5. Warehouse Structure — 91 Objects

```
SupplyChain_Warehouse/
│
├── bronze/ (41 objects)
│   ├── Tables/ (22)
│   │   ├── brz_saleshistory_afi__invoicedetail             87,700,000 rows (from _edw)
│   │   ├── brz_saleshistory_afi__invoicedetail_edw         87,700,000 rows ★ EDW supplement
│   │   ├── brz_saleshistory_afi__invoiceheader             24,700,000 rows (from _edw)
│   │   ├── brz_saleshistory_afi__invoiceheader_edw         24,700,000 rows ★ EDW supplement
│   │   ├── brz_supplychain_enh_1__demandforecastsnapshotdaily  42,400,000 rows (from _edw)
│   │   ├── brz_supplychain_enh_1__demandforecastsnapshotdaily_edw  42,400,000 rows ★ EDW supplement
│   │   ├── brz_wholesale_codis_afi__codatan                   918,213 rows
│   │   ├── brz_wholesale_codis_afi__comast                    229,461 rows
│   │   ├── brz_wholesale_codis_afi__extord                    229,736 rows
│   │   ├── brz_wholesale_codis_afi__extorit                   912,132 rows
│   │   ├── ref_calendar                                        21,551 rows
│   │   ├── ref_customer_account                                35,581 rows
│   │   ├── ref_customer_account_group                          35,454 rows
│   │   ├── ref_customer_grouping                                    9 rows
│   │   ├── ref_customer_shipping_location                     127,515 rows
│   │   ├── ref_forecast_cycle                                      43 rows
│   │   ├── ref_forecast_horizon                                     8 rows  (hardcoded INSERT, no view)
│   │   ├── ref_item_master                                    379,331 rows
│   │   ├── ref_order_type                                          29 rows
│   │   ├── ref_product                                        379,000 rows (from _edw)
│   │   ├── ref_product_edw                                    379,000 rows ★ EDW supplement
│   │   └── ref_warehouse                                           55 rows
│   │
│   ├── SPs/ (1)
│   │   └── usp_refresh_edw_tables          Refresh 4 _edw tables from SC_Lakehouse _ver2
│   │
│   └── Views/ (18)
│       ├── vw_brz_saleshistory_afi__invoicedetail
│       ├── vw_brz_saleshistory_afi__invoiceheader
│       ├── vw_brz_supplychain_enh_1__demandforecastsnapshotdaily
│       ├── vw_brz_wholesale_codis_afi__codatan
│       ├── vw_brz_wholesale_codis_afi__comast
│       ├── vw_brz_wholesale_codis_afi__extord
│       ├── vw_brz_wholesale_codis_afi__extorit
│       ├── vw_ref_calendar
│       ├── vw_ref_customer_account
│       ├── vw_ref_customer_account_group
│       ├── vw_ref_customer_grouping
│       ├── vw_ref_customer_shipping_location
│       ├── vw_ref_forecast_cycle
│       ├── vw_ref_forecast_horizon  (SELECT ... UNION ALL for 8 hardcoded rows)
│       ├── vw_ref_item_master
│       ├── vw_ref_order_type
│       ├── vw_ref_product
│       └── vw_ref_warehouse
│
├── silver/ (16 objects)
│   ├── Tables/ (8)
│   │   ├── slv_invoice_detail_line_level      35,798,317 rows  (wave 0)
│   │   ├── slv_forecast_demand_monthly        13,876,949 rows  (wave 0)
│   │   ├── slv_open_order_line_level             258,197 rows  (wave 0)
│   │   ├── slv_actual_demand_monthly             571,822 rows  (wave 1)
│   │   ├── slv_actual_demand_weekly            1,102,162 rows  (wave 1)
│   │   ├── slv_invoice_weekly                 15,571,003 rows  (wave 1)
│   │   ├── slv_open_order_monthly                119,575 rows  (wave 1)
│   │   └── slv_naive_forecast_monthly            346,792 rows  (wave 2)
│   │
│   └── Views/ (8)
│       ├── vw_slv_invoice_detail_line_level
│       ├── vw_slv_forecast_demand_monthly
│       ├── vw_slv_open_order_line_level
│       ├── vw_slv_actual_demand_monthly
│       ├── vw_slv_actual_demand_weekly
│       ├── vw_slv_invoice_weekly
│       ├── vw_slv_open_order_monthly
│       └── vw_slv_naive_forecast_monthly
│
├── gold/ (4 objects)
│   ├── Tables/ (2)
│   │   ├── gld_fact_flat_forecast_actual       14,795,563 rows
│   │   └── gld_fact_forecast_kpi               41,055,048 rows
│   │
│   └── Views/ (2)
│       ├── vw_gld_fact_flat_forecast_actual
│       └── vw_gld_fact_forecast_kpi
│
└── meta/ (23 objects)
    ├── Tables/ (8)
    │   ├── sp_registry              28 rows   (config: SP definitions, 22 columns)
    │   ├── sp_run_history          330+ rows  (log: SP executions, with CST timestamps)
    │   ├── dq_rules                 30 rows   (config: DQ check definitions)
    │   ├── dq_results               30 rows   (log: DQ check outcomes)
    │   ├── sp_lineage               52 rows   (map: data flow edges)
    │   ├── pipeline_run_log                    (log: pipeline-level runs)
    │   ├── slv_dag_waves_runtime     8 rows   (runtime: wave computation)
    │   └── view_definitions         28 rows   (snapshot: all VIEW SQL code for GitHub Actions)
    │
    ├── Stored Procedures/ (10)
    │   ├── usp_generic_load         ★ CORE: replaces all 28 per-table SPs, 8 load patterns
    │   ├── usp_log_run              Log with retry 3x (snapshot conflict mitigation)
    │   ├── usp_log_pipeline_run     Pipeline start/end tracking with CST
    │   ├── usp_finalize_pipeline    Build lineage + update pipeline_run_log
    │   ├── usp_compute_slv_waves    Iterative DAG wave computation (max 30)
    │   ├── usp_run_silver_dag       Sequential DAG runner (backup, not used in prod)
    │   ├── usp_check_dq             DQ engine legacy (WHILE loop bug — replaced by usp_check_dq_single)
    │   ├── usp_check_dq_single     ★ NEW: single-rule DQ engine (no WHILE loop, pipeline-friendly)
    │   ├── usp_build_lineage        Parse source_objects → sp_lineage
    │   └── usp_debug_loop           Debug utility
    │
    ├── Functions/ (3)
    │   ├── ufn_should_run           Scheduling gate (returns 1/0)
    │   ├── ufn_cron_is_due          Cron expression parser
    │   └── ufn_utc_to_cst           UTC → CST/CDT converter (DST aware)
    │
    └── Views/ (2)
        ├── vw_table_dictionary      Maps sp_registry → Enterprise 63-col TableDictionary + 6 v9 extras
        └── vw_run_history_tz        Execution log in 3 timezones (UTC/CST/VN)

TOTALS: ~42 tables + 30 views + 11 SPs + 3 functions = ~91 objects
        + 7 pipelines = 98 managed artifacts
        4 _edw tables are TEMPORARY supplement (revert when EL data is complete)
        See docs/operations/edw_source_swap.md
```

---

## 6. sp_registry — 22 columns, 28 rows

The central config table. Defines EVERY data table in the system.

```sql
CREATE TABLE meta.sp_registry (
    sp_name             VARCHAR(200)    NOT NULL,   -- PK equivalent (e.g., 'meta.usp_generic_load')
    view_name           VARCHAR(200)    NULL,       -- e.g., 'bronze.vw_brz_xxx'
    target_schema       VARCHAR(50)     NOT NULL,   -- bronze / silver / gold
    target_table        VARCHAR(200)    NOT NULL,   -- e.g., 'brz_xxx'
    layer               VARCHAR(10)     NOT NULL,   -- BRZ / REF / SLV / GLD
    load_type           VARCHAR(20)     NOT NULL,   -- overwrite / incremental / upsert / datekey / daterange / identity / cdc / scd2
    frequency           VARCHAR(20)     NOT NULL,   -- daily / hourly / weekly / monthly
    scheduled_hour      INT             NULL,
    execution_order     INT             NOT NULL,   -- 1=BRZ/REF, 2-4=SLV, 5=GLD
    parallel_group      INT             NULL,
    depends_on          VARCHAR(500)    NULL,       -- JSON: ["silver.usp_load_slv_xxx"]
    source_objects      VARCHAR(2000)   NULL,       -- JSON: ["Enterprise_Lakehouse.schema.table"]
    watermark_column    VARCHAR(100)    NULL,       -- for incremental pattern
    primary_key         VARCHAR(500)    NULL,       -- for upsert/scd2
    date_key            VARCHAR(100)    NULL,       -- for datekey/daterange
    date_range_days     INT             NULL,       -- for daterange
    is_active           INT             NOT NULL,   -- 0/1 (no BIT in Fabric)
    last_load_date      DATETIME2(6)    NULL,       -- auto-updated by usp_log_run
    last_watermark_value VARCHAR(200)   NULL,       -- auto-updated
    next_run_time       DATETIME2(6)    NULL,       -- auto-updated based on frequency
    rows_loaded         BIGINT          NULL,       -- auto-updated
    project             VARCHAR(50)     NULL,       -- e.g., 'forecast' (for multi-mart filter)
    cron_expression     VARCHAR(50)     NULL        -- e.g., '0 2 * * *'
);
```

**Manual INSERT** when adding a new table. **Auto-UPDATE** by usp_log_run after each SP execution (last_load_date, rows_loaded, next_run_time).

---

## 7. Meta Schema — 10 SPs + 3 Functions + 2 Views + 8 Tables

### 8 Tables

| Table | Rows | Auto/Manual | Role |
|-------|------|-------------|------|
| sp_registry | 28 | Manual INSERT, auto UPDATE | Config: what to run, how, when, depends_on |
| sp_run_history | 330+ | Auto (usp_log_run) | Log per SP execution (run_id, status, rows, duration, CST timestamps) |
| dq_rules | 30 | Manual INSERT | DQ check config (7 check types) |
| dq_results | 30 | Auto (DQ engine) | DQ outcomes |
| sp_lineage | 52 | Auto (usp_build_lineage) | Source→target data flow edges |
| pipeline_run_log | ~5 | Auto (usp_log_pipeline_run + usp_finalize) | Pipeline-level tracking |
| slv_dag_waves_runtime | 8 | Auto (usp_compute_slv_waves) | Wave assignments per silver table |

### sp_run_history DDL

```sql
CREATE TABLE meta.sp_run_history (
    run_id              VARCHAR(36)     NOT NULL,
    pipeline_run_id     VARCHAR(36)     NULL,
    sp_name             VARCHAR(200)    NOT NULL,
    start_time          DATETIME2(6)    NOT NULL,
    end_time            DATETIME2(6)    NULL,
    duration_seconds    INT             NULL,
    rows_affected       BIGINT          NULL,
    status              VARCHAR(20)     NOT NULL,  -- running / success / failed
    error_message       VARCHAR(4000)   NULL,
    load_type           VARCHAR(20)     NULL,
    start_cst           DATETIME2(6)    NULL,      -- added 2026-04-16
    end_cst             DATETIME2(6)    NULL       -- added 2026-04-16
);
```

### 9 Stored Procedures — Detail

| SP | Parameters | Logic | Called by |
|----|-----------|-------|-----------|
| **usp_generic_load** | @target_schema, @target_table | Read sp_registry → route by load_type → DROP+CTAS (overwrite) / INSERT WHERE (incremental) / MERGE (upsert) / etc. Uses sp_executesql for dynamic SQL | Pipeline ForEach |
| **usp_log_run** | @run_id, @sp_name, @status, @rows_affected, @error_message, @pipeline_run_id, @load_type | status='running' → INSERT. Else → UPDATE with end_time, duration, rows. Also UPDATE sp_registry (last_load_date, rows_loaded, next_run_time). **Has retry 3x** (WHILE + TRY/CATCH + WAITFOR DELAY 2s) for snapshot conflicts | usp_generic_load |
| **usp_log_pipeline_run** | @pipeline_run_id, @pipeline_name | INSERT pipeline_run_log (status='running', start_time, start_cst) | Master pipeline log_start activity |
| **usp_finalize_pipeline** | @pipeline_run_id | EXEC usp_build_lineage → count success/failed → UPDATE pipeline_run_log (status='success', end_time, counts) | Master pipeline finalize activity |
| **usp_compute_slv_waves** | (none) | DELETE slv_dag_waves_runtime → iterative WHILE: wave 0 (no silver deps), wave N (all deps satisfied). Max 30 waves | Silver pipeline step 1 |
| **usp_run_silver_dag** | (none) | Sequential backup orchestrator. Not used in prod pipeline | Manual only |
| **usp_check_dq** | @layer (optional) | Legacy DQ engine (WHILE loop). **REPLACED by usp_check_dq_single** | Deprecated |
| **usp_check_dq_single** | @rule_id, @pipeline_run_id | ★ NEW: Process 1 DQ rule — gen SQL, execute, write result. CRITICAL fail → THROW (stops pipeline). WARNING fail → log only | Pipeline ForEach (pl_dq_check) |
| **usp_build_lineage** | (none) | DELETE sp_lineage → parse source_objects JSON → INSERT edges with ROW_NUMBER() | usp_finalize_pipeline |
| **usp_debug_loop** | (none) | Debug utility for WHILE loop behavior | Ad-hoc |

### usp_compute_slv_waves — Full SQL

```sql
CREATE OR ALTER PROCEDURE meta.usp_compute_slv_waves AS
BEGIN
    DELETE FROM meta.slv_dag_waves_runtime;
    DECLARE @wave INT = 0, @assigned INT = 0, @new_count INT = 1;
    DECLARE @total INT, @max_waves INT = 30;

    SELECT @total = COUNT(*) FROM meta.sp_registry
    WHERE layer = 'SLV' AND is_active = 1;

    -- Wave 0: SPs with no silver dependencies
    INSERT INTO meta.slv_dag_waves_runtime (sp_name, wave)
    SELECT sp_name, 0 FROM meta.sp_registry
    WHERE layer = 'SLV' AND is_active = 1
    AND (depends_on IS NULL OR depends_on NOT LIKE '%silver.usp_%');

    SELECT @assigned = COUNT(*) FROM meta.slv_dag_waves_runtime;
    SET @wave = 1;

    -- Iterate: assign next wave when ALL deps are already assigned
    WHILE @assigned < @total AND @wave < @max_waves AND @new_count > 0
    BEGIN
        INSERT INTO meta.slv_dag_waves_runtime (sp_name, wave)
        SELECT r.sp_name, @wave FROM meta.sp_registry r
        WHERE r.layer = 'SLV' AND r.is_active = 1
        AND r.sp_name NOT IN (SELECT sp_name FROM meta.slv_dag_waves_runtime)
        AND NOT EXISTS (
            SELECT 1 FROM meta.sp_registry dep
            WHERE dep.layer = 'SLV' AND dep.is_active = 1
            AND r.depends_on LIKE '%' + dep.sp_name + '%'
            AND dep.sp_name NOT IN (SELECT sp_name FROM meta.slv_dag_waves_runtime)
        );
        SET @new_count = @@ROWCOUNT;
        SET @assigned = @assigned + @new_count;
        SET @wave = @wave + 1;
    END
END
```

### 3 Functions

| Function | Returns | Logic |
|----------|---------|-------|
| **ufn_should_run** | INT (0/1) | Checks is_active=1 AND (next_run_time IS NULL OR next_run_time <= GETUTCDATE()) |
| **ufn_cron_is_due** | INT (0/1) | Parses cron_expression (5-field) against current UTC time |
| **ufn_utc_to_cst** | DATETIME2(6) | UTC → CST/CDT. DST aware: 2nd Sunday Mar (spring forward) → 1st Sunday Nov (fall back). Maps Enterprise fn_GetDate |

### 2 Views

| View | Columns | Logic |
|------|---------|-------|
| **vw_table_dictionary** | 69 (63 Enterprise + 6 v9 extras) | Maps sp_registry → Enterprise TableDictionary format. [Modified]/[LastAudit]/[LastBatchStartDate] use CST via ufn_utc_to_cst |
| **vw_run_history_tz** | all sp_run_history cols + 3 timezone sets | UTC (original) + CST (ufn_utc_to_cst) + VN (UTC+7) |

---

## 8. Generic SP — 8 Load Patterns

| Pattern | load_type | SQL Logic | Required sp_registry columns |
|---------|-----------|-----------|------------------------------|
| **Overwrite** | `overwrite` | DROP TABLE IF EXISTS + CTAS from view | (none) |
| **Incremental** | `incremental` | First run: CTAS. Subsequent: INSERT WHERE watermark > last value | `watermark_column`, `last_watermark_value` |
| **Upsert** | `upsert` | MERGE on primary_key (GA Jan 2026) | `primary_key` |
| **DateKey** | `datekey` | DELETE WHERE date_key IN (view's distinct date_keys) + INSERT | `date_key` |
| **DateRange** | `daterange` | DELETE WHERE date_key >= DATEADD(DAY, -N, GETUTCDATE()) + INSERT | `date_key`, `date_range_days` |
| **Identity** | `identity` | INSERT WHERE PK > MAX existing PK | `primary_key` |
| **CDC** | `cdc` | Apply change data capture operations | `primary_key` |
| **SCD2** | `scd2` | Close old versions (end_date, is_current=0) + insert new | `primary_key` |

**Key**: Uses `sp_executesql` with `@parameters` to bypass Fabric's "variables not supported in distributed mode" restriction.

**Call pattern**: `EXEC meta.usp_generic_load @target_schema = 'bronze', @target_table = 'brz_xxx';`

---

## 9. Silver DAG System

### Current Wave Assignments (3 waves, 8 SPs)

| Wave | SP | Rows | Dependencies |
|------|-----|------|-------------|
| **0** | slv_invoice_detail_line_level | 35.8M | brz_invoicedetail + brz_invoiceheader + ref_customer_account_group |
| **0** | slv_forecast_demand_monthly | 13.9M | brz_demandforecast + ref_forecast_cycle + ref_calendar |
| **0** | slv_open_order_line_level | 258K | brz_codatan + comast + extord + extorit + ref_item_master + ref_order_type |
| **1** | slv_actual_demand_monthly | 572K | **slv_invoice_detail** + **slv_open_order** + ref_calendar |
| **1** | slv_actual_demand_weekly | 1.1M | **slv_invoice_detail** + **slv_open_order** + ref_calendar |
| **1** | slv_invoice_weekly | 15.6M | **slv_invoice_detail** + ref_calendar |
| **1** | slv_open_order_monthly | 120K | **slv_open_order** + ref_calendar |
| **2** | slv_naive_forecast_monthly | 347K | **slv_actual_demand_monthly** + ref_calendar |

### How it works
1. `usp_compute_slv_waves` reads `depends_on` from sp_registry
2. Iteratively assigns waves (0, 1, 2, ..., max 30)
3. Results stored in `slv_dag_waves_runtime`
4. Pipeline reads waves, executes sequentially between waves, parallel within wave

---

## 10. 6 Pipelines — Full Detail

### Pipeline Inventory

| Pipeline | ID | Role |
|----------|------|------|
| pl_sc_master | 319a8160-3f3a-4b87-8ad6-75ac4f3ec184 | Master: refresh_edw → log → ForEach projects → finalize → SM |
| pl_sc_mart | 9a1e7a12-30ab-465c-a45d-b051619193ac | Mart orchestrator: bronze → silver → gold per @project |
| pl_sc_bronze | 1bdbaebb-7222-4e9c-a45d-3e632bba846d | Lookup+ForEach bronze/ref WHERE project=@project |
| pl_sc_silver | 46437ae6-3a15-4697-957d-f1f44ba10633 | Parent: compute waves, invoke child per wave |
| pl_sc_silver_wave | 57a09720-21a2-49b5-a472-1e19abd14f76 | Child: run SPs for 1 wave in parallel |
| pl_sc_gold | 94fc130e-f327-46a9-b7ba-cd2aa328c0da | Lookup+ForEach gold WHERE project=@project |
| **pl_dq_check** | **c32dc18d-d027-4672-9872-f73404cd7c6f** | **★ NEW: DQ gate — Lookup rules by layer → ForEach → usp_check_dq_single** |

### pl_sc_master (319a8160) — Master Orchestrator

Activities (10, sequential):
1. **refresh_edw** (SqlServerStoredProcedure) → EXEC bronze.usp_refresh_edw_tables (refreshes 4 _edw tables from SC_Lakehouse _ver2)
2. **log_start** (SqlServerStoredProcedure) → EXEC meta.usp_log_pipeline_run
3. **pl_sc_bronze** (InvokePipeline) → GUID 1bdbaebb
4. **dq_bronze** (InvokePipeline) → pl_dq_check, layer='BRZ','REF'
5. **pl_sc_silver** (InvokePipeline) → GUID 46437ae6
6. **dq_silver** (InvokePipeline) → pl_dq_check, layer='SLV'
7. **pl_sc_gold** (InvokePipeline) → GUID 94fc130e
8. **dq_gold** (InvokePipeline) → pl_dq_check, layer='GLD'
9. **finalize** (SqlServerStoredProcedure) → EXEC meta.usp_finalize_pipeline
10. **refresh_sm** (PBISemanticModelRefresh) → SC_Control_Tower
- Concurrency: 1 (prevents overlap)
- DQ CRITICAL fail → pipeline stops, downstream layers do NOT run

### pl_sc_bronze (1bdbaebb)

1. **Lookup** (LakehouseTableSource, cross-DB):
   ```sql
   SELECT target_schema, target_table
   FROM SupplyChain_Warehouse.meta.sp_registry
   WHERE layer IN ('BRZ', 'REF') AND is_active = 1
   ```
   Returns 18 tables.

2. **ForEach** (batch=**6**, isSequential=false, PARALLEL):
   - EXEC meta.usp_generic_load @target_schema=@item().target_schema, @target_table=@item().target_table
   - Retry: 3x, interval: 60s

### pl_sc_silver (46437ae6) — PARENT

1. **compute_waves** (SqlServerStoredProcedure) → EXEC meta.usp_compute_slv_waves
2. **get_distinct_waves** (Lookup, cross-DB):
   ```sql
   SELECT DISTINCT wave FROM SupplyChain_Warehouse.meta.slv_dag_waves_runtime ORDER BY wave
   ```
3. **ForEach wave** (isSequential=**true**):
   - InvokePipeline: pl_sc_silver_wave (57a09720)
   - Parameter: wave_number = @item().wave

### pl_sc_silver_wave (57a09720) — CHILD

Parameter: `wave_number` (INT)

1. **Lookup** (cross-DB):
   ```sql
   SELECT r.target_schema, r.target_table
   FROM SupplyChain_Warehouse.meta.slv_dag_waves_runtime w
   JOIN SupplyChain_Warehouse.meta.sp_registry r ON w.sp_name = r.sp_name
   WHERE w.wave = @pipeline().parameters.wave_number
   ```
2. **ForEach** (batch=**8**, PARALLEL):
   - EXEC meta.usp_generic_load

### pl_sc_gold (94fc130e)

1. **Lookup** → WHERE layer = 'GLD' AND is_active = 1 → Returns 2 tables
2. **ForEach** (batch=**2**, PARALLEL) → EXEC meta.usp_generic_load

### pl_dq_check (c32dc18d) — ★ NEW DQ Gate

Parameters: `dq_layer` (String, e.g., `'BRZ','REF'`), `pipeline_run_id` (String)

1. **Lookup** (LakehouseTableSource, cross-DB):
   ```sql
   SELECT rule_id FROM SupplyChain_Warehouse.meta.dq_rules
   WHERE is_active = 1 AND layer IN ({dq_layer})
   ```
2. **ForEach** (batch=**10**, PARALLEL):
   - EXEC meta.usp_check_dq_single @rule_id = @item().rule_id, @pipeline_run_id = @pipeline_run_id
   - If CRITICAL rule fails → SP throws error → ForEach marks failed → master pipeline stops

---

## 11. Pipeline Connection Topology

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

**WHY Lakehouse for Lookup?** Fabric Pipeline Lookup natively supports LakehouseTableSource but NOT Warehouse directly. Trying Warehouse → "Failed to open resource". Workaround: cross-DB 3-part naming through Lakehouse SQL endpoint.

---

## 12. Pipeline Execution Trace

```
T+00:00  pl_sc_master triggers
T+00:00  → refresh_edw: EXEC bronze.usp_refresh_edw_tables (refresh 4 _edw tables)
T+01:00  → log_start: INSERT pipeline_run_log (status='running')
T+01:00  → Invoke pl_sc_bronze
T+00:01    → Lookup: 18 tables from sp_registry
T+00:02    → ForEach batch=6: first 6 SPs parallel
T+03:00    → All 18 bronze complete (~1.35B rows, ~3 min)
T+03:00  → dq_bronze: Invoke pl_dq_check (layer='BRZ','REF')
T+03:01    → Lookup: 22 rules → ForEach batch=10 → usp_check_dq_single
T+03:30    → DQ bronze PASS (22/22) — if any CRITICAL fails, pipeline stops here
T+03:30  → Invoke pl_sc_silver
T+03:31    → EXEC usp_compute_slv_waves (assigns 8 SPs to 3 waves)
T+03:32    → ForEach wave (sequential):
T+03:32      → Wave 0: 3 SPs parallel (slowest: forecast_demand 110s)
T+05:22      → Wave 1: 4 SPs parallel (slowest: invoice_weekly 144s)
T+07:47      → Wave 2: 1 SP (naive_forecast 5s)
T+07:53    → Silver complete (~67.5M rows, ~6 min)
T+07:53  → dq_silver: Invoke pl_dq_check (layer='SLV')
T+08:10    → DQ silver PASS (8/8)
T+08:10  → Invoke pl_sc_gold
T+08:11    → Lookup: 2 tables → ForEach batch=2: both parallel
T+08:55    → Gold complete (~55.9M rows, ~1 min)
T+08:55  → dq_gold: Invoke pl_dq_check (layer='GLD')
T+09:05    → DQ gold PASS (4/4 — but WARNING fails are logged, not blocking)
T+09:05  → finalize: EXEC usp_finalize_pipeline (build lineage, update log)
T+09:06  → refresh_sm: PBISemanticModelRefresh (Direct Lake metadata sync)
T+09:07  pl_sc_master completes

TOTAL: ~17-20 minutes, 1.47 billion rows, 28 tables + 30 DQ checks + SM refresh
```

### Performance

| Run type | Duration | Tables | Notes |
|----------|----------|--------|-------|
| Full run (28 tables) | **17-20 min** | 28/28 | All layers sequential |
| With smart skip | **~15 min** | 18/28 | 10 monthly tables skipped |
| Failed run | 4 min | partial | Snapshot conflict → retry next trigger |

---

## 13. Semantic Model — SC_Control_Tower

| Aspect | Value |
|--------|-------|
| Name | SC_Control_Tower |
| ID | a52841ee-d853-46df-b2f7-2a2cc4493d60 |
| Mode | Direct Lake (reads Parquet from Warehouse, no import) |
| Tables | 8 (5 dims + 2 facts + _Measure + para_metric_table) |
| Relationships | 9 |
| DAX measures | ~30 |
| Refresh | Auto — PBISemanticModelRefresh at end of master pipeline |

### Table Mapping

| Display Name | Warehouse Source | Type |
|-------------|-----------------|------|
| dim_calendar | bronze.ref_calendar | Dim |
| dim_customer | bronze.ref_customer_account | Dim |
| dim_customer_group | bronze.ref_customer_grouping | Dim |
| dim_product | bronze.ref_product | Dim |
| dim_warehouse | bronze.ref_warehouse | Dim |
| fact_flat_forecast_actual | gold.gld_fact_flat_forecast_actual | Fact |
| fact_forecast_kpi | gold.gld_fact_forecast_kpi | Fact |
| _Measure | (DAX container) | Utility |

### Source Remapping Technique

Display names kept same as v8 → reports switch source without breaking.
Under the hood: sourceLineageTag + partition entityName/schemaName point to v9 schemas.

### SM API

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Create | POST | `/v1/workspaces/{id}/semanticModels` (TMDL definition parts) |
| Get definition | POST | `/v1/workspaces/{id}/semanticModels/{id}/getDefinition` (async 202) |
| Refresh | POST | `https://api.powerbi.com/v1.0/myorg/groups/{ws}/datasets/{id}/refreshes` |

---

## 14. DQ System

### Architecture (updated 2026-04-17)

```
meta.dq_rules (30 rows)              ← config, manual INSERT
       ↓
pl_dq_check (pipeline)            ← Lookup rules by layer → ForEach → call SP
       ↓
meta.usp_check_dq_single             ← process 1 rule: gen SQL, execute, write result
       ↓
meta.dq_results (30 rows)            ← output, auto-populated
       ↓
CRITICAL fail → THROW → pipeline stops
WARNING fail → log only → pipeline continues
```

**Integrated into master pipeline**: bronze → **dq_bronze** → silver → **dq_silver** → gold → **dq_gold** → finalize

### 7 Check Types

| Check Type | SQL Pattern |
|------------|-------------|
| completeness | `SUM(CASE WHEN col IS NULL THEN 0 ELSE 1 END) * 100.0 / COUNT(*)` |
| uniqueness | `COUNT(*) - COUNT(DISTINCT col)` (expects 0) |
| referential_integrity | Custom SQL from params |
| row_count | `COUNT(*)` vs threshold |
| validity | Custom SQL from params |
| freshness | `DATEDIFF(HOUR, MAX(_load_dt), GETUTCDATE())` vs threshold |
| custom_sql | Execute SQL from params column, expect 0 = pass |

### Current: 30 rules, 30/30 PASS (tested 2026-04-17)

| Layer | Rules | Check Types |
|-------|-------|-------------|
| BRZ | 8 | completeness on key columns |
| REF | 4+4 | completeness + row_count |
| SLV | 8 | completeness + row_count |
| GLD | 4 | completeness + row_count |

### DQ Engine: usp_check_dq_single

- Processes **1 rule at a time** (no WHILE loop → bypasses Fabric bug)
- Called by pipeline ForEach (batch=10, parallel)
- CRITICAL fail → `THROW 50001` → pipeline stops, downstream layers do NOT run
- WARNING fail → log FAIL to dq_results, pipeline continues
- Uses `QUOTENAME()` for SQL injection safety
- Supports all 7 check types via sp_executesql

### Historical Bug (RESOLVED)

Old `usp_check_dq` used WHILE loop + sp_executesql → only ran 1 iteration in Fabric. **Fixed** by creating `usp_check_dq_single` (single-rule, no loop) + pipeline ForEach orchestration.

---

## 15. Lineage System — 52 Edges

Auto-generated from `source_objects` JSON in sp_registry. Rebuilt every pipeline run by `usp_build_lineage` (called in finalize step).

| Flow | Edges |
|------|-------|
| Enterprise_Lakehouse → bronze | 18 (1:1 source mapping) |
| bronze → silver | 22 (many:1 JOINs) |
| silver → silver | 8 (cross-silver deps) |
| silver → gold | 4 |
| **Total** | **52** |

---

## 16. Naming Convention

### Objects

| Schema | Tables | Views | Pipelines |
|--------|--------|-------|-----------|
| bronze | `brz_{src}__{tbl}` / `ref_{entity}` | `vw_brz_*` / `vw_ref_*` | `pl_bronze_{project}` |
| silver | `slv_{concept}` | `vw_slv_*` | `pl_silver_{project}` |
| gold | `gld_{fact|dim}_{subject}` | `vw_gld_*` | `pl_gold_{project}` |
| meta | descriptive | `vw_*` | `pl_sc_master` (unique) |

### Column Prefixes

| Prefix | Meaning | Example |
|--------|---------|---------|
| `id_` | Identifiers/keys | id_customer |
| `code_` | Codes/categories | code_warehouse |
| `name_` | Descriptive names | name_product |
| `qty_` | Quantities | qty_ordered |
| `amt_` | Monetary amounts | amt_sales |
| `dt_` | Dates | dt_invoice |
| `num_` | Numbers | num_line_item |
| `ts_` | Timestamps | ts_snapshot |
| `pct_` | Percentages | pct_accuracy |
| `is_` | Boolean flags (INT 0/1) | is_active |
| `_load_dt` | System column (load timestamp) | Always DATETIME2(6) |

### Special Rules

- Bronze double underscore (`__`): separates source system from entity. `brz_saleshistory_afi__invoicedetail`
- Gold `gld_` prefix: required to avoid collision with v8 `dbo.fact_*`
- Pipeline naming: `pl_{layer}_{project}`. Master invoke by GUID → renaming safe

---

## 17. Scheduling & Concurrency

| Aspect | Value |
|--------|-------|
| Pipeline trigger | Manual (auto schedule not yet enabled) |
| Table frequency | 18 daily (`0 2 * * *`) + 10 monthly (`0 2 1 * *`) via sp_registry |
| Smart skip | Lookup WHERE `next_run_time <= GETUTCDATE()` |
| Concurrency | Master: 1, Bronze: batch=6, Silver wave: batch=8, Gold: batch=2 |
| Functions | `ufn_should_run` (simple gate) + `ufn_cron_is_due` (cron parser) |

---

## 18. Snapshot Conflict Mitigation — 3 Layers

When 6+ SPs run parallel, concurrent writes to `sp_run_history` cause snapshot isolation conflicts.

| Layer | Detail |
|-------|--------|
| **1. Reduced batch** | Bronze 8→6, less concurrent writes |
| **2. SP retry 3x** | `usp_log_run`: WHILE loop + TRY/CATCH + WAITFOR DELAY '00:00:02' (2s between retries) |
| **3. Pipeline retry 3x** | Activity retry=3, interval=60s |

**Result**: pipeline status went from "partial" (3-7 table failures per run) → **"success" (0 failures)**.

---

## 19. Timezone Sync — CST

Maps Enterprise team's `fn_GetDate` function.

| Component | Detail |
|-----------|--------|
| **ufn_utc_to_cst** | Scalar function. DST aware: 2nd Sunday Mar (spring forward, -5h → -6h offset) → 1st Sunday Nov (fall back) |
| **sp_run_history** | +2 columns: `start_cst`, `end_cst` (auto-populated by usp_log_run) |
| **pipeline_run_log** | +2 columns: `start_cst`, `end_cst` |
| **vw_table_dictionary** | `[Modified]`, `[LastAudit]`, `[LastBatchStartDate]` output CST |
| **vw_run_history_tz** | 3 timezones: UTC + CST + VN (UTC+7) |
| **Backfilled** | 330 existing rows updated with CST timestamps |

---

## 20. Enterprise Architecture — US Team

Clone: `enterprise_reference/data-edw-fabric/` (2578 files, private repo `afi-migration-pilot`)

### Key Framework: ETL_Framework

| Component | Detail |
|-----------|--------|
| **TableDictionary** | 63 columns — config for EVERY table enterprise-wide |
| **usp_IncrementalTableLoad** | 33KB generic SP, 8 load patterns |
| **usp_SCD2_TableLoad** | SCD Type 2 |
| **usp_RefreshCuratedTableFromView** | Full refresh view → table |
| **fn_GetDate** | UTC → EST/CST/PST (DST aware) |
| **usp_DataWarehouseDataFeedAlert_Fabric** | SLA alert + email |

### Enterprise Repo Auth

Requires SAML SSO:
```bash
gh auth refresh -h github.com     # Re-authorize OAuth
gh repo clone afi-migration-pilot/data-edw-fabric  # Use gh CLI (not git clone)
```

---

## 21. Enterprise Mapping Status

| Area | Status | Detail |
|------|--------|--------|
| Load patterns | **8/8 (100%)** | All 8 patterns mapped to Enterprise equivalents |
| TableDictionary | **63/63 (100%)** | vw_table_dictionary maps all Enterprise columns + 6 v9 extras |
| AuditLog | **Mapped** | sp_run_history = Enterprise AuditLog |
| Pipeline orchestration | **Mapped** | Fabric Pipelines = Azure Pipelines |
| DAG orchestration | **v9 ahead** | Enterprise doesn't have depends_on/wave computation |
| Auto lineage | **v9 ahead** | Enterprise doesn't have auto-built lineage |
| DQ config-driven | **v9 ahead** | Enterprise DQ is simpler (row count only) |
| fn_GetDate timezone | **Done** | ufn_utc_to_cst (CST, DST aware) |
| Alerts/email | **Not done** | Enterprise has usp_DataWarehouseDataFeedAlert_Fabric |
| .sqlproj validation | **Not done** | Enterprise has build-time schema validation |
| Multi-environment | **Not done** | Enterprise has Dev → Prod via publish profiles |
| SqlCmdVariable | **Not needed** | Only DEV environment currently |
| **Total** | **~85%** | |

### Load Pattern Mapping

| v9 load_type | Enterprise Equivalent | Enterprise SP |
|-------------|----------------------|--------------|
| overwrite | DELINSERT | usp_IncrementalTableLoad |
| incremental | Append/DateKey | usp_IncrementalTableLoad |
| upsert | Upsert | usp_IncrementalTableLoad |
| datekey | DateKey | usp_IncrementalTableLoad |
| daterange | DateRange | usp_UpdateCuratedTableFromView_DateRange |
| identity | Identity | usp_IncrementalTableLoad |
| cdc | CDC | usp_IncrementalTableLoad |
| scd2 | SCD2 | usp_SCD2_TableLoad |

---

## 22. Fabric Warehouse Constraints — 18 Workarounds

| # | Constraint | Workaround | Discovery |
|---|-----------|-----------|-----------|
| 1 | No DEFAULT constraint | Set values in SP | Phase 0 |
| 2 | No IDENTITY column | ROW_NUMBER() or MAX(id)+1 | Phase 0 |
| 3 | No PRIMARY KEY (enforcement) | DQ uniqueness check | Phase 0 |
| 4 | No CURSOR / @@FETCH_STATUS | WHILE + MIN(id) pattern | Phase 2 |
| 5 | No recursive CTE | SP iterative WHILE loop | Phase 2 |
| 6 | DATETIME2 needs precision | Always DATETIME2(6) | Phase 1 |
| 7 | `datetime` in CTAS | CAST(GETUTCDATE() AS DATETIME2(6)) | Phase 1 |
| 8 | BIT type unstable | Use INT (0/1) | Phase 0 |
| 9 | TRIM(numeric) fails | CAST to VARCHAR first | Phase 1 |
| 10 | NVARCHAR(4000) in CTAS | CAST to VARCHAR(n) | Phase 1 |
| 11 | CAST AS NVARCHAR default 30 chars | Always specify NVARCHAR(200) | Phase 2 |
| 12 | SetVariable self-reference | 2 variables (next + current) | Phase 2 |
| 13 | ForEach inside Until = BadRequest | Parent-child pipeline | Phase 2 |
| 14 | Variables in distributed queries | sp_executesql with @parameters | Phase 1 |
| 15 | Warehouse not in Pipeline Lookup | LakehouseTableSource + cross-DB 3-part naming | Phase 2 |
| 16 | sp_executesql in WHILE loop (1 iteration) | Run from Python | Phase 3 |
| 17 | DECIMAL(10,4) overflow | Use DECIMAL(18,2) | Phase 3 |
| 18 | Table-valued functions not supported | Use scalar functions | Phase 4 |

---

## 23. Spark SQL → T-SQL Conversion

| Spark SQL | T-SQL |
|-----------|-------|
| `CAST(x AS STRING)` | `CAST(x AS VARCHAR(200))` |
| `to_date(CAST(x AS STRING), 'yyyyMMdd')` | `TRY_CONVERT(DATE, CAST(x AS VARCHAR(20)))` |
| `CAST(x AS TIMESTAMP)` | `TRY_CAST(x AS DATETIME2(6))` |
| `CAST(x AS DOUBLE)` | `CAST(x AS FLOAT)` |
| `true` / `false` | `1` / `0` (INT) |
| `` `column` `` (backtick) | `[column]` (brackets) |
| `"string"` (double quote) | `'string'` (single quote) |
| `GETUTCDATE()` | `CAST(GETUTCDATE() AS DATETIME2(6))` |
| `DATE_FORMAT(col, 'yyyy.MM')` | `FORMAT(col, 'yyyy.MM')` |
| `ADD_MONTHS(date, n)` | `DATEADD(MONTH, n, date)` |
| `DATE_TRUNC('year', date)` | `DATETRUNC(YEAR, date)` |
| `MAKE_DATE(y, m, d)` | `DATEFROMPARTS(y, m, d)` |
| `LIMIT 1` | `TOP 1` |

---

## 24. All Bugs Encountered & Fixes

| # | Error | Root Cause | Fix |
|---|-------|-----------|-----|
| 1 | `datetime not supported in CTAS` | GETUTCDATE() returns datetime | `CAST(GETUTCDATE() AS DATETIME2(6))` |
| 2 | `TRIM requires string` | TRIM on numeric column | Remove TRIM or CAST VARCHAR first |
| 3 | `Variables not supported in distributed` | WHERE col = @variable | sp_executesql with @parameter |
| 4 | `NVARCHAR default 30 chars` | CAST AS NVARCHAR truncates | CAST AS NVARCHAR(200) |
| 5 | `ForEach inside Until = BadRequest` | MS limitation | Parent-child pipeline pattern |
| 6 | `Snapshot isolation conflict` | Parallel DROP+CTAS | 3-layer mitigation (batch, SP retry, pipeline retry) |
| 7 | `Pipeline "Failed to open resource"` | Wrong connection ID in Lookup | LakehouseTableSource + Lakehouse connection |
| 8 | `SP "ReferenceName null"` | Script activity format wrong | SqlServerStoredProcedure + linkedService |
| 9 | `Gold table name collision` | dbo.fact_* trùng gold.fact_* | Prefix gld_ |
| 10 | `SM warning icons` | Direct Lake chưa refresh | Refresh SM via Power BI API |
| 11 | `DECIMAL(10,4) overflow` | threshold=1000000 | DECIMAL(18,2) |
| 12 | `usp_check_dq loop 1 iteration` | WHILE + sp_executesql in Fabric | Run DQ from Python (workaround) |
| 13 | `ref_forecast_horizon no view` | Hardcoded 8 rows, generic SP needs view | View with SELECT UNION ALL |
| 14 | `SAML SSO block git clone` | Enterprise org auth | gh auth refresh + gh repo clone |
| 15 | `Streamlit Python 3.14 crash` | streamlit-agraph incompatible | .python-version = 3.11 |

---

## 25. Key Technical Decisions — All Iterations

### Silver DAG — 4 attempts

| # | Approach | Result | Why |
|---|----------|--------|-----|
| 1 | SP orchestrator (sequential) | Works but no parallelism | usp_run_silver_dag |
| 2 | Until loop | BadRequest | ForEach not allowed inside Until |
| 3 | 10 hardcoded wave stages | Works but rigid (21 activities) | Max 10 waves |
| 4 | **Parent-child pipeline** | **FINAL** | MS recommended, parallel + auto-scale |

### Generic SP — 2 attempts

| # | Approach | Result | Why |
|---|----------|--------|-----|
| 1 | Variables in WHERE clause | Fail | "Variables not supported in distributed mode" |
| 2 | **sp_executesql @parameters** | **FINAL** | Parameterized query works in Fabric WH |

### Gold naming

- First: `gold.fact_forecast_kpi` → collision with `dbo.fact_forecast_kpi` (v8) → Portal crash
- **Final**: `gold.gld_fact_forecast_kpi` (prefix gld_)

### SM source remapping

- Display names kept same as v8 → reports copy visuals without breaking
- Source: sourceLineageTag + partition entityName/schemaName remapped to v9 schemas

---

## 26. Streamlit Lineage App

| Aspect | Value |
|--------|-------|
| URL | https://vn-fabric-lineage.streamlit.app |
| Login | admin123 / admin123 (override via Streamlit secrets) |
| Tech | Streamlit + React SVG DAG |
| Data | CSV exports from Warehouse (auto-refresh TTL=600s) |
| Tabs | 3: Table Lineage DAG, ETL Flow by Table, View Definitions |
| Silver waves | slv0 (light blue), slv1 (blue), slv2 (dark blue) |
| Source | `lineage_explorer/` folder |
| Files | app.py, templates/lineage.html, data/*.csv, requirements.txt |

### Deploy Issues Resolved

| Issue | Fix |
|-------|-----|
| Python 3.14 → crash | `.python-version = 3.11` at repo root |
| pyodbc → can't install on Streamlit Cloud | Remove pyodbc, use CSV files |
| streamlit-agraph → ugly | Replace with React SVG DAG (custom lineage.html) |

---

## 27. GitHub Repo Structure

**Public**: https://github.com/ankinguyen-engineer-2002/Fabric-v9-Warehouse-Medallion

```
Fabric-v9-Warehouse-Medallion/
├── .claude/                        (Claude Code cache — gitignored)
├── .devcontainer/
│   └── devcontainer.json           (Python 3.11, Streamlit auto-run)
├── .github/
│   └── workflows/
│       └── refresh_lineage_data.yml (GitHub Actions: Service Principal → export CSVs)
├── .gitignore
├── .python-version                 (3.11)
├── runtime.txt                     (python-3.11)
├── README.md                       (13 sections, architecture + docs index)
├── SESSION_CONTEXT.md              (Full chat history context for AI continuity)
├── FULL_CONTEXT.md                 ★ THIS FILE
├── _private/
│   └── portfolio_architecture_detail.md  (Portfolio version, gitignored)
│
├── diagrams/
│   ├── v9_presentation.mmd         (Stakeholder overview)
│   ├── template_full_architecture.mmd  (DE/Architect detail)
│   ├── v9_supplychain_full_architecture.mmd  (v9 actual)
│   └── svg/                        (6 SVG architecture diagrams)
│
├── docs/
│   ├── templates/                  (Generic, apply to any project)
│   │   ├── architecture.md
│   │   ├── pipeline_guide.md
│   │   └── setup_guide.md
│   ├── supplychain/                (Project-specific v9)
│   │   ├── architecture.md         (All 85 objects, IDs)
│   │   ├── pipeline.md             (Execution trace)
│   │   └── setup.md                (Implementation log)
│   ├── operations/                 (How-to guides)
│   │   ├── onboarding.md, runbook.md, alerting.md
│   │   ├── scheduling.md, timezone_sync.md
│   │   ├── sqlproj_validation.md, generic_sp_migration.md
│   ├── enterprise/                 (Scale + alignment)
│   │   ├── multi_mart_scale.md, fabric_vs_enterprise.md, roadmap.md
│   └── archive/                    (.docx, notebooks_source.txt)
│
├── lineage_explorer/               (Streamlit lineage app)
│   ├── app.py
│   ├── requirements.txt
│   ├── templates/lineage.html      (React SVG DAG renderer)
│   └── data/                       (Auto-refreshed every 10 min by GitHub Actions)
│       ├── lineage.csv             (52 edges)
│       ├── registry.csv            (28 tables config)
│       ├── views.csv               (28 view SQL definitions)
│       └── run_history.csv         (recent SP runs)
│
└── enterprise_reference/
    └── data-edw-fabric/            (2578 files, Enterprise .sqlproj clone)
```

---

## 28. GitHub Actions Workflow

File: `.github/workflows/refresh_lineage_data.yml`

- Schedule: `*/10 * * * *` (every 10 minutes) + manual dispatch
- What it does: Service Principal → get Azure token → pyodbc connect → export 4 CSVs → commit & push
- CSVs: lineage.csv, registry.csv, views.csv, run_history.csv
- **Needs GitHub Secrets**: `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_TENANT_ID`, `FABRIC_SERVER`
- Status: Workflow defined but **secrets not yet configured** (needs Service Principal setup)

---

## 29. Fabric MCP Server & REST API

### MCP Tools Used

| Tool | Purpose |
|------|---------|
| `health_check` | Verify Fabric connection |
| `scan_workspace` | List all workspace items |
| `get_pipeline_def` | Read pipeline JSON definition |
| `trigger_pipeline` | Trigger pipeline run |
| `get_pipeline_status` | Check run status |
| `get_pipeline_history` | Recent runs |
| `get_notebook_list` | List notebooks |
| `get_metadata` | Read metadata tables |
| `get_lineage` | Read lineage data |
| `query_warehouse` | Execute SQL queries |

### Fabric REST API Endpoints

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Create pipeline | POST | `/v1/workspaces/{ws}/items` (type=DataPipeline) |
| Update pipeline def | POST | `/v1/workspaces/{ws}/items/{id}/updateDefinition` |
| Create SM | POST | `/v1/workspaces/{ws}/semanticModels` |
| Get SM def | POST | `/v1/workspaces/{ws}/semanticModels/{id}/getDefinition` (async 202) |
| Refresh SM | POST | `https://api.powerbi.com/v1.0/myorg/groups/{ws}/datasets/{id}/refreshes` |
| List items | GET | `/v1/workspaces/{ws}/items?type=DataPipeline` |

---

## 30. Build Timeline — Session History

### 2026-04-13 — Initial Build
- Set up project repo, uploaded architecture docs (.docx)
- Created all 4 schemas, 8 meta tables, 10 SPs
- Built 18 bronze views + tables, 8 silver views + tables, 2 gold tables
- Migrated from 28 per-table SPs → 1 generic SP (meta.usp_generic_load)
- Created 7 pipelines via Fabric REST API (5 original + pl_dq_check + pl_sc_mart)
- Created SC_Control_Tower semantic model (Direct Lake)

### 2026-04-14 — DAG & Lineage
- Fixed silver DAG wave computation (4 architectural iterations)
- Built auto-lineage (usp_build_lineage → 52 edges)
- Deployed Streamlit lineage app (streamlit-agraph → React SVG migration)
- Fixed multiple Fabric constraints (datetime, NVARCHAR, etc.)
- 3 pipeline runs: #1 fail (nested SP), #2 fail (Until), #3 SUCCESS (parent-child)

### 2026-04-15 — Enterprise Alignment
- Cloned Enterprise repo (afi-migration-pilot/data-edw-fabric, 2578 files)
- Built vw_table_dictionary (63/63 Enterprise columns mapped)
- Added scheduling (cron_expression, ufn_should_run, ufn_cron_is_due)
- Added multi-mart scale architecture doc
- Added devcontainer + GitHub Actions workflow

### 2026-04-17 — DQ System Fix
- **Created usp_check_dq_single**: single-rule DQ engine, no WHILE loop, bypasses Fabric bug
- **Created pl_dq_check pipeline**: Lookup dq_rules by layer → ForEach batch=10 → usp_check_dq_single
- **Updated pl_sc_master**: 6→9 activities, DQ gates between every layer
- **Tested 30/30 rules**: all PASS. CRITICAL fail → THROW (stops pipeline). WARNING fail → log only
- **Deleted SESSION_CONTEXT.md**: replaced by FULL_CONTEXT.md
- Object count: 77→78 (+1 SP: usp_check_dq_single), pipelines: 5→6 (+pl_dq_check)

### 2026-04-23 — EDW Source Supplement
- **Created 4 _edw tables**: CTAS from SupplyChain_Lakehouse _ver2 (invoicedetail 87.7M, invoiceheader 24.7M, demandforecast 42.4M, ref_product 379K)
- **Swapped 4 bronze views**: from Enterprise_Lakehouse to _edw tables (EL has incomplete data for Group A)
- **Updated 2 gold views**: vw_gld_fact_flat_forecast_actual (code_horizon fix), vw_gld_fact_forecast_kpi (5 KPI columns added)
- **Fixed vw_ref_calendar**: added dt_fsc_quarter_first, dt_fsc_quarter_last
- **Created bronze.usp_refresh_edw_tables**: refreshes 4 _edw tables from Lakehouse _ver2
- **Updated pl_sc_master**: added refresh_edw as first activity (before log_start)
- **Updated sp_registry**: source_objects changed to _edw references for 4 tables
- **TEMPORARY** — revert when Enterprise_Lakehouse data is complete. Rollback documented in edw_source_swap.md
- Object count: 86 → 91 (+4 _edw tables, +1 SP)

### 2026-04-16 — Polish & Robustness
- **Renamed 4 child pipelines**: pl_sc_bronze → pl_sc_bronze, etc. (`pl_{layer}_{project}`)
- **Bronze batch 8→6**: reduce snapshot conflict
- **usp_log_run retry 3x**: WHILE + TRY/CATCH + WAITFOR DELAY 2s
- **ufn_utc_to_cst**: DST aware timezone function
- **CST columns**: start_cst/end_cst on sp_run_history + pipeline_run_log
- **vw_run_history_tz**: 3 timezones (UTC/CST/VN)
- Backfilled 330 existing rows with CST
- Wrote 4 new guides: onboarding, sqlproj, timezone, scheduling
- Rewrote README (13 sections, 18 doc links)
- Created _private/portfolio_architecture_detail.md
- Dropped legacy vw_slv_dag_waves, cleaned old run history
- Object count: 75 → 77 (+ufn_utc_to_cst, +vw_run_history_tz, +ufn_cron_is_due)

---

## 31. Rebuild Order — Phase by Phase

If need to rebuild from scratch:

1. **Phase 0**: CREATE SCHEMA meta → 8 tables → 10 SPs + 3 functions
2. **Phase 1**: 18 bronze views → EXEC meta.usp_generic_load for each table
3. **Phase 1.5**: Seed sp_registry (18 rows) + dq_rules + run DQ
4. **Phase 2**: 8 silver views → EXEC meta.usp_generic_load (DAG order)
5. **Phase 2.5**: Seed sp_registry (8 rows) + dq_rules
6. **Phase 3**: 2 gold views → EXEC meta.usp_generic_load
7. **Phase 3.5**: Seed sp_registry (2 rows) + dq_rules
8. **Phase 4**: EXEC meta.usp_build_lineage
9. **Phase 5: Create 7 pipelines via Fabric REST API (JSON definitions)
10. **Phase 6**: Create SC_Control_Tower semantic model via API (TMDL)
11. **Phase 7**: Deploy Streamlit lineage app

---

## 32. What's Remaining / TODO

| Item | Priority | Detail |
|------|----------|--------|
| **Alerts/email** | Medium | **BLOCKED — needs IT**. Tried Power Automate (Premium), Teams Webhook (no channel), Graph API (admin consent), Data Activator (401). App `616bb922` created. Design ready: alerting_setup_guide.md |
| **.sqlproj CI/CD** | Medium | **BLOCKED — needs Azure DevOps access**. SqlCmdVariable `$(...)` pattern documented. DO NOT convert SQL until sqlpackage deploy flow ready |
| **Multi-environment** | High | **BLOCKED — needs Azure DevOps access**. DEV → TEST → PROD via Fabric Deployment Pipelines |
| **GitHub Actions secrets** | Low | Need Service Principal (AZURE_CLIENT_ID/SECRET/TENANT_ID) for auto CSV refresh |
| ~~**DQ in pipeline**~~ | ~~Done~~ | ~~Fixed 2026-04-17: usp_check_dq_single + pl_dq_check + master pipeline integration~~ |
| ~~**Pipeline auto-trigger**~~ | ~~Done~~ | ~~Enabled 2026-04-18: Fabric Schedule daily 2:00 AM UTC+7, end 2099~~ |
| ~~**Runbook**~~ | ~~Done~~ | ~~Created 2026-04-18: runbook_operations.md — health check, errors, re-run, escalation~~ |
| ~~**sp_run_history**~~ | ~~Done~~ | ~~Verified 2026-04-18: already append-only (120 rows, 28 SPs). No DELETE in usp_log_run~~ |
| **Source-target reconciliation DQ** | Medium | Row count comparison source (Enterprise_Lakehouse) vs target (bronze). Not yet implemented |
| **Business logic DQ** | Low | Domain-specific rules (forecast accuracy ranges, trend anomaly). Future phase |

---

## 33. File Index — Tất cả docs trong repo

### Root

| File | Purpose |
|------|---------|
| README.md | 13-section public README |
| SESSION_CONTEXT.md | AI session context (chat history knowledge) |
| FULL_CONTEXT.md | ★ THIS FILE — everything in one place |
| .python-version | 3.11 |
| runtime.txt | python-3.11 (for Streamlit Cloud) |
| .gitignore | Large files, .claude/, _private/, .DS_Store |

### docs/ — Documentation

| Path | Type | Purpose |
|------|------|---------|
| docs/templates/architecture.md | Template | Generic architecture reference |
| docs/templates/pipeline_guide.md | Template | Generic pipeline execution trace |
| docs/templates/setup_guide.md | Template | Phase-by-phase setup DDL/SP templates |
| docs/supplychain/architecture.md | Project | All ~85 objects: names, rows, IDs, sources |
| docs/supplychain/pipeline.md | Project | Execution trace: actual SP names, durations |
| docs/supplychain/setup.md | Project | Implementation log: Spark→T-SQL conversions |
| docs/operations/onboarding.md | Guide | How DA/DE adds new ETL table (2 steps) |
| docs/operations/edw_source_swap.md | Guide | EDW source supplement: swap/rollback, verification, SM comparison |
| docs/operations/scheduling.md | Guide | Cron, smart skip, concurrency, snapshot fix |
| docs/operations/sqlproj_validation.md | Guide | 3 SQL validation approaches |
| docs/operations/timezone_sync.md | Guide | UTC+CST+VN, fn_GetDate mapping |
| docs/operations/generic_sp_migration.md | Guide | Migration: 28 SPs → 1 generic SP |
| docs/enterprise/multi_mart_scale.md | Guide | N marts parallel, cross-mart deps |
| docs/enterprise/fabric_vs_enterprise.md | Guide | Enterprise ETL framework vs v9 |

### lineage_explorer/ — Streamlit App

| File | Purpose |
|------|---------|
| app.py | Main Streamlit app (3 tabs) |
| requirements.txt | Python dependencies |
| templates/lineage.html | React SVG DAG renderer |
| data/lineage.csv | 52 lineage edges (auto-refresh 10min) |
| data/registry.csv | 28 tables config (auto-refresh 10min) |
| data/views.csv | 28 view SQL definitions (auto-refresh 10min) |
| data/run_history.csv | Recent SP execution history (auto-refresh 10min) |

---

*Built with Claude Code + Fabric MCP Server. ~4 days from zero to production-ready.*
*Tổng cộng ~1.47 tỷ rows, ~85 objects, 7 pipelines, 1 generic SP, 8 load patterns, 54 DQ rules (30 active). Multi-mart architecture. Health check: 49/49 PASS.*
