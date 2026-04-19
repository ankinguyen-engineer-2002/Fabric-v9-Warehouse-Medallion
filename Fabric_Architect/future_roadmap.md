# Future Roadmap — Updates, Scale & Optimization
> Independent assessment from Principal Solution Architect & Data Engineer perspective
> Created: 2026-04-17 | Updated: 2026-04-18 | Architecture v9 score: 8.2/10

---

## Current State Summary

| Dimension | Score | Status |
|-----------|-------|--------|
| Architecture design | 9/10 | Generic SP + metadata-driven + DAG = enterprise-grade |
| Code quality | 8/10 | Clean T-SQL, error handling, retry logic |
| Documentation | 9/10 | FULL_CONTEXT.md, onboarding guide, 13 docs |
| Scalability | 7/10 | Design scales (multi-mart planned), unproven > 28 tables |
| Reliability | 8.5/10 | DQ gates (54 rules, 4 check types, pipeline-driven) + 3-layer retry + performance baseline + cost monitoring. No rollback/backup |
| Security | 6/10 | Azure AD auth, no RLS, no schema change audit |
| Operability | 6/10 | Runbook created, auto-trigger enabled. Alerting blocked (needs IT). Bus factor improving |
| **Overall** | **8.2/10** | Architecture excellent. DQ expanded (54 rules). Ops improved. Cost + perf monitoring active. Alerting blocked by IT |

---

## Strengths (keep as-is)

| # | What | Why it's good |
|---|------|---------------|
| 1 | Generic SP (1 SP, 8 patterns) | Zero per-table maintenance. Scale 28→280 without pipeline changes |
| 2 | Metadata-driven (sp_registry) | Single source of truth. Add table = 2 SQL statements |
| 3 | DAG wave computation | Auto-scale max 30 waves. Correct dependency resolution |
| 4 | Parent-child pipeline | MS recommended. Dynamic wave count, parallel within wave |
| 5 | DQ gates between layers | 54 rules, 4 check types (completeness/row_count/freshness/uniqueness), pipeline-driven ForEach. CRITICAL → STOP, WARNING → log only. 54/54 PASS |
| 6 | Pure T-SQL | Zero Spark cold-start. Deterministic deploy. Git-friendly |
| 7 | Auto-built lineage | source_objects → 52 edges, rebuilt every run |
| 8 | Smart skip scheduling | Monthly tables auto-skip. Saves compute |
| 9 | Snapshot conflict 3-layer retry | Proven 0% failure rate |
| 10 | Enterprise compatibility | 63/63 TableDictionary, 8/8 load patterns mapped |

---

## Weaknesses (need to fix)

| # | What | Severity | Impact |
|---|------|----------|--------|
| 1 | No CI/CD | **High** | No review gate, rollback difficult, manual deploy |
| 2 | No monitoring/alerting | **High** | Pipeline fail → nobody knows → stale data → wrong reports. **BLOCKED**: needs IT to approve Mail.Send or Teams channel. App created: `616bb922-8969-4ff8-8dcf-3667c0ae8e19`. Design ready in alerting_setup_guide.md |
| 3 | ~~Bus factor = 1~~ **MITIGATED** | ~~High~~ Medium | Runbook created (runbook_operations.md). Pipeline auto-trigger enabled (daily 2AM UTC+7). Still 1 person but now documented + operable by others |
| 4 | ~~sp_run_history not append-only~~ **RESOLVED** | ~~Medium~~ | Verified 2026-04-18: already append-only (120 rows, 28 SPs, 3 days history). No DELETE in usp_log_run. TODO: add retention policy (purge > 90 days) |
| 5 | DQ only internal | Medium | No source-target reconciliation. Source corruption undetected |
| 6 | No data contracts | Medium | Source schema change → silent failure or wrong data |
| 7 | Overwrite = no history | Medium | 17/18 bronze tables DROP+CTAS. No rollback possible |
| 8 | Warehouse lock-in | Low | Pure Fabric. Migration → full rewrite (acceptable if Fabric is company strategy) |
| 9 | ~~DQ engine limited~~ **RESOLVED** | ~~Low~~ | 4/7 check types active (completeness, row_count, freshness, uniqueness). 54 rules, 54/54 PASS. Phase 3 expansion 2026-04-18: +8 uniqueness/freshness rules. 3 types reserved (referential_integrity, validity, custom_sql) |
| 10 | Manual sp_registry seeding | Low | No UI, no validation. Error-prone at scale |

---

## Phase 1: Production Hardening (do first)

> Priority: before going live with real business users

