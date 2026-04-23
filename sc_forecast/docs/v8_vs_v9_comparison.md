# V8 → V9 Migration: So sanh kien truc & Source Data Mapping

> SupplyChain Warehouse — Microsoft Fabric | Ashley Furniture Vietnam
> Scan date: 2026-04-23 | Scanned live from workspace `c8d9fc83` via Fabric REST API
> Data source: M-code (Dataflow Gen2), notebook source (PySpark), pipeline JSON, folder structure

---

## 1. Tong quan kien truc

| Khia canh | V8 (Legacy) | V9 (Current) |
|-----------|-------------|--------------|
| **Storage** | SupplyChain_Lakehouse (Delta Lake) | SupplyChain_Warehouse (Synapse DW) |
| **Compute** | PySpark Notebooks (80 notebooks) | Pure T-SQL (1 generic SP) |
| **Cold start** | 30-60s (Spark init per notebook) | 0s (warehouse always warm) |
| **ETL logic** | Python variables (`COLUMN_SQL`, `SQL_TRANSFORM`) | SQL Views (SELECT tu source) |
| **Load engine** | 3 engine notebooks (brz/slv/gld_engine) | 1 generic SP (`usp_generic_load`, 8 load patterns) |
| **Orchestration** | Pipeline -> ForEach -> Notebook Activity | Pipeline -> ForEach -> SP call |
| **Metadata** | 1 bang (`utl_pipeline_metadata`) trong Lakehouse | 11 meta tables trong Warehouse |
| **DAG** | Static `execution_order` (integer cung: 1,2,3,4,5) | Dynamic `depends_on` JSON -> auto-compute waves |
| **DQ** | Python `nb_dq_engine` (hardcoded) | Config-driven 30 rules, 7 check types |
| **Lineage** | Khong co | Auto-built 52 edges tu `source_objects` JSON |
| **Schema** | `dbo` (flat, tat ca trong 1 schema) | 4 schemas: `bronze`, `silver`, `gold`, `meta` |
| **Version control** | Notebook JSON (kho diff) | SQL DDL files (git-friendly) |
| **Folder structure** | `01_Standard_Pipeline/{1_brz,2_slv,3_gld,...}` | `The future/` (pipelines + semantic model) |

---

## 2. NGUON GOC DU LIEU — Day la phan quan trong nhat

### 2.1 Chuoi du lieu tong the

```
                         V8 (Legacy)                                    V9 (Current)
                         ──────────                                     ──────────

  ┌─────────────────────────┐                           ┌─────────────────────────┐
  │  ASHLEY_EDW (SQL Server)│                           │  ASHLEY_EDW (SQL Server)│
  │  ashley-edw.database    │                           │  ashley-edw.database    │
  │  .windows.net           │                           │  .windows.net           │
  │  ─────────────────────  │                           │  ─────────────────────  │
  │  AFISales_DW            │                           │  (van la source goc,    │
  │  Enterprise_DW          │                           │   nhung team khac       │
  │  SupplyChain_DW         │                           │   quan ly ingestion)    │
  │  SupplyChain_Enh        │                           └──────────┬──────────────┘
  │  Wholesale_*            │                                      │
  │  PowerBI_SupplyChain    │                                      │ Dataflow Gen2
  └──────────┬──────────────┘                                      │ / Mirroring
             │                                                     │ (team khac)
             │ Dataflow Gen2                                       ▼
             │ (M-code: Sql.Database)               ┌─────────────────────────────┐
             ▼                                      │   Enterprise_Lakehouse      │
  ┌─────────────────────────────┐                   │   (584e7d2c) - SHARED       │
  │   Enterprise_Lakehouse      │                   │   Schemas:                  │
  │   (584e7d2c) - SHARED       │                   │     SalesHistory_AFI/       │
  │   Delta tables organized    │                   │     SupplyChain_Enh_1/      │
  │   by schema folders         │                   │     Wholesale_Codis_AFI/    │
  └──────────┬──────────────────┘                   │     MasterData_DW/          │
             │                                      │     Customers/              │
             │ abfss:// (Spark read Delta)          │     SupplyChain_DW/         │
             │ via brz_engine notebook              │     Wholesale_ProductSourcing│
             ▼                                      └──────────┬──────────────────┘
  ┌─────────────────────────────┐                              │
  │   SupplyChain_Lakehouse     │                              │ 3-part naming
  │   (62a3081e)                │                              │ (SQL Views)
  │   dbo.brz_*  (bronze)      │                              ▼
  │   dbo.slv_*  (silver)      │                   ┌─────────────────────────────┐
  │   dbo.gld_*  (gold)        │                   │   SupplyChain_Warehouse     │
  │   dbo.utl_*  (metadata)    │                   │   (e146ffe2)               │
  └──────────┬──────────────────┘                   │   bronze.*  (18 tables)    │
             │                                      │   silver.*  (8 tables)     │
             │ Direct Lake                          │   gold.*    (2 tables)     │
             ▼                                      │   meta.*    (11 tables)    │
  ┌─────────────────────┐                           └──────────┬──────────────────┘
  │ Supply Chain Control│                                      │ Direct Lake
  │ Tower (SM: 3eecf594)│                                      ▼
  └─────────────────────┘                           ┌─────────────────────┐
                                                    │ SC_Control_Tower    │
                                                    │ (SM: a52841ee)     │
                                                    └─────────────────────┘
```

