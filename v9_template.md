# Warehouse-Native Medallion — Architecture Template
> Fabric T-SQL · Metadata-driven · DAG orchestration
> Applicable to any Fabric Warehouse project

---

## 1. Architecture Pattern

```
Source Lakehouse (shortcuts / external data)
        │
        ▼
┌─────────────────────────────────────────────────┐
│            Fabric Warehouse                      │
│                                                  │
│   ┌──────────┐   ┌──────────┐   ┌──────────┐   │
│   │  bronze   │──▶│  silver   │──▶│   gold   │   │
│   │ raw mirror│   │ transform │   │ BI-ready │   │
│   └──────────┘   └──────────┘   └──────────┘   │
│                                                  │
│   ┌──────────────────────────────────────────┐  │
│   │              meta                         │  │
│   │  config · log · DQ · lineage · DAG        │  │
│   └──────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
        │
        ▼
   Power BI Direct Lake
```

### 4 Schemas

| Schema | Role | Contains |
|--------|------|----------|
| `bronze` | Raw mirror from source | Tables + Views (ETL logic) + SPs (load) |
| `silver` | Clean, join, business rules | Tables + Views + SPs |
| `gold` | Business-ready facts/dims | Tables + Views + SPs |
| `meta` | System control plane | Config tables + Log tables + Utility SPs/functions |

### Design Principles
- **Pure T-SQL** — no Notebooks, no PySpark, no Lakehouse ETL
- **3-file-per-table** — VIEW (logic) + SP (execution) + TABLE (data)
- **Metadata-driven** — adding a table = INSERT 1 row, no pipeline change
- **DAG orchestration** — `depends_on` column, auto wave computation
- **Config-driven DQ** — rules in table, not hardcoded

---

## 2. Warehouse Structure Template

```
{Warehouse_Name}/
│
├── bronze/
│   ├── Tables/
│   │   ├── brz_{source_system}__{entity}          ← raw mirror
│   │   └── ref_{entity}                            ← reference/dimension
│   ├── Views/
│   │   ├── vw_brz_{source_system}__{entity}        ← ETL: SELECT FROM source
│   │   └── vw_ref_{entity}                         ← ETL: SELECT FROM source
│   └── Stored Procedures/
│       ├── usp_load_brz_{source_system}__{entity}  ← DROP + CTAS
│       └── usp_load_ref_{entity}                   ← DROP + CTAS
│
├── silver/
│   ├── Tables/
│   │   └── slv_{business_concept}                  ← cleaned/joined
│   ├── Views/
│   │   └── vw_slv_{business_concept}               ← ETL: JOINs, CTEs, transforms
│   └── Stored Procedures/
│       └── usp_load_slv_{business_concept}         ← DROP + CTAS
│
├── gold/
│   ├── Tables/
│   │   └── gld_{fact|dim}_{subject}                ← BI-ready
│   ├── Views/
│   │   └── vw_gld_{fact|dim}_{subject}             ← ETL: aggregation, UNION
│   └── Stored Procedures/
│       └── usp_load_gld_{fact|dim}_{subject}       ← DROP + CTAS
│
└── meta/
    ├── Tables/
    │   ├── sp_registry                  ← config: what SP, how, when, depends on
    │   ├── sp_run_history               ← log: every SP execution
    │   ├── dq_rules                     ← config: DQ check definitions
    │   ├── dq_results                   ← log: DQ check outcomes
    │   ├── sp_lineage                   ← map: source → target edges
    │   ├── pipeline_run_log             ← log: pipeline-level runs
    │   └── slv_dag_waves_runtime        ← runtime: wave computation results
    │
    ├── Stored Procedures/
    │   ├── usp_log_run                  ← log SP start/end/rows/status
    │   ├── usp_check_dq                 ← DQ engine: read rules → execute → log
    │   ├── usp_build_lineage            ← parse source_objects → build lineage
    │   ├── usp_compute_slv_waves        ← iterative DAG wave computation
    │   └── usp_run_silver_dag           ← orchestrator (backup, sequential)
    │
    └── Functions/
        └── ufn_should_run               ← check schedule gate (1/0)
```

---

## 3. Naming Convention

