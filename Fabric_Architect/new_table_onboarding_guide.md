# Onboarding Guide — Theem bang ETL moi vao Pipeline
> Huong dan tu A-Z cho DA/DE moi: tao bang, dang ky metadata, test, tu dong chay trong pipeline
> Khong can tao Stored Procedure, khong can sua Pipeline

---

## Tong quan

Kien truc hien tai la **metadata-driven**: pipeline doc `sp_registry` de biet can load bang nao, kieu gi, tu dau. Viec cua ban chi la:

```
1. Tao VIEW (chua logic ETL)
2. INSERT 1 dong vao sp_registry (dang ky bang)
3. Test thu bang tay
4. Xong — pipeline tu dong pick up lan chay tiep theo
```

**Khong can**: tao Stored Procedure, sua pipeline JSON, deploy gi them.

---

## Buoc 0 — Xac dinh layer

| Layer | Khi nao dung | Source doc tu dau |
|-------|-------------|-------------------|
| **bronze** | Mirror data tho tu source, khong transform | Lakehouse tables (qua 3-part naming) |
| **bronze (ref_)** | Reference/dimension data it thay doi | Lakehouse tables |
| **silver** | Join, transform, business rules tu bronze | Bronze tables (cung Warehouse) |
| **gold** | Aggregate, KPI, BI-ready tu silver | Silver tables (cung Warehouse) |

---

## Buoc 1 — Chon naming

### Bang

| Layer | Pattern | Vi du |
|-------|---------|-------|
| bronze | `brz_{source_system}__{entity}` | `brz_saleshistory_afi__invoicedetail` |
| bronze (ref) | `ref_{entity}` | `ref_customer_account` |
| silver | `slv_{business_concept}` | `slv_actual_demand_monthly` |
| gold | `gld_fact_{subject}` hoac `gld_dim_{subject}` | `gld_fact_forecast_kpi` |

### View

| Layer | Pattern | Vi du |
|-------|---------|-------|
| bronze | `bronze.vw_brz_{name}` | `bronze.vw_brz_saleshistory_afi__invoicedetail` |
| bronze (ref) | `bronze.vw_ref_{name}` | `bronze.vw_ref_customer_account` |
| silver | `silver.vw_slv_{name}` | `silver.vw_slv_actual_demand_monthly` |
| gold | `gold.vw_gld_{name}` | `gold.vw_gld_fact_forecast_kpi` |

> **Quy tac**: 2 dau gach duoi `__` ngan cach source system va entity. 1 dau gach duoi `_` ngan cach cac tu trong ten.

---

## Buoc 2 — Chon load_type

| load_type | Mo ta | Khi nao dung | Yeu cau them |
|-----------|-------|-------------|--------------|
| `overwrite` | Xoa bang cu, tao lai tu VIEW | Data nho, hoac muon full refresh moi lan | (khong can gi them) |
| `incremental` | Chi INSERT dong moi (theo watermark) | Data lon, chi them moi, khong sua cu | `watermark_column` |
| `upsert` | DELETE dong cu + INSERT dong moi (theo PK) | Data co update, can merge | `primary_key` |
| `datekey` | DELETE + INSERT theo ngay cu the | Fact tables theo ngay | `date_key` |
| `daterange` | DELETE + INSERT N ngay gan nhat | Fact tables can refresh window | `date_key` + `date_range_days` |
| `identity` | Chi INSERT dong co PK > MAX hien tai | Append-only, PK tang dan | `primary_key` |
| `cdc` | Apply change data capture | Source co CDC log | `primary_key` |
| `scd2` | Slowly Changing Dimension Type 2 | Dimension can track lich su | `primary_key` |

> **90% truong hop** dung `overwrite`. Chi dung cac loai khac khi data qua lon hoac co yeu cau dac biet.

---

## Buoc 3 — Tao VIEW

VIEW chua **toan bo logic ETL**. Generic SP chi doc VIEW roi ghi vao TABLE.

### 3a. Bronze — mirror tu source

```sql
CREATE OR ALTER VIEW bronze.vw_brz_{source}__{entity}
AS
SELECT *
FROM Enterprise_Lakehouse.{source_schema}.{source_table};
```

**Vi du thuc te:**
```sql
CREATE OR ALTER VIEW bronze.vw_brz_saleshistory_afi__invoicedetail
AS
SELECT *
FROM Enterprise_Lakehouse.SalesHistory_AFI.InvoiceDetail;
```

> **Luu y**: `Enterprise_Lakehouse` la ten Lakehouse trong cung Workspace. Dung 3-part naming: `{Lakehouse}.{Schema}.{Table}`.

