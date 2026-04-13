# Architecture v9 — Overview & Template
> SupplyChain_Warehouse · Warehouse-Native Medallion
> 4 Schemas · 28 Tables · 4 Pipelines

---

## 1. Data Flow

```
Enterprise_Lakehouse (US team, source of truth)
        │
        ▼
┌─────────────────────────────────────────────────┐
│            SupplyChain_Warehouse                │
│                                                 │
│   ┌──────────┐   ┌──────────┐   ┌──────────┐  │
│   │  bronze   │──▶│  silver   │──▶│   gold   │  │
│   │ 18 tables │   │ 8 tables  │   │ 2 tables │  │
│   │ raw mirror│   │ clean+join│   │ BI-ready │  │
│   └──────────┘   └──────────┘   └──────────┘  │
│                                                 │
│   ┌────────────────────────────────────────┐   │
│   │              meta                       │   │
│   │  7 tables · 5 SPs · 1 function         │   │
│   │  config · log · DQ · lineage · DAG      │   │
│   └────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
        │
        ▼
   Power BI Direct Lake
```

---

## 2. Warehouse Structure (Tree View)

```
SupplyChain_Warehouse/
│
├── bronze/
│   ├── Tables/
│   │   ├── brz_saleshistory_afi__invoicedetail        (35.8M rows)
│   │   ├── brz_saleshistory_afi__invoiceheader         (4.0M rows)
│   │   ├── brz_supplychain_enh_1__demandforecast...    (1.3B rows)
│   │   ├── brz_wholesale_codis_afi__codatan            (918K rows)
│   │   ├── brz_wholesale_codis_afi__comast             (229K rows)
│   │   ├── brz_wholesale_codis_afi__extord             (230K rows)
│   │   ├── brz_wholesale_codis_afi__extorit            (912K rows)
│   │   ├── ref_calendar                                (22K rows)
│   │   ├── ref_customer_account                        (36K rows)
│   │   ├── ref_customer_account_group                  (35K rows)
│   │   ├── ref_customer_grouping                       (9 rows)
│   │   ├── ref_customer_shipping_location              (128K rows)
│   │   ├── ref_forecast_cycle                          (43 rows)
│   │   ├── ref_forecast_horizon                        (8 rows)
│   │   ├── ref_item_master                             (379K rows)
│   │   ├── ref_order_type                              (29 rows)
│   │   ├── ref_product                                 (373K rows)
│   │   └── ref_warehouse                               (55 rows)
│   │
│   ├── Views/
│   │   ├── vw_brz_saleshistory_afi__invoicedetail      → Enterprise_Lakehouse.SalesHistory_AFI.InvoiceDetail
│   │   ├── vw_brz_saleshistory_afi__invoiceheader      → Enterprise_Lakehouse.SalesHistory_AFI.InvoiceHeader
│   │   ├── vw_brz_supplychain_enh_1__demandforecast... → Enterprise_Lakehouse.SupplyChain_Enh_1.DemandForecast...
│   │   ├── vw_brz_wholesale_codis_afi__codatan         → Enterprise_Lakehouse.Wholesale_Codis_AFI.codatan
│   │   ├── vw_brz_wholesale_codis_afi__comast          → Enterprise_Lakehouse.Wholesale_Codis_AFI.COMAST
│   │   ├── vw_brz_wholesale_codis_afi__extord          → Enterprise_Lakehouse.Wholesale_Codis_AFI.EXTORD
│   │   ├── vw_brz_wholesale_codis_afi__extorit         → Enterprise_Lakehouse.Wholesale_Codis_AFI.EXTORIT
│   │   ├── vw_ref_calendar                             → Enterprise_Lakehouse.MasterData_DW.DimDate
│   │   ├── vw_ref_customer_account                     → Enterprise_Lakehouse.Customers.AccountMaster
│   │   ├── vw_ref_customer_account_group               → Enterprise_Lakehouse.Wholesale_ProductSourcing_AFI.CustomerGrouping
│   │   ├── vw_ref_customer_grouping                    → Enterprise_Lakehouse.Wholesale_ProductSourcing_AFI.CustomerGrouping
│   │   ├── vw_ref_customer_shipping_location           → Enterprise_Lakehouse.Customers.ShippingLocations
│   │   ├── vw_ref_forecast_cycle                       → SupplyChain_Lakehouse.dbo.ref_forecast_cycle
│   │   ├── vw_ref_item_master                          → Enterprise_Lakehouse.MasterData_DW.DimItemMaster
│   │   ├── vw_ref_order_type                           → Enterprise_Lakehouse.Wholesale_Codis_AFI.AAORDTYP
│   │   ├── vw_ref_product                              → Enterprise_Lakehouse.SupplyChain_DW.DimCurrentProductDetails
│   │   └── vw_ref_warehouse                            → Enterprise_Lakehouse.SupplyChain_DW.DimAFIWarehouses
│   │
│   └── Stored Procedures/
│       ├── usp_load_brz_saleshistory_afi__invoicedetail       [overwrite]
│       ├── usp_load_brz_saleshistory_afi__invoiceheader       [overwrite]
│       ├── usp_load_brz_supplychain_enh_1__demandforecast...  [incremental]
│       ├── usp_load_brz_wholesale_codis_afi__codatan          [overwrite]
│       ├── usp_load_brz_wholesale_codis_afi__comast           [overwrite]
│       ├── usp_load_brz_wholesale_codis_afi__extord           [overwrite]
│       ├── usp_load_brz_wholesale_codis_afi__extorit          [overwrite]
│       ├── usp_load_ref_calendar                              [overwrite]
│       ├── usp_load_ref_customer_account                      [overwrite]
│       ├── usp_load_ref_customer_account_group                [overwrite]
│       ├── usp_load_ref_customer_grouping                     [overwrite]
│       ├── usp_load_ref_customer_shipping_location            [overwrite]
│       ├── usp_load_ref_forecast_cycle                        [overwrite]
│       ├── usp_load_ref_forecast_horizon                      [overwrite, hardcoded]
│       ├── usp_load_ref_item_master                           [overwrite]
│       ├── usp_load_ref_order_type                            [overwrite]
│       ├── usp_load_ref_product                               [overwrite]
│       └── usp_load_ref_warehouse                             [overwrite]
│
├── silver/
│   ├── Tables/
│   │   ├── slv_invoice_detail_line_level               (35.8M rows)  [wave 0]
│   │   ├── slv_forecast_demand_monthly                 (13.9M rows)  [wave 0]
│   │   ├── slv_open_order_line_level                   (258K rows)   [wave 0]
│   │   ├── slv_actual_demand_monthly                   (572K rows)   [wave 1]
│   │   ├── slv_actual_demand_weekly                    (1.1M rows)   [wave 1]
│   │   ├── slv_invoice_weekly                          (15.6M rows)  [wave 1]
│   │   ├── slv_open_order_monthly                      (120K rows)   [wave 1]
│   │   └── slv_naive_forecast_monthly                  (347K rows)   [wave 2]
│   │
│   ├── Views/
│   │   ├── vw_slv_invoice_detail_line_level            ← bronze.brz_invoicedetail + invoiceheader + ref_cust_acct_group
│   │   ├── vw_slv_forecast_demand_monthly              ← bronze.brz_demandforecast + ref_forecast_cycle + ref_calendar
│   │   ├── vw_slv_open_order_line_level                ← bronze.brz_codatan + comast + extord + extorit + ref_item_master + ref_order_type
│   │   ├── vw_slv_actual_demand_monthly                ← silver.slv_invoice_detail + slv_open_order + bronze.ref_calendar
│   │   ├── vw_slv_actual_demand_weekly                 ← silver.slv_invoice_detail + slv_open_order + bronze.ref_calendar
│   │   ├── vw_slv_invoice_weekly                       ← silver.slv_invoice_detail + bronze.ref_calendar
│   │   ├── vw_slv_open_order_monthly                   ← silver.slv_open_order + bronze.ref_calendar + ref_cust_acct_group
│   │   └── vw_slv_naive_forecast_monthly               ← silver.slv_actual_demand_monthly + bronze.ref_calendar
│   │
│   └── Stored Procedures/
│       ├── usp_load_slv_invoice_detail_line_level      [overwrite, wave 0]
│       ├── usp_load_slv_forecast_demand_monthly        [overwrite, wave 0]
│       ├── usp_load_slv_open_order_line_level          [overwrite, wave 0]
│       ├── usp_load_slv_actual_demand_monthly          [overwrite, wave 1, deps: slv_invoice_detail + slv_open_order]
│       ├── usp_load_slv_actual_demand_weekly           [overwrite, wave 1, deps: slv_invoice_detail + slv_open_order]
│       ├── usp_load_slv_invoice_weekly                 [overwrite, wave 1, deps: slv_invoice_detail]
│       ├── usp_load_slv_open_order_monthly             [overwrite, wave 1, deps: slv_open_order]
│       └── usp_load_slv_naive_forecast_monthly         [overwrite, wave 2, deps: slv_actual_demand_monthly]
│
├── gold/
│   ├── Tables/
│   │   ├── gld_fact_flat_forecast_actual               (14.8M rows)
│   │   └── gld_fact_forecast_kpi                       (41.1M rows)
│   │
│   ├── Views/
│   │   ├── vw_gld_fact_flat_forecast_actual            ← UNION: slv_actual + slv_forecast + slv_naive
│   │   └── vw_gld_fact_forecast_kpi                    ← CTE: forecast×horizon JOIN actuals + naive
│   │
│   └── Stored Procedures/
│       ├── usp_load_gld_fact_flat_forecast_actual      [overwrite]
│       └── usp_load_gld_fact_forecast_kpi              [overwrite]
│
└── meta/
    ├── Tables/
    │   ├── sp_registry              (28 rows)   — config: SP nao, chay kieu gi, phu thuoc gi
    │   ├── sp_run_history           (34 rows)   — log: moi lan SP chay
    │   ├── dq_rules                 (30 rows)   — config: DQ rules
    │   ├── dq_results               (30 rows)   — log: DQ results
    │   ├── sp_lineage               (52 rows)   — map: source → target
    │   ├── pipeline_run_log         (0 rows)    — log: pipeline runs
    │   └── slv_dag_waves_runtime    (8 rows)    — runtime: wave computation
    │
    ├── Views/
    │   └── vw_slv_dag_waves                     — (legacy, thay boi SP iterative)
    │
    ├── Stored Procedures/
    │   ├── usp_log_run                          — ghi log moi lan SP chay
    │   ├── usp_check_dq                         — DQ engine (co bug WHILE loop)
    │   ├── usp_build_lineage                    — auto-build lineage tu source_objects
    │   ├── usp_compute_slv_waves                — tinh wave tu depends_on (iterative, max 30)
    │   └── usp_run_silver_dag                   — orchestrator backup (sequential)
    │
    └── Functions/
        └── ufn_should_run                       — check is_active + next_run_time
```