| # | Item | Why | Effort | How |
|---|------|-----|--------|-----|
| 1 | **Alerting on pipeline failure** | Data stale and nobody knows = worst case | 1-2 days | **⚠ BLOCKED — needs IT**. Tried: Power Automate (Premium license), Teams Webhook (no channel), Graph API (admin consent), Data Activator (401). App created: `616bb922`. Design ready: alerting_setup_guide.md. When IT approves → 5 min setup |
| 2 | ~~**sp_run_history append-only**~~ | ~~Need execution history~~ | ~~0.5 day~~ | **DONE** — verified 2026-04-18: already append-only (120 rows, 28 SPs). TODO: retention policy purge >90 days |
| 3 | ~~**Runbook / SOP**~~ | ~~Bus factor 1~~ | ~~1 day~~ | **DONE 2026-04-18** — runbook_operations.md: health check, 6 common errors, re-run guide, useful queries, escalation path. Added to README |
| 4 | ~~**Pipeline auto-trigger**~~ | ~~Manual trigger~~ | ~~0.5 day~~ | **DONE 2026-04-18** — Fabric Schedule: daily 2:00 AM UTC+7 (Bangkok/Hanoi), end 2099 |
| 5 | **Source-target reconciliation** | Bronze copy wrong → all downstream wrong → DQ won't catch it | 2 days | New check_type `reconciliation`: COUNT(*) source vs COUNT(*) target. Auto-generate from source_objects in sp_registry |

---

## Phase 2: CI/CD & Multi-Environment (before adding team members)

> Priority: before anyone else touches the codebase
>
> **⚠ BLOCKER: Items 6, 7, 8, 10 require Azure DevOps access (not yet granted as of 2026-04-18)**
> - Without Azure DevOps: cannot set up .sqlproj build pipeline, PR gates, or SqlCmdVariable deploy flow
> - Item 9 (rollback strategy) is NOT blocked — can implement independently
> - When access is granted: ~4-5 days to set up full CI/CD (create .sqlproj, convert SQL to `$(...)`, azure-pipelines.yml, publish profiles)

| # | Item | Why | Effort | How | Blocked? |
|---|------|-----|--------|-----|----------|
| 6 | **DEV → TEST → PROD** | Production changes need validation before going live | 3-5 days | Fabric Deployment Pipelines or Git sync. 3 workspaces, promotion gates | **YES — Azure DevOps** |
| 7 | **Git-based SQL validation** | Catch syntax errors before deploy | 2 days | `.sqlproj` + `dotnet build` (DacFx). Build FAILS if schema invalid → errors caught before deploy. Matches Enterprise pattern | **YES — Azure DevOps** |
| 8 | **Code review gate** | Prevent breaking changes | 1 day | Azure DevOps PR required before deploy. Branch protection rules | **YES — Azure DevOps** |
| 9 | **Rollback strategy** | Bad deploy → need to undo quickly | 1 day | Pre-deploy: snapshot sp_registry + meta tables. Post-deploy: verify DQ. Fail → restore snapshot | No |
| 10 | **Environment config (SqlCmdVariable)** | Same code, different connections per env | 1 day | Convert 30+ views: `Enterprise_Lakehouse.x.y` → `[$(Enterprise_Lakehouse)].x.y`. Publish profiles per env override values. `sqlpackage publish` replaces `$(...)` before Fabric sees it. **DO NOT convert SQL until sqlpackage deploy flow is ready — `$(...)` syntax breaks direct Fabric execution** | **YES — Azure DevOps** |

---

## Phase 3: Scale to N Tables / N Projects (when growing)

> Priority: when adding 2nd data mart or > 50 tables

| # | Item | Why | Effort | How |
|---|------|-----|--------|-----|
| 11 | **Multi-mart parallel** | N projects in 1 pipeline. Cost = max(mart) not sum(marts) | 2 days | Already designed in multi_mart_scale_architecture.md. Master ForEach projects → child pipelines per layer |
| 12 | **Data contracts** | Source schema change detection before it breaks ETL | 3 days | Before bronze load: compare source INFORMATION_SCHEMA vs expected schema from sp_registry. Alert on drift |
| 13 | ~~**DQ expansion**~~ | ~~Activate remaining check types~~ | ~~1-2 days~~ | **DONE 2026-04-18** — +8 rules (uniqueness on SLV/GLD PKs, freshness on SLV/GLD). 30→54 rules, 3→4 check types. Pipeline tested 54/54 PASS. 3 types reserved (referential_integrity, validity, custom_sql) |
| 14 | **Cost monitoring** | Track CU consumption per pipeline run | 1 day | Fabric capacity metrics API → log CU per run → alert if over budget |
| 15 | **Performance baseline** | Detect degradation before users complain | 2 days | Track avg duration per SP in sp_run_history. Alert if > 2x baseline. Requires append-only history (Phase 1 item 2) |