### 3b. Bronze (ref) — reference data

```sql
CREATE OR ALTER VIEW bronze.vw_ref_customer_account
AS
SELECT
    CAST(CustomerNumber AS VARCHAR(20)) AS id_customer,
    CAST(CustomerName AS VARCHAR(200)) AS name_customer,
    CAST(City AS VARCHAR(100)) AS name_city,
    CAST(State AS VARCHAR(50)) AS code_state
FROM Enterprise_Lakehouse.SupplyChain_DW.DimCustomers;
```

> **Tip**: CAST cac cot sang dung data type, dat alias theo naming convention (`id_`, `name_`, `code_`, `qty_`, `amt_`, `dt_`, `is_`).

### 3c. Silver — join + transform

```sql
CREATE OR ALTER VIEW silver.vw_slv_actual_demand_monthly
AS
SELECT
    inv.id_customer,
    cal.year_month,
    SUM(inv.qty_shipped) AS qty_demand
FROM silver.slv_invoice_detail_line_level inv
JOIN bronze.ref_calendar cal
    ON inv.dt_invoice = cal.dt_date
GROUP BY inv.id_customer, cal.year_month;
```

> **Silver view doc tu bronze tables** (hoac silver tables khac). Khong doc truc tiep tu Lakehouse.

### 3d. Gold — aggregate, KPI

```sql
CREATE OR ALTER VIEW gold.vw_gld_fact_forecast_kpi
AS
SELECT
    fc.year_month,
    fc.id_product,
    fc.qty_forecast,
    act.qty_actual,
    CASE WHEN fc.qty_forecast > 0
         THEN act.qty_actual * 1.0 / fc.qty_forecast
         ELSE NULL END AS pct_accuracy
FROM silver.slv_forecast_demand_monthly fc
LEFT JOIN silver.slv_actual_demand_monthly act
    ON fc.year_month = act.year_month
    AND fc.id_product = act.id_product;
```

---

## Buoc 4 — Dang ky vao sp_registry

Day la buoc **quan trong nhat**. INSERT 1 dong vao `meta.sp_registry` de pipeline biet bang cua ban ton tai.

### Template day du:

```sql
INSERT INTO meta.sp_registry (
    sp_name,              -- Luon la 'meta.usp_generic_load'
    view_name,            -- Ten VIEW ban vua tao (schema.view_name)
    target_schema,        -- Schema chua TABLE (bronze/silver/gold)
    target_table,         -- Ten TABLE se duoc tao
    layer,                -- 'BRZ', 'REF', 'SLV', 'GLD'
    load_type,            -- overwrite/incremental/upsert/...
    frequency,            -- 'daily', 'monthly', 'hourly', 'weekly'
    scheduled_hour,       -- Gio chay (UTC), thuong la 2
    execution_order,      -- Thu tu trong layer (1 = mac dinh)
    is_active,            -- 1 = active, 0 = skip
    source_objects,       -- JSON array cac source tables (cho lineage)
    project,              -- Ten project (vd: 'supplychain', 'forecast')
    cron_expression,      -- Cron schedule (vd: '0 2 * * *')
    -- Cac cot optional (de NULL neu khong can):
    depends_on,           -- JSON array cac silver tables phu thuoc
    watermark_column,     -- Cot dung lam watermark (incremental)
    primary_key,          -- Cot PK (upsert/scd2/identity/cdc)
    date_key,             -- Cot date (datekey/daterange)
    date_range_days       -- So ngay (daterange)
)
VALUES (
    'meta.usp_generic_load',
    '{schema}.vw_{table_name}',
    '{target_schema}',
    '{target_table}',
    '{LAYER}',
    '{load_type}',
    '{frequency}',
    2,
    1,
    1,
    '["source1", "source2"]',
    '{project}',
    '0 2 * * *',
    NULL, NULL, NULL, NULL, NULL
);
```

### Vi du cu the theo tung layer:

#### Bronze (overwrite, daily):
```sql
INSERT INTO meta.sp_registry (
    sp_name, view_name, target_schema, target_table,
    layer, load_type, frequency, scheduled_hour, execution_order,
    is_active, source_objects, project, cron_expression
) VALUES (
    'meta.usp_generic_load',
    'bronze.vw_brz_wholesale_codis_afi__comast',
    'bronze', 'brz_wholesale_codis_afi__comast',
    'BRZ', 'overwrite', 'daily', 2, 1,
    1, '["Enterprise_Lakehouse.Wholesale_Codis_AFI.COMAST"]',
    'supplychain', '0 2 * * *'
);
```

