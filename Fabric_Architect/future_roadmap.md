# Future Roadmap — Updates, Scale & Optimization
> Independent assessment from Principal Solution Architect & Data Engineer perspective
> Created: 2026-04-17 | Architecture v9 score: 7.3/10

---

## Current State Summary

| Dimension | Score | Status |
|-----------|-------|--------|
| Architecture design | 9/10 | Generic SP + metadata-driven + DAG = enterprise-grade |
| Code quality | 8/10 | Clean T-SQL, error handling, retry logic |
| Documentation | 9/10 | FULL_CONTEXT.md, onboarding guide, 13 docs |
| Scalability | 7/10 | Design scales (multi-mart planned), unproven > 28 tables |
| Reliability | 7/10 | DQ gates + retry good, no rollback/backup |
| Security | 6/10 | Azure AD auth, no RLS, no schema change audit |
| Operability | 5/10 | No alerting, no monitoring, bus factor 1 |
| **Overall** | **7.3/10** | Architecture excellent. Ops needs hardening |

---

## Strengths (keep as-is)

| # | What | Why it's good |
|---|------|---------------|
| 1 | Generic SP (1 SP, 8 patterns) | Zero per-table maintenance. Scale 28→280 without pipeline changes |
| 2 | Metadata-driven (sp_registry) | Single source of truth. Add table = 2 SQL statements |
| 3 | DAG wave computation | Auto-scale max 30 waves. Correct dependency resolution |
| 4 | Parent-child pipeline | MS recommended. Dynamic wave count, parallel within wave |
| 5 | DQ gates between layers | CRITICAL stops pipeline. Config-driven, severity-based |
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
| 2 | No monitoring/alerting | **High** | Pipeline fail → nobody knows → stale data → wrong reports |
| 3 | Bus factor = 1 | **High** | 1 person built everything. No runbook, no on-call |
| 4 | sp_run_history not append-only | Medium | Overwrites old rows. Can't trend analysis or debug historical failures |
| 5 | DQ only internal | Medium | No source-target reconciliation. Source corruption undetected |
| 6 | No data contracts | Medium | Source schema change → silent failure or wrong data |
| 7 | Overwrite = no history | Medium | 17/18 bronze tables DROP+CTAS. No rollback possible |
| 8 | Warehouse lock-in | Low | Pure Fabric. Migration → full rewrite (acceptable if Fabric is company strategy) |
| 9 | DQ engine limited | Low | Only 2 check types used (completeness + row_count). 5 unused |
| 10 | Manual sp_registry seeding | Low | No UI, no validation. Error-prone at scale |

---

## Phase 1: Production Hardening (do first)

> Priority: before going live with real business users

| # | Item | Why | Effort | How |
|---|------|-----|--------|-----|
| 1 | **Alerting on pipeline failure** | Data stale and nobody knows = worst case | 1-2 days | Fabric Pipeline → On Failure → Logic App / Power Automate → email/Teams. Or implement Enterprise `usp_DataWarehouseDataFeedAlert_Fabric` pattern |
| 2 | **sp_run_history append-only** | Need execution history for debugging, trend analysis, SLA tracking | 0.5 day | Remove DELETE logic from usp_log_run. Add retention policy (keep 90 days, purge older) |
| 3 | **Runbook / SOP** | Bus factor 1 → need documentation for others to operate | 1 day | Write: "Pipeline failed → check sp_run_history → common errors → how to re-run → escalation path" |
| 4 | **Pipeline auto-trigger** | Manual trigger = human dependency = unreliable | 0.5 day | Fabric scheduled trigger: daily 2AM UTC. Already have cron + smart skip ready |
| 5 | **Source-target reconciliation** | Bronze copy wrong → all downstream wrong → DQ won't catch it | 2 days | New check_type `reconciliation`: COUNT(*) source vs COUNT(*) target. Auto-generate from source_objects in sp_registry |

---

## Phase 2: CI/CD & Multi-Environment (before adding team members)

> Priority: before anyone else touches the codebase

| # | Item | Why | Effort | How |
|---|------|-----|--------|-----|
| 6 | **DEV → TEST → PROD** | Production changes need validation before going live | 3-5 days | Fabric Deployment Pipelines or Git sync. 3 workspaces, promotion gates |
| 7 | **Git-based SQL validation** | Catch syntax errors before deploy | 2 days | Option A: SQL linter (sqlfluff). Option B: .sqlproj build. Option C: dry-run EXEC. See sqlproj_validation_guide.md |
| 8 | **Code review gate** | Prevent breaking changes | 1 day | GitHub PR required before deploy. Branch protection rules |
| 9 | **Rollback strategy** | Bad deploy → need to undo quickly | 1 day | Pre-deploy: snapshot sp_registry + meta tables. Post-deploy: verify DQ. Fail → restore snapshot |
| 10 | **Environment config** | Same code, different connections per env | 1 day | SqlCmdVariable pattern or env-specific sp_registry seeds |

---

## Phase 3: Scale to N Tables / N Projects (when growing)

> Priority: when adding 2nd data mart or > 50 tables

| # | Item | Why | Effort | How |
|---|------|-----|--------|-----|
| 11 | **Multi-mart parallel** | N projects in 1 pipeline. Cost = max(mart) not sum(marts) | 2 days | Already designed in multi_mart_scale_architecture.md. Master ForEach projects → child pipelines per layer |
| 12 | **Data contracts** | Source schema change detection before it breaks ETL | 3 days | Before bronze load: compare source INFORMATION_SCHEMA vs expected schema from sp_registry. Alert on drift |
| 13 | **DQ expansion** | More check types for better coverage | 2 days | Add uniqueness checks on silver PKs. Add freshness checks on gold tables. Add referential integrity silver→bronze |
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

**Do first**: Top-left quadrant (high impact, low effort) → Alerting, append-only history, runbook, auto-trigger.

---

## Quick Wins (can do in 1 day each)

1. Enable Fabric scheduled trigger (0.5 day)
2. Make sp_run_history append-only + 90-day retention (0.5 day)
3. Write runbook for pipeline failure (1 day)
4. Add freshness DQ rule for gold tables (0.5 day)
5. Create Power BI report on meta tables (1 day)

---

*This roadmap should be revisited quarterly or when major changes happen (new project, new team member, Enterprise alignment).*
