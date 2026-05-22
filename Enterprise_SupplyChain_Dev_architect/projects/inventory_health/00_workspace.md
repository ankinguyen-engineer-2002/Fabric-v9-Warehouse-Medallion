# 00 — Workspace, Warehouses, Auth

> **Status:** CODE-AUTHORED. Same workspace + warehouses as `forecast/` project. NO new infrastructure required.

## Fabric Workspace

| Item | Value |
|------|-------|
| Display name | `SupplyChain Dev` |
| Workspace ID | `c8d9fc83-18b6-4e1d-8264-0b49eed36fe0` |
| Capacity | DATAWAREHOUSE PROD |
| Environment | DEV |
| Owner | VN SC DA team (Aric + Cherry) |

## Warehouses

| Warehouse | ID | Purpose | Inventory Health usage |
|---|---|---|---|
| `SupplyChain_Processing_Warehouse` | `c0262cef-b8a7-495f-bccc-53b098c7948c` | Silver + Meta control plane | Hosts new schema `InventoryHistory_Enh` (24 tables) + 1 new `ReferenceMaster_Enh.Vendor` |
| `SupplyChain_Gold_Warehouse` | `98e2a911-5af9-442e-9cc8-5d8dadb8b762` | Gold Direct Lake serving | Hosts new schema `InventoryHealth_DW` (8 tables) |

SQL Endpoint (both WHs): `7woj2wroypauvkpn72b56t46ju-qp6ntsfwdaou5atebne65u3p4a.datawarehouse.fabric.microsoft.com`

## Lakehouses

| Lakehouse | ID | Purpose | Inventory Health usage |
|---|---|---|---|
| `Enterprise_Lakehouse` | (Bob hub) | OneLake shortcuts to Enterprise Bronze | Primary source for 22 of 32 bronze tables |
| `SupplyChain_Lakehouse` | `62a3081e-4093-4f46-856c-f50aa58732fa` | EDW supplement staging | 3 workaround paths (pomaster, podetail_v2, logility_demandfulfillment) + 4 stale bronze dataflow targets pending DE US |

## Authentication

Per memory `reference_fabric_connections`:
- Connection mode: `az login` interactive (no Service Principal required)
- For programmatic use: `az account get-access-token --resource https://api.fabric.microsoft.com`
- pyodbc via SQL Endpoint using `ODBC Driver 18 for SQL Server` (installed locally)
- MCP server `fabric-dynamic` reuses the same `az` token

## Permissions required

| Action | Permission | Status |
|---|---|---|
| READ Processing + Gold WH | Member of `SupplyChain Dev` workspace | ✅ Aric has |
| WRITE views + INSERT registry rows | Contributor of `SupplyChain Dev` workspace | ✅ Aric has |
| Trigger pipelines manually | Contributor + Item Permissions on `pl_sc_master` | ✅ Aric has |
| Schedule trigger auto-enable | IT-level permission | ⏳ BLOCKED (same as forecast — separate IT ticket) |
| Alerting (Mail.Send/Teams) | IT-level permission | ⏳ BLOCKED |

## Network / Capacity

Same Fabric capacity as forecast (DATAWAREHOUSE PROD). No additional throughput concern — registry-driven multi-mart pipeline runs sequentially per project; forecast (~31 min) + inventory_health (estimated ~25-35 min) ≈ ~1 hour total daily window.
