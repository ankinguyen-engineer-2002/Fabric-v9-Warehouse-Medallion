# Open Questions — inventory_health mart

> **Status (updated 2026-05-19):** 3 Robert sign-offs ⏳ + ~~4 DE US loads~~ → 3 done (Dhivya 2026-05-18) + 1 workaround OK (deploy-unblocking) + 1 Bob architecture Q.

---

## §A. Robert sign-offs (3 questions, CRITICAL PATH)

Email draft ready in `_source_v1/05_NEXT_STEPS.md` Section "Track D". Send to Robert, cc team lead.

### Q1 — H1: ItemAllocationFlag value

`Wholesale_OrderManagement_AFI.OpenOrderDetail.ItemAllocationFlag` probe results:
- `0` → 16,802 rows
- `2` → 901,411 rows
- (value `1` does NOT exist)

Original ETL filtered `= 1` → 0 rows. Fix: changed to `= 2`. **Question for Robert**: is "Allocated" semantically `= 2`, or is there another valid value? Affects AllocatedDemandQty on FactInventoryHealthSnapshot.

**Where in v10**: [etl/silver_views.sql:v_AllocatedDemandCandidate](etl/silver_views.sql) — comment `H1 FIX`.

### Q2 — H5: WeekFourFlag interpretation

BRD §6.3 Revenue at Risk: "At Week Four Ending: [SINegQty] × [FOBPrice]". Two interpretations:
- **(A) Exact** — single week, week-ending = today + 28 days (Saturday rounding). Current implementation.
- **(B) Range** — 4 weeks forward (W1+W2+W3+W4 = 4 weeks). Would inflate Revenue at Risk ~4×.

**Where in v10**: [etl/gold_views.sql:v_FactInventoryRiskForward](etl/gold_views.sql) — comment `H5 FIX`.

### Q3 — M3: COGS rolling grain (52M vs 52W)

BRD says "52 weeks trailing COGS" for KPI #22 Inventory Turns. Implementation: monthly grain `ROWS BETWEEN 51 PRECEDING` → 52 months (~4.3 yr), not 52 weeks (~1 yr).

Options:
- **(A) Keep 52M** (current) — label measure clearly "COGS 52M Trailing"
- **(B) Rewrite 52W** — rebuild CogsRollingHelper at weekly grain (Saturday week-ending), add FiscalWeekYear join column, accept ~30 min extra ETL time

**Where in v10**: [etl/gold_views.sql:v_CogsRollingHelper](etl/gold_views.sql) + [semantic/Measures_DAX.dax](semantic/Measures_DAX.dax) + [semantic/SemanticModel.tmdl](semantic/SemanticModel.tmdl) — all marked `M3 FIX`.

---

## §B. DE US team — bronze loads — RESOLUTION (updated 2026-05-19)

Dhivya (DE US) confirmed 5-row table in Slack 2026-05-18 4:45 PM. Aric verified via pyodbc 2026-05-19.

| # | Table | Status 2026-05-19 | Rows verified | Action remaining |
|---|---|---|---:|---|
| 1 | `Enterprise.Wholesale_ProductSourcing_AFI.PoMaster` | ✅ **DONE** (Dhivya 2026-05-18) | 5,688,132 | Switch `v_PurchaseOrder` source path SC_LH → Enterprise |
| 2 | `Enterprise.Inventory_Enh_History.ItemBalance` | ⏳ Enterprise schema vẫn missing — **WORKAROUND OK**: `SC_LH.dbo.itembalance` via `df_brz_ItemBalance` | 48,968,574 | (a) Chase Dhivya Enterprise promote OR (b) deploy v1 với SC_LH source |
| 3 | `Enterprise.SupplyChain_Enh.DemandFulfillmentCommonContainer_Logility` (Dhivya viết tắt "DemandFulfilmentCommonContain_Logility.ItemStatus") | ✅ **DONE** (Dhivya 2026-05-18) | 38,356,303 | Switch `v_LogilityItemStatus` source path SC_LH → Enterprise |
| 4 | `Enterprise.SupplyChain_Enh.PurchaseOrderSnapshot` | ⏳ Enterprise vẫn missing — **WORKAROUND OK**: `SC_LH.dbo.purchaseordersnapshot` via `df_brz_PurchaseOrderSnapshot` (2B rows ⚠️) | 1,997,040,026 | Phase 2 only; defer |
| 5 | `Enterprise.Wholesale_ProductSourcing_AFI.PoDetail` (originally 0 rows, separate item) | ✅ **DONE** (Dhivya 2026-05-18) | 21,945,294 | None — view already reads Enterprise (B1) |