### 2.2 V8: Source goc = ASHLEY_EDW (On-Prem SQL Server)

**Phat hien tu scan M-code thuc te**: TAT CA 18 Dataflow Gen2 deu doc tu cung 1 SQL Server:

```
Server:   ashley-edw.database.windows.net
Database: ASHLEY_EDW
```

**Bang mapping Dataflow → Source SQL → Destination**:

| Dataflow | M-code Source (Sql.Database) | SQL Query | Destination |
|---|---|---|---|
| `df_Wholesale_SalesHistory_AFI__InvoiceDetail` | `ASHLEY_EDW` | `SELECT * FROM Wholesale_SalesHistory_AFI.InvoiceDetail WHERE QuantityShipped > 0 AND CurrentRequestDate >= DATEADD(YEAR, -2, GETDATE())` | Enterprise_Lakehouse |
| `df_AFISales_DW__DimCustomers` | `ASHLEY_EDW` | `SELECT * FROM AFISales_DW.DimCustomers` | Enterprise_Lakehouse |
| `df_Enterprise_DW__DimDate` | `ASHLEY_EDW` | `SELECT * FROM Enterprise_DW.DimDate` | Enterprise_Lakehouse |
| `df_AFISales_DW__FactOpenOrders` | `ASHLEY_EDW` | `SELECT * FROM AFISales_DW.FactOpenOrders` | Enterprise_Lakehouse |
| `df_AFISales_DW__DimAshleyWarehouseMaster` | `ASHLEY_EDW` | `SELECT * FROM AFISales_DW.DimAshleyWarehouseMaster` | Enterprise_Lakehouse |
| `df_SupplyChain_DW__DimCurrentProductDetails` | `ASHLEY_EDW` | `SELECT * FROM SupplyChain_DW.DimCurrentProductDetails` | Enterprise_Lakehouse |
| `df_Wholesale_ProductSourcing_AFI__CustomerGrouping` | `ASHLEY_EDW` | `SELECT * FROM Wholesale_ProductSourcing_AFI.CustomerGrouping` | Enterprise_Lakehouse |
| `df_brz_SalesHistory_AFI_InvoiceDetail` | `ASHLEY_EDW` | Native SQL with TRIM, CAST, column aliasing | Enterprise_Lakehouse |
| `df_brz_SalesHistory_AFI_InvoiceHeader` | `ASHLEY_EDW` | Native SQL with TRIM, CAST | Enterprise_Lakehouse |
| `df_brz_SupplyChain_Enh_1_DemandForecastSnapshotDaily_copy1` | `ASHLEY_EDW` | Complex JOIN `SupplyChain_Enh.DemandForecastSnapshot` + `Enterprise_DW.DimDate`, filtered by 41 snapshot dates | Enterprise_Lakehouse |
| `df_ref_product` | `ASHLEY_EDW` | Native SQL with TRIM, CAST, FLAG logic | Enterprise_Lakehouse |
| `df_ref_forecast_cycle` | **SharePoint** | `SharePoint.Tables("https://masterashley.sharepoint.com/sites/SCPGlobalTeam")` | Enterprise_Lakehouse |
| `SharepointDaily` | **SharePoint** | 2 sources: SCPGlobalTeam + SCPGlobalTeam-Bedding1 (Excel workbook) | Warehouse |
| `SundayWeekly_TempADW` | `ASHLEY_EDW` | Multiple queries: InvoiceDetail, InvoiceHeader, InventoryActivity, WarehouseMaster | Warehouse |
| `temp_SCPDim` | `ASHLEY_EDW` | 5 queries: Calendar, CustomerAcctMaster, DimCurrentProductDetails, etc. | Warehouse |
| `OneTimeForecastSnapshotLoad` | `ASHLEY_EDW` | DemandForecastSnapshot + DimDate JOIN (one-time historical load) | SupplyChain_Lakehouse |
| `TempActualsLoad` | `ASHLEY_EDW` | CustomerAcctMaster + FactOpenOrders | SupplyChain_Lakehouse |
| `remove_df_SupplyChain_Enh__DemandForecastSnapshot` | `ASHLEY_EDW` | DemandForecastSnapshot filtered by 41 snapshot dates, 3-year window | Enterprise_Lakehouse |

