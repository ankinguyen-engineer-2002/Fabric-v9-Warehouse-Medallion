# Architecture v9 — Full Technical Detail
> SupplyChain_Warehouse · Fabric F256 · Warehouse-Native Medallion
> Build date: 2026-04-13
> Author: Claude Code + Aric Nguyen

---

# 1. OVERVIEW

v9 chuyen toan bo pipeline tu v8 (Notebook + Lakehouse + PySpark) sang **Warehouse + T-SQL + Stored Procedures**. Chay song song v8, khong dung v8.

| Hang muc | v8 | v9 |
|----------|----|----|
| Storage | SupplyChain_Lakehouse (Delta) | SupplyChain_Warehouse (native Parquet) |
| Compute | PySpark notebooks | T-SQL Stored Procedures |
| ETL logic | Python vars (COLUMN_SQL, SQL_TRANSFORM) | CREATE VIEW statements |
| Orchestration | Pipeline → ForEach → Notebook | Pipeline → ForEach → EXEC SP |
| Metadata | utl_pipeline_metadata (1 bang) | meta schema (7 tables + 6 SPs) |
| DAG | execution_order (cung) | depends_on + auto wave computation |
| DQ | Python nb_dq_engine (hardcode) | Config-driven dq_rules table |

**Tong objects v9**: 4 schemas · 28 data tables · 27 views · 28 SPs · 7 meta tables · 6 meta SPs/functions · 4 pipelines

---

# 2. SCHEMA DESIGN — 4 Schemas

## 2.1 `bronze` — Raw mirror tu Enterprise_Lakehouse

**18 tables** doc truc tiep tu Enterprise_Lakehouse qua 3-part naming.
Moi table co 3 objects: TABLE + VIEW + SP.

- VIEW = ETL logic (column mapping, CAST, TRIM, filter)
- SP = Execution (DROP + CTAS from view + log)
- TABLE = Materialized data (CTAS output)

**Naming**: `brz_{source_system}__{table}` hoac `ref_{entity}`

**Load patterns**:
- 17 tables: **overwrite** (DROP + CTAS moi lan)
- 1 table: **incremental** (brz_demandforecast — INSERT WHERE ts_snapshot > watermark)

**Source**: Enterprise_Lakehouse.{schema}.{table} (schema = folder name, khong phai dbo)

## 2.2 `silver` — Clean, conform, business rules

**8 tables** doc tu `bronze.*`, apply JOINs, CTEs, aggregations.
SQL logic chuyen tu Spark SQL sang T-SQL.

**Naming**: `slv_{business_concept}`
**Load pattern**: tat ca overwrite
**DAG**: depends_on column trong sp_registry → auto wave computation

## 2.3 `gold` — Business-ready cho Power BI

**2 tables** doc tu `silver.*` + `bronze.ref_*`.

**Naming**: `gld_{fact/dim}_{subject}` (prefix gld_ de tranh trung ten voi v8 dbo/test_sp)
**Load pattern**: tat ca overwrite

## 2.4 `meta` — System layer (all-in-one)

**7 tables + 5 SPs + 1 function + 1 view** — config, log, DQ, lineage, orchestration.
Gom tat ca system objects vao 1 schema. `dbo` giu sach.

---

# 3. META SCHEMA — Chi tiet tung object

## 3.1 Tables (7)

### meta.sp_registry (28 rows)
"Danh ba" — config moi SP: ten, view, load_type, frequency, depends_on, source_objects.
Pipeline Lookup doc bang nay de biet chay SP nao.

### meta.sp_run_history (34+ rows)
"Nhat ky" — moi lan SP chay = 1 dong (run_id, sp_name, start/end, rows, status, error).
usp_log_run ghi vao day.

### meta.dq_rules (30 rows)
"Luat kiem tra" — config DQ rules: check_type, column, severity, threshold.
Config-driven: them rule = INSERT 1 row.

### meta.dq_results (30 rows)
"Ket qua" — moi lan DQ chay = 1 dong (rule_id, status, actual_value, expected_value).

