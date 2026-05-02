# ADR-003: Bob/Rakesh Standards Compliance Audit — v10 vs DOCX

Date: 2026-05-03

Status: Open — Pending Bob/Rakesh confirmation on 4 items

## Context

v10 Hybrid Medallion architecture was audited against Bob's `SQL Server Data Warehouse Standards.docx` and Bob's email feedback. This ADR documents the compliance status, gaps, and pending decisions.

Source evidence:
- `02_Architect_v10_May/SQL Server Data Warehouse Standards.docx` (local-only)
- `02_Architect_v10_May/04_revised_bob_standards_proposal.md`
- `02_Architect_v10_May/09_bob_standards_mapping_matrix.md`
- `02_Architect_v10_May/08_v10_gap_matrix.md`
- Live Fabric audit: 2026-05-03

---

## 1. Compliance Summary

| Category | Count | Status |
|---|---|---|
| Fully compliant | 13 | PASS |
| Adapted for Fabric (documented) | 7 | PASS with adaptation |
| Needs fix (easy) | 2 | Action items below |
| Needs Bob decision | 2 | Pending |
| Not applicable (Fabric) | 7 | N/A |

---

## 2. PASS — 13 Standards Met

| # | Standard | Evidence |
|---|---|---|
| 1 | Schemas phân nhóm logic | 6 domain schemas + 1 Gold schema |
| 2 | Table names PascalCase | 22/22 verified |
| 3 | Gold tables Fact/Dim prefix | FactForecastActual, FactForecastKpi |
| 4 | No user objects in dbo | 0 objects |
| 5 | TableDictionary metadata | `Meta.vw_TableDictionary` 63 Enterprise columns, 28/28 coverage |
| 6 | ETL tool + method documented | load_type, frequency, source_objects, view_name all populated |
| 7 | Architecture approval process | ADR-001, ADR-002, readiness scorecard |
| 8 | Kimball star schema | Fact tables in Gold |
| 9 | Date columns use DATE/DATETIME | All `dt_*` verified |
| 10 | Separate environments | DEV workspace active |
| 11 | Direct Lake for BI | Gold physical tables = semantic source (adapted from old view rule) |
| 12 | ETL replication types | 8 load patterns documented + implemented |
| 13 | Metadata-driven ETL | 1 generic SP, registry-driven |

---

## 3. NEEDS FIX — 2 Easy Items

### FIX-001: SELECT * in ReferenceMaster Views

**Bob rule**: "All views should have explicit column names. SELECT * needs justification and architect approval."

**Current**: 7 ReferenceMaster views use `SELECT *`:
- `vw_CustomerAccount`
- `vw_CustomerShippingLocation`
- `vw_ForecastCycle`
- `vw_ItemMaster`
- `vw_OrderType`
- `vw_Product`
- `vw_Warehouse`

**Fix**: Replace `SELECT *` with explicit column lists. Non-breaking — view output stays the same.

**Effort**: ~30 min

### FIX-002: Primary Key Metadata Empty

**Bob rule**: "All tables should have a Primary Key that can be used to uniquely identify each row. All tables will be periodically tested for duplicates based on that key."

**Current**: `Meta.AssetRegistryV10.primary_key` column exists but is NULL for all 28 assets.

**Fix**: Populate PK values. Example mappings:

| Asset | Primary Key |
|---|---|
| `SalesHistory.InvoiceDetailLineLevel` | `id_invoice, num_item_sequence` |
| `ForecastHistory.ForecastDemandMonthly` | `id_item_sku, code_warehouse, code_customer_group, dt_fsc_month_first, dt_snapshot` |
| `OpenOrderHistory.OpenOrderLineLevel` | `id_order, num_item_sequence` |
| `ForecastAccuracy.FactForecastActual` | `id_item_sku, code_warehouse, code_customer_group, dt_fsc_month_first, code_horizon, name_version` |
| `ReferenceMaster.Calendar` | `sk_date` |
| `ReferenceMaster.ItemMaster` | `ItemSKU` |

**Effort**: ~15 min

---

## 4. NEEDS BOB DECISION — 2 Items

### DECISION-001: Schema Suffix Convention

**DOCX says**: Schemas must have suffixes: `_DW` (curated), `_ENH` (enhanced/Silver), `_WRK` (work/staging), `_XBK` (backup), `_Audit`, `_Archive`.

**Bob email says**: PascalCase for Silver/Gold. No mention of suffixes.

**v10 current**: PascalCase without suffix (SalesHistory, ForecastAccuracy, Staging, Meta).

**If Bob requires suffix**:

| Current | Would become |
|---|---|
| `Staging` | `Staging_WRK` |
| `ReferenceMaster` | `ReferenceMaster_ENH` |
| `SalesHistory` | `SalesHistory_ENH` |
| `ForecastHistory` | `ForecastHistory_ENH` |
| `OpenOrderHistory` | `OpenOrderHistory_ENH` |
| `ForecastAccuracy` (Gold) | `ForecastAccuracy_DW` |
| `Meta` | `Meta` or `Meta_Audit` |

**Impact if changing**: DROP + CREATE all schemas, rebuild 22 tables + 28 views + registry + pipeline Lookup SQL + semantic model. ~1 full session.

**Question for Bob**: Confirm suffix style — `ForecastHistory_ENH` / `ForecastAccuracy_DW` vs pure PascalCase `ForecastHistory` / `ForecastAccuracy`?

### DECISION-002: Column Naming Convention

**DOCX says**: "All column names should be pascal case (mixed case) and should only be all upper case when the column name only contains abbreviations. All lower case is not acceptable."

**v10 current**: snake_case (`id_item_sku`, `dt_invoice`, `code_warehouse`).

**Context**:
- v9 also used snake_case (inherited)
- Enterprise `Supply Chain Control Tower` semantic model (BCherry) also uses snake_case
- Enterprise `SCP_Core` schema uses PascalCase with spaces (`Item SKU`, `Transaction Date`)
- Changing to PascalCase = rebuild ALL views + semantic model + downstream reports

**Question for Bob**: Accept snake_case as documented deviation (matching v9 + existing semantic models)? Or require PascalCase rebuild?

---

## 5. NOT APPLICABLE — 7 Items (Fabric vs ADW)

| Standard | Why N/A for Fabric |
|---|---|
| HASH/REPLICATE distribution | Fabric Warehouse serverless — no distribution control |
| CCIX/CIX indexing | Delta Lake storage — no index control |
| Table partitioning (60M+ rows) | Fabric auto-manages |
| Column statistics maintenance | Fabric auto-manages |
| SQL Agent job scheduling | Fabric Pipeline Schedule replaces |
| PolyBase external tables | OneLake shortcuts replace |
| SSIS/RadarSync/EnterpriseSync ETL tools | Fabric Pipelines + generic SP framework replaces |

---

## 6. GAP Matrix — Open High-Severity Items

| Gap | Severity | Issue | Current | Action When Ready |
|---|---|---|---|---|
| GAP-001 | High | Source-target reconciliation not active | 6 rules seeded, not executed | Wire into pipeline after DQ activation |
| GAP-004 | High | CI/CD blocked | Azure DevOps access not granted | Unblock with IT |
| GAP-005 | High | Security model not defined | No RLS/workspace security design | Design after Bob sign-off |
| GAP-008 | High | Alerting blocked | 4 approaches failed (IT permissions) | Unblock with IT |
| GAP-010 | High | Source contracts not in pipeline flow | 674 contracts seeded, not active gate | Promote to pre-load validation |
| GAP-012 | High | Silver DAG not project-aware | Computes all active Silver | Add project filter to wave computation |

---

## 7. Rebuild Plan (After Bob Confirms)

### If Bob confirms PascalCase (no suffix) — current state
- Fix FIX-001 (SELECT * views) — 30 min
- Fix FIX-002 (PK metadata) — 15 min
- Done

### If Bob requires suffix convention
1. Create new schemas with suffix: `SalesHistory_ENH`, `ForecastAccuracy_DW`, etc.
2. Recreate all views in new schemas
3. CTAS all tables into new schemas
4. Update registry (asset_id, physical_schema)
5. Update pipeline Lookup SQL
6. Rebuild lineage + DQ rules
7. Drop old schemas
8. Rebuild semantic model
9. Estimated effort: 1 full session (~2-3 hours)

### If Bob requires PascalCase columns
1. Update all Silver/Gold views with PascalCase column names
2. Reload all tables
3. Update semantic model TMDL column mappings
4. Update DQ rules column references
5. Estimated effort: 1 full session (~2-3 hours)

---

## 8. References

- Bob DOCX: `02_Architect_v10_May/SQL Server Data Warehouse Standards.docx`
- Bob mapping: `02_Architect_v10_May/09_bob_standards_mapping_matrix.md`
- Bob proposal: `02_Architect_v10_May/04_revised_bob_standards_proposal.md`
- Gap matrix: `02_Architect_v10_May/08_v10_gap_matrix.md`
- ADR-001: Adopt Hybrid Medallion
- ADR-002: EDW Supplement Exit Strategy