### 2.3 EDW Schema Mapping — Tu ASHLEY_EDW den Enterprise_Lakehouse

| ASHLEY_EDW Schema | Table | -> | Enterprise_Lakehouse Path | V9 Bronze Table |
|---|---|---|---|---|
| `Wholesale_SalesHistory_AFI` | InvoiceDetail | -> | `SalesHistory_AFI/InvoiceDetail` | brz_saleshistory_afi__invoicedetail |
| `Wholesale_SalesHistory_AFI` | InvoiceHeader | -> | `SalesHistory_AFI/InvoiceHeader` | brz_saleshistory_afi__invoiceheader |
| `SupplyChain_Enh` | DemandForecastSnapshot | -> | `SupplyChain_Enh_1/DemandForecastSnapshotDaily` | brz_supplychain_enh_1__demandforecastsnapshotdaily |
| `Enterprise_DW` | DimDate | -> | `MasterData_DW/DimDate` | ref_calendar |
| `AFISales_DW` | DimCustomers | -> | `Customers/AccountMaster` | ref_customer_account |
| `AFISales_DW` | DimAshleyWarehouseMaster | -> | `SupplyChain_DW/DimAFIWarehouses` | ref_warehouse |
| `SupplyChain_DW` | DimCurrentProductDetails | -> | `SupplyChain_DW/DimCurrentProductDetails` | ref_product |
| `Wholesale_ProductSourcing_AFI` | CustomerGrouping | -> | `Wholesale_ProductSourcing_AFI/CustomerGrouping` | ref_customer_account_group |
| `AFISales_DW` | FactOpenOrders | -> | `Wholesale_Codis_AFI/{codatan,COMAST,EXTORD,EXTORIT}` | brz_wholesale_codis_afi__* |
| `PowerBI_SupplyChain` | CustomerAcctMaster_AFI | -> | `Customers/AccountMaster` | ref_customer_account |
| *(SharePoint)* | SCPGlobalTeam list | -> | `SupplyChain_Lakehouse.dbo/ref_forecast_cycle` | ref_forecast_cycle |

> **Quan trong**: Schema names THAY DOI giua EDW va Enterprise_Lakehouse. Vi du:
> - `Wholesale_SalesHistory_AFI` (EDW) -> `SalesHistory_AFI` (Lakehouse)
> - `Enterprise_DW` (EDW) -> `MasterData_DW` (Lakehouse)
> - `AFISales_DW` (EDW) -> `Customers` hoac `SupplyChain_DW` (Lakehouse)

### 2.4 3 Loai Source trong V8

| Loai Source | Connection | So luong Dataflows | Mo ta |
|---|---|---|---|
| **SQL Server (ASHLEY_EDW)** | `Sql.Database("ashley-edw.database.windows.net", "ASHLEY_EDW")` | 15/18 | Primary source - on-prem EDW |
| **SharePoint** | `SharePoint.Tables("https://masterashley.sharepoint.com/sites/SCPGlobalTeam")` | 2/18 | Forecast cycle dates, Bedding data |
| **Excel (via SharePoint)** | `Excel.Workbook(...)` | 1/18 | Bedding1 workbook |

### 2.5 V9: Source = Enterprise_Lakehouse (da duoc populate san)

Trong v9, **khong con Dataflow Gen2 nao** cho ETL. Source data da nam san trong Enterprise_Lakehouse (duoc populate boi team khac hoac cac dataflow cu van chay). V9 chi doc:

```sql
-- V9 bronze view (truc tiep, khong qua notebook)
CREATE VIEW bronze.vw_brz_saleshistory_afi__invoicedetail AS
SELECT [CustomerNumber] AS id_customer, ...
FROM Enterprise_Lakehouse.SalesHistory_AFI.InvoiceDetail;
```

**So sanh cach access source**:

| | V8 | V9 (14 tables via EL) | V9 (4 tables via _edw) |
|---|---|---|---|
| **Source location** | `abfss://c8d9fc83@onelake.../584e7d2c/Tables/{schema}/{table}` | `Enterprise_Lakehouse.{Schema}.{Table}` | `bronze.*_edw` (CTAS tu SC_Lakehouse `_ver2`) |
| **Access method** | Spark `spark.read.format("delta").load(path)` | T-SQL 3-part naming | T-SQL direct read (same warehouse) |
| **Intermediary** | brz_engine notebook (130+ lines Python) | SQL View (5-20 lines SQL) | SQL View (5-20 lines SQL) |
| **Transform** | `COLUMN_SQL` Python variable -> `spark.sql()` | SELECT with TRIM/CAST in VIEW | SELECT with TRIM/CAST in VIEW |
| **Output target** | `SupplyChain_Lakehouse.dbo.{table}` (Delta) | `SupplyChain_Warehouse.bronze.{table}` (Parquet) | Same |

