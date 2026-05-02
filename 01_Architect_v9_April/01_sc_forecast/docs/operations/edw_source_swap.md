# EDW Source Supplement -- Swap Guide & Rollback
> Status: **EDW source ACTIVE** (since 2026-04-23)
> Reason: Enterprise_Lakehouse has incomplete data for 4 Group A tables
> TEMPORARY -- revert when EL data is complete

---

## 1. Current State (EDW Source Active)

4 bronze tables now read from `_edw` tables (CTAS from SupplyChain_Lakehouse `_ver2` tables) instead of Enterprise_Lakehouse directly.

| Bronze View | Old Source (EL) | Current Source (_edw) | Rows (EDW) | Rows (EL) |
|---|---|---|---|---|
| `vw_brz_saleshistory_afi__invoicedetail` | `Enterprise_Lakehouse.SalesHistory_AFI.InvoiceDetail` | `bronze.brz_saleshistory_afi__invoicedetail_edw` | 87.7M | 35M |
| `vw_brz_saleshistory_afi__invoiceheader` | `Enterprise_Lakehouse.SalesHistory_AFI.InvoiceHeader` | `bronze.brz_saleshistory_afi__invoiceheader_edw` | 24.7M | 4M |
| `vw_brz_supplychain_enh_1__demandforecastsnapshotdaily` | `Enterprise_Lakehouse.SupplyChain_Enh_1.DemandForecastSnapshotDaily` | `bronze.brz_supplychain_enh_1__demandforecastsnapshotdaily_edw` | 42.4M | 1.3B* |
| `vw_ref_product` | `Enterprise_Lakehouse.SupplyChain_DW.DimCurrentProductDetails` | `bronze.ref_product_edw` | 379K | 373K |

> *EL demandforecast has more rows but different grain/coverage. EDW matches v8 exactly.

### Why

Enterprise_Lakehouse (EL) doesn't have complete data for these 4 Group A tables. The v8 Dataflow Gen2 already loads full EDW data into `SupplyChain_Lakehouse` as `_ver2` tables. We CTAS those into warehouse as `_edw` tables and swap bronze views.

### What Changed (2026-04-23)

1. **4 _edw tables** created via CTAS from `SupplyChain_Lakehouse.dbo.*_ver2`
2. **4 bronze views** swapped to read from `_edw` tables instead of EL
3. **`demandforecastsnapshotdaily` load_type** changed: `incremental` -> `overwrite` in sp_registry
4. **2 gold views** updated: 5 new KPI columns (`qty_squared_fcst_error`, `qty_squared_naive_fcst_error`, `valid_obs_flag`, `valid_actual_nonzero_flag`, `abs_pct_error`) + `code_horizon` fix
5. **`vw_ref_calendar`** updated: added `dt_fsc_quarter_first`, `dt_fsc_quarter_last`
6. **SM TMDL** updated: 5 new columns + 5 new measures + 2 calendar columns
7. **1 SP created**: `bronze.usp_refresh_edw_tables` -- refreshes 4 _edw tables
8. **Pipeline updated**: `pl_sc_master` -- `refresh_edw` activity added as first step (before log_start)
9. **sp_registry** `source_objects` updated to `_edw` references for 4 tables

---

## 2. Data Flow (Current -- EDW Active)

```
ASHLEY_EDW (SQL Server)
    | Dataflow Gen2 (v8, managed by others)
SupplyChain_Lakehouse.dbo.*_ver2 (Delta, complete data)
    | CTAS (bronze.usp_refresh_edw_tables, called by pl_sc_master first step)
bronze.*_edw tables (Warehouse, 4 tables)
    | bronze views read from _edw
bronze.brz_* tables (materialized by usp_generic_load)
    |
silver -> gold -> semantic model
```

### Lineage Explorer note

The raw lineage snapshot exported to `lineage_explorer/data/lineage.csv` still contains 52 edges from `meta.sp_lineage`.
The Streamlit Lineage Explorer augments that snapshot at render time with 4 synthetic bridge edges:
`SupplyChain_Lakehouse.dbo.*_ver2 -> bronze.*_edw -> bronze.{target_table}`.
This keeps the graph aligned with the documented temporary EDW supplement without changing the warehouse lineage table itself.