| Schema | Table | View | SP |
|--------|-------|------|----|
| bronze | `brz_{source}__{table}` / `ref_{entity}` | `vw_brz_*` / `vw_ref_*` | `usp_load_brz_*` / `usp_load_ref_*` |
| silver | `slv_{concept}` | `vw_slv_{concept}` | `usp_load_slv_{concept}` |
| gold | `gld_{fact\|dim}_{subject}` | `vw_gld_*` | `usp_load_gld_*` |
| meta | descriptive (sp_registry, dq_rules...) | `vw_*` | `usp_*` / `ufn_*` |

Column naming:
- `id_*` — identifiers/keys
- `code_*` — codes/categories
- `name_*` — descriptive names
- `qty_*` — quantities
- `amt_*` — monetary amounts
- `dt_*` — dates
- `num_*` — numeric values
- `ts_*` — timestamps
- `pct_*` — percentages
- `val_*` — calculated values
- `is_*` — boolean flags (INT 0/1)
- `sk_*` — surrogate keys

---

## 4. Meta Tables — DDL Templates

### meta.sp_registry
```sql
CREATE TABLE meta.sp_registry (
    sp_name                 VARCHAR(200)    NOT NULL,    -- full name: schema.usp_load_xxx
    view_name               VARCHAR(200)    NULL,        -- schema.vw_xxx (NULL if hardcoded)
    target_schema           VARCHAR(50)     NOT NULL,    -- bronze / silver / gold
    target_table            VARCHAR(200)    NOT NULL,    -- table name without schema
    layer                   VARCHAR(10)     NOT NULL,    -- BRZ / REF / SLV / GLD
    load_type               VARCHAR(20)     NOT NULL,    -- overwrite / incremental / upsert / scd2
    frequency               VARCHAR(20)     NOT NULL,    -- daily / hourly / weekly / monthly
    scheduled_hour          INT             NULL,        -- UTC hour
    execution_order         INT             NOT NULL,    -- 1=BRZ/REF, 2-4=SLV, 5=GLD
    parallel_group          INT             NULL,
    depends_on              VARCHAR(500)    NULL,        -- JSON: ["silver.usp_load_slv_xxx"]
    source_objects          VARCHAR(2000)   NULL,        -- JSON: ["Enterprise_Lakehouse.schema.table"]
    watermark_column        VARCHAR(100)    NULL,        -- for incremental load
    primary_key             VARCHAR(500)    NULL,        -- for upsert/MERGE
    is_active               INT             NOT NULL,    -- 0/1
    last_load_date          DATETIME2(6)    NULL,
    last_watermark_value    VARCHAR(200)    NULL,
    next_run_time           DATETIME2(6)    NULL,
    rows_loaded             BIGINT          NULL,
    project                 VARCHAR(50)     NULL         -- multi-project support
);
```

### meta.sp_run_history
```sql
CREATE TABLE meta.sp_run_history (
    run_id                  VARCHAR(36)     NOT NULL,    -- NEWID() per execution
    pipeline_run_id         VARCHAR(36)     NULL,
    sp_name                 VARCHAR(200)    NOT NULL,
    start_time              DATETIME2(6)    NOT NULL,
    end_time                DATETIME2(6)    NULL,
    duration_seconds        INT             NULL,
    rows_affected           BIGINT          NULL,
    status                  VARCHAR(20)     NOT NULL,    -- running/success/failed/skipped
    error_message           VARCHAR(4000)   NULL,
    load_type               VARCHAR(20)     NULL
);
```

### meta.dq_rules
```sql
CREATE TABLE meta.dq_rules (
    rule_id                 INT             NOT NULL,
    rule_name               VARCHAR(200)    NOT NULL,
    target_schema           VARCHAR(50)     NOT NULL,
    target_table            VARCHAR(200)    NOT NULL,
    check_type              VARCHAR(30)     NOT NULL,    -- completeness/uniqueness/row_count/freshness/custom_sql
    column_name             VARCHAR(100)    NULL,
    severity                VARCHAR(10)     NOT NULL,    -- CRITICAL/WARNING/INFO
    threshold               DECIMAL(18,2)   NULL,
    params                  VARCHAR(1000)   NULL,        -- JSON for extra config
    is_active               INT             NOT NULL,
    layer                   VARCHAR(10)     NOT NULL
);
```