> **Cap nhat 2026-04-23: EDW Source Supplement** — 4 Group A tables chuyen sang doc tu `_edw` tables vi EL co du lieu thieu (VD: invoicedetail 35M trong EL vs 87.7M trong EDW). Day la tam thoi — revert khi EL data day du. Chi tiet: [edw_source_swap.md](operations/edw_source_swap.md).

---

## 3. V8 Folder Structure — Scanned tu Workspace

```
ROOT/
  Enterprise_Lakehouse (584e7d2c)      -- Shared source
  SupplyChain_Lakehouse (62a3081e)     -- V8 output
  SupplyChain_Warehouse (e146ffe2)     -- V9 output
  
  01_Forecast_Project/                 -- V8 MAIN PROJECT
    01_Standard_Pipeline/              -- V8 PRODUCTION PIPELINE
      1_brz/                           -- 22 items
        brz_engine/                    -- Generic bronze loader notebook
        pl_brz_daily                   -- Bronze pipeline
        nb_brz_SalesHistory_AFI__InvoiceDetail
        nb_brz_SalesHistory_AFI__InvoiceHeader
        nb_brz_SupplyChain_Enh_1__DemandForecastSnapshotDaily
        nb_brz_Wholesale_Codis_AFI__codatan
        nb_brz_Wholesale_Codis_AFI__COMAST
        nb_brz_Wholesale_Codis_AFI__EXTORD
        nb_brz_Wholesale_Codis_AFI__EXTORIT
        nb_ref_calendar, nb_ref_customer_account, nb_ref_product...
        df_brz_SalesHistory_AFI_InvoiceDetail (Dataflow)
        df_brz_SalesHistory_AFI_InvoiceHeader (Dataflow)
        df_brz_SupplyChain_Enh_1_DemandForecastSnapshotDaily_copy1
        df_ref_product, df_ref_forecast_cycle
      2_slv/                           -- 9 items
        slv_engine/                    -- Generic silver loader notebook
        pl_slv_daily                   -- Silver pipeline
        nb_slv_invoice_detail_line_level
        nb_slv_actual_demand_monthly, nb_slv_actual_demand_weekly
        nb_slv_forecast_demand_monthly, nb_slv_naive_forecast_monthly
        nb_slv_invoice_weekly, nb_slv_open_order_line_level
        nb_slv_open_order_monthly
      3_gld/                           -- Gold layer
        gld_engine/                    -- Generic gold loader notebook
      4_env_config/                    -- Environment config notebook
      6_sp/                            -- Stored procedure pipeline
        pl_warehouse
      7_dq/                            -- DQ notebooks
        nb_dq_engine, nb_dq_after_brz, nb_utl_dq_setup
    test_data_dictionary/              -- 34 items (archived/removed notebooks)
  
  01_Forecast_Project_Mockup/          -- V8 EARLY PROTOTYPE
    df_AFISales_DW__DimCustomers       -- Old dataflows (direct EDW reads)
    df_Enterprise_DW__DimDate
    df_AFISales_DW__FactOpenOrders
    df_SupplyChain_DW__DimCurrentProductDetails
    df_Wholesale_SalesHistory_AFI__InvoiceDetail
    df_Wholesale_ProductSourcing_AFI__CustomerGrouping
    pipeline1, pl_forecast             -- Old prototype pipelines
    remove_nb_*                        -- 6 archived notebooks
  
  SCP_Dataflows/                       -- SharePoint + Temp dataflows
    SharepointDaily, SundayWeekly_TempADW, temp_SCPDim
    TempOneTimeLoads/
      OneTimeForecastSnapshotLoad, TempActualsLoad
  
  The future/                          -- V9 NEW ARCHITECTURE
    pl_sc_master, pl_sc_bronze, pl_sc_silver, pl_sc_silver_wave
    pl_sc_gold, pl_dq_check, pl_sc_mart
    Pipeline Alert Reflex
    SC_Control_Tower (Semantic Model)
```

---

## 4. So sanh Bronze Layer chi tiet

### V8: Dataflow → Enterprise_Lakehouse → brz_engine Notebook → SupplyChain_Lakehouse

