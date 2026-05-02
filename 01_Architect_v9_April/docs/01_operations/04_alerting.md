# Pipeline Alerting Setup — Power Automate + Teams
> Step-by-step guide to set up automatic alerts when pipeline fails
> Estimated time: 15-20 minutes (after IT approves)
>
> **⚠ STATUS: BLOCKED — needs IT support (as of 2026-04-18)**
> - Power Automate: needs Premium license
> - Teams Webhook: needs channel creation permission
> - Graph API: needs admin consent for Mail.Send on app `616bb922-8969-4ff8-8dcf-3667c0ae8e19`
> - Data Activator: 401 error on OneLake events
> - **When any of above is resolved → follow setup below (5-10 minutes)**

---

## Architecture

```
pl_sc_master (Fabric Pipeline)
    │
    ├── [Success] → finalize → SM refresh → done
    │
    └── [On Failure] → Web Activity POST
                          │
                          ▼
                   Power Automate Flow
                   (HTTP trigger → parse → Teams)
                          │
                          ▼
                   Teams Channel Message
                   (Adaptive Card — rich format)
```

---

## Part 1: Create Power Automate Flow (10 minutes)

### Step 1 — New Flow

1. Go to **https://make.powerautomate.com**
2. Left menu → **+ Create** → **Instant cloud flow**
3. Flow name: `Fabric Pipeline Alert`
4. Trigger: chon **When an HTTP request is received**
5. Click **Create**

### Step 2 — Configure HTTP Trigger

Click vao trigger **When an HTTP request is received**, dan JSON Schema vao:

```json
{
  "type": "object",
  "properties": {
    "pipeline_name": { "type": "string" },
    "pipeline_run_id": { "type": "string" },
    "status": { "type": "string" },
    "timestamp": { "type": "string" },
    "workspace_id": { "type": "string" },
    "error_message": { "type": "string" }
  }
}
```

→ Click **Save** 1 lan de lay **HTTP POST URL** (copy URL nay, can dung sau)

### Step 3 — Add Teams Action

