# Scheduling & Concurrency Guide
> Pipeline trigger, table frequency, smart skip, concurrency control
> Kiến trúc hiện tại + multi data mart

---

## 1. Cơ chế trigger hiện tại — Pipeline KHÔNG đọc schedule

### Sự thật quan trọng

**Pipeline hiện tại KHÔNG dùng `ufn_should_run`**. Mỗi lần trigger → TẤT CẢ active tables đều chạy, bất kể frequency.

```
Pipeline trigger (manual hoặc schedule)
    ↓
Lookup: SELECT target_schema, target_table
        FROM sp_registry WHERE is_active = 1
    ↓
ForEach: EXEC meta.usp_generic_load cho MỌI table
    ↓
generic SP: DROP + CTAS (overwrite) hoặc INSERT (incremental)
    ↓
usp_log_run: SET next_run_time = DATEADD(frequency)
```

**Kết quả**: trigger 1 lần → 28 tables ĐỀU CHẠY → monthly tables cũng bị overwrite mỗi ngày nếu pipeline trigger daily.

### sp_registry hiện tại (28 tables)

| Frequency | Số tables | Loại | Thực tế đang xảy ra |
|-----------|----------|------|---------------------|
| `daily` | 18 | BRZ (7), SLV (8), GLD (2), REF (1) | Chạy mỗi trigger ✅ đúng |
| `monthly` | 10 | REF (10) | Chạy mỗi trigger ❌ lãng phí CU |

### `ufn_should_run` — tồn tại nhưng CHƯA DÙNG

```sql
-- Function này đã tạo nhưng pipeline Lookup KHÔNG gọi nó
CREATE FUNCTION meta.ufn_should_run(@sp_name VARCHAR(200))
RETURNS INT
AS
BEGIN
    RETURN CASE
        WHEN is_active = 0 THEN 0
        WHEN next_run_time IS NULL THEN 1
        WHEN next_run_time <= GETUTCDATE() THEN 1
        ELSE 0
    END
END
```

### `next_run_time` — được SET nhưng CHƯA ai CHECK

Khi SP chạy xong, `usp_log_run` tính next_run_time:
```sql
next_run_time = CASE
    WHEN frequency = 'daily'   → tomorrow 00:00 UTC
    WHEN frequency = 'hourly'  → +1 hour
    WHEN frequency = 'weekly'  → +1 week
    WHEN frequency = 'monthly' → +1 month
END
```

Hiện tại: monthly tables có `next_run_time = 2026-05-15` nhưng pipeline KHÔNG check → vẫn load mỗi trigger.

---

## 2. Hai tầng scheduling — Pipeline vs Table

```
┌─────────────────────────────────────────────────────────┐
│  TẦNG 1: PIPELINE SCHEDULE (Fabric level)              │
│  "Khi nào master pipeline trigger?"                     │
│  → Fabric Pipeline Schedule: daily 2AM / hourly / cron  │
│  → Hoặc manual Run                                      │
│  → Config: Fabric Portal → Pipeline → Schedule tab      │
│  → KHÔNG liên quan sp_registry                          │
└─────────────────────────────┬───────────────────────────┘
                              ↓ trigger
┌─────────────────────────────────────────────────────────┐
│  TẦNG 2: TABLE FREQUENCY (application level)            │
│  "Table nào THỰC SỰ cần chạy trong trigger này?"       │
│  → sp_registry.frequency + next_run_time                │
│  → ufn_should_run gate                                  │
│  → Pipeline trigger 10 lần nhưng monthly skip 9 lần    │
│  → HIỆN TẠI CHƯA KÍCH HOẠT (pipeline không gọi gate)  │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Cách kích hoạt smart skip (đổi pipeline Lookup)

### Hiện tại (chạy TẤT CẢ):
```sql
SELECT target_schema, target_table
FROM SupplyChain_Warehouse.meta.sp_registry
WHERE layer IN ('BRZ','REF') AND is_active = 1
```

### Sau khi kích hoạt (smart skip):
```sql
SELECT target_schema, target_table
FROM SupplyChain_Warehouse.meta.sp_registry
WHERE layer IN ('BRZ','REF') AND is_active = 1
  AND (next_run_time IS NULL OR next_run_time <= GETUTCDATE())
```

**Thêm 1 dòng WHERE** → monthly tables tự skip khi chưa đến kỳ.

### Ảnh hưởng:
- daily tables: `next_run_time = tomorrow` → mỗi ngày trigger → pass ✅
- monthly tables: `next_run_time = next month` → skip 29/30 ngày ✅
- hourly tables: `next_run_time = +1h` → mỗi giờ trigger → pass ✅
- Lần đầu (`next_run_time = NULL`): luôn chạy ✅

### Tiết kiệm CU:
- 10 monthly tables × ~5s mỗi lần = 50s/trigger lãng phí
- 30 triggers/tháng × 50s = 25 phút CU lãng phí/tháng
- Nhỏ nhưng tích lũy khi scale N marts × N tables

---

## 4. Concurrency Control

### 4.1 Pipeline-level concurrency

```
pl_sc_master: concurrency = 1
  → Chỉ 1 instance chạy tại 1 thời điểm
  → Nếu trigger lần 2 khi lần 1 đang chạy → queue (đợi)
  → Tránh: 2 pipelines cùng DROP + CTAS 1 table
```

**Config**: đã set `"concurrency": 1` trong pipeline definition.

### 4.2 ForEach-level concurrency

```
pl_sc_bronze: ForEach batchCount = 8
  → 8 tables load song song cùng lúc
  → Fabric WH dual compute pool: READ (view) + WRITE (CTAS) tách biệt
  → Snapshot conflict khi 8 DROP+CTAS đồng thời → retry 3×60s handle