**Buoc 1**: Dataflow Gen2 doc tu ASHLEY_EDW, ghi vao Enterprise_Lakehouse:
```
M-code (Power Query):
  Source = Sql.Database("ashley-edw.database.windows.net", "ASHLEY_EDW",
    [Query = "SELECT * FROM Wholesale_SalesHistory_AFI.InvoiceDetail..."])
  → Output: Enterprise_Lakehouse.SalesHistory_AFI.InvoiceDetail (Delta table)
```

**Buoc 2**: Bronze notebook khai bao source va transform:
```python
# nb_brz_SalesHistory_AFI__InvoiceDetail (cell 1)
TARGET_TABLE = "brz_saleshistory_afi__invoicedetail"
SOURCE_TABLE = "SalesHistory_AFI/InvoiceDetail"  # path trong Enterprise_Lakehouse

COLUMN_SQL = """
    SELECT
        TRIM(CustomerNumber)                       AS id_customer,
        TRIM(InvoiceNumber)                        AS id_invoice,
        CAST(QuantityShipped AS DECIMAL(12,3))     AS qty_shipped,
        CAST(InvoiceDate AS DATE)                  AS dt_invoice,
        ...
    FROM raw_source
    WHERE InvoiceNumber IS NOT NULL
      AND InvoiceDate >= '2023-01-01'
"""

# cell 2 - goi brz_engine
notebookutils.notebook.run("brz_engine", 7200, {
    "TARGET_TABLE": TARGET_TABLE,
    "SOURCE_TABLE": SOURCE_TABLE,
    "COLUMN_SQL":   COLUMN_SQL
})
```

**Buoc 3**: `brz_engine` notebook thuc thi:
```python
# brz_engine.py (generic, khong chinh)
SOURCE_BASE = "abfss://c8d9fc83@onelake.dfs.fabric.microsoft.com/584e7d2c/Tables"
SOURCE_PATH = f"{SOURCE_BASE}/{SOURCE_TABLE}"   # → Enterprise_Lakehouse path

df_raw = spark.read.format("delta").load(SOURCE_PATH)   # Doc tu Enterprise_Lakehouse
df_raw.createOrReplaceTempView("raw_source")
df_final = spark.sql(COLUMN_SQL)                         # Apply transform
df_final.write.format("delta").mode("overwrite") \
    .saveAsTable(f"SupplyChain_Lakehouse.dbo.{TARGET_TABLE}")  # Ghi vao SC_Lakehouse
```

### V9: SQL View → Generic SP → SupplyChain_Warehouse

**Chi can 2 SQL statements**:
```sql
-- 1. View doc truc tiep tu Enterprise_Lakehouse
CREATE VIEW bronze.vw_brz_saleshistory_afi__invoicedetail AS
SELECT
    TRIM([CustomerNumber])                         AS id_customer,
    TRIM([InvoiceNumber])                          AS id_invoice,
    CAST([QuantityShipped] AS DECIMAL(12,3))       AS qty_shipped,
    CAST([InvoiceDate] AS DATE)                    AS dt_invoice,
    ...
    CAST(GETUTCDATE() AS DATETIME2(6))             AS _load_dt
FROM Enterprise_Lakehouse.SalesHistory_AFI.InvoiceDetail
WHERE InvoiceNumber IS NOT NULL;

-- 2. Dang ky trong metadata
INSERT INTO meta.sp_registry (...) VALUES (...);
-- DONE. Pipeline tu dong pick up.
```

### So sanh truc tiep

| Khia canh | V8 Bronze | V9 Bronze |
|---|---|---|
| **Source** | Enterprise_Lakehouse via `abfss://` Spark read | Enterprise_Lakehouse via 3-part naming SQL |
| **Transform** | Python `COLUMN_SQL` variable -> `spark.sql()` | SQL VIEW (SELECT...FROM) |
| **Engine** | `brz_engine` notebook (130+ lines Python, retry logic, metadata update) | `usp_generic_load` SP (1 SP, 8 patterns) |
| **Output** | `SupplyChain_Lakehouse.dbo.{table}` (Delta) | `SupplyChain_Warehouse.bronze.{table}` (Parquet) |
| **Files per table** | 1 notebook (~30 lines) + 1 engine call | 1 VIEW + 1 INSERT row |
| **Metadata update** | Python code in brz_engine (exponential backoff retry) | SP handles automatically |
| **Scheduling gate** | Python: `if NEXT_RUN and now < NEXT_RUN` | SQL: `WHERE next_run_time <= GETUTCDATE()` in pipeline Lookup |
| **Cold start** | 30-60s (Spark init) | 0s |

---

## 5. So sanh Silver Layer chi tiet

### V8: slv_engine Notebook