### meta.sp_lineage (52 rows)
"Ban do" — source→target edges. Auto-built boi usp_build_lineage tu source_objects JSON.

### meta.pipeline_run_log (0 rows)
"Nhat ky pipeline" — top-level pipeline run log.

### meta.slv_dag_waves_runtime (8 rows)
"Wave computation" — ket qua tinh wave cho silver DAG. Populated boi usp_compute_slv_waves.

## 3.2 Stored Procedures (5)

### meta.usp_log_run
Ghi log moi lan SP chay. Goi 2 lan: dau (running) + cuoi (success/failed).
Update sp_registry: last_load_date, rows_loaded, next_run_time.

### meta.usp_check_dq
DQ engine: doc dq_rules → sinh SQL → execute → ghi dq_results.
**Bug**: WHILE loop trong Fabric WH chi chay 1 iteration. Workaround: chay DQ tu Python/Pipeline.

### meta.usp_build_lineage
Parse source_objects JSON tu sp_registry → populate sp_lineage.

### meta.usp_compute_slv_waves
**Iterative wave computation** (thay recursive CTE — Fabric WH khong ho tro):
- Vong 1: assign wave 0 (SPs khong deps silver)
- Vong 2: assign wave 1 (SPs ma tat ca deps da assign)
- ...tiep tuc den khi het SP hoac max 30 waves
- Ket qua ghi vao slv_dag_waves_runtime

### meta.usp_run_silver_dag
SP orchestrator (backup — pipeline hybrid da thay the):
Compute waves → loop wave 0..N → loop SPs trong wave → EXEC.
Sequential trong wave. Dung khi pipeline Until khong kha dung.

## 3.3 Function (1)

### meta.ufn_should_run
Tra ve 1/0: is_active=1 AND (next_run_time IS NULL OR next_run_time <= GETUTCDATE()).

## 3.4 View (1)

### meta.vw_slv_dag_waves
View cu (3 CTE co dinh, max 3 waves). Da thay bang SP iterative. Giu lai de reference.

---

# 4. BRONZE LAYER — 18 Tables chi tiet

## 4.1 Source mapping

| v9 Table | Source (3-part) | Rows | Load |
|----------|----------------|------|------|
| brz_saleshistory_afi__invoicedetail | Enterprise_Lakehouse.SalesHistory_AFI.InvoiceDetail | 35,798,317 | overwrite |
| brz_saleshistory_afi__invoiceheader | Enterprise_Lakehouse.SalesHistory_AFI.InvoiceHeader | 4,044,847 | overwrite |
| brz_supplychain_enh_1__demandforecastsnapshotdaily | Enterprise_Lakehouse.SupplyChain_Enh_1.DemandForecastSnapshotDaily | 1,306,460,284 | **incremental** |
| brz_wholesale_codis_afi__codatan | Enterprise_Lakehouse.Wholesale_Codis_AFI.codatan | 918,213 | overwrite |
| brz_wholesale_codis_afi__comast | Enterprise_Lakehouse.Wholesale_Codis_AFI.COMAST | 229,461 | overwrite |
| brz_wholesale_codis_afi__extord | Enterprise_Lakehouse.Wholesale_Codis_AFI.EXTORD | 229,736 | overwrite |
| brz_wholesale_codis_afi__extorit | Enterprise_Lakehouse.Wholesale_Codis_AFI.EXTORIT | 912,132 | overwrite |
| ref_calendar | Enterprise_Lakehouse.MasterData_DW.DimDate | 21,551 | overwrite |
| ref_customer_account | Enterprise_Lakehouse.Customers.AccountMaster | 35,581 | overwrite |
| ref_customer_account_group | Enterprise_Lakehouse.Wholesale_ProductSourcing_AFI.CustomerGrouping | 35,454 | overwrite |
| ref_customer_grouping | Enterprise_Lakehouse.Wholesale_ProductSourcing_AFI.CustomerGrouping | 9 | overwrite |
| ref_customer_shipping_location | Enterprise_Lakehouse.Customers.ShippingLocations | 127,515 | overwrite |
| ref_forecast_cycle | SupplyChain_Lakehouse.dbo.ref_forecast_cycle | 43 | overwrite |
| ref_forecast_horizon | Hardcoded INSERT 8 rows | 8 | overwrite |
| ref_item_master | Enterprise_Lakehouse.MasterData_DW.DimItemMaster | 379,331 | overwrite |
| ref_order_type | Enterprise_Lakehouse.Wholesale_Codis_AFI.AAORDTYP | 29 | overwrite |
| ref_product | Enterprise_Lakehouse.SupplyChain_DW.DimCurrentProductDetails | 373,326 | overwrite |
| ref_warehouse | Enterprise_Lakehouse.SupplyChain_DW.DimAFIWarehouses | 55 | overwrite |