**Plus column-deprecation finding (Dhivya rows 3-4, verified Aric 2026-05-19):**
- `ITBEXT.CRHLD/DLHLD/TOHLD/ATPQT` — 0 nonzero/3.39M rows → deprecated, không cần reload
- `ITEMBL.PHYOH` — 0 nonzero/3.41M rows → deprecated
- Action: thêm DQ rule `expected_zero` + DELETE 2 dataflow drafts (`df_brz_ITBEXT_Reloaded`, `df_brz_ITEMBL_PHYOH_Reloaded`)

**Plus dup classification update (Rakeshbalaji Slack 2026-05-09, verified Aric 2026-05-19):**

| Bảng | Grain | Loại | Evidence | Fix |
|---|---|---|---|---|
| `PoDetail` | (podordernum, podvendornum, poditemsequence) | ✅ **TRUE row dup** | 1 pair, 53/53 cols identical (Key 'P0SM242'\|'612908'\|1) | ROW_NUMBER ORDER BY podduedate DESC (current, OK) |
| `Logility` | (Item, Whse, WeekEnding) | ❌ **GRAIN CONFLICT** (không phải dup) | 9,128 pairs, 47/53 cols identical, 6 metrics differ (FirmDemand/Netfcst/ShippableInvQty/ShippableInvAmt/MosofSupply/OnHandAmt). Pattern: 1 data-row + 1 zero-placeholder | **FIXED 2026-05-19**: new ORDER BY prefers non-zero metrics row, then StatusChngDate, then OnHandAmt |
| `MasterData_ItemMaster_AFI.ITEMASA` | (STID, ITNBR) | N/A (out of scope) | Not used in inventory_health views | Not our concern; Bob's hub stranded-table issue |

**ETL code fixes applied 2026-05-19** (Silver layer only — Gold unaffected):
1. `v_PurchaseOrder` LEFT JOIN switched: `SC_LH.dbo.pomaster` → `Enterprise_Lakehouse.Wholesale_ProductSourcing_AFI.PoMaster`
2. `v_LogilityItemStatus` FROM switched: `SC_LH.dbo.logility_demandfulfillment` → `Enterprise_Lakehouse.SupplyChain_Enh.DemandFulfillmentCommonContainer_Logility`
3. `v_LogilityItemStatus` ORDER BY rewritten for grain-conflict (prefer non-zero data row)
4. `v_LogilityItemStatusSnapshotWeekly` SourceSystem/SourceTable hardcodes updated to Enterprise
5. `registry_inserts.sql`: A2 PurchaseOrder `is_active=1` (was 0), A3 LogilityItemStatus `is_active=1` (was 0), source_objects JSON now points to EL

**Registry final state**: A1/A2/A3 → `is_active=1` (EL primary); A4 → `is_active=0` (still blocked, but workaround dataflow ready); A5 → `is_active=0` (Phase 2 defer).

**Deploy unblocked**: với 3 EL loads + 2 SC_LH workarounds + view code updated, bronze layer ready cho v1 deploy. Còn lại: **3 Robert sign-offs (H1/H5/M3)** — critical path.

---

## §C. Bob architecture — 1 question

### Q4 — Cross-mart Dim reuse: DimCalendar / DimProduct / DimWarehouse

V10 forecast project published `ForecastAccuracy_DW.DimCalendar/DimProduct/DimWarehouse`. Inventory Health design intent was to potentially REUSE these dims via DirectLake cross-mart relationship.

**Decision made (this folder)**: KEEP inventory_health Gold dims self-contained in `InventoryHealth_DW`. Reason: deliverable v1 designed DAX measures against inventory-specific column schemas that differ from forecast's DimProduct.

**Question for Bob**: is duplicated physical Gold dim acceptable for now, or should we promote forecast's dims to a shared schema (e.g., `SharedDims_DW`) that both marts read? Tradeoff: simplicity (current) vs DRY (shared schema).

---

## §D. Deferred (L3) — Phase 2

| Item | Owner | Defer reason |
|---|---|---|
| MOMAST OSTAT firm list `('10','40','45')` | Robert | Phase 2 — current placeholder works for now |
| Transfer InTransit historical (currently NULL for SnapshotType='Weekly') | Aric | Phase 2 — snapshot-aware version using InventorySnapshotWeekly |
| ATPSUM "8AM 2nd version" intraday refresh | DE US | Phase 2 if needed |
| AvgIvc subquery tightening (potential dup rows) | Aric | Phase 2 — current accuracy acceptable for Phase 1 |

---

## Email status

- 2026-05-18: Draft prepared.
- 2026-05-18 4:45 PM: Dhivya (DE US) confirmed §B items via Slack — 3 Enterprise loads done + 2 workarounds via Aric dataflows + 5 cols confirmed deprecated.
- 2026-05-19: Aric verified all row counts via pyodbc.
- Email NOT yet sent (waiting for Aric to consolidate Q1/Q2/Q3 into single email per memory `feedback_working_style`). **§B items can now be dropped from email — only Q1/Q2/Q3 + Q4 remain.**