---

## 3. Rollback to EL Source (When EL Data Is Complete)

Execute in order on Fabric Portal SQL editor. **Do NOT skip steps.**

### Step 1: Revert 4 bronze views to EL source

> **IMPORTANT**: Before running, verify the complete view SQL from the warehouse:
> ```sql
> SELECT view_name, definition FROM meta.view_definitions
> WHERE view_name IN (
>     'bronze.vw_brz_saleshistory_afi__invoicedetail',
>     'bronze.vw_brz_saleshistory_afi__invoiceheader',
>     'bronze.vw_brz_supplychain_enh_1__demandforecastsnapshotdaily',
>     'bronze.vw_ref_product'
> );
> ```
> The view SQL below is the original EL-pointing version. If `meta.view_definitions` still has the
> `_edw` version, use the SQL below to restore.

#### View 1: invoiceheader (complete)

```sql
CREATE OR ALTER VIEW bronze.vw_brz_saleshistory_afi__invoiceheader AS
SELECT
    CAST(InvoiceNumber AS VARCHAR(200))        AS id_invoice,
    CAST(CustomerNumber AS VARCHAR(200))       AS id_customer,
    CAST(ShiptoNumber AS VARCHAR(200))         AS id_ship_to,
    CAST(OrderNumber AS VARCHAR(200))          AS id_order,
    CAST(PurchaseOrder AS VARCHAR(200))        AS id_purchase_order,
    CAST(Warehouse AS VARCHAR(200))            AS id_warehouse,
    CAST(ShiptoSalesman AS VARCHAR(200))       AS id_salesman,
    CAST(TripNumber AS VARCHAR(200))           AS id_trip,
    CAST(DropNumber AS VARCHAR(200))           AS id_drop,
    CAST(PromotionNumber AS VARCHAR(200))      AS id_promotion,
    CAST(CreditApprovalNBR AS VARCHAR(200))    AS id_credit_approval,
    CAST(InvoiceDate AS DATE)            AS dt_invoice,
    CAST(CASE
        WHEN CAST(RequestDate AS VARCHAR(200)) IN ('0', '0.0', '') THEN NULL
        ELSE RequestDate
    END AS DATE)                         AS dt_request,
    CAST(CASE
        WHEN CAST(OrderDate AS VARCHAR(200)) IN ('0', '0.0', '') THEN NULL
        ELSE OrderDate
    END AS DATE)                         AS dt_order,
    CAST(CASE
        WHEN CAST(TripCreatedDate AS VARCHAR(200)) IN ('0', '0.0', '') THEN NULL
        ELSE TripCreatedDate
    END AS DATE)                         AS dt_trip_created,
    CAST(InvoiceAmount AS DECIMAL(18,2)) AS amt_invoice,
    CAST(TaxAmount AS DECIMAL(18,2))     AS amt_tax,
    CAST(TermsDiscount AS DECIMAL(18,2)) AS amt_terms_discount,
    TRIM(ShiptoName)                     AS name_ship_to,
    TRIM(ShiptoAddress1)                 AS name_ship_to_address_1,
    TRIM(ShiptoAddress2)                 AS name_ship_to_address_2,
    TRIM(ShiptoCity)                     AS name_ship_to_city,
    TRIM(SoldtoName)                     AS name_sold_to,
    TRIM(ShiptoCountryName)              AS name_ship_to_country,
    TRIM(ShipInstructions)               AS name_ship_instructions,
    TRIM(ShiptoState)                    AS code_ship_to_state,
    TRIM(ShiptoZipCode)                  AS code_ship_to_zip,
    TRIM(OrderArrivalCode)               AS code_order_arrival,
    TRIM(AdvertisingFlag)                AS code_advertising_flag,
    TRIM(OrderType)                      AS code_order_type,
    TRIM(OrderTypePrimary)               AS code_order_type_primary,
    TRIM(OrderTypeSecondary)             AS code_order_type_secondary,
    TRIM(OrderTypeUsrDefine3)            AS code_order_type_usr_3,
    TRIM(OrderTypeUsrDefine4)            AS code_order_type_usr_4,
    TRIM(CreditCode)                     AS code_credit,
    TRIM(CurrencyCode)                   AS code_currency,
    CAST(PostingMonth AS INT)            AS num_posting_month,
    CAST(LeadTime AS INT)                AS num_lead_time_days,
    CAST(Sequence AS INT)                AS num_sequence,
    CAST(ShipWeight AS DECIMAL(18,4))    AS val_ship_weight
FROM Enterprise_Lakehouse.SalesHistory_AFI.InvoiceHeader;
```