```

### 4.3 Mart-level concurrency (multi-mart tương lai)

```
pl_sc_master: ForEach marts isSequential=false, batch=10
  → 10 marts chạy parallel
  → Mỗi mart riêng biệt: bronze/silver/gold riêng
  → Cross-mart deps chạy SAU khi tất cả marts xong
```

### 4.4 Snapshot conflict — nguyên nhân + giải pháp

```
Nguyên nhân:
  Table A: DROP → CREATE TABLE AS SELECT... (đang write)
  Table B: DROP → CREATE TABLE AS SELECT FROM Table A (đang read Table A)
  → Conflict: Table A đang bị modify trong khi Table B đang read nó

Giải pháp hiện tại:
  Pipeline retry = 3 lần, interval = 60 giây
  → Lần 1 fail → đợi 60s → retry → Table A đã xong → success

Giải pháp tối ưu (tương lai):
  Bronze batch = 8 (nhỏ hơn → ít conflict)
  Silver: parent-child DAG → wave-by-wave (tables cùng wave không depend nhau)
  Gold: batch = 2 (ít tables)
```

### 4.5 Semantic Model refresh concurrency

```
SM refresh: 1 lần cuối pipeline
  → Direct Lake mode: chỉ sync metadata (~1-2s), không import data
  → Không conflict với table load (đã xong trước khi SM refresh)
  → Nếu N SMs: ForEach parallel batch=N
```

---

## 5. Trigger scenarios và ảnh hưởng

### Scenario A: Daily 2AM (recommend production hiện tại)

```
Schedule: daily 02:00 UTC
Duration: ~20 phút
Tables chạy: 28/28 (hiện tại, chưa smart skip)
              18/28 (sau smart skip — 10 monthly skip)
CU estimate: ~50 CU/ngày
SM refresh: 1 lần/ngày
```

### Scenario B: Hourly (khi cần data fresher)

```
Schedule: every 1 hour (6AM-10PM = 16 triggers/ngày)
Duration: ~20 phút mỗi trigger
Tables chạy (với smart skip):
  - hourly tables: mỗi trigger ✅
  - daily tables: 1/16 triggers ✅ (skip 15)
  - monthly tables: ~0/16 ✅ (skip tất cả trừ kỳ)
CU estimate: 16 × ~10 CU (mostly skip) = ~160 CU/ngày
  So với daily: 3x cost nhưng data fresh hơn 16x
```

### Scenario C: Every 15 minutes

```
Schedule: */15 * * * * (96 triggers/ngày)
Rủi ro: pipeline overlap nếu duration > 15 phút
Giải pháp: concurrency=1 → queue
CU estimate: 96 × ~5 CU (mostly skip) = ~480 CU/ngày
Chỉ hợp lý khi: có tables frequency='realtime' (5-10 phút)
```

### Scenario D: Multi-schedule (recommend multi-mart production)

```
Pipeline 1: pl_sc_master_batch (daily 2AM)
  → ALL tables, ALL marts
  → Full run: bronze → silver → gold → SM

Pipeline 2: pl_sc_master_hot (every 1 hour, 7AM-9PM)
  → CHỈ tables frequency='hourly'
  → Lookup thêm: WHERE frequency = 'hourly'
  → Light run: chỉ vài tables → fast

Pipeline 3: pl_sc_master_realtime (every 15 min) [future]
  → CHỈ tables frequency='realtime'
  → 1-2 incremental tables
  → Ultra-light: ~30s per run
```

---

## 6. Cách setup schedule trên Fabric

### Via Fabric Portal (UI):
```
1. Fabric Portal → Workspace → pl_sc_master
2. Click "Schedule" tab
3. Scheduled run: ON
4. Repeat: Daily
5. Time: 02:00 AM
6. Timezone: SE Asia Standard Time (UTC+7) hoặc UTC
7. Start: today
8. End: No end date
```

### Via REST API:
```bash
# Get pipeline schedule
curl -X GET "https://api.fabric.microsoft.com/v1/workspaces/{ws}/items/{pipeline}/schedules" \
  -H "Authorization: Bearer $TOKEN"

# Create/Update schedule
curl -X POST "https://api.fabric.microsoft.com/v1/workspaces/{ws}/items/{pipeline}/schedules" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "enabled": true,
    "configuration": {
      "type": "Cron",
      "startDateTime": "2026-04-16T02:00:00",
      "interval": 1440,
      "localTimeZoneId": "SE Asia Standard Time"
    }
  }'
```

---

## 7. Tóm tắt: cần thay đổi gì

### Kích hoạt smart skip (recommend):

| Component | Thay đổi | Effort |
|-----------|---------|--------|
| Bronze Lookup query | Thêm `AND (next_run_time IS NULL OR next_run_time <= GETUTCDATE())` | 1 phút |
| Silver wave Lookup | Tương tự | 1 phút |
| Gold Lookup query | Tương tự | 1 phút |
| Pipeline schedule | Set daily 2AM trên Fabric Portal | 1 phút |
| **Tổng** | | **4 phút** |

### Không cần thay đổi:

| Component | Lý do |
|-----------|-------|
| sp_registry | frequency + next_run_time đã có |
| ufn_should_run | Đã tạo, chỉ chưa dùng trong pipeline |
| usp_log_run | Đã tính next_run_time đúng |
| usp_generic_load | Frequency-agnostic |
| Views | Không liên quan scheduling |
| Meta tables | Đã đủ columns |