## 4.2 SP patterns

### Overwrite pattern (17 tables)
```sql
DROP TABLE IF EXISTS bronze.{table};
CREATE TABLE bronze.{table} AS
SELECT *, CAST(GETUTCDATE() AS DATETIME2(6)) AS _load_dt
FROM bronze.vw_{table};
```

### Incremental pattern (demandforecast only)
```sql
-- First run (no watermark): full load with cutoff
CREATE TABLE bronze.{table} AS SELECT ... FROM view WHERE ts_snapshot >= '2023-01-01';
-- Subsequent runs: append new rows
INSERT INTO bronze.{table} SELECT ... FROM view WHERE ts_snapshot > @last_watermark;
-- Update watermark in sp_registry
```

## 4.3 Spark SQL → T-SQL conversions

| Spark SQL | T-SQL |
|-----------|-------|
| CAST(x AS STRING) | CAST(x AS VARCHAR(200)) |
| to_date(CAST(x AS STRING), 'yyyyMMdd') | TRY_CONVERT(DATE, CAST(x AS VARCHAR(20))) |
| CAST(x AS TIMESTAMP) | TRY_CAST(x AS DATETIME2(6)) |
| CAST(x AS DOUBLE) | CAST(x AS FLOAT) |
| true/false | 1/0 (INT) |
| `column` (backtick) | [column] (bracket) |
| "string" (double quote) | 'string' (single quote) |
| GETUTCDATE() | CAST(GETUTCDATE() AS DATETIME2(6)) — trong CTAS |
| CURRENT_DATE() | CAST(GETDATE() AS DATE) |
| DATE_FORMAT(col, 'yyyy.MM') | FORMAT(col, 'yyyy.MM') |
| ADD_MONTHS(date, n) | DATEADD(MONTH, n, date) |
| DATE_TRUNC('year', date) | DATETRUNC(YEAR, date) |
| MAKE_DATE(y, m, d) | DATEFROMPARTS(y, m, d) |
| LIMIT 1 | TOP 1 |

---

# 5. SILVER LAYER — 8 Tables chi tiet

## 5.1 DAG Dependencies

```
Wave 0 (no silver deps, PARALLEL):
  slv_invoice_detail_line_level     ← brz_invoicedetail + invoiceheader + ref_cust_acct_group
  slv_forecast_demand_monthly       ← brz_demandforecast + ref_forecast_cycle + ref_calendar
  slv_open_order_line_level         ← brz_codatan + comast + extord + extorit + ref_item_master + ref_order_type

Wave 1 (depends wave 0, PARALLEL):
  slv_actual_demand_monthly         ← slv_invoice_detail + slv_open_order + ref_calendar
  slv_actual_demand_weekly          ← slv_invoice_detail + slv_open_order + ref_calendar
  slv_invoice_weekly                ← slv_invoice_detail + ref_calendar
  slv_open_order_monthly            ← slv_open_order + ref_calendar

Wave 2 (depends wave 1):
  slv_naive_forecast_monthly        ← slv_actual_demand_monthly + ref_calendar
```

## 5.2 Row counts