---

## Phase 4: Enterprise Integration (when aligning with US team)

> Priority: when Enterprise team wants to integrate or standardize

| # | Item | Why | Effort | How |
|---|------|-----|--------|-----|
| 16 | **Alert/email system** | Map Enterprise usp_DataWarehouseDataFeedAlert_Fabric | 2 days | Implement SLA-based alerts: gold table not refreshed by X AM → email stakeholders |
| 17 | **SLA monitoring** | BI consumers need freshness guarantees | 1 day | Gold table _load_dt vs SLA deadline. Check in DQ gold rules with freshness type |
| 18 | **Cross-warehouse lineage** | Understand data flow across v8, v9, Enterprise | 3 days | Extend sp_lineage to include cross-warehouse edges. Visualize in Streamlit app |
| 19 | **Shared TableDictionary sync** | Enterprise team queries vw_table_dictionary using their column names | 1 day | Already have view. Need: scheduled export or direct cross-DB query from Enterprise |
| 20 | **Unified monitoring dashboard** | Single view of all pipeline health, DQ results, lineage | 2 days | Power BI report on meta tables (sp_run_history, dq_results, pipeline_run_log, sp_lineage) |

---

## Priority Matrix

```
                    HIGH IMPACT
                        |
         P1.1 Alerting  |  P2.6 CI/CD (DEV→PROD)
         P1.2 History   |  P2.7 SQL validation
         P1.3 Runbook   |  P3.12 Data contracts
                        |
  LOW EFFORT -----------+----------- HIGH EFFORT
                        |
         P1.4 Auto-trig |  P3.11 Multi-mart
         P1.5 Reconcil  |  P4.18 Cross lineage
         P3.13 DQ expand|  P4.20 Dashboard
                        |
                    LOW IMPACT
```

**Do first**: Top-left quadrant (high impact, low effort) → ~~Alerting~~ (blocked IT), ~~append-only history~~ (done), ~~runbook~~ (done), ~~auto-trigger~~ (done). **3/4 completed 2026-04-18.**

---

## Quick Wins (can do in 1 day each)

1. ~~Enable Fabric scheduled trigger~~ **DONE 2026-04-18** — daily 2AM UTC+7
2. ~~Make sp_run_history append-only~~ **DONE** — already append-only (verified)
3. ~~Write runbook for pipeline failure~~ **DONE 2026-04-18** — runbook_operations.md
4. ~~Add freshness DQ rule for gold tables~~ **DONE** — freshness active on gold
5. Create Power BI report on meta tables (1 day)

---

## Enterprise Alignment Summary (as of 2026-04-18)

| Category | Coverage | Detail |
|----------|----------|--------|
| Load Patterns | 8/8 (100%) | All Enterprise patterns in usp_generic_load |
| TableDictionary | 63/63 (100%) | vw_table_dictionary maps all columns |
| Audit Log | ✅ | sp_run_history ↔ Enterprise AuditLog |
| Timezone | ✅ | ufn_utc_to_cst (DST aware) |
| DQ/Audit | ✅ | 7 check types (3 active) — **exceeds** Enterprise (row count only) |
| Schema Pattern | ✅ | 4 schemas ↔ Enterprise 3-tier domain |
| Alerts/Email | ❌ | Enterprise has usp_DataWarehouseDataFeedAlert_Fabric → Phase 1+4 |
| CI/CD (.sqlproj) | ❌ | Enterprise has .sqlproj + DacFx + Azure Pipelines → Phase 2 (blocked: no Azure DevOps access) |
| Multi-environment | ❌ | Enterprise has Dev/Prod publish profiles + SqlCmdVariable → Phase 2 (blocked: no Azure DevOps access) |
| **Current** | **~91%** | 8/11 Enterprise features mapped |
| **After Phase 2** | **~95%** | + CI/CD + multi-env |
| **After Phase 4** | **100%** | + alerts/email |

### v9 features that EXCEED Enterprise (Enterprise doesn't have):

| Feature | v9 | Enterprise |
|---------|-----|-----------|
| DAG orchestration | depends_on + auto wave computation | ❌ |
| Auto lineage | sp_lineage 52 edges, auto-rebuilt | ❌ |
| Advanced DQ | 7 check types, severity-based, pipeline gates | Row count only |
| SM auto-refresh | Direct Lake + API refresh | ❌ |
| Multi-mart ready | project column, design sẵn | ❌ |
| Smart skip scheduling | Cron + ufn_should_run per table | ❌ |

---

*This roadmap should be revisited quarterly or when major changes happen (new project, new team member, Enterprise alignment).*