#### Bronze ref (overwrite, monthly):
```sql
INSERT INTO meta.sp_registry (
    sp_name, view_name, target_schema, target_table,
    layer, load_type, frequency, scheduled_hour, execution_order,
    is_active, source_objects, project, cron_expression
) VALUES (
    'meta.usp_generic_load',
    'bronze.vw_ref_customer_account',
    'bronze', 'ref_customer_account',
    'REF', 'overwrite', 'monthly', 2, 1,
    1, '["Enterprise_Lakehouse.SupplyChain_DW.DimCustomers"]',
    'supplychain', '0 2 1 * *'
);
```

#### Silver (overwrite, daily, co depends_on):
```sql
INSERT INTO meta.sp_registry (
    sp_name, view_name, target_schema, target_table,
    layer, load_type, frequency, scheduled_hour, execution_order,
    is_active, source_objects, project, cron_expression, depends_on
) VALUES (
    'meta.usp_generic_load',
    'silver.vw_slv_actual_demand_monthly',
    'silver', 'slv_actual_demand_monthly',
    'SLV', 'overwrite', 'daily', 2, 1,
    1,
    '["silver.slv_invoice_detail_line_level","silver.slv_open_order_line_level","bronze.ref_calendar"]',
    'supplychain', '0 2 * * *',
    '["silver.slv_invoice_detail_line_level","silver.slv_open_order_line_level"]'
);
```

> **`depends_on`**: chi can khai bao cho **silver** tables phu thuoc silver tables khac. Pipeline se tu tinh wave va chay dung thu tu. Bronze va gold khong can depends_on.

#### Gold (overwrite, daily):
```sql
INSERT INTO meta.sp_registry (
    sp_name, view_name, target_schema, target_table,
    layer, load_type, frequency, scheduled_hour, execution_order,
    is_active, source_objects, project, cron_expression
) VALUES (
    'meta.usp_generic_load',
    'gold.vw_gld_fact_forecast_kpi',
    'gold', 'gld_fact_forecast_kpi',
    'GLD', 'overwrite', 'daily', 2, 1,
    1,
    '["silver.slv_forecast_demand_monthly","silver.slv_actual_demand_monthly"]',
    'forecast', '0 2 * * *'
);
```

#### Incremental (co watermark):
```sql
INSERT INTO meta.sp_registry (
    sp_name, view_name, target_schema, target_table,
    layer, load_type, frequency, scheduled_hour, execution_order,
    is_active, source_objects, project, cron_expression,
    watermark_column
) VALUES (
    'meta.usp_generic_load',
    'bronze.vw_brz_supplychain_enh_1__demandforecastsnapshotdaily',
    'bronze', 'brz_supplychain_enh_1__demandforecastsnapshotdaily',
    'BRZ', 'incremental', 'daily', 2, 1,
    1,
    '["Enterprise_Lakehouse.SupplyChain_Enh_1.DemandForecastSnapshotDaily"]',
    'supplychain', '0 2 * * *',
    'SnapshotDate'
);
```

---

## Buoc 5 — Test thu bang tay

Chay truc tiep tren Warehouse de kiem tra truoc khi pipeline tu dong load:

```sql
-- Chay 1 lan de tao TABLE + verify data
EXEC meta.usp_generic_load
    @target_schema = 'bronze',
    @target_table  = 'brz_wholesale_codis_afi__comast';
```

### Kiem tra ket qua:

```sql
-- 1. Bang da duoc tao?
SELECT COUNT(*) FROM bronze.brz_wholesale_codis_afi__comast;

-- 2. Log da ghi?
SELECT TOP 1 * FROM meta.sp_run_history
WHERE sp_name = 'bronze.brz_wholesale_codis_afi__comast'
ORDER BY start_time DESC;

-- 3. sp_registry da update?
SELECT last_load_date, rows_loaded, next_run_time
FROM meta.sp_registry
WHERE target_table = 'brz_wholesale_codis_afi__comast';
```

> **Neu loi**: doc `error_message` trong `sp_run_history`. Thuong gap: VIEW sai ten cot, source table khong ton tai, data type mismatch.

---

## Buoc 6 (Optional) — Them DQ rules