### meta.dq_results
```sql
CREATE TABLE meta.dq_results (
    result_id               INT             NOT NULL,
    pipeline_run_id         VARCHAR(36)     NULL,
    rule_id                 INT             NOT NULL,
    check_time              DATETIME2(6)    NOT NULL,
    status                  VARCHAR(10)     NOT NULL,    -- PASS/FAIL
    actual_value            VARCHAR(500)    NULL,
    expected_value          VARCHAR(500)    NULL,
    error_detail            VARCHAR(4000)   NULL
);
```

### meta.sp_lineage
```sql
CREATE TABLE meta.sp_lineage (
    lineage_id              INT             NOT NULL,
    source_schema           VARCHAR(100)    NOT NULL,
    source_table            VARCHAR(200)    NOT NULL,
    target_schema           VARCHAR(100)    NOT NULL,
    target_table            VARCHAR(200)    NOT NULL,
    relationship_type       VARCHAR(20)     NULL,        -- direct/join/union/lookup
    sp_name                 VARCHAR(200)    NULL
);
```

### meta.pipeline_run_log
```sql
CREATE TABLE meta.pipeline_run_log (
    pipeline_run_id         VARCHAR(36)     NOT NULL,
    pipeline_name           VARCHAR(100)    NOT NULL,
    status                  VARCHAR(20)     NOT NULL,
    start_time              DATETIME2(6)    NOT NULL,
    end_time                DATETIME2(6)    NULL,
    tables_succeeded        INT             NULL,
    tables_failed           INT             NULL,
    dq_failures_critical    INT             NULL,
    notes                   VARCHAR(2000)   NULL
);
```

### meta.slv_dag_waves_runtime
```sql
CREATE TABLE meta.slv_dag_waves_runtime (
    sp_name                 VARCHAR(200)    NOT NULL,
    wave                    INT             NOT NULL
);
```

---

## 5. SP Templates

### 5.1 Data Load SP (overwrite)
```sql
CREATE OR ALTER PROCEDURE {schema}.usp_load_{table} AS
BEGIN
    DECLARE @run_id VARCHAR(36) = CONVERT(VARCHAR(36), NEWID());
    DECLARE @rows BIGINT;
    EXEC meta.usp_log_run @run_id, '{schema}.usp_load_{table}', 'running',
         @load_type = 'overwrite';
    BEGIN TRY
        DROP TABLE IF EXISTS {schema}.{table};
        CREATE TABLE {schema}.{table} AS
        SELECT *, CAST(GETUTCDATE() AS DATETIME2(6)) AS _load_dt
        FROM {schema}.vw_{table};
        SELECT @rows = COUNT(*) FROM {schema}.{table};
        EXEC meta.usp_log_run @run_id, '{schema}.usp_load_{table}', 'success',
             @rows_affected = @rows, @load_type = 'overwrite';
    END TRY
    BEGIN CATCH
        DECLARE @err VARCHAR(4000) = ERROR_MESSAGE();
        EXEC meta.usp_log_run @run_id, '{schema}.usp_load_{table}', 'failed',
             @error_message = @err, @load_type = 'overwrite';
        THROW;
    END CATCH
END
```