#### View 2: demandforecastsnapshotdaily (complete)

```sql
CREATE OR ALTER VIEW bronze.vw_brz_supplychain_enh_1__demandforecastsnapshotdaily AS
SELECT
    TRIM(dfcItem)                                        AS id_item_sku,
    TRIM(dfcWarehouse)                                   AS code_warehouse,
    CAST(dfcFiscalMonth AS INT)                          AS num_fiscal_month,
    TRIM(DfcCustomerGroups)                              AS code_customer_group,
    CAST(dfcResultantForecast AS DECIMAL(14,3))          AS qty_resultant_forecast,
    CAST(dfcPromotionalLift AS DECIMAL(14,3))            AS qty_promotional_lift,
    CAST(dfcForcedForecast AS DECIMAL(14,3))             AS qty_forced_forecast,
    CAST(dfcOrderFutureQty AS INT)                       AS qty_order_future,
    CAST(dfcPermComptQty AS DECIMAL(14,2))               AS qty_perm_component,
    TRY_CAST(dfcSnapshot AS DATETIME2(6))                AS ts_snapshot,
    TRIM(dfcMainPiece)                                   AS code_main_piece,
    TRIM(dfcCollectiveClass)                             AS name_collective_class,
    TRIM(dfcUsr32Text)                                   AS name_product_category,
    TRIM(dfcFCSTTypeCode)                                AS code_forecast_type,
    TRIM(dfcMgmtCode)                                    AS code_management,
    TRIM(dfcDerivedFCSTID)                               AS id_derived_forecast,
    CAST(dfcDerivedFCSTFctr AS DECIMAL(10,3))            AS val_derived_forecast_factor,
    CAST(dfcValidDemandMonths AS INT)                    AS num_valid_demand_months,
    TRIM(dfcUsr25Text)                                   AS name_usr25,
    TRIM(usra)                                           AS name_created_by,
    TRY_CAST(dtea AS DATETIME2(6))                       AS ts_created,
    TRIM(usrc)                                           AS name_modified_by,
    TRY_CAST(dtec AS DATETIME2(6))                       AS ts_modified
FROM Enterprise_Lakehouse.SupplyChain_Enh_1.DemandForecastSnapshotDaily
WHERE dfcItem IS NOT NULL
  AND dfcSnapshot >= '2023-01-01';
```

#### View 3: invoicedetail (partial -- verify remaining columns from warehouse)

The view definition exceeds the `meta.view_definitions` export limit (4000 chars). The column list below contains 72 columns from the CSV export. **Before running**, query the warehouse for the complete current definition and adapt:

```sql
-- Query this FIRST to get the current _edw version's complete column list:
SELECT definition FROM meta.view_definitions
WHERE view_name = 'bronze.vw_brz_saleshistory_afi__invoicedetail';

-- Then create the EL version with the same column list, changing only the FROM clause:
CREATE OR ALTER VIEW bronze.vw_brz_saleshistory_afi__invoicedetail AS
SELECT
    TRIM(CustomerNumber)                                    AS id_customer,
    CAST(InvoiceNumber AS VARCHAR(200))                     AS id_invoice,
    TRIM(ExtendedInvoiceNumber)                             AS id_invoice_extended,
    TRIM(ItemSKU)                                           AS id_item_sku,
    CAST(ItemSequence AS INT)                               AS num_item_sequence,
    TRIM(OrderNumber)                                       AS id_order,
    TRIM(ShiptoNumber)                                      AS code_ship_to,
    TRIM(Warehouse)                                         AS code_warehouse,
    TRIM(CurrencyCode)                                      AS code_currency,
    CAST(QuantityShipped AS DECIMAL(12,3))                  AS qty_shipped,
    CAST(QuantityOrdered AS DECIMAL(12,3))                  AS qty_ordered,
    CAST(QuantityBackOrdered AS DECIMAL(12,3))              AS qty_backordered,
    CAST(InvoiceAmount AS DECIMAL(14,2))                    AS amt_invoice,
    CAST(Price AS DECIMAL(14,2))                            AS amt_price,
    CAST(StandardPrice AS DECIMAL(14,2))                    AS amt_standard_price,
    CAST(ContractPrice AS DECIMAL(14,2))                    AS amt_contract_price,
    CAST(NetSales AS DECIMAL(14,3))                         AS amt_net_sales,
    CAST(Discount AS DECIMAL(12,2))                         AS amt_discount,
    CAST(PriceAdjustment AS DECIMAL(12,2))                  AS amt_price_adjustment,
    CAST(Freight AS DECIMAL(12,2))                          AS amt_freight,
    CAST(AdvertisingAccrual AS DECIMAL(12,2))               AS amt_advertising_accrual,
    CAST(DFIDiscount AS DECIMAL(12,2))                      AS amt_dfi_discount,
    InvoiceDate                                             AS dt_invoice,
    OrderDate                                               AS dt_order,
    RequestDate                                             AS dt_request,
    OrderEntry                                              AS dt_order_entry,
    PromisedDelivery                                        AS dt_promised_delivery,
    OriginalRequestDate                                     AS dt_original_request,
    OriginalPromiseDate                                     AS dt_original_promise,
    CurrentRequestDate                                      AS dt_current_request,
    CurrentPromiseDate                                      AS dt_current_promise,
    DeliveryDate                                            AS dt_delivery,
    ActualDelivery                                          AS dt_actual_delivery,
    TripCloseDate                                           AS dt_trip_close,
    FirstScanDate                                           AS dt_first_scan,
    TripCreateDate                                          AS dt_trip_create,
    OriginalInvoiceDate                                     AS dt_original_invoice,
    OriginalOrderDate                                       AS dt_original_order,
    CAST(DefaultDeliveryDays AS VARCHAR(200))                AS code_default_delivery_days,
    CAST(DeliveryDays AS VARCHAR(200))                       AS val_delivery_days,
    CAST(DeliveryDaysOriginalPromiseDate AS VARCHAR(200))    AS val_delivery_days_original_promise,
    CAST(DeliveryDaysRaw AS VARCHAR(200))                    AS val_delivery_days_raw,
    CAST(DeliveryDaysOriginalPromiseDateRaw AS VARCHAR(200)) AS val_delivery_days_original_promise_raw,
    TRIM(CAST(BilltoSalesman AS VARCHAR(200)))              AS id_salesperson_billto,
    TRIM(CAST(ShiptoSalesman AS VARCHAR(200)))              AS id_salesperson_shipto,
    CAST(TripNumber AS INT)                                 AS num_trip,
    CAST(DropNumber AS INT)                                 AS num_drop,
    TRIM(ItemClass)                                         AS code_item_class,
    TRIM(CustomerSku)                                       AS code_customer_sku
    -- ... REMAINING COLUMNS: verify from meta.view_definitions in warehouse
    -- The _edw version and EL version have the same column list;
    -- only the FROM clause differs.
FROM Enterprise_Lakehouse.SalesHistory_AFI.InvoiceDetail
WHERE InvoiceNumber IS NOT NULL;
```

#### View 4: ref_product (partial -- verify remaining columns from warehouse)

Same truncation issue. 53 columns captured below. **Query warehouse for complete column list before running.**