```sql
-- Kiem tra cot khong NULL
INSERT INTO meta.dq_rules (
    rule_id, rule_name, target_schema, target_table,
    check_type, column_name, severity, is_active, layer
) VALUES (
    (SELECT ISNULL(MAX(rule_id),0)+1 FROM meta.dq_rules),
    'brz_comast id_customer not null',
    'bronze', 'brz_wholesale_codis_afi__comast',
    'completeness', 'id_customer', 'CRITICAL', 1, 'BRZ'
);

-- Kiem tra so dong toi thieu
INSERT INTO meta.dq_rules (
    rule_id, rule_name, target_schema, target_table,
    check_type, severity, threshold, is_active, layer
) VALUES (
    (SELECT ISNULL(MAX(rule_id),0)+1 FROM meta.dq_rules),
    'brz_comast min 100K rows',
    'bronze', 'brz_wholesale_codis_afi__comast',
    'row_count', 'WARNING', 100000, 1, 'BRZ'
);
```

| check_type | Kiem tra gi | Columns can |
|------------|------------|-------------|
| `completeness` | Cot khong duoc NULL | `column_name` |
| `row_count` | So dong >= threshold | `threshold` |

---

## Buoc 7 — Xong! Pipeline tu dong pick up

**Khong can lam gi them.** Lan chay pipeline tiep theo:

1. `pl_bronze_forecast` Lookup doc `sp_registry` → thay bang moi cua ban → load
2. `pl_silver_forecast` compute waves → tinh lai DAG → chay dung thu tu
3. `pl_gold_forecast` Lookup → load gold tables
4. `usp_finalize_pipeline` tu dong rebuild lineage (bao gom bang moi)

### Smart skip:
- Neu `frequency = 'daily'` va `cron = '0 2 * * *'`: chay moi ngay
- Neu `frequency = 'monthly'` va `cron = '0 2 1 * *'`: tu dong skip 29/30 ngay

---

## Checklist tom tat

```
[ ] 1. Xac dinh layer: bronze / silver / gold
[ ] 2. Dat ten theo naming convention
[ ] 3. Chon load_type (overwrite la mac dinh)
[ ] 4. CREATE VIEW voi logic ETL
[ ] 5. INSERT vao meta.sp_registry
[ ] 6. EXEC meta.usp_generic_load — test thu
[ ] 7. Kiem tra: SELECT COUNT, sp_run_history, sp_registry
[ ] 8. (Optional) INSERT DQ rules
[ ] 9. (Optional) Khai bao depends_on (chi silver)
[ ] Done — pipeline tu dong load lan tiep theo
```

---

## Cron cheat sheet

| Cron | Nghia |
|------|-------|
| `0 2 * * *` | 2AM moi ngay |
| `0 2 * * 1` | 2AM thu 2 hang tuan |
| `0 2 * * 1-5` | 2AM weekdays |
| `0 2 1 * *` | 2AM ngay 1 moi thang |
| `0 */4 * * *` | Moi 4 gio |
| `*/15 6-22 * * 1-5` | Moi 15 phut, 6AM-10PM, weekdays |

---

## FAQ

### Q: Toi can tao Stored Procedure rieng khong?
**Khong.** `meta.usp_generic_load` xu ly tat ca 8 load patterns. Ban chi can tao VIEW + dang ky.

### Q: Toi can sua pipeline khong?
**Khong.** Pipeline doc `sp_registry` dong (Lookup query). Bang moi tu dong xuat hien.

### Q: Silver table cua toi phu thuoc silver table khac thi sao?
Khai bao `depends_on` trong `sp_registry`. Pipeline tinh wave tu dong — table khong phu thuoc gi chay truoc (wave 0), table phu thuoc chay sau (wave 1, 2, ...).

### Q: Lam sao biet bang cua toi da chay thanh cong?
```sql
SELECT sp_name, status, rows_affected, start_time, duration_seconds
FROM meta.sp_run_history
WHERE sp_name = '{schema}.{table_name}'
ORDER BY start_time DESC;
```

### Q: Muon tam tat bang khong chay nua?
```sql
UPDATE meta.sp_registry SET is_active = 0
WHERE target_table = '{table_name}';
```

### Q: Muon xoa bang hoan toan?
```sql
-- 1. Xoa khoi registry
DELETE FROM meta.sp_registry WHERE target_table = '{table_name}';
-- 2. Xoa DQ rules (neu co)
DELETE FROM meta.dq_rules WHERE target_table = '{table_name}';
-- 3. Xoa TABLE + VIEW
DROP TABLE IF EXISTS {schema}.{table_name};
DROP VIEW IF EXISTS {schema}.vw_{table_name};
```

### Q: `source_objects` dung lam gi?
Dung de **tu dong build lineage** (bang `sp_lineage`). Ghi chinh xac ten cac tables ma VIEW cua ban SELECT FROM. Format JSON array: `'["schema.table1","schema.table2"]'`.