```python
# nb_slv_invoice_detail_line_level (cell 1)
TARGET_TABLE = 'slv_invoice_detail_line_level'
LAKEHOUSE = "SupplyChain_Lakehouse"
DB = f'{LAKEHOUSE}.dbo'

SQL_TRANSFORM = f'''
SELECT
    INV.id_invoice, INV.id_order, INV.id_item_sku, ...
    UPPER(CG.code_customer_group) AS code_customer_group,
    IH.num_lead_time_days
FROM {DB}.brz_saleshistory_afi__invoicedetail_ver2 AS INV
LEFT JOIN {DB}.brz_saleshistory_afi__invoiceheader_ver2 AS IH
    ON INV.id_invoice = IH.id_invoice AND ...
LEFT JOIN {DB}.ref_customer_account_group AS CG
    ON CG.id_customer = INV.id_customer
'''
# cell 2
notebookutils.notebook.run("slv_engine", 7200, {
    "TARGET_TABLE": TARGET_TABLE,
    "SQL_TRANSFORM": SQL_TRANSFORM
})
```

- Doc tu `SupplyChain_Lakehouse.dbo.brz_*` (bronze output cua chinh v8)
- Transform = Python string SQL
- `slv_engine` doc tu lakehouse, ghi lai vao lakehouse

### V9: SQL View

```sql
CREATE VIEW silver.vw_slv_invoice_detail_line_level AS
SELECT
    INV.id_invoice, INV.id_order, INV.id_item_sku, ...
    UPPER(CG.code_customer_group) AS code_customer_group,
    IH.num_lead_time_days
FROM bronze.brz_saleshistory_afi__invoicedetail AS INV
LEFT JOIN bronze.brz_saleshistory_afi__invoiceheader AS IH
    ON INV.id_invoice = IH.id_invoice AND ...
LEFT JOIN bronze.ref_customer_account_group AS CG
    ON CG.id_customer = INV.id_customer;
```

- Doc tu `bronze.*` (cung warehouse, khac schema)
- Logic **GIONG HET** v8 — chi thay `{DB}.brz_*` bang `bronze.brz_*`

---

## 6. Pipeline Architecture

### V8: pl_master_daily (scanned definition)

```
pl_master_daily
  ├─ pl_brz_daily (invoke pipeline)
  │    ├─ Lookup: SELECT table_name, notebook_name
  │    │          FROM dbo.utl_pipeline_metadata
  │    │          WHERE layer='BRZ' AND execution_order=1
  │    └─ ForEach (batch=3): Notebook Activity (notebook_id = @item().notebook_name)
  │
  ├─ pl_slv_daily (invoke pipeline) [depends: pl_brz_daily Succeeded]
  │    ├─ Wave 1: Lookup WHERE layer='SLV' AND execution_order=2 → ForEach batch=3
  │    ├─ Wave 2: Lookup WHERE execution_order=3 → ForEach batch=3
  │    └─ Wave 3: Lookup WHERE execution_order=4 → ForEach batch=3
  │
  ├─ pl_gld_daily (invoke pipeline) [depends: pl_slv_daily Succeeded]
  │    ├─ Lookup WHERE layer='GLD' AND execution_order=5
  │    └─ ForEach (batch=3): Notebook Activity
  │
  ├─ pl_sp_daily (invoke pipeline) [depends: pl_gld_daily Succeeded]
  │    └─ Stored procedure execution
  │
  └─ Control Tower SM Refresh (PBISemanticModelRefresh)
       └─ Refresh tables: dim_customer_grouping, dim_calendar, dim_warehouse,
          dim_product, _Measure, dim_forecast_horizon,
          fact_flat_forecast_actual, fact_forecast_kpi
```

**V8 pipeline dac diem**:
- 5 activities, chay tuan tu
- Silver co 3 hardcoded waves (execution_order 2,3,4)
- batch=3 (thap hon v9)
- Retry = 0-1 (thap)
- Khong co DQ gate giua cac layer
- Khong co lineage rebuild
- Schedule: Cron interval 60 min (khong phai daily fixed)

### V9: pl_sc_master (7 pipelines)

```
pl_sc_master (319a8160)
  ├─ log_start (INSERT pipeline_run_log)
  ├─ pl_sc_bronze (Lookup sp_registry WHERE layer IN ('BRZ','REF') → ForEach batch=6)
  ├─ pl_dq_check (layer='BRZ','REF') ← 22 DQ rules
  ├─ pl_sc_silver (Parent: usp_compute_slv_waves → ForEach sequential)
  │    └─ pl_sc_silver_wave (Child: ForEach parallel per wave)
  ├─ pl_dq_check (layer='SLV') ← 8 DQ rules
  ├─ pl_sc_gold (Lookup → ForEach batch=2)
  ├─ pl_dq_check (layer='GLD') ← 4 DQ rules
  ├─ finalize (usp_build_lineage + update pipeline_run_log)
  └─ refresh_sm (SC_Control_Tower - Direct Lake)
```

