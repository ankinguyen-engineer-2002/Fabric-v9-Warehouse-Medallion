# Task Tracker — Roadmap Implementation
> Created: 2026-04-18 | Owner: Aric
> Gach bo (~~strikethrough~~) khi xong

---

## Phase 1: Production Hardening (lam truoc khi go-live)

- [ ] **P1.1 — Alerting on pipeline failure** (1-2 ngay) **⚠ BLOCKED — cần IT support**
  - Pipeline fail → gui email/Teams tu dong
  - Da thu: Power Automate (can Premium), Teams Webhook (can channel), Graph API (can admin consent), Data Activator (401)
  - **App da tao**: `Fabric Pipeline Alert` (App ID: `616bb922-8969-4ff8-8dcf-3667c0ae8e19`)
  - **Can admin lam 1 trong 3**: (1) consent Mail.Send cho app, (2) cap quyen tao Teams channel, (3) cap Power Automate Premium
  - Adaptive Card JSON + email template da thiet ke xong trong alerting_setup_guide.md
  - Khi admin approve → setup 5 phut la xong

- [x] ~~**P1.2 — sp_run_history append-only**~~ **ALREADY DONE** (verified 2026-04-18)
  - ~~usp_log_run da la INSERT + UPDATE, khong co DELETE~~
  - ~~120 rows, 28 SPs, lich su 3 ngay (2026-04-15 → 17)~~
  - **TODO nho**: them retention policy purge > 90 ngay (tranh phinh bang)

- [x] ~~**P1.3 — Runbook / SOP** (1 ngay)~~ **DONE 2026-04-18**
  - ~~File: Fabric_Architect/runbook_operations.md~~
  - ~~Covers: health check, 6 common errors, re-run options, useful queries, escalation path~~
  - ~~Added to README Documentation Index~~

- [x] ~~**P1.4 — Pipeline auto-trigger** (0.5 ngay)~~ **DONE 2026-04-18**
  - ~~Setup Fabric Schedule: daily 2AM UTC+7 (Bangkok/Hanoi), end 2099~~

- [ ] **P1.5 — Source-target reconciliation** (2 ngay)
  - Them check_type 'reconciliation': COUNT(*) source vs COUNT(*) target
  - Auto-generate tu source_objects trong sp_registry
  - Hien tai: DQ chi check ben trong warehouse, source copy thieu → khong biet

- [x] ~~**P1.6 — EDW Source Supplement**~~ **DONE 2026-04-23**
  - ~~4 Group A tables chuyen sang doc tu _edw tables (CTAS tu SC_Lakehouse _ver2)~~
  - ~~Ly do: Enterprise_Lakehouse thieu du lieu (invoicedetail 35M vs EDW 87.7M)~~
  - ~~4 _edw tables created, 4 bronze views swapped, 2 gold views updated (code_horizon + 5 KPI cols)~~
  - ~~1 SP created: bronze.usp_refresh_edw_tables~~
  - ~~Pipeline: pl_sc_master them refresh_edw activity (first step)~~
  - ~~vw_ref_calendar: them 2 cols (dt_fsc_quarter_first, dt_fsc_quarter_last)~~
  - ~~Object count: 86 → 91. DAY LA TAM THOI — revert khi EL data day du~~
  - ~~Rollback documented: docs/operations/edw_source_swap.md~~

---

## Phase 3: Scale (khi them mart thu 2 hoac > 50 tables)

- [x] ~~**P3.11 — Multi-mart**~~ **DONE 2026-04-18** — LIVE. pl_sc_master ForEach → pl_sc_mart → bronze→silver→gold. 7 pipelines. Tested 28/28, 20.3 min
- [x] ~~**P3.12 — Data contracts**~~ **CREATED 2026-04-18** — 674 columns, 10 tables. **Not in pipeline flow**
- [x] ~~**P3.13 — DQ expansion**~~ **CREATED 2026-04-18** — 24 rules (uniqueness+freshness). **Deactivated** (is_active=0). DQ gates in pipeline deactivated
- [x] ~~**P3.14 — Cost monitoring**~~ **CREATED 2026-04-18** — table ready. **Not in pipeline flow** (finalize reverted)
- [x] ~~**P3.15 — Performance baseline**~~ **CREATED 2026-04-18** — 28 SPs baselined. **Not in pipeline flow** (finalize reverted)

> **Note**: All Phase 3 features are CREATED in warehouse (tables, SPs, rules exist) but NOT active in pipeline flow.
> Pipeline runs lean at ~18-19 min. DQ gates deactivated (activities exist, skip when run).
> To activate: re-enable DQ activities + set dq_rules is_active=1 + re-deploy enhanced finalize SP.
> Tradeoff: ~18 min (lean) vs ~27 min (full DQ + cost + perf).

---

## Phase 4: Enterprise Integration (khi US team can)

- [ ] **P4.16 — Alert/email system** (2 ngay)
  - Map Enterprise usp_DataWarehouseDataFeedAlert_Fabric
  - SLA-based: gold table chua refresh truoc 8AM → email stakeholder

- [ ] **P4.17 — SLA monitoring** (1 ngay)
  - Gold _load_dt vs SLA deadline
  - Them DQ freshness rules cho tat ca gold tables

- [ ] **P4.18 — Cross-warehouse lineage** (3 ngay)
  - Extend sp_lineage: them cross-warehouse edges (v8 → Lakehouse → v9)
  - Visualize trong Streamlit app

- [ ] **P4.19 — TableDictionary sync** (1 ngay)
  - Scheduled export hoac cross-DB query tu Enterprise
  - vw_table_dictionary da co, can setup sync

- [ ] **P4.20 — Unified monitoring dashboard** (2 ngay)
  - Power BI report: pipeline health, DQ results, lineage, SLA
  - Data tu: sp_run_history, dq_results, pipeline_run_log, sp_lineage

---

## Phase 2: CI/CD (BLOCKED — can Azure DevOps access)

- [ ] P2.6 — DEV → TEST → PROD
- [ ] P2.7 — .sqlproj SQL validation
- [ ] P2.8 — Code review gate (PR)
- [ ] P2.9 — Rollback strategy (NOT blocked)
- [ ] P2.10 — SqlCmdVariable conversion

> ⚠ Khong convert SQL sang $(...) cho den khi co Azure DevOps + sqlpackage deploy flow

---

*Cap nhat lan cuoi: 2026-04-23*
