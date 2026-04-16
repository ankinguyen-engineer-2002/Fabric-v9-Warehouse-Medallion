# Timezone Sync Guide — Dong bo thoi gian voi US Team
> UTC (core) + CST (Enterprise/US) + VN (UTC+7)
> Map chinh xac voi Enterprise fn_GetDate + TableDictionary

---

## Tong quan

| Team | Timezone | Offset | Dung cho |
|------|----------|--------|----------|
| **VN team** | UTC+7 (Vietnam) | Luon +7 | Xem log hang ngay |
| **US team** | CST/CDT (Central) | -6 (winter) / -5 (DST summer) | Enterprise TableDictionary, audit |
| **Core** | UTC | 0 | Source of truth, stored trong database |

Enterprise team (US) dung `fn_GetDate` trong 30+ SPs de chuyen UTC → CST truoc khi ghi log. v9 can lam tuong tu de `vw_table_dictionary` map dung voi Enterprise.

---

## Da implement (2026-04-16)

### 1. Scalar function: `meta.ufn_utc_to_cst`

```sql
-- Tuong duong Enterprise fn_GetDate nhung la scalar (Fabric WH khong ho tro table-valued)
-- Tu dong xu ly DST: Mar-Nov = UTC-5 (CDT), Nov-Mar = UTC-6 (CST)
SELECT meta.ufn_utc_to_cst(GETUTCDATE())  -- → CST time
```

DST logic: kiem tra ngay co nam giua 2nd Sunday March va 1st Sunday November.

### 2. Cot CST trong log tables

| Table | Cot moi | Ghi boi |
|-------|---------|---------|
| `sp_run_history` | `start_cst`, `end_cst` | `usp_log_run` (tu dong) |
| `pipeline_run_log` | `start_cst`, `end_cst` | `usp_log_pipeline_run` (tu dong) |

Data cu da backfill (325 rows sp_run_history, 5 rows pipeline_run_log).

### 3. View `vw_table_dictionary` — [Modified] xuat ra CST

| Enterprise column | Truoc | Sau |
|-------------------|-------|-----|
| `[Modified]` | `last_load_date` (UTC) | `ufn_utc_to_cst(last_load_date)` **(CST)** |
| `[LastAudit]` | NULL | `ufn_utc_to_cst(last_load_date)` **(CST)** |
| `[LastBatchStartDate]` | NULL | `ufn_utc_to_cst(last_load_date)` **(CST)** |

→ US team query `vw_table_dictionary` → thay gio CST giong Enterprise.

### 4. View `vw_run_history_tz` — xem ca 3 timezone

```sql
SELECT sp_name, start_utc, start_cst, start_vn
FROM meta.vw_run_history_tz
ORDER BY start_utc DESC;

-- Ket qua:
-- gld_fact_forecast_kpi | 17:12 UTC | 12:12 CST | 00:12 VN
```

| Cot | Timezone | Ai xem |
|-----|----------|--------|
| `start_utc` / `end_utc` | UTC | Core, so sanh cross-system |
| `start_cst` / `end_cst` | CST/CDT | US team |
| `start_vn` / `end_vn` | UTC+7 | VN team |

---

## Mapping voi Enterprise fn_GetDate

| Enterprise | v9 | Khop? |
|-----------|-----|-------|
| `DW_Developer.fn_GetDate(@dt)` returns TABLE (CSTDateValue, ESTDateValue, PSTDateValue) | `meta.ufn_utc_to_cst(@dt)` returns scalar DATETIME2(6) | Logic CST giong nhau |
| DST: Mar 2nd Sunday → Nov 1st Sunday | DST: tuong tu | DST logic giong |
| Table-valued function | Scalar function | Fabric WH khong ho tro TVF → dung scalar |
| Goi trong 30+ SPs | Goi trong 2 SPs (usp_log_run, usp_log_pipeline_run) + 1 view | Du dung |

### EST va PST thi sao?

Enterprise tra ve 3 timezone (CST, EST, PST). v9 chi implement **CST** vi:
- Ashley HQ = Wisconsin = Central Time
- `[Modified]` trong TableDictionary ghi CST
- Neu can EST/PST, tao them:

```sql
-- De nhung chua can:
-- CREATE FUNCTION meta.ufn_utc_to_est(...) -- CST logic + offset +1h
-- CREATE FUNCTION meta.ufn_utc_to_pst(...) -- CST logic + offset -2h
```

---

## Objects tao moi

| Object | Loai | Muc dich |
|--------|------|----------|
| `meta.ufn_utc_to_cst` | Scalar Function | UTC → CST/CDT (DST aware) |
| `meta.vw_run_history_tz` | View | Log voi 3 timezone (UTC, CST, VN) |
| `sp_run_history.start_cst` | Column | CST start time |
| `sp_run_history.end_cst` | Column | CST end time |
| `pipeline_run_log.start_cst` | Column | CST start time |
| `pipeline_run_log.end_cst` | Column | CST end time |

### SPs da sua

| SP | Thay doi |
|----|---------|
| `usp_log_run` | Ghi `start_cst`, `end_cst` khi INSERT/UPDATE |
| `usp_log_pipeline_run` | Ghi `start_cst`, `end_cst` khi INSERT/UPDATE |

### Views da sua

| View | Thay doi |
|------|---------|
| `vw_table_dictionary` | `[Modified]`, `[LastAudit]`, `[LastBatchStartDate]` → CST |
