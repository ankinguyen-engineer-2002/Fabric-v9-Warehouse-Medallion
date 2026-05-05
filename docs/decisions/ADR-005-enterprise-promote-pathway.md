# ADR-005: Enterprise Promote Pathway — US/VN Collaboration Model

Date: 2026-05-03

Status: Proposed — naming resolved (2026-05-04), ownership questions 3-7 still pending Bob

## Context

Two teams collaborate to build data infrastructure for Vietnam Supply Chain on Microsoft Fabric:

- **Bob's team (US, Enterprise Data)**: Owns EnterpriseData workspace, sets enterprise standards, manages shared infrastructure.
- **Cherry + Aric's team (VN, Supply Chain DA)**: Builds SC data products (Forecast Accuracy, Order Management), currently self-contained in SupplyChain workspace.

Cherry proposed a phased approach to Bob: VN team develops all-in within the SupplyChain workspace, then promotes stable data products to EnterpriseData workspace when ready for multi-BU consumption.

Key constraints:

- Timezone gap: US (CST) vs VN (ICT) = ~12h offset. Each approval loop costs 24-48h.
- VN team needs delivery speed during dev. US team needs governance control on enterprise assets.
- Current architecture is fully self-contained — Bronze/Silver/Gold/Meta all within SupplyChain workspace.

## Decision

### Phase 1: Dev — VN Team Full Control (current state)

Build everything inside SupplyChain workspace. No external dependencies for dev/test cycle.

```
SupplyChain Workspace (VN team owns)
├── Bronze   → Lakehouse shortcuts (read from EnterpriseData)
├── Silver   → Processing_Warehouse (domain schemas)
├── Gold     → Gold_Warehouse (dedicated, Direct Lake ready)
└── Meta     → Control plane (registry, DQ, lineage, DAG, logging)
```

Rules:
- VN team has full CRUD on all objects — no approval needed per change.
- Naming follows Bob standards from day 1 (pending confirmation on 2 items from ADR-003).
- DQ rules and source contracts are built alongside tables, not retrofitted.

### Phase 2: Promote — Bob Review Once Per Data Product

When a data product is stable and used across multiple BUs:

```
Promote Checklist:
  ✅ DQ rules active, 0 critical failures for 30+ days
  ✅ Source contracts validated (SourceContract + SourceContractRun)
  ✅ Lineage auto-built (LineageEdge complete)
  ✅ Naming convention matches Bob standards
  ✅ Primary keys populated in AssetRegistry
  ✅ Schema follows business logic group naming
  ✅ Column-level documentation in Enterprise Dictionary
```

Promote mechanism — export bundle per data product:
1. **SQL bundle**: Views + SPs (copy-paste, no GUIDs)
2. **Config bundle**: AssetRegistry rows + DQ rules + lineage edges (INSERT scripts)
3. **Pipeline**: Requires reconfiguration (workspaceId, artifactId, connections)

### Portability Assessment

| Component | Portability | Notes |
|---|---|---|
| View definitions (SQL) | 95% copy-paste | Pure SQL, no workspace dependency |
| SP definitions (SQL) | 95% copy-paste | `usp_GenericLoad` is generic |
| Meta config (registry, DQ) | 90% export/import | SELECT → INSERT scripts |
| Lineage edges | 100% auto-rebuild | `usp_BuildLineage` regenerates |
| Pipeline JSON | 50% — needs reconfig | Hardcoded GUIDs: workspaceId, artifactId, pipelineId |
| LinkedService connections | 40% — needs reconfig | Different workspace = different endpoint |
| Cross-DB 3-part naming | 30% — needs reconfig | `Processing_Warehouse.Schema.Table` name changes |

### Open Questions for Bob

| # | Question | Impact | Urgency | Status |
|---|---|---|---|---|
| 1 | ~~Naming convention: PascalCase columns or snake_case?~~ | ~~Full schema rename~~ | ~~Immediate~~ | **RESOLVED** — PascalCase adopted, ~1,800 columns renamed (2026-05-04) |
| 2 | ~~Schema suffix: `_DW`/`_ENH` or clean PascalCase?~~ | ~~Schema rename~~ | ~~Immediate~~ | **RESOLVED** — `_DW`/`_ENH`/`_WRK` suffix adopted, 6 schemas renamed (2026-05-04) |
| 3 | Promote ownership: VN team deploys on Enterprise WH, or Bob team deploys? | Affects tooling + access requirements | High | **PENDING Bob** |
| 4 | Post-promote maintenance: VN team maintains, or handoff to US? | Affects DQ monitoring + change request process | High | **PENDING Bob** |
| 5 | Enterprise WH target name? | Affects cross-DB references | Medium | **PENDING Bob** |
| 6 | Dictionary API: Can VN team add column metadata to Enterprise Dictionary? | Enables column-level lineage | Medium | **PENDING Bob** |
| 7 | EnterpriseData workspace access for VN team? | Enables source discovery + shortcut management | Medium | **PENDING Bob** |

## Consequences

### Positive

- VN team retains full delivery speed during dev — no approval bottleneck.
- Bob reviews once per data product (not per commit/change).
- Quality is baked in from day 1 (DQ, contracts, lineage) — not a promote-time scramble.
- Framework is metadata-driven — 80%+ of code is portable without modification.
- Phased model reduces risk: if promote requirements change, only Phase 2 adapts.

### Costs and Risks

- Pipeline reconfiguration at promote time is manual (~1-2 day effort per data product).
- ~~If naming convention differs from current (snake_case → PascalCase), migration is significant.~~ **DONE** — full rebuild executed 2026-05-04 (22 tables, 23 views, ~1,800 columns, 7 Gold tables).
- Post-promote ownership must be clearly defined before first promote — ambiguity leads to orphaned data products.
- Cross-DB 3-part naming creates coupling to warehouse names — consider parameterizing.

### Recommended Prep Actions

1. **Parameterize pipeline GUIDs** — move workspaceId/artifactId to pipeline parameters for promote portability.
2. **Build export script** — `export_data_product.py` to dump all SQL + config for a given project.
3. ~~**Hold on new data products** until naming convention is confirmed with Bob~~ — **RESOLVED**: naming convention confirmed and implemented (2026-05-04).
4. **Request EnterpriseData access** — Cherry's message to Bob is the right first step.