---

## 3. Pipeline Architecture

### 3.1 Master Flow

```
pl_sc_master
  │
  ├──[1] Execute pl_sc_bronze ──── bronze layer load (18 SPs parallel batch=8)
  │
  ├──[2] Execute pl_sc_silver ──── silver layer load (DAG waves, parallel per wave)
  │
  └──[3] Execute pl_sc_gold ────── gold layer load (2 SPs parallel batch=2)
```

### 3.2 pl_sc_bronze — Lookup + ForEach

```
┌─────────────────────────────────────────────────────────────────┐
│ pl_sc_bronze                                                    │
│                                                                 │
│  ┌──────────────┐      ┌──────────────────────────────────┐   │
│  │   Lookup      │─────▶│   ForEach (batch=8, PARALLEL)    │   │
│  │ lk_brz_ref   │      │                                  │   │
│  │              │      │  ┌──────────────────────────┐   │   │
│  │ SELECT sp_name│      │  │ SqlServerStoredProcedure  │   │   │
│  │ FROM meta.    │      │  │ EXEC @item().sp_name      │   │   │
│  │ sp_registry   │      │  └──────────────────────────┘   │   │
│  │ WHERE layer   │      │                                  │   │
│  │ IN (BRZ,REF)  │      │  × 18 SPs (8 parallel at a time)│   │
│  └──────────────┘      └──────────────────────────────────┘   │
│                                                                 │
│  Lookup source: LakehouseTableSource (cross-DB query)          │
│  SP target: SupplyChain_Warehouse (DataWarehouse linkedService) │
└─────────────────────────────────────────────────────────────────┘
```