**V9 pipeline dac diem**:
- 9 activities, co DQ gates
- Silver DAG tu dong compute (khong hardcode waves)
- batch=6 bronze, batch=2 gold
- Retry 3x/2s trong SP + 3x/60s trong pipeline
- Parent-child pattern cho silver
- Schedule: Daily 2AM UTC+7 (fixed)

---

## 7. Metadata System

### V8: utl_pipeline_metadata (1 table, Lakehouse)

```
Columns: table_name, layer, execution_order, load_type, watermark_column,
         primary_key, frequency, is_active, scheduled_hour,
         last_watermark_value, last_load_date, rows_loaded, status,
         next_run_time, error_message, pipeline_notes, source_tables
```
- Luu trong `SupplyChain_Lakehouse.dbo.utl_pipeline_metadata`
- Update boi Python code trong brz/slv/gld_engine
- Exponential backoff retry (max 15 retries) de tranh Delta conflict

### V9: 11 meta tables (Warehouse)

| Table | V8 tuong duong | Moi trong V9? |
|---|---|---|
| sp_registry | utl_pipeline_metadata (1 phan) | Upgrade: 22 cols vs ~15 cols |
| sp_run_history | *(khong co)* | NEW |
| dq_rules | *(hardcoded trong nb_dq_engine)* | NEW (config-driven) |
| dq_results | *(khong co)* | NEW |
| slv_dag_waves_runtime | *(hardcoded execution_order)* | NEW (auto-computed) |
| lineage | *(khong co)* | NEW |
| pipeline_run_log | *(khong co)* | NEW |
| view_definitions | *(khong co)* | NEW |
| performance_baseline | *(khong co)* | NEW (Phase 3) |
| pipeline_cost_log | *(khong co)* | NEW (Phase 3) |
| schema_contracts | *(khong co)* | NEW (Phase 3) |

---

## 8. Object Count

| Layer | V8 (Lakehouse) | V9 (Warehouse) |
|---|---|---|
| **Dataflows** | 18 (active + archived) | 0 (khong can) |
| **Notebooks** | 80 (28 active + 34 remove_ + 18 engine/util) | 0 |
| **Pipelines** | 9 (v8) + 7 (v9) = 16 total | 7 |
| **Bronze tables** | 18 (dbo.*) | 22 (bronze.* incl 4 _edw) + 18 views + 1 SP |
| **Silver tables** | 8 (dbo.*) | 8 (silver.*) + 8 views |
| **Gold tables** | 2 (dbo.*) | 2 (gold.*) + 2 views |
| **Meta tables** | 1 | 11 |
| **SPs** | 0 | 11 (10 meta + 1 bronze) |
| **Functions** | 0 | 3 |
| **Total objects** | ~110 items trong workspace | ~91 objects trong warehouse |

---

## 9. BANG TONG HOP: Source Mapping Bronze V8 vs V9

