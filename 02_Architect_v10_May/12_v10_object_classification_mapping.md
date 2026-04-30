# v10 Object Classification Mapping

Date: 2026-04-30

Evidence source:

- Live export: `02_Architect_v10_May/readiness_exports/20260430_230936/sql/03_sp_registry.csv`
- Pipeline definitions: `02_Architect_v10_May/readiness_exports/20260430_230936/pipeline_definitions/`

Purpose: classify current v9 registry objects before any v10 build, rename, move, or physical separation.

## 1. Classification Rules

- `LogicalBronzeCandidate`: source-aligned object that should usually be read directly from `Enterprise_Access_Lakehouse`.
- `StagingException`: persisted Warehouse mirror remains justified because source is incomplete/temporary/unstable or needs persisted snapshot.
- `ReferenceMaster`: reference/domain dimensions; ownership must be decided case-by-case.
- `DomainSilver`: Supply Chain-owned transformation logic.
- `EnterpriseReusableSilver`: conformed reusable object to promote to EnterpriseData only after approval.
- `GoldServing`: BI-ready physical Gold table for Direct Lake semantic model.

## 2. Current Object Mapping

| Current object | Layer | Current source | v10 class | Access mode | Target location | Decision note |
|---|---|---|---|---|---|---|
| `bronze.brz_saleshistory_afi__invoicedetail` | `BRZ` | `["bronze.brz_saleshistory_afi__invoicedetail_edw"]` | StagingException / EDWSupplement | `BronzeMirror` | `SupplyChain_Processing_Warehouse.Staging` | Keep staged until Enterprise source SLA/coverage validated |
| `bronze.brz_saleshistory_afi__invoiceheader` | `BRZ` | `["bronze.brz_saleshistory_afi__invoiceheader_edw"]` | StagingException / EDWSupplement | `BronzeMirror` | `SupplyChain_Processing_Warehouse.Staging` | Keep staged until Enterprise source SLA/coverage validated |
| `bronze.brz_supplychain_enh_1__demandforecastsnapshotdaily` | `BRZ` | `["bronze.brz_supplychain_enh_1__demandforecastsnapshotdaily_edw"]` | StagingException / EDWSupplement | `BronzeMirror` | `SupplyChain_Processing_Warehouse.Staging` | Keep staged until Enterprise source SLA/coverage validated |
| `bronze.brz_wholesale_codis_afi__codatan` | `BRZ` | `["Enterprise_Lakehouse.Wholesale_Codis_AFI.codatan"]` | LogicalBronzeCandidate / DirectReadCandidate | `DirectShortcut` | `Enterprise_Access_Lakehouse` shortcut, no default persistence | Evaluate whether casts/aliases should move to Silver |
| `bronze.brz_wholesale_codis_afi__comast` | `BRZ` | `["Enterprise_Lakehouse.Wholesale_Codis_AFI.COMAST"]` | LogicalBronzeCandidate / DirectReadCandidate | `DirectShortcut` | `Enterprise_Access_Lakehouse` shortcut, no default persistence | Evaluate whether casts/aliases should move to Silver |
| `bronze.brz_wholesale_codis_afi__extord` | `BRZ` | `["Enterprise_Lakehouse.Wholesale_Codis_AFI.EXTORD"]` | LogicalBronzeCandidate / DirectReadCandidate | `DirectShortcut` | `Enterprise_Access_Lakehouse` shortcut, no default persistence | Evaluate whether casts/aliases should move to Silver |
| `bronze.brz_wholesale_codis_afi__extorit` | `BRZ` | `["Enterprise_Lakehouse.Wholesale_Codis_AFI.EXTORIT"]` | LogicalBronzeCandidate / DirectReadCandidate | `DirectShortcut` | `Enterprise_Access_Lakehouse` shortcut, no default persistence | Evaluate whether casts/aliases should move to Silver |
| `gold.gld_fact_flat_forecast_actual` | `GLD` | `["silver.slv_actual_demand_monthly","silver.slv_forecast_demand_monthly","silver.slv_naive_forecast_monthly"]` | GoldServing / BIServing | `GoldPublish` | `SupplyChain_Gold_Warehouse.ForecastAccuracy` | Physical Gold table for Direct Lake semantic model |
| `gold.gld_fact_forecast_kpi` | `GLD` | `["silver.slv_actual_demand_monthly","silver.slv_forecast_demand_monthly","silver.slv_naive_forecast_monthly","bronze.ref_forecast_horizon"]` | GoldServing / BIServing | `GoldPublish` | `SupplyChain_Gold_Warehouse.ForecastAccuracy` | Physical Gold table for Direct Lake semantic model |
| `bronze.ref_calendar` | `REF` | `["Enterprise_Lakehouse.MasterData_DW.DimDate"]` | ReferenceMaster / NeedOwnerDecision | `DirectShortcutOrEnterpriseSilver` | EnterpriseData if reusable, else `SupplyChain_Processing_Warehouse.ReferenceMaster` | Likely reusable/reference; needs Bob/Rakesh ownership decision |
| `bronze.ref_customer_account` | `REF` | `["Enterprise_Lakehouse.Customers.AccountMaster"]` | ReferenceMaster / NeedOwnerDecision | `DirectShortcutOrEnterpriseSilver` | EnterpriseData if reusable, else `SupplyChain_Processing_Warehouse.ReferenceMaster` | Likely reusable/reference; needs Bob/Rakesh ownership decision |
| `bronze.ref_customer_account_group` | `REF` | `["Enterprise_Lakehouse.Wholesale_ProductSourcing_AFI.CustomerGrouping"]` | ReferenceMaster / NeedOwnerDecision | `DirectShortcutOrEnterpriseSilver` | EnterpriseData if reusable, else `SupplyChain_Processing_Warehouse.ReferenceMaster` | Likely reusable/reference; needs Bob/Rakesh ownership decision |
| `bronze.ref_customer_grouping` | `REF` | `["Enterprise_Lakehouse.Wholesale_ProductSourcing_AFI.CustomerGrouping"]` | ReferenceMaster / NeedOwnerDecision | `DirectShortcutOrEnterpriseSilver` | EnterpriseData if reusable, else `SupplyChain_Processing_Warehouse.ReferenceMaster` | Likely reusable/reference; needs Bob/Rakesh ownership decision |
| `bronze.ref_customer_shipping_location` | `REF` | `["Enterprise_Lakehouse.Customers.ShippingLocations"]` | ReferenceMaster / NeedOwnerDecision | `DirectShortcutOrEnterpriseSilver` | EnterpriseData if reusable, else `SupplyChain_Processing_Warehouse.ReferenceMaster` | Likely reusable/reference; needs Bob/Rakesh ownership decision |
| `bronze.ref_forecast_cycle` | `REF` | `["SupplyChain_Lakehouse.dbo.ref_forecast_cycle"]` | ReferenceMaster / DomainReference | `DirectShortcut` | `SupplyChain_Processing_Warehouse.ReferenceMaster` | Keep domain reference if not enterprise reusable |
| `bronze.ref_forecast_horizon` | `REF` | `["manual"]` | ReferenceMaster / DomainReference | `ManualSeed` | `SupplyChain_Processing_Warehouse.ReferenceMaster` | Keep domain reference if not enterprise reusable |
| `bronze.ref_item_master` | `REF` | `["Enterprise_Lakehouse.MasterData_DW.DimItemMaster"]` | ReferenceMaster / NeedOwnerDecision | `DirectShortcutOrEnterpriseSilver` | EnterpriseData if reusable, else `SupplyChain_Processing_Warehouse.ReferenceMaster` | Likely reusable/reference; needs Bob/Rakesh ownership decision |
| `bronze.ref_order_type` | `REF` | `["Enterprise_Lakehouse.Wholesale_Codis_AFI.AAORDTYP"]` | ReferenceMaster / DomainReference | `DirectShortcut` | `SupplyChain_Processing_Warehouse.ReferenceMaster` | Keep domain reference if not enterprise reusable |
| `bronze.ref_product` | `REF` | `["bronze.ref_product_edw"]` | ReferenceMaster / NeedOwnerDecision | `BronzeMirrorOrEnterpriseSilver` | EnterpriseData if reusable, else `SupplyChain_Processing_Warehouse.ReferenceMaster` | Uses EDW supplement today; ownership and source readiness need approval |
| `bronze.ref_warehouse` | `REF` | `["Enterprise_Lakehouse.SupplyChain_DW.DimAFIWarehouses"]` | ReferenceMaster / DomainReference | `DirectShortcut` | `SupplyChain_Processing_Warehouse.ReferenceMaster` | Keep domain reference if not enterprise reusable |
| `silver.slv_actual_demand_monthly` | `SLV` | `["silver.slv_invoice_detail_line_level","silver.slv_open_order_line_level","bronze.ref_calendar","bronze.ref_customer_account_group"]` | DomainSilver / SupplyChainSpecific | `WarehouseTransform` | `SupplyChain_Processing_Warehouse.SalesHistory` | Promote only if conformed/reusable across domains |
| `silver.slv_actual_demand_weekly` | `SLV` | `["silver.slv_invoice_detail_line_level","silver.slv_open_order_line_level","bronze.ref_calendar","bronze.ref_customer_account_group"]` | DomainSilver / SupplyChainSpecific | `WarehouseTransform` | `SupplyChain_Processing_Warehouse.SalesHistory` | Promote only if conformed/reusable across domains |
| `silver.slv_forecast_demand_monthly` | `SLV` | `["bronze.brz_supplychain_enh_1__demandforecastsnapshotdaily","bronze.ref_forecast_cycle","bronze.ref_calendar"]` | DomainSilver / SupplyChainSpecific | `WarehouseTransform` | `SupplyChain_Processing_Warehouse.ForecastHistory` | Promote only if conformed/reusable across domains |
| `silver.slv_invoice_detail_line_level` | `SLV` | `["bronze.brz_saleshistory_afi__invoicedetail","bronze.brz_saleshistory_afi__invoiceheader","bronze.ref_customer_account_group"]` | DomainSilver / SupplyChainSpecific | `WarehouseTransform` | `SupplyChain_Processing_Warehouse.SalesHistory` | Promote only if conformed/reusable across domains |
| `silver.slv_invoice_weekly` | `SLV` | `["silver.slv_invoice_detail_line_level","bronze.ref_calendar"]` | DomainSilver / SupplyChainSpecific | `WarehouseTransform` | `SupplyChain_Processing_Warehouse.SalesHistory` | Promote only if conformed/reusable across domains |
| `silver.slv_naive_forecast_monthly` | `SLV` | `["silver.slv_actual_demand_monthly","bronze.ref_calendar"]` | DomainSilver / SupplyChainSpecific | `WarehouseTransform` | `SupplyChain_Processing_Warehouse.ForecastHistory` | Promote only if conformed/reusable across domains |
| `silver.slv_open_order_line_level` | `SLV` | `["bronze.brz_wholesale_codis_afi__codatan","bronze.brz_wholesale_codis_afi__comast","bronze.brz_wholesale_codis_afi__extord","bronze.brz_wholesale_codis_afi__extorit","bronze.ref_item_master","bronze.ref_order_type"]` | DomainSilver / SupplyChainSpecific | `WarehouseTransform` | `SupplyChain_Processing_Warehouse.OpenOrderHistory` | Promote only if conformed/reusable across domains |
| `silver.slv_open_order_monthly` | `SLV` | `["silver.slv_open_order_line_level","bronze.ref_calendar","bronze.ref_customer_account_group"]` | DomainSilver / SupplyChainSpecific | `WarehouseTransform` | `SupplyChain_Processing_Warehouse.OpenOrderHistory` | Promote only if conformed/reusable across domains |

## 3. Summary Counts

| Target class | Count | Notes |
|---|---:|---|
| StagingException / EDWSupplement | 3 BRZ + 1 REF candidate | EDW-backed objects should not move to direct-only until source coverage is approved |
| LogicalBronzeCandidate / DirectReadCandidate | 4 BRZ | Direct by default if source contracts/performance pass |
| ReferenceMaster / NeedOwnerDecision | 7 REF | Likely reusable or shared; Bob/Rakesh decision required |
| ReferenceMaster / DomainReference | 3 REF | Keep local unless EnterpriseData wants ownership |
| DomainSilver | 8 SLV | Keep in SupplyChain unless approved as reusable/conformed |
| GoldServing | 2 GLD | Move/publish to dedicated Gold Warehouse physical tables |

## 4. Open Decisions

- Exact Silver schema naming: `SalesHistory`, `ForecastHistory`, `OpenOrderHistory` vs suffix forms such as `SalesHistory_ENH`.
- Which reference objects become Enterprise reusable Silver/reference assets.
- Whether `ref_product` remains EDW-backed staging exception or becomes EnterpriseData-owned reference.
- Whether current Bronze direct-read candidates contain transformations that must be moved into Silver.