### 3.3 pl_sc_silver — Hybrid DAG (auto-scale N waves)

```
┌──────────────────────────────────────────────────────────────────────────┐
│ pl_sc_silver                                                             │
│  variables: current_wave="0", next_wave="0"                             │
│                                                                          │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────────────────────┐│
│  │ SP            │──▶│ Lookup        │──▶│ Until                        ││
│  │ compute_waves │   │ get_max_wave  │   │ (current_wave > max_wave)    ││
│  │               │   │               │   │                              ││
│  │ Tinh wave tu  │   │ SELECT MAX    │   │  ┌────────┐  ┌──────────┐  ││
│  │ depends_on    │   │ (wave)        │   │  │ Lookup  │─▶│ ForEach  │  ││
│  │ → runtime tbl │   │ → vd: 2      │   │  │ wave=@w │  │ batch=8  │  ││
│  └──────────────┘   └──────────────┘   │  │ → 3 SPs │  │ PARALLEL │  ││
│                                          │  └────────┘  └────┬─────┘  ││
│                                          │                    │        ││
│                                          │  ┌────────────────┐│        ││
│                                          │  │ SetVariable ×2  ││        ││
│                                          │  │ next = curr + 1 ││        ││
│                                          │  │ curr = next     ││        ││
│                                          │  └────────────────┘│        ││
│                                          │                    ▼        ││
│                                          │  Loop: wave 0 → 1 → 2 → end││
│                                          └──────────────────────────────┘│
│                                                                          │
│  Wave 0: invoice_detail | forecast_demand | open_order     (3 PARALLEL) │
│  Wave 1: actual_monthly | actual_weekly | invoice_weekly |  (4 PARALLEL)│
│           open_order_monthly                                             │
│  Wave 2: naive_forecast_monthly                            (1)          │
│                                                                          │
│  Auto-scale: them table → INSERT sp_registry + depends_on → tu dong     │
│  Them 50 tables voi 10 waves → SP tu tinh → Until loop tu chay         │
└──────────────────────────────────────────────────────────────────────────┘
```