```sql
-- Query this FIRST:
SELECT definition FROM meta.view_definitions
WHERE view_name = 'bronze.vw_ref_product';

-- Then create EL version:
CREATE OR ALTER VIEW bronze.vw_ref_product AS
SELECT
    CAST(CurrentProductDetailsKey AS INT)                 AS sk_product,
    TRIM(ItemSKU)                                        AS id_item_sku,
    TRIM(Item)                                           AS id_item,
    TRIM(SCPItem)                                        AS id_scp_item,
    TRIM(ItemDescription)                                AS name_item_description,
    TRIM(Colors)                                         AS name_color,
    CAST(QtyInBox AS INT)                                AS num_qty_in_box,
    TRIM(UOM)                                            AS code_uom,
    TRIM(SeriesNumber)                                   AS code_series,
    TRIM(ExtSeriesNumber)                                AS code_ext_series,
    TRIM(ItemExtSeriesNumber)                             AS code_item_ext_series,
    TRIM(SeriesName)                                     AS name_series,
    TRIM(SeriesColor)                                    AS name_series_color,
    TRIM(SeriesDescription)                              AS name_series_description,
    TRIM([Item-Description-Series])                      AS name_item_desc_series,
    TRIM([SH-Item-Description-Series])                   AS name_sh_item_desc_series,
    TRIM([SH-Series-Description])                        AS name_sh_series_description,
    TRIM([Item-Description-Series-ItemColor])            AS name_item_desc_series_color,
    TRIM(ItemClassCode)                                  AS code_item_class,
    TRIM(ItemClassName)                                   AS name_item_class,
    TRIM(ItemClass)                                      AS name_item_class_full,
    TRIM(ItemCode)                                       AS code_item,
    TRIM(ItemGrouping)                                   AS name_item_grouping,
    TRIM(ItemStyleCode)                                  AS code_item_style,
    TRIM(ItemStyleGroup)                                 AS name_item_style_group,
    TRIM(ItemStyle)                                      AS name_item_style,
    TRIM(ProductLine)                                    AS name_product_line,
    TRIM(RetailCategoryCode)                             AS code_retail_category,
    TRIM(RetailCategoryDescription)                      AS name_retail_category,
    CAST(MerchandisingCategory AS VARCHAR(200))          AS name_merchandising_category,
    TRIM(ChildStyleDescription)                          AS name_child_style,
    TRIM(ParentStyleDescription)                         AS name_parent_style,
    CAST(PricePoint AS VARCHAR(200))                     AS name_price_point,
    TRIM(AssociationCode)                                AS code_association,
    TRIM(SalesClassCode)                                 AS code_sales_class,
    TRIM(SalesClassDescription)                          AS name_sales_class_description,
    TRIM(SalesClass)                                     AS name_sales_class,
    TRIM(AFISalesCategoryCode)                           AS code_afi_sales_category,
    TRIM(AFISalesCategory)                               AS name_afi_sales_category,
    TRIM(AFISalesDivisionCode)                           AS code_afi_sales_division,
    TRIM(AFISalesDivision)                               AS name_afi_sales_division,
    TRIM(AFIFinanceDivision)                             AS name_afi_finance_division,
    TRIM(DiscountClassCode)                              AS code_discount_class,
    TRIM(DiscountClassDescription)                       AS name_discount_class_description,
    TRIM(DiscountClass)                                  AS name_discount_class,
    TRIM(CommissionClassCode)                             AS code_commission_class,
    TRIM(CommissionClassDescription)                     AS name_commission_class_description,
    TRIM(CommissionClass)                                AS name_commission_class,
    TRIM(FreightClassCode)                               AS code_freight_class
    -- ... REMAINING COLUMNS: verify from meta.view_definitions in warehouse
    -- The _edw version and EL version have the same column list;
    -- only the FROM clause differs.
FROM Enterprise_Lakehouse.SupplyChain_DW.DimCurrentProductDetails;
```

### Step 2: Revert sp_registry source_objects back to EL paths

```sql
UPDATE meta.sp_registry
SET source_objects = '["Enterprise_Lakehouse.SalesHistory_AFI.InvoiceDetail"]'
WHERE target_table = 'brz_saleshistory_afi__invoicedetail';

UPDATE meta.sp_registry
SET source_objects = '["Enterprise_Lakehouse.SalesHistory_AFI.InvoiceHeader"]'
WHERE target_table = 'brz_saleshistory_afi__invoiceheader';

UPDATE meta.sp_registry
SET source_objects = '["Enterprise_Lakehouse.SupplyChain_Enh_1.DemandForecastSnapshotDaily"]'
WHERE target_table = 'brz_supplychain_enh_1__demandforecastsnapshotdaily';

UPDATE meta.sp_registry
SET source_objects = '["Enterprise_Lakehouse.SupplyChain_DW.DimCurrentProductDetails"]'
WHERE target_table = 'ref_product';
```

### Step 3: Revert demandforecastsnapshotdaily load_type back to incremental