### 5.2 Data Load SP (incremental)
```sql
CREATE OR ALTER PROCEDURE {schema}.usp_load_{table} AS
BEGIN
    DECLARE @run_id VARCHAR(36) = CONVERT(VARCHAR(36), NEWID());
    DECLARE @rows BIGINT;
    DECLARE @last_wm VARCHAR(200);
    DECLARE @new_wm VARCHAR(200);
    DECLARE @table_exists INT = 0;

    EXEC meta.usp_log_run @run_id, '{schema}.usp_load_{table}', 'running',
         @load_type = 'incremental';
    BEGIN TRY
        SELECT @table_exists = COUNT(*) FROM sys.tables t
        JOIN sys.schemas s ON t.schema_id = s.schema_id
        WHERE s.name = '{schema}' AND t.name = '{table}';

        SELECT @last_wm = last_watermark_value FROM meta.sp_registry
        WHERE sp_name = '{schema}.usp_load_{table}';

        IF @table_exists = 0 OR @last_wm IS NULL
        BEGIN
            -- First run: full load with cutoff
            DROP TABLE IF EXISTS {schema}.{table};
            CREATE TABLE {schema}.{table} AS
            SELECT *, CAST(GETUTCDATE() AS DATETIME2(6)) AS _load_dt
            FROM {schema}.vw_{table}
            WHERE {watermark_column} >= CAST(@cutoff AS DATETIME2(6));
            SELECT @rows = COUNT(*) FROM {schema}.{table};
        END
        ELSE
        BEGIN
            -- Subsequent: append new rows only
            INSERT INTO {schema}.{table}
            SELECT *, CAST(GETUTCDATE() AS DATETIME2(6)) AS _load_dt
            FROM {schema}.vw_{table}
            WHERE {watermark_column} > CAST(@last_wm AS DATETIME2(6));
            SELECT @rows = @@ROWCOUNT;
        END

        SELECT @new_wm = CAST(MAX({watermark_column}) AS VARCHAR(200))
        FROM {schema}.{table};
        UPDATE meta.sp_registry SET last_watermark_value = @new_wm
        WHERE sp_name = '{schema}.usp_load_{table}';

        EXEC meta.usp_log_run @run_id, '{schema}.usp_load_{table}', 'success',
             @rows_affected = @rows, @load_type = 'incremental';
    END TRY
    BEGIN CATCH
        DECLARE @err VARCHAR(4000) = ERROR_MESSAGE();
        EXEC meta.usp_log_run @run_id, '{schema}.usp_load_{table}', 'failed',
             @error_message = @err, @load_type = 'incremental';
        THROW;
    END CATCH
END
```

### 5.3 meta.usp_log_run
```sql
CREATE OR ALTER PROCEDURE meta.usp_log_run
    @run_id VARCHAR(36), @sp_name VARCHAR(200), @status VARCHAR(20),
    @rows_affected BIGINT = NULL, @error_message VARCHAR(4000) = NULL,
    @pipeline_run_id VARCHAR(36) = NULL, @load_type VARCHAR(20) = NULL
AS
BEGIN
    IF @status = 'running'
        INSERT INTO meta.sp_run_history (run_id, pipeline_run_id, sp_name, start_time, status, load_type)
        VALUES (@run_id, @pipeline_run_id, @sp_name, CAST(GETUTCDATE() AS DATETIME2(6)), 'running', @load_type);
    ELSE
    BEGIN
        UPDATE meta.sp_run_history
        SET end_time = CAST(GETUTCDATE() AS DATETIME2(6)),
            duration_seconds = DATEDIFF(SECOND, start_time, GETUTCDATE()),
            rows_affected = @rows_affected, status = @status, error_message = @error_message
        WHERE run_id = @run_id;

        UPDATE meta.sp_registry
        SET last_load_date = CAST(GETUTCDATE() AS DATETIME2(6)), rows_loaded = @rows_affected,
            next_run_time = CASE
                WHEN frequency = 'daily'   THEN DATEADD(DAY, 1, CAST(GETUTCDATE() AS DATE))
                WHEN frequency = 'hourly'  THEN DATEADD(HOUR, 1, GETUTCDATE())
                WHEN frequency = 'weekly'  THEN DATEADD(WEEK, 1, CAST(GETUTCDATE() AS DATE))
                WHEN frequency = 'monthly' THEN DATEADD(MONTH, 1, CAST(GETUTCDATE() AS DATE))
                ELSE DATEADD(DAY, 1, CAST(GETUTCDATE() AS DATE)) END
        WHERE sp_name = @sp_name;
    END
END
```

### 5.4 meta.usp_compute_slv_waves
```sql
CREATE OR ALTER PROCEDURE meta.usp_compute_slv_waves AS
BEGIN
    DELETE FROM meta.slv_dag_waves_runtime;
    DECLARE @wave INT = 0, @assigned INT = 0, @new_count INT = 1, @total INT, @max_waves INT = 30;

    SELECT @total = COUNT(*) FROM meta.sp_registry WHERE layer = 'SLV' AND is_active = 1;

    -- Wave 0: no silver deps
    INSERT INTO meta.slv_dag_waves_runtime (sp_name, wave)
    SELECT sp_name, 0 FROM meta.sp_registry
    WHERE layer = 'SLV' AND is_active = 1
    AND (depends_on IS NULL OR depends_on NOT LIKE '%silver.usp_%');

    SELECT @assigned = COUNT(*) FROM meta.slv_dag_waves_runtime;
    SET @wave = 1;

    -- Iterate: assign next wave when ALL deps are in previous waves
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

---

## 6. Pipeline Templates

### 6.1 Master Pipeline
```
pl_{project}_master (sequential, concurrency=1):
  [1] Execute pl_{project}_bronze
  [2] Execute pl_{project}_silver
  [3] Execute pl_{project}_gold