1. Click **+ New step**
2. Search: **Microsoft Teams**
3. Chon: **Post adaptive card in a chat or channel**
4. Cau hinh:
   - Post as: **Flow bot**
   - Post in: **Channel**
   - Team: *(chon team cua ban)*
   - Channel: *(chon channel nhan alert, vi du #pipeline-alerts)*
   - Adaptive Card: **dan JSON ben duoi**

### Adaptive Card JSON (copy nguyen khoi nay):

```json
{
  "type": "AdaptiveCard",
  "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
  "version": "1.5",
  "body": [
    {
      "type": "ColumnSet",
      "columns": [
        {
          "type": "Column",
          "width": "auto",
          "items": [
            {
              "type": "TextBlock",
              "text": "🔴",
              "size": "Large"
            }
          ],
          "verticalContentAlignment": "Center"
        },
        {
          "type": "Column",
          "width": "stretch",
          "items": [
            {
              "type": "TextBlock",
              "text": "PIPELINE FAILED",
              "weight": "Bolder",
              "size": "Large",
              "color": "Attention"
            },
            {
              "type": "TextBlock",
              "text": "SupplyChain Warehouse ETL",
              "spacing": "None",
              "isSubtle": true
            }
          ]
        }
      ]
    },
    {
      "type": "Container",
      "style": "emphasis",
      "items": [
        {
          "type": "FactSet",
          "facts": [
            {
              "title": "Pipeline",
              "value": "@{triggerBody()?['pipeline_name']}"
            },
            {
              "title": "Status",
              "value": "❌ @{triggerBody()?['status']}"
            },
            {
              "title": "Time (UTC+7)",
              "value": "@{convertFromUtc(triggerBody()?['timestamp'], 'SE Asia Standard Time', 'yyyy-MM-dd HH:mm:ss')}"
            },
            {
              "title": "Run ID",
              "value": "@{triggerBody()?['pipeline_run_id']}"
            }
          ]
        }
      ],
      "bleed": true
    },
    {
      "type": "Container",
      "items": [
        {
          "type": "TextBlock",
          "text": "Error Details",
          "weight": "Bolder",
          "spacing": "Medium"
        },
        {
          "type": "TextBlock",
          "text": "@{triggerBody()?['error_message']}",
          "wrap": true,
          "color": "Attention",
          "fontType": "Monospace",
          "size": "Small"
        }
      ]
    },
    {
      "type": "TextBlock",
      "text": "Quick Actions",
      "weight": "Bolder",
      "spacing": "Large"
    },
    {
      "type": "ColumnSet",
      "columns": [
        {
          "type": "Column",
          "width": "stretch",
          "items": [
            {
              "type": "TextBlock",
              "text": "1️⃣  Check **sp_run_history** for failed tables",
              "wrap": true,
              "size": "Small"
            },
            {
              "type": "TextBlock",
              "text": "2️⃣  Check **dq_results** for DQ failures",
              "wrap": true,
              "size": "Small"
            },
            {
              "type": "TextBlock",
              "text": "3️⃣  Re-run pipeline if transient error",
              "wrap": true,
              "size": "Small"
            },
            {
              "type": "TextBlock",
              "text": "4️⃣  See **runbook_operations.md** for details",
              "wrap": true,
              "size": "Small"
            }
          ]
        }
      ]
    }
  ],
  "actions": [
    {
      "type": "Action.OpenUrl",
      "title": "🔍 Open Fabric Monitor",
      "url": "https://app.fabric.microsoft.com/groups/@{triggerBody()?['workspace_id']}/pipelines"
    },
    {
      "type": "Action.OpenUrl",
      "title": "📖 Open Runbook",
      "url": "https://github.com/AricNguyen/20260413_Fabric_Refactor_Architect/blob/main/sc_forecast/docs/operations/runbook.md"
    }
  ]
}
```

> **Luu y**: cac gia tri `@{triggerBody()?['...']}` se tu dong thay the bang Dynamic Content trong Power Automate editor. Neu dan JSON truc tiep ma Power Automate khong nhan dien, thi dung UI:
> - Click vao tung field → chon **Dynamic content** → chon gia tri tuong ung (pipeline_name, status, timestamp, v.v.)

### Step 4 — (Optional) Add Email Action

1. Click **+ New step** (sau Teams action)
2. Search: **Office 365 Outlook**
3. Chon: **Send an email (V2)**
4. Cau hinh:
   - To: `NAric@ashleyfurniture.com` (hoac distribution list)
   - Subject: `⚠ Pipeline FAILED: @{triggerBody()?['pipeline_name']}`
   - Body (HTML):

```html
<h2 style="color: #d13438;">⚠ Pipeline Failed</h2>
<table style="border-collapse: collapse; font-family: Segoe UI, sans-serif;">
  <tr>
    <td style="padding: 8px; font-weight: bold; background: #f3f2f1;">Pipeline</td>
    <td style="padding: 8px;">@{triggerBody()?['pipeline_name']}</td>
  </tr>
  <tr>
    <td style="padding: 8px; font-weight: bold; background: #f3f2f1;">Status</td>
    <td style="padding: 8px; color: #d13438;">@{triggerBody()?['status']}</td>
  </tr>
  <tr>
    <td style="padding: 8px; font-weight: bold; background: #f3f2f1;">Time</td>
    <td style="padding: 8px;">@{triggerBody()?['timestamp']}</td>
  </tr>
  <tr>
    <td style="padding: 8px; font-weight: bold; background: #f3f2f1;">Run ID</td>
    <td style="padding: 8px; font-family: monospace;">@{triggerBody()?['pipeline_run_id']}</td>
  </tr>
  <tr>
    <td style="padding: 8px; font-weight: bold; background: #f3f2f1;">Error</td>
    <td style="padding: 8px; color: #d13438; font-family: monospace;">@{triggerBody()?['error_message']}</td>
  </tr>
</table>
<br>
<p><b>Next steps:</b></p>
<ol>
  <li>Check <code>meta.sp_run_history</code> for failed tables</li>
  <li>Check <code>meta.dq_results</code> for DQ failures</li>
  <li>Re-run pipeline if transient error</li>
  <li>See <a href="https://github.com/AricNguyen/20260413_Fabric_Refactor_Architect/blob/main/sc_forecast/docs/operations/runbook.md">Runbook</a> for troubleshooting</li>
</ol>
```

### Step 5 — Save & Test

1. Click **Save**
2. Click **Test** → **Manually** → **Test**
3. Gui test request tu terminal (minh se cho ban command)

---

## Part 2: Update Fabric Pipeline (5 minutes)

### Step 6 — Add Web Activity in pl_sc_master

1. Open **Fabric Portal** → Workspace → **pl_sc_master**
2. Click vao **finalize** activity (hoac activity cuoi truoc SM refresh)
3. Keo duong do **On Failure** (X) ra
4. Them activity: **Web**
5. Cau hinh Web activity:

| Setting | Value |
|---------|-------|
| Name | `alert_pipeline_failure` |
| URL | *(dan HTTP POST URL tu Step 2)* |
| Method | **POST** |
| Headers | `Content-Type`: `application/json` |
| Body | *(dan JSON ben duoi)* |

### Web Activity Body:

```json
{
  "pipeline_name": "@{pipeline().Pipeline}",
  "pipeline_run_id": "@{pipeline().RunId}",
  "status": "FAILED",
  "timestamp": "@{utcnow()}",
  "workspace_id": "c8d9fc83-18b6-4e1d-8264-0b49eed36fe0",
  "error_message": "Pipeline failed. Check Fabric Monitor for details."
}
```

> **Luu y ve On Failure routing**:
> - Moi activity trong pipeline deu co 4 outputs: Success, Failure, Completion, Skipped
> - Can noi **On Failure** tu NHIEU activities ve cung `alert_pipeline_failure`
> - Recommend: noi tu cac activity chinh: `pl_sc_bronze`, `pl_sc_silver_wave`, `pl_sc_gold`, `dq_check` activities
> - Cach noi: Click activity → keo duong do (X) → tha vao `alert_pipeline_failure`

### Step 7 — Publish Pipeline

1. Click **Publish** (hoac **Save** tuy Fabric version)
2. Done

---

## Part 3: Test (2 minutes)

### Test Power Automate flow truc tiep tu terminal:

```bash
# Replace YOUR_FLOW_URL voi URL tu Step 2
curl -X POST "YOUR_FLOW_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "pipeline_name": "pl_sc_master",
    "pipeline_run_id": "test-12345-abcde",
    "status": "FAILED",
    "timestamp": "2026-04-18T09:00:00Z",
    "workspace_id": "c8d9fc83-18b6-4e1d-8264-0b49eed36fe0",
    "error_message": "TEST ALERT — Snapshot isolation conflict on bronze.brz_invoice. This is a test message."
  }'
```

### Kiem tra:
- [ ] Teams channel nhan duoc Adaptive Card?
- [ ] Card hien thi day du: pipeline name, status, time, error, buttons?
- [ ] Email nhan duoc (neu co Step 4)?
- [ ] Button "Open Fabric Monitor" mo dung link?

---

## Teams Adaptive Card Preview

Khi nhan duoc alert, Teams se hien thi card nhu sau:

```
┌─────────────────────────────────────────────┐
│ 🔴 PIPELINE FAILED                         │
│    SupplyChain Warehouse ETL                │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ Pipeline    pl_sc_master                │ │
│ │ Status      ❌ FAILED                   │ │
│ │ Time        2026-04-18 09:00:00 (UTC+7) │ │
│ │ Run ID      abc123-def456               │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ Error Details                               │
│ ┌─────────────────────────────────────────┐ │
│ │ Snapshot isolation conflict on           │ │
│ │ bronze.brz_invoice                      │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ Quick Actions                               │
│ 1️⃣  Check sp_run_history for failed tables  │
│ 2️⃣  Check dq_results for DQ failures        │
│ 3️⃣  Re-run pipeline if transient error      │
│ 4️⃣  See runbook_operations.md for details    │
│                                             │
│ [🔍 Open Fabric Monitor] [📖 Open Runbook]  │
└─────────────────────────────────────────────┘
```

---

## (Optional) Success Alert

Neu muon nhan alert khi pipeline **thanh cong** (de confirm data loaded):

1. Them 1 Web activity nua tren nhanh **On Success** cua finalize
2. Body:

```json
{
  "pipeline_name": "@{pipeline().Pipeline}",
  "pipeline_run_id": "@{pipeline().RunId}",
  "status": "SUCCESS",
  "timestamp": "@{utcnow()}",
  "workspace_id": "c8d9fc83-18b6-4e1d-8264-0b49eed36fe0",
  "error_message": "All tables loaded successfully."
}
```

3. Trong Power Automate flow, them **Condition**:
   - If `status` = "FAILED" → Red card (current)
   - If `status` = "SUCCESS" → Green card

### Success Adaptive Card (green version):

Thay doi trong card:
- `"🔴"` → `"🟢"`
- `"PIPELINE FAILED"` → `"PIPELINE SUCCESS"`
- `"color": "Attention"` → `"color": "Good"`

---

*Doc nay la mot phan cua Runbook. Xem them: [runbook_operations.md](runbook_operations.md)*