### 3.4 pl_sc_gold — Lookup + ForEach

```
┌─────────────────────────────────────────────────────────────────┐
│ pl_sc_gold                                                      │
│                                                                 │
│  ┌──────────────┐      ┌──────────────────────────────────┐   │
│  │   Lookup      │─────▶│   ForEach (batch=2, PARALLEL)    │   │
│  │ lk_gld       │      │                                  │   │
│  │              │      │  EXEC @item().sp_name             │   │
│  │ WHERE layer   │      │  × 2 SPs                         │   │
│  │ = 'GLD'      │      │                                  │   │
│  └──────────────┘      └──────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. 3-File-Per-Table Pattern (Template)

Moi data table trong bronze/silver/gold co dung 3 objects:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    VIEW      │     │     SP       │     │   TABLE      │
│ "Cong thuc"  │────▶│  "Robot"     │────▶│  "San pham"  │
│              │     │              │     │              │
│ SELECT ...   │     │ DROP + CTAS  │     │ Data thuc    │
│ FROM source  │     │ FROM view    │     │ (Parquet)    │
│ WHERE ...    │     │ + log meta   │     │              │
└─────────────┘     └─────────────┘     └─────────────┘
```

### SP Template (overwrite)
```sql
CREATE OR ALTER PROCEDURE {schema}.usp_load_{table} AS
BEGIN
    DECLARE @run_id VARCHAR(36) = CONVERT(VARCHAR(36), NEWID());
    DECLARE @rows BIGINT;
    EXEC meta.usp_log_run @run_id, '{schema}.usp_load_{table}', 'running';
    BEGIN TRY
        DROP TABLE IF EXISTS {schema}.{table};
        CREATE TABLE {schema}.{table} AS
        SELECT *, CAST(GETUTCDATE() AS DATETIME2(6)) AS _load_dt
        FROM {schema}.vw_{table};
        SELECT @rows = COUNT(*) FROM {schema}.{table};
        EXEC meta.usp_log_run @run_id, '{schema}.usp_load_{table}', 'success', @rows_affected = @rows;
    END TRY
    BEGIN CATCH
        DECLARE @err VARCHAR(4000) = ERROR_MESSAGE();
        EXEC meta.usp_log_run @run_id, '{schema}.usp_load_{table}', 'failed', @error_message = @err;
        THROW;
    END CATCH
END
```