```

### 6.2 Bronze/Gold Pipeline (Lookup + ForEach)
```
pl_{project}_{layer}:
  [1] Lookup (LakehouseTableSource, cross-DB):
      SELECT sp_name FROM {Warehouse}.meta.sp_registry
      WHERE layer = '{LAYER}' AND is_active = 1

  [2] ForEach (batch=N, PARALLEL):
      SqlServerStoredProcedure: EXEC @item().sp_name
      linkedService: {Warehouse} (DataWarehouse endpoint)
```

### 6.3 Silver Pipeline (Hybrid DAG — auto-scale N waves)
```
pl_{project}_silver:
  variables: current_wave="0", next_wave="0"

  [1] SP: EXEC meta.usp_compute_slv_waves
      → compute DAG waves from depends_on

  [2] Lookup: SELECT MAX(wave) AS max_wave
      → know how many waves

  [3] Until (current_wave > max_wave):
      [3a] Lookup: SELECT sp_name WHERE wave = @current_wave
      [3b] ForEach (batch=N, PARALLEL): EXEC @item().sp_name
      [3c] SetVariable: next_wave = current_wave + 1
      [3d] SetVariable: current_wave = next_wave
```

### Connection Pattern
```
Lookup: LakehouseTableSource + connectionSettings + Lakehouse connection
        sqlReaderQuery: cross-DB → {Warehouse}.meta.sp_registry

SP:     SqlServerStoredProcedure + linkedService (DataWarehouse endpoint)

Invoke: InvokePipeline + externalReferences.connection
```

---

## 7. Adding a New Table — Checklist

### Bronze table
- [ ] CREATE VIEW bronze.vw_brz_{name} AS SELECT ... FROM {Source_Lakehouse}.{schema}.{table}
- [ ] CREATE PROCEDURE bronze.usp_load_brz_{name} (copy overwrite template)
- [ ] INSERT INTO meta.sp_registry (sp_name, layer='BRZ', ...)
- [ ] INSERT INTO meta.dq_rules (completeness + row_count)
- [ ] EXEC SP to load data
- [ ] Verify: row count, DQ pass

### Silver table
- [ ] CREATE VIEW silver.vw_slv_{name} AS SELECT ... FROM bronze.* JOIN ...
- [ ] CREATE PROCEDURE silver.usp_load_slv_{name} (copy overwrite template)
- [ ] INSERT INTO meta.sp_registry (layer='SLV', depends_on='["silver.usp_load_slv_xxx"]')
- [ ] INSERT INTO meta.dq_rules
- [ ] Pipeline auto picks up via wave computation — no pipeline change needed

### Gold table
- [ ] CREATE VIEW gold.vw_gld_{name} AS SELECT ... FROM silver.*
- [ ] CREATE PROCEDURE gold.usp_load_gld_{name} (copy overwrite template)
- [ ] INSERT INTO meta.sp_registry (layer='GLD', depends_on=...)
- [ ] INSERT INTO meta.dq_rules

---

## 8. Fabric Warehouse Constraints

| Not supported | Workaround |
|---------------|------------|
| DEFAULT constraint | Handle in SP |
| IDENTITY | ROW_NUMBER() or MAX(id)+1 |
| PRIMARY KEY / UNIQUE | DQ uniqueness check |
| CURSOR / @@FETCH_STATUS | WHILE + MIN(id) pattern |
| Temp tables (#) | CTE or real table |
| Recursive CTE | SP iterative loop |
| DATETIME2 (no precision) | Always DATETIME2(6) |
| datetime in CTAS | CAST(GETUTCDATE() AS DATETIME2(6)) |
| BIT type | INT (0/1) |
| TRIM(numeric) | CAST to VARCHAR first |
| nvarchar(4000) in CTAS | CAST to VARCHAR(n) |
| SetVariable self-reference | Use 2 variables |
| Warehouse Lookup in Pipeline | LakehouseTableSource + cross-DB |
