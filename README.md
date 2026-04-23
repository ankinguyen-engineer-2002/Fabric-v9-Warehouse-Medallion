# Fabric Refactor Architect

> Warehouse-native medallion architecture on Microsoft Fabric. Pure T-SQL, metadata-driven, DAG orchestration.

Repo nay chua cac du an data warehouse tren Microsoft Fabric, moi du an la 1 subfolder rieng voi docs, setup, va operations day du.

---

## Projects

| Project | Mo ta | Status |
|---------|-------|--------|
| [sc_forecast/](sc_forecast/) | Supply Chain Demand Forecasting — 28 tables, 7 pipelines, 1 generic SP | Production (daily 2AM UTC+7) |

> Du an moi se duoc tao theo cung cau truc. Copy tu `docs/templates/` de bat dau.

---

## Repo Structure

```
/
├── README.md                    ← Ban dang doc file nay
├── CLAUDE.md                    # AI assistant instructions (IDs, rules, patterns)
├── FULL_CONTEXT.md              # Master context — all schemas, code, history
├── task.md                      # Roadmap progress tracker
│
├── sc_forecast/                 # [PROJECT] Supply Chain Forecast
│   ├── README.md                #   Project overview + doc index + quick start
│   ├── docs/                    #   Architecture, setup, pipeline, v8-v9 comparison
│   │   └── operations/          #   Runbook, onboarding, scheduling, EDW swap
│   └── enterprise/              #   Roadmap, multi-mart, enterprise comparison
│
├── docs/templates/              # Generic templates — dung khi tao project moi
│   ├── architecture.md          #   Template: object inventory, IDs, source mapping
│   ├── setup_guide.md           #   Template: implementation log, DDL, patterns
│   └── pipeline_guide.md        #   Template: execution trace, timing, activities
│
├── diagrams/                    # Mermaid .mmd architecture diagrams + SVG exports
├── lineage_explorer/            # Streamlit lineage app (live: vn-fabric-lineage.streamlit.app)
├── scripts/                     # Health checks, automation
└── .github/workflows/           # GitHub Actions (lineage data refresh)
```

---

## Quick Links

| Can gi? | Di dau? |
|---------|---------|
| Hieu kien truc sc_forecast | [sc_forecast/README.md](sc_forecast/README.md) |
| Them bang moi | [sc_forecast/docs/operations/onboarding.md](sc_forecast/docs/operations/onboarding.md) |
| Pipeline bi loi | [sc_forecast/docs/operations/runbook.md](sc_forecast/docs/operations/runbook.md) |
| Doi source EDW / rollback EL | [sc_forecast/docs/operations/edw_source_swap.md](sc_forecast/docs/operations/edw_source_swap.md) |
| So sanh v8 vs v9 | [sc_forecast/docs/v8_vs_v9_comparison.md](sc_forecast/docs/v8_vs_v9_comparison.md) |
| Xem lineage truc tuyen | [Lineage Explorer](https://vn-fabric-lineage.streamlit.app) (admin123 / admin123) |
| Doc toan bo context (cho AI) | [FULL_CONTEXT.md](FULL_CONTEXT.md) |
| Tao project moi | Copy `docs/templates/` vao subfolder moi |

---

## Tao Project Moi

```bash
# 1. Tao subfolder
mkdir -p sc_regional/docs/operations sc_regional/enterprise

# 2. Copy templates
cp docs/templates/architecture.md sc_regional/docs/
cp docs/templates/setup_guide.md sc_regional/docs/
cp docs/templates/pipeline_guide.md sc_regional/docs/

# 3. Tao README rieng
# Tham khao sc_forecast/README.md lam mau
```

---

*Built with Claude Code + Fabric MCP Server*