| Table | Rows |
|-------|------|
| slv_invoice_detail_line_level | 35,798,317 |
| slv_forecast_demand_monthly | 13,876,949 |
| slv_open_order_line_level | 258,197 |
| slv_actual_demand_monthly | 571,822 |
| slv_actual_demand_weekly | 1,102,162 |
| slv_invoice_weekly | 15,571,003 |
| slv_open_order_monthly | 119,575 |
| slv_naive_forecast_monthly | 346,792 |

---

# 6. GOLD LAYER — 2 Tables chi tiet

| Table | Source | Rows |
|-------|--------|------|
| gld_fact_flat_forecast_actual | UNION ALL: slv_actual + slv_forecast + slv_naive | 14,795,563 |
| gld_fact_forecast_kpi | CTE chain: forecast×horizon LEFT JOIN actuals + naive | 41,055,048 |

---

# 7. PIPELINE ARCHITECTURE

## 7.1 Topology

```
pl_sc_master (sequential)
  ├─ Execute pl_sc_bronze
  ├─ Execute pl_sc_silver
  └─ Execute pl_sc_gold
```

## 7.2 pl_sc_bronze
```
Lookup (LakehouseTableSource → cross-DB):
  SELECT sp_name FROM SupplyChain_Warehouse.meta.sp_registry
  WHERE layer IN ('BRZ','REF') AND is_active = 1
  ↓
ForEach (batch=8, PARALLEL):
  SqlServerStoredProcedure: EXEC @item().sp_name
  linkedService: SupplyChain_Warehouse (DataWarehouse endpoint)
```

## 7.3 pl_sc_silver (Hybrid DAG — auto-scale N waves)
```
[1] SqlServerStoredProcedure: EXEC meta.usp_compute_slv_waves
    → Tinh wave tu depends_on, ghi vao slv_dag_waves_runtime

[2] Lookup: SELECT MAX(wave) AS max_wave FROM slv_dag_waves_runtime

[3] Until (current_wave > max_wave):

    [3a] Lookup: SELECT sp_name WHERE wave = @current_wave
    [3b] ForEach (batch=8, PARALLEL): EXEC @item().sp_name
    [3c] SetVariable: next_wave = current_wave + 1
    [3d] SetVariable: current_wave = next_wave

    Variables: current_wave (String, "0"), next_wave (String, "0")
    Note: 2 variables de tranh self-reference (Fabric khong cho A = A + 1)
```

## 7.4 pl_sc_gold
```
Lookup: SELECT sp_name FROM sp_registry WHERE layer = 'GLD' AND is_active = 1
  ↓
ForEach (batch=2, PARALLEL):
  SqlServerStoredProcedure: EXEC @item().sp_name
```

## 7.5 Connection topology
```
Lookup activities: LakehouseTableSource
  → connectionSettings.type = Lakehouse
  → artifactId = SupplyChain_Lakehouse (62a3081e)
  → externalReferences.connection = b4311980 (Lakehouse connection)
  → sqlReaderQuery: cross-DB query → SupplyChain_Warehouse.meta.*

SP activities: SqlServerStoredProcedure
  → linkedService.type = DataWarehouse
  → endpoint = 7woj2w...datawarehouse.fabric.microsoft.com
  → artifactId = SupplyChain_Warehouse (e146ffe2)

Master invoke: InvokePipeline
  → externalReferences.connection = 3bee8b0e (pipeline connection)
```

---

# 8. DQ SYSTEM

## 8.1 Config-driven
Rules trong `meta.dq_rules`. Them/sua/xoa rule = INSERT/UPDATE/DELETE.

## 8.2 Check types
completeness (NOT NULL), uniqueness (PK), referential_integrity (FK), row_count (min/max), validity (value set), freshness (within N hours), custom_sql.

## 8.3 Hien trang
30 rules: 18 bronze + 8 silver + 4 gold. 30/30 PASS.

## 8.4 Known bug
`meta.usp_check_dq` WHILE loop chi chay 1 iteration trong Fabric WH. Workaround: chay DQ tu Python. TODO: viet lai SP hoac tich hop DQ vao Pipeline.