```sql
UPDATE meta.sp_registry
SET load_type = 'incremental'
WHERE target_table = 'brz_supplychain_enh_1__demandforecastsnapshotdaily';
```

### Step 4: Drop _edw tables and refresh SP

```sql
DROP TABLE IF EXISTS bronze.brz_saleshistory_afi__invoicedetail_edw;
DROP TABLE IF EXISTS bronze.brz_saleshistory_afi__invoiceheader_edw;
DROP TABLE IF EXISTS bronze.brz_supplychain_enh_1__demandforecastsnapshotdaily_edw;
DROP TABLE IF EXISTS bronze.ref_product_edw;

DROP PROCEDURE IF EXISTS bronze.usp_refresh_edw_tables;
```

### Step 5: Remove refresh_edw activity from pl_sc_master

Do this in Fabric Portal:
1. Open `pl_sc_master` (ID: `319a8160-3f3a-4b87-8ad6-75ac4f3ec184`)
2. Delete the `refresh_edw` activity (first activity, before `log_start`)
3. Reconnect: pipeline start -> `log_start` (was: start -> `refresh_edw` -> `log_start`)
4. Save and publish

### Step 6: Rebuild lineage

```sql
EXEC meta.usp_build_lineage;
```

### Step 7: Trigger lineage data refresh

Run the GitHub Actions workflow `refresh_lineage_data.yml` to update the lineage CSV exports, or wait for the next auto-trigger.

### What to KEEP (improvements, not rollback)

- **Gold view changes**: 5 new KPI columns + `code_horizon` fix -- these are improvements
- **`vw_ref_calendar` changes**: `dt_fsc_quarter_first`, `dt_fsc_quarter_last` -- these are improvements
- **SM TMDL changes**: 5 new columns + 5 new measures + 2 calendar columns -- these are improvements
- **All silver views**: unchanged, no rollback needed

---

## 4. Post-Rollback Verification

```sql
-- 1. Verify views read from EL (should show Enterprise_Lakehouse in definition)
SELECT view_name, LEFT(definition, 200) AS definition_preview
FROM meta.view_definitions
WHERE view_name IN (
    'bronze.vw_brz_saleshistory_afi__invoicedetail',
    'bronze.vw_brz_saleshistory_afi__invoiceheader',
    'bronze.vw_brz_supplychain_enh_1__demandforecastsnapshotdaily',
    'bronze.vw_ref_product'
);
-- Expected: definition contains 'Enterprise_Lakehouse', NOT '_edw'

-- 2. Verify sp_registry source_objects point to EL
SELECT target_table, source_objects, load_type
FROM meta.sp_registry
WHERE target_table IN (
    'brz_saleshistory_afi__invoicedetail',
    'brz_saleshistory_afi__invoiceheader',
    'brz_supplychain_enh_1__demandforecastsnapshotdaily',
    'ref_product'
);
-- Expected: source_objects = Enterprise_Lakehouse.*, demandforecast load_type = 'incremental'

-- 3. Verify _edw tables are gone
SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE '%_edw';
-- Expected: 0 rows

-- 4. Verify refresh SP is gone
SELECT ROUTINE_SCHEMA, ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_NAME = 'usp_refresh_edw_tables';
-- Expected: 0 rows

-- 5. Run pipeline and check row counts
-- After full pipeline run:
SELECT target_table, rows_loaded, last_load_date
FROM meta.sp_registry
WHERE target_table IN (
    'brz_saleshistory_afi__invoicedetail',
    'brz_saleshistory_afi__invoiceheader',
    'brz_supplychain_enh_1__demandforecastsnapshotdaily',
    'ref_product'
);
-- Expected EL row counts: ~35M / ~4M / ~1.3B / ~373K

-- 6. Verify gold tables still produce correct output
SELECT code_horizon, COUNT(*) AS cnt
FROM gold.gld_fact_flat_forecast_actual
GROUP BY code_horizon;
-- Expected: 'Actual demand', 'Naive forecast' (not NULL)

-- 7. Verify semantic model refreshes successfully
-- Trigger manual SM refresh from Fabric Portal or wait for pipeline finalize
```

---

## 5. Switch Back to EDW (If Needed Again)

### Step 1: Recreate _edw tables from Lakehouse _ver2

