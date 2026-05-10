<div align="center">

# Hybrid Medallion Architecture
### Multi-Workspace Enterprise Data Platform on Microsoft Fabric

<br/>

![PLATFORM](https://img.shields.io/badge/PLATFORM-Microsoft_Fabric-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![PATTERN](https://img.shields.io/badge/PATTERN-Hub_+_Value_Stream-6C3483?style=for-the-badge)
![BI](https://img.shields.io/badge/BI-Direct_Lake-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![CONTROL](https://img.shields.io/badge/CONTROL-Metadata_Driven-CC2927?style=for-the-badge)

[![Lineage Explorer](https://img.shields.io/badge/LIVE-Fabric_Lineage_Flow-0ea5e9?style=for-the-badge&logo=streamlit&logoColor=white)](https://sc-lineage.streamlit.app/)

</div>

---

## What this repo is

A **2-workspace enterprise data architecture** for Ashley Furniture's Supply Chain value stream on Microsoft Fabric. Implements the **hub-and-spoke pattern** Bob Horton's enterprise team established:

```
🇺🇸 EnterpriseData-Dev (HUB)            🇻🇳 Enterprise SupplyChain-Dev (VALUE STREAM)
   ┌──────────────────────────┐            ┌──────────────────────────┐
   │ Bronze raw + Silver      │            │ Bronze view (shortcut    │
   │ shared cross-team:       │ shortcut │ from hub) + Silver       │
   │ • SalesHistory_AFI       │ ───────▶ │ SC-specific + Gold +     │
   │ • MasterData_DW          │            │ semantic + reports       │
   │ • SupplyChain_Warehouse  │ ◀───────  │                          │
   │ (NEW — VN team builds)   │ cross-DB │                          │
   │ • ETL_Framework          │  write   │                          │
   └──────────────────────────┘            └──────────────────────────┘
   Bob/Rakesh team owns                    Aric + Cherry (VN SC) team owns
```

This repo documents the **VN team's contribution** to that architecture.

---

## Repo navigation

| Folder | Purpose | Owner |
|--------|---------|-------|
| [`Enterprise_Data_architect/`](Enterprise_Data_architect/) | Analysis of Bob's hub workspace `EnterpriseData-Dev` (synthesized from scan) | VN team's view of hub |
| [`Enterprise_SupplyChain_Dev_architect/`](Enterprise_SupplyChain_Dev_architect/) | VN team's value-stream workspace architecture (formerly `02_Architect_v10_May`) | VN team |
| [`docs/decisions/`](docs/decisions/) | Architecture Decision Records (ADRs) | Both |
| [`lineage_explorer/`](lineage_explorer/) | Streamlit live lineage app | VN team |
| [`_external_refs/`](.gitignore) | Cloned external repos (Bob's docs, gitignored) | (read-only) |

Both architect folders use **identical taxonomy** for easy side-by-side comparison:

```
<workspace>_architect/
├── INDEX.md                  # Top-level navigation
├── 00_overview/              # Workspace identity + at-a-glance
├── 10_evidence/              # Inventory + scan synthesis
├── 20_proposals/             # Plans, comparisons, integration
├── 30_runbook/               # Operational notes
├── projects/                 # Per-domain deep dives
├── artifacts/                # Generated outputs
├── diagrams/                 # Mermaid + SVG
└── tools/                    # Analysis scripts
```

---

## Cross-workspace data flow

```mermaid
flowchart LR
    classDef hub fill:#fce7f3,stroke:#db2777,color:#831843
    classDef vs fill:#dbeafe,stroke:#2563eb,color:#1e3a8a
    classDef ext fill:#fef3c7,stroke:#d97706,color:#92400e

    SRC[(EDW + Synapse +<br/>SaaS feeds)]:::ext

    SRC --> SRC_DATA

    subgraph HUB ["🇺🇸 EnterpriseData-Dev (Hub)"]
        SRC_DATA[Source_Data<br/>BRONZE 64 sch / 636 tbl]:::hub
        WHS[Wholesale_Warehouse<br/>SalesHistory_AFI etc.]:::hub
        RTL[Retail_Warehouse<br/>Retail_Sales_Enh etc.]:::hub
        MDW[MasterData_Warehouse<br/>MasterData_DW]:::hub
        SCW[SupplyChain_Warehouse<br/>NEW — VN team builds<br/>Forecast_Enh]:::hub
        ETL[ETL_Framework<br/>35 procs · TableDictionary 65 cols]:::hub
        CW[Centralized_Warehouse<br/>GOLD aggregator]:::hub
    end

    SRC_DATA --> WHS
    SRC_DATA --> RTL
    SRC_DATA --> MDW
    SRC_DATA --> SCW
    ETL -.drives.-> WHS
    ETL -.drives.-> RTL
    ETL -.drives.-> MDW
    ETL -.drives.-> SCW
    WHS --> CW
    RTL --> CW
    MDW --> CW
    SCW --> CW

    subgraph VS ["🇻🇳 Enterprise SupplyChain-Dev (VN value stream)"]
        EL[Enterprise_Lakehouse<br/>shortcut aggregator]:::vs
        SCP[SupplyChain_Processing_Warehouse<br/>SC-specific Silver + Meta]:::vs
        SCG[SupplyChain_Gold_Warehouse<br/>ForecastAccuracy_DW<br/>5 Dim + 2 Fact]:::vs
        SM[Semantic Model<br/>sc_forecast_control_tower<br/>Direct Lake]:::vs
        PBI[Power BI<br/>+ Streamlit]:::vs
    end

    HUB -.18 OneLake shortcuts.-> EL
    EL --> SCP
    SCP --> SCG
    SCG --> SM
    SM --> PBI

    SCP -.cross-DB SP call.-> SCW
```

**Key principle**: Each domain Silver lives at hub (owned by domain team). Each value stream has its own workspace for Gold + serving + value-stream-specific Silver.

---

## Architecture Decision Records

| ADR | Focus | Status |
|---|---|---|
| [ADR-001](docs/decisions/ADR-001-v10-hybrid-medallion.md) | **Hybrid Medallion** — 3-layer design within VN workspace | **Implemented** |
| [ADR-002](docs/decisions/ADR-002-edw-supplement-exit-strategy.md) | **EDW Supplement exit** — pending Enterprise_Lakehouse data completeness | Active |
| [ADR-003](docs/decisions/ADR-003-bob-standards-compliance-audit.md) | **Enterprise standards audit** — naming + PascalCase resolved | Resolved |
| [ADR-004](docs/decisions/ADR-004-architecture-maturity-assessment.md) | **Maturity assessment** — Staff/Principal level | Accepted |
| [ADR-005](docs/decisions/ADR-005-enterprise-promote-pathway.md) | **Enterprise promote pathway (v2)** — 2-workspace topology + 3 promote targets | Proposed |
| [ADR-006](docs/decisions/ADR-006-repo-restructure-documentation-maturity.md) | **Repo restructure** — 4-folder taxonomy | Accepted |
| [ADR-008](docs/decisions/ADR-008-bob-alignment-naming-and-integration.md) | **Bob alignment** — naming `_Enh`/`_Wrk`/`v_*` + TableDictionary port | **Implemented** |

---

## Status — VN team contribution

| Area | Status | Detail |
|------|--------|--------|
| Naming alignment | ✅ Done | Schema casing + view prefix + control plane match Bob's pattern (ADR-008) |
| Control plane (TableDictionary + UpdateLog + AuditLog + procs) | ✅ Done | Cloned 65-col schema, ported procs, `usp_LogRun v2` chains |
| Pipeline orchestration (7 pipelines, DAG waves) | ✅ Done | 30m34s end-to-end run verified 2026-05-10 |
| Gold + semantic model | ✅ Live | `sc_forecast_control_tower` Direct Lake, 35 DAX measures |
| Cross-DB sync to hub `ETL_Framework` | ⏳ Pending | Need Bob Q1 — write permission + AuditLog DDL |
| `SupplyChain_Warehouse` creation in hub | ⏳ Pending | Need Bob Q3 — see [proposal](Enterprise_Data_architect/20_proposals/02_supply_chain_warehouse_proposal.md) |
| Promote shared Silver (forecast) to hub | 🔄 Plan ready | Pending Q3 |
| MasterData_DW DimDate extension (+29 cols) | 🔄 Plan ready | Pending Q2 |
| ADO repo access | ⏳ Pending IT (Q4) | Need Bob/Rakesh push |
| Mail.Send admin consent | ⏳ Pending IT (Q4) | — |
| Schedule trigger automation | ⏳ Blocked by IT | Manual trigger works |

Open questions: [`Enterprise_SupplyChain_Dev_architect/projects/forecast/_open_questions_for_bob.md`](Enterprise_SupplyChain_Dev_architect/projects/forecast/_open_questions_for_bob.md)

---

## Quick start — reading paths

### For new VN team member
1. This README (5 min)
2. [VN architect INDEX](Enterprise_SupplyChain_Dev_architect/INDEX.md) (10 min)
3. [Forecast project README](Enterprise_SupplyChain_Dev_architect/projects/forecast/README.md) (10 min)

### For VN team member needing to understand Bob's hub
1. [Bob hub workspace overview](Enterprise_Data_architect/00_overview/01_workspace_overview.md) (5 min)
2. [Bob hub architecture at a glance](Enterprise_Data_architect/00_overview/02_architecture_at_a_glance.md) (5 min)
3. [Bob ETL framework summary](Enterprise_Data_architect/10_evidence/02_etl_framework_summary.md) (10 min)
4. [Full ETL framework deep-dive synthesis](Enterprise_Data_architect/projects/etl_framework/SYNTHESIS.md) (45 min, 1210 lines)

### For Bob's team reviewing VN work
1. This README (5 min)
2. [ADR-008 — Bob alignment Implemented](docs/decisions/ADR-008-bob-alignment-naming-and-integration.md) (10 min)
3. [VN's analysis of your hub](Enterprise_Data_architect/) — verify VN team understands your patterns
4. [SupplyChain_Warehouse proposal](Enterprise_Data_architect/20_proposals/02_supply_chain_warehouse_proposal.md) (15 min)

---

## Tech stack

- **Platform**: Microsoft Fabric (Warehouse + Lakehouse + Pipelines + Semantic Model)
- **Language**: Pure T-SQL stored procedures (no PySpark, no Notebook ETL)
- **Pattern**: Metadata-driven, registry-based (1 generic SP covers 8 load patterns)
- **BI**: Direct Lake on Gold (no DirectQuery fallback)
- **Lineage**: Auto-built from `source_objects` JSON in registry
- **Auth**: Azure CLI tokens (`az login` → pyodbc + REST API)
- **Git**: Single-branch `main` model (per CLAUDE.md §I)

---

## Live infrastructure snapshot — VN team

| Item | Value |
|------|-------|
| Workspace | `Enterprise SupplyChain-Dev` (`c8d9fc83-18b6-4e1d-8264-0b49eed36fe0`) |
| Processing WH | `SupplyChain_Processing_Warehouse` (`c0262cef-...`) |
| Gold WH | `SupplyChain_Gold_Warehouse` (`98e2a911-...`) |
| Total objects | 103 (45 tables + 30 views + 18 SPs + 3 functions + 7 pipelines) |
| Total rows | ~423M (337M Processing + 84M Gold) |
| Pipeline | `pl_sc_master` 30m34s end-to-end (verified 2026-05-10) |
| Semantic model | `sc_forecast_control_tower` (`f06a2361-...`) — Direct Lake, 35 DAX measures |
| Lineage edges | 60 (auto-built) |
| DQ rules | 54 |

---

## Cross-refs

- **Bob's hub analysis**: [`Enterprise_Data_architect/INDEX.md`](Enterprise_Data_architect/INDEX.md)
- **VN value stream architect**: [`Enterprise_SupplyChain_Dev_architect/INDEX.md`](Enterprise_SupplyChain_Dev_architect/INDEX.md)
- **All ADRs**: [`docs/decisions/`](docs/decisions/)
- **Live lineage UI**: https://sc-lineage.streamlit.app/

_Last updated: 2026-05-10 (post Bob alignment + cross-WS restructure)_