---

# 9. LINEAGE

52 edges tu dong sinh boi `meta.usp_build_lineage` (parse source_objects JSON).

```
Enterprise_Lakehouse (18 edges) → bronze (22 edges) → silver (8 cross-deps) → gold (7 edges)
```

---

# 10. FABRIC WAREHOUSE CONSTRAINTS

| Feature | Ho tro? | Workaround |
|---------|---------|------------|
| DEFAULT constraint | Khong | Xu ly trong SP khi INSERT |
| IDENTITY | Khong | ROW_NUMBER() hoac MAX(id)+1 |
| PRIMARY KEY / UNIQUE | Khong | DQ check uniqueness |
| CURSOR / @@FETCH_STATUS | Khong | WHILE + MIN(id) WHERE id > @current |
| Temp tables (#) | Khong | CTE hoac real table + DROP |
| Recursive CTE | Khong | SP iterative (WHILE loop) |
| DATETIME2 (no precision) | Khong | DATETIME2(6) bat buoc |
| datetime type | Khong trong CTAS | CAST(GETUTCDATE() AS DATETIME2(6)) |
| BIT type | Khong on dinh | Dung INT (0/1) |
| TRIM(numeric) | Khong | Bo TRIM hoac CAST VARCHAR truoc |
| nvarchar(4000) trong CTAS | Khong | CAST ve VARCHAR(n) |
| SetVariable self-reference | Khong | Dung 2 variables (temp + actual) |
| Warehouse Lookup trong Pipeline | Khong native | LakehouseTableSource + cross-DB query |

---

# 11. ALTERNATIVES CONSIDERED

| Van de | Phuong an thu | Ket qua | Phuong an chot |
|--------|--------------|---------|---------------|
| Bronze source | Doc tu SupplyChain_Lakehouse (v8 tables) | Phu thuoc v8 | **Doc tu Enterprise_Lakehouse** (doc lap) |
| Enterprise_Lakehouse access | 3-part dbo.* | 404 error | **3-part {schema}.{table}** (schema=folder) |
| Silver DAG | execution_order (cung) | Khong scale | **depends_on + iterative wave** |
| Wave computation | Recursive CTE | Khong ho tro Fabric WH | **SP iterative (WHILE loop)** |
| Wave view | 3 CTE co dinh | Max 3 waves | **SP + runtime table** (max 30 waves) |
| Silver pipeline | SP orchestrator (sequential) | Mat song song | **Hybrid Until loop** (parallel ForEach) |
| SetVariable loop | current_wave = current_wave + 1 | Self-reference error | **2 variables** (next_wave + current_wave) |
| Pipeline Lookup source | WarehouseSource + connectionSettings | "Failed to open resource" | **LakehouseTableSource + cross-DB** |
| Pipeline SP activity | Script activity | "ReferenceName null" | **SqlServerStoredProcedure + linkedService** |
| Gold table naming | fact_* | Trung ten v8 dbo/test_sp | **gld_fact_*** |
| DQ engine SP | WHILE + sp_executesql loop | Chi chay 1 iteration | **Python-side DQ** (workaround) |
| DQ threshold column | DECIMAL(10,4) | Overflow 1000000 | **DECIMAL(18,2)** |
| Dynamic SQL | VARCHAR @sql | sp_executesql reject | **NVARCHAR(4000)** |
| NVARCHAR cast | CAST AS NVARCHAR | Default 30 chars, truncate | **CAST AS NVARCHAR(200)** |

---

# 12. ROW COUNT VALIDATION v9 vs v8

## Bronze/REF: Gan khop (7 EXACT, 10 ~OK <0.5%)
Chenh nho do v9 doc source moi hon v8 (v8 load luc 2AM).

## Silver/Gold: Khac nhieu
Root cause: v8 silver doc tu `_ver2` tables (nhieu data hon base table). v9 doc tu Enterprise_Lakehouse base tables.
ETL logic dung — cung cong thuc, cung JOIN, cung filter. Chenh do nguon data khac.