```sql
CREATE TABLE bronze.brz_saleshistory_afi__invoicedetail_edw AS
SELECT * FROM SupplyChain_Lakehouse.dbo.brz_saleshistory_afi__invoicedetail_ver2;

CREATE TABLE bronze.brz_saleshistory_afi__invoiceheader_edw AS
SELECT * FROM SupplyChain_Lakehouse.dbo.brz_saleshistory_afi__invoiceheader_ver2;

CREATE TABLE bronze.brz_supplychain_enh_1__demandforecastsnapshotdaily_edw AS
SELECT * FROM SupplyChain_Lakehouse.dbo.brz_supplychain_enh_1__demandforecastsnapshotdaily_ver2;

CREATE TABLE bronze.ref_product_edw AS
SELECT * FROM SupplyChain_Lakehouse.dbo.ref_product_ver2;
```

### Step 2: Swap 4 views to read from _edw tables

For each view, change the FROM clause from `Enterprise_Lakehouse.{Schema}.{Table}` to `bronze.{table}_edw`. Keep the same SELECT column list. Example:

```sql
-- Pattern: take the current EL view, change only the FROM clause
CREATE OR ALTER VIEW bronze.vw_brz_saleshistory_afi__invoicedetail AS
SELECT
    -- ... same column list as EL version ...
FROM bronze.brz_saleshistory_afi__invoicedetail_edw  -- changed from Enterprise_Lakehouse.SalesHistory_AFI.InvoiceDetail
WHERE InvoiceNumber IS NOT NULL;                     -- keep same WHERE clause if any
```

Repeat for all 4 views:
- `FROM bronze.brz_saleshistory_afi__invoiceheader_edw`
- `FROM bronze.brz_supplychain_enh_1__demandforecastsnapshotdaily_edw` (keep WHERE clause)
- `FROM bronze.ref_product_edw`

### Step 3: Update sp_registry

```sql
UPDATE meta.sp_registry
SET source_objects = '["bronze.brz_saleshistory_afi__invoicedetail_edw"]'
WHERE target_table = 'brz_saleshistory_afi__invoicedetail';

UPDATE meta.sp_registry
SET source_objects = '["bronze.brz_saleshistory_afi__invoiceheader_edw"]'
WHERE target_table = 'brz_saleshistory_afi__invoiceheader';

UPDATE meta.sp_registry
SET source_objects = '["bronze.brz_supplychain_enh_1__demandforecastsnapshotdaily_edw"]',
    load_type = 'overwrite'  -- change from incremental to overwrite (EDW CTAS has no watermark)
WHERE target_table = 'brz_supplychain_enh_1__demandforecastsnapshotdaily';

UPDATE meta.sp_registry
SET source_objects = '["bronze.ref_product_edw"]'
WHERE target_table = 'ref_product';
```

### Step 4: Recreate bronze.usp_refresh_edw_tables SP

```sql
CREATE OR ALTER PROCEDURE bronze.usp_refresh_edw_tables
AS
BEGIN
    -- Drop and recreate all 4 _edw tables from Lakehouse _ver2 source
    DROP TABLE IF EXISTS bronze.brz_saleshistory_afi__invoicedetail_edw;
    CREATE TABLE bronze.brz_saleshistory_afi__invoicedetail_edw AS
    SELECT * FROM SupplyChain_Lakehouse.dbo.brz_saleshistory_afi__invoicedetail_ver2;

    DROP TABLE IF EXISTS bronze.brz_saleshistory_afi__invoiceheader_edw;
    CREATE TABLE bronze.brz_saleshistory_afi__invoiceheader_edw AS
    SELECT * FROM SupplyChain_Lakehouse.dbo.brz_saleshistory_afi__invoiceheader_ver2;

    DROP TABLE IF EXISTS bronze.brz_supplychain_enh_1__demandforecastsnapshotdaily_edw;
    CREATE TABLE bronze.brz_supplychain_enh_1__demandforecastsnapshotdaily_edw AS
    SELECT * FROM SupplyChain_Lakehouse.dbo.brz_supplychain_enh_1__demandforecastsnapshotdaily_ver2;

    DROP TABLE IF EXISTS bronze.ref_product_edw;
    CREATE TABLE bronze.ref_product_edw AS
    SELECT * FROM SupplyChain_Lakehouse.dbo.ref_product_ver2;
END;
```