| # | Bronze Table | V8 Ultimate Source | V8 Intermediary | V8 Read Method | V9 Source | V9 Read Method |
|---|---|---|---|---|---|---|
| 1 | brz_saleshistory_afi__invoicedetail | `ASHLEY_EDW.Wholesale_SalesHistory_AFI.InvoiceDetail` | Dataflow → Enterprise_Lakehouse | Spark `abfss://...584e7d2c/Tables/SalesHistory_AFI/InvoiceDetail` | Enterprise_Lakehouse.SalesHistory_AFI.InvoiceDetail | SQL View 3-part naming |
| 2 | brz_saleshistory_afi__invoiceheader | `ASHLEY_EDW.Wholesale_SalesHistory_AFI.InvoiceHeader` | Dataflow → Enterprise_Lakehouse | Spark `abfss://` | Enterprise_Lakehouse.SalesHistory_AFI.InvoiceHeader | SQL View |
| 3 | brz_supplychain_enh_1__demandforecastsnapshotdaily | `ASHLEY_EDW.SupplyChain_Enh.DemandForecastSnapshot` + `Enterprise_DW.DimDate` JOIN | Dataflow (complex, 41 snapshot dates filter) | Spark `abfss://` | Enterprise_Lakehouse.SupplyChain_Enh_1.DemandForecastSnapshotDaily | SQL View (incremental) |
| 4-7 | brz_wholesale_codis_afi__* | `ASHLEY_EDW.AFISales_DW.FactOpenOrders` (partial) | Dataflow → Enterprise_Lakehouse | Spark `abfss://` | Enterprise_Lakehouse.Wholesale_Codis_AFI.{table} | SQL View |
| 8 | ref_order_type | `ASHLEY_EDW` (inferred) | Enterprise_Lakehouse | Spark `abfss://` | Enterprise_Lakehouse.Wholesale_Codis_AFI.AAORDTYP | SQL View |
| 9 | ref_calendar | `ASHLEY_EDW.Enterprise_DW.DimDate` | Dataflow → Enterprise_Lakehouse | Spark `abfss://` | Enterprise_Lakehouse.MasterData_DW.DimDate | SQL View |
| 10 | ref_item_master | `ASHLEY_EDW.Enterprise_DW.DimItemMaster` (inferred) | Enterprise_Lakehouse | Spark `abfss://` | Enterprise_Lakehouse.MasterData_DW.DimItemMaster | SQL View |
| 11 | ref_customer_account | `ASHLEY_EDW.AFISales_DW.DimCustomers` / `PowerBI_SupplyChain.CustomerAcctMaster_AFI` | Dataflow → Enterprise_Lakehouse | Spark `abfss://` | Enterprise_Lakehouse.Customers.AccountMaster | SQL View |
| 12 | ref_customer_shipping_location | `ASHLEY_EDW` (inferred) | Enterprise_Lakehouse | Spark `abfss://` | Enterprise_Lakehouse.Customers.ShippingLocations | SQL View |
| 13 | ref_product | `ASHLEY_EDW.SupplyChain_DW.DimCurrentProductDetails` | Dataflow → Enterprise_Lakehouse | Spark `abfss://` | Enterprise_Lakehouse.SupplyChain_DW.DimCurrentProductDetails | SQL View |
| 14 | ref_warehouse | `ASHLEY_EDW.AFISales_DW.DimAshleyWarehouseMaster` | Dataflow → Enterprise_Lakehouse | Spark `abfss://` | Enterprise_Lakehouse.SupplyChain_DW.DimAFIWarehouses | SQL View |
| 15-16 | ref_customer_account_group, ref_customer_grouping | `ASHLEY_EDW.Wholesale_ProductSourcing_AFI.CustomerGrouping` | Dataflow → Enterprise_Lakehouse | Spark `abfss://` | Enterprise_Lakehouse.Wholesale_ProductSourcing_AFI.CustomerGrouping | SQL View |
| 17 | ref_forecast_cycle | **SharePoint**: `masterashley.sharepoint.com/sites/SCPGlobalTeam` | Dataflow → SupplyChain_Lakehouse | Spark `abfss://` | SupplyChain_Lakehouse.dbo.ref_forecast_cycle | SQL View (legacy) |
| 18 | ref_forecast_horizon | *(manual/hardcoded)* | Notebook INSERT | Spark createDataFrame | *(hardcoded trong VIEW)* | SQL View |

---

## 10. Ket luan

### Ban chat migration V8 → V9:

**KHONG DOI**:
- Source goc van la `ASHLEY_EDW` (on-prem SQL Server) + SharePoint
- Enterprise_Lakehouse van la intermediary
- Business logic (JOINs, transforms, column mappings) giong nhau
- 28 tables, cung KPIs, cung semantic model tables

**THAY DOI**:

| | V8 | V9 | Ly do |
|---|---|---|---|
| **Ingestion** | Dataflow Gen2 (M-code) doc tu EDW, ghi Enterprise_Lakehouse | Enterprise_Lakehouse da co san (team khac quan ly) | Tach biet trach nhiem |
| **Bronze ETL** | `brz_engine` notebook (Spark, abfss://) | SQL View + generic SP | Zero cold-start, git-friendly |
| **Silver ETL** | `slv_engine` notebook (Spark SQL) | SQL View + generic SP | Tuong tu |
| **Gold ETL** | `gld_engine` notebook | SQL View + generic SP | Tuong tu |
| **DAG** | `execution_order` (1,2,3,4,5) hardcode | `depends_on` JSON → auto waves | Flexible, self-documenting |
| **DQ** | `nb_dq_engine` Python notebook | Config-driven SP + pipeline ForEach | 30 rules, 7 types |
| **Lineage** | Khong co (chi co `source_tables` text) | Auto-built 52 edges | Observability |
| **Total code** | ~80 notebooks + ~3000 lines Python | ~28 views + ~500 lines SQL + 1 SP | 80% less code |
| **Retry** | Python exponential backoff (metadata only) | 3-layer: SP + pipeline + batch size | Robust |
| **Parallelism** | batch=3, no retry | batch=6 (brz), dynamic waves (slv) | 2x throughput |
