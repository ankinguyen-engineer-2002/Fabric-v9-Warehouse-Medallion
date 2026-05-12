# 00 — Workspace, Warehouses, Auth

> **Status:** Skeleton — same workspace as `forecast/`, no infrastructure changes required for `inventory_health`. Will reuse Processing + Gold WHs.

## Fabric Workspace

| Item | Value |
|------|-------|
| Display name | `SupplyChain Dev` |
| Workspace ID | `c8d9fc83-18b6-4e1d-8264-0b49eed36fe0` |
| Capacity | DATAWAREHOUSE PROD |
| Environment | DEV |

## Warehouses (reused from forecast)

| Warehouse | ID | Role for `inventory_health` mart |
|-----------|----|----------------------------------|
| `SupplyChain_Processing_Warehouse` | `c0262cef-b8a7-495f-bccc-53b098c7948c` | Silver — add new domain schemas (`InventoryHistory_Enh`, ...) |
| `SupplyChain_Gold_Warehouse` | `98e2a911-5af9-442e-9cc8-5d8dadb8b762` | Gold — add new schema `InventoryHealth_DW` |

## New schemas to provision (DDL TBD)

| Schema | Layer | Purpose |
|--------|-------|---------|
| `InventoryHistory_Enh` | Silver | Daily inventory snapshots (on-hand, in-transit, allocated) |
| `InventoryMovementHistory_Enh` | Silver | Movement events (receipts, shipments, transfers, adjustments) |
| `StockoutHistory_Enh` | Silver | Stockout / backorder signals derived from order vs availability |
| `InventoryHealth_DW` | Gold | Star schema — Fact + shared Dims (reuse from `ForecastAccuracy_DW` where possible) |

## Auth (same pattern as forecast)

| Method | Detail |
|--------|--------|
| SQL endpoint | `7woj2wroypauvkpn72b56t46ju-qp6ntsfwdaou5atebne65u3p4a.datawarehouse.fabric.microsoft.com` |
| Token | `az account get-access-token --resource https://database.windows.net/` |
| pyodbc | Token struct via `attrs_before={1256: token_struct}` |
| Fabric API | `az account get-access-token --resource https://api.fabric.microsoft.com` |
| Power BI API | `az account get-access-token --resource https://analysis.windows.net/powerbi/api` |

## TBD — fill during build

- [ ] Confirm source data location (EDW supplement vs Enterprise_Lakehouse shortcut)
- [ ] Final schema names + table list
- [ ] Row count baseline after first load
- [ ] Pipeline IDs once registered