### Step 5: Add refresh_edw activity back to pl_sc_master

In Fabric Portal:
1. Open `pl_sc_master`
2. Add a new **Stored Procedure** activity named `refresh_edw`
3. Set: `EXEC bronze.usp_refresh_edw_tables`
4. Connect: pipeline start -> `refresh_edw` -> `log_start` (before existing flow)
5. Save and publish

### Step 6: Rebuild lineage

```sql
EXEC meta.usp_build_lineage;
```

---

## 6. Verification Checklist

After any source swap (EL or EDW), verify ALL items:

- [ ] All 4 views point to correct source (check `meta.view_definitions`)
- [ ] `sp_registry.source_objects` matches view source for all 4 tables
- [ ] `demandforecastsnapshotdaily` load_type matches source (`incremental` for EL, `overwrite` for EDW)
- [ ] Pipeline run completes successfully (28/28 tables)
- [ ] Row counts match expected:
  - EDW: ~87M / ~24M / ~42M / ~379K
  - EL: ~35M / ~4M / ~1.3B / ~373K
- [ ] Silver tables downstream refresh without errors
- [ ] Gold tables produce correct KPI values (code_horizon not NULL)
- [ ] Semantic model refresh succeeds
- [ ] Lineage rebuilt (`EXEC meta.usp_build_lineage`)
- [ ] GitHub Actions lineage CSV export refreshed

---

## 7. Semantic Model Comparison Procedure

After swapping source, compare KPI outputs between v8 and v9:

```sql
-- 1. Compare gold fact row counts
SELECT 'v9' AS version, COUNT(*) AS rows
FROM gold.gld_fact_flat_forecast_actual
UNION ALL
SELECT 'v8', COUNT(*)
FROM SupplyChain_Lakehouse.dbo.fact_flat_forecast_actual;

-- 2. Compare gold KPI row counts
SELECT 'v9' AS version, COUNT(*) AS rows
FROM gold.gld_fact_forecast_kpi
UNION ALL
SELECT 'v8', COUNT(*)
FROM SupplyChain_Lakehouse.dbo.fact_forecast_kpi;

-- 3. Compare KPI aggregates (sample)
SELECT 'v9' AS version,
    COUNT(DISTINCT id_item_sku) AS distinct_skus,
    SUM(qty_actual_demand) AS total_actual,
    SUM(qty_forecast_demand) AS total_forecast
FROM gold.gld_fact_forecast_kpi
UNION ALL
SELECT 'v8',
    COUNT(DISTINCT id_item_sku),
    SUM(qty_actual_demand),
    SUM(qty_forecast_demand)
FROM SupplyChain_Lakehouse.dbo.fact_forecast_kpi;

-- 4. Check code_horizon values (should be 'Actual demand'/'Naive forecast', not NULL)
SELECT code_horizon, COUNT(*) AS cnt
FROM gold.gld_fact_flat_forecast_actual
GROUP BY code_horizon;

-- 5. Check new KPI columns exist and have data
SELECT TOP 5
    qty_squared_fcst_error,
    qty_squared_naive_fcst_error,
    valid_obs_flag,
    valid_actual_nonzero_flag,
    abs_pct_error
FROM gold.gld_fact_forecast_kpi;
```

### Expected Results After EDW Swap

| Metric | v8 (reference) | v9 (should match) |
|---|---|---|
| fact_flat rows | ~14.8M | ~14.8M |
| fact_kpi rows | ~41M | ~41M |
| code_horizon values | 'Actual demand', 'Naive forecast' | Same (not NULL) |
| KPI columns | 5 (squared_error, valid_obs, etc.) | Same |

---

## 8. _edw Table Refresh SP

`bronze.usp_refresh_edw_tables` refreshes all 4 _edw tables from Lakehouse _ver2 source. Called by `refresh_edw` activity in `pl_sc_master` as the first step (before log_start).

```sql
-- Trigger manually if needed:
EXEC bronze.usp_refresh_edw_tables;
```

Runtime depends on _ver2 table sizes (~87M + ~24M + ~42M + ~379K rows). Runs once per pipeline execution.

---

*Last updated: 2026-04-23*