### SP Template (incremental)
```sql
-- First run (no watermark): full load with cutoff filter
CREATE TABLE {schema}.{table} AS SELECT ... FROM view WHERE watermark >= @cutoff;

-- Subsequent runs: append only new rows
INSERT INTO {schema}.{table} SELECT ... FROM view WHERE watermark > @last_watermark;

-- Update watermark in sp_registry
UPDATE meta.sp_registry SET last_watermark_value = @new_wm WHERE sp_name = ...;
```

---

## 5. Them Table Moi — Chi can 3 buoc

### Bronze
```sql
-- 1. Tao VIEW
CREATE OR ALTER VIEW bronze.vw_brz_new_table AS
SELECT col1, col2 FROM Enterprise_Lakehouse.{schema}.{source_table};

-- 2. Tao SP (copy template, doi ten)
CREATE OR ALTER PROCEDURE bronze.usp_load_brz_new_table AS ...

-- 3. INSERT sp_registry
INSERT INTO meta.sp_registry (sp_name, view_name, target_schema, target_table,
    layer, load_type, frequency, execution_order, is_active, source_objects, project)
VALUES ('bronze.usp_load_brz_new_table', 'bronze.vw_brz_new_table',
    'bronze', 'brz_new_table', 'BRZ', 'overwrite', 'daily', 1, 1,
    '["Enterprise_Lakehouse.{schema}.{source_table}"]', 'supplychain');
```

### Silver (voi depends_on)
```sql
-- 1. Tao VIEW (doc tu bronze.*)
-- 2. Tao SP (copy template)
-- 3. INSERT sp_registry voi depends_on
INSERT INTO meta.sp_registry (..., depends_on, ...)
VALUES (..., '["silver.usp_load_slv_table_a","silver.usp_load_slv_table_b"]', ...);
-- Pipeline tu dong pick up, SP tu tinh wave, ForEach chay song song.
```

---

## 6. Naming Convention

| Schema | Table prefix | View prefix | SP prefix | Vi du |
|--------|-------------|-------------|-----------|-------|
| bronze | brz_ / ref_ | vw_brz_ / vw_ref_ | usp_load_brz_ / usp_load_ref_ | bronze.brz_wholesale_codis_afi__codatan |
| silver | slv_ | vw_slv_ | usp_load_slv_ | silver.slv_actual_demand_monthly |
| gold | gld_ | vw_gld_ | usp_load_gld_ | gold.gld_fact_flat_forecast_actual |
| meta | (descriptive) | vw_ | usp_ / ufn_ | meta.sp_registry, meta.usp_log_run |

---

## 7. Object Count Summary

| Schema | Tables | Views | SPs | Functions | Total |
|--------|--------|-------|-----|-----------|-------|
| bronze | 18 | 17 | 18 | — | 53 |
| silver | 8 | 8 | 8 | — | 24 |
| gold | 2 | 2 | 2 | — | 6 |
| meta | 7 | 1 | 5 | 1 | 14 |
| **Total** | **35** | **28** | **33** | **1** | **97** |

Pipelines: 4 (pl_sc_master, pl_sc_bronze, pl_sc_silver, pl_sc_gold)
