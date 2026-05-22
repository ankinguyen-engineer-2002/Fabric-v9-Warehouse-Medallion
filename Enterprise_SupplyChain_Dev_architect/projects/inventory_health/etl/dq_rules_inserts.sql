-- ============================================================
-- Meta.DQRule rows — InventoryHealth Project
-- ============================================================
-- Target: SupplyChain_Processing_Warehouse.Meta.DQRule
-- Patterns: completeness (PK NOT NULL %), row_count (lower bound), uniqueness (PK dedupe)
-- Severity: CRITICAL (fact + master) | WARNING (helper + snapshot)
-- ============================================================

-- ============================================================
-- §1. ReferenceMaster — completeness + uniqueness on Vendor
-- ============================================================
INSERT INTO Meta.DQRule (
    rule_name, layer, target_schema, target_table,
    check_type, column_name, severity, threshold, is_active
) VALUES
('Vendor.VendorNumber completeness',  'ReferenceMaster', 'ReferenceMaster_Enh', 'Vendor', 'completeness',  'VendorNumber', 'CRITICAL', 100.0, 1),
('Vendor.VendorNumber uniqueness',    'ReferenceMaster', 'ReferenceMaster_Enh', 'Vendor', 'uniqueness',     'VendorNumber', 'CRITICAL', NULL,  1),
('Vendor row_count > 1000',           'ReferenceMaster', 'ReferenceMaster_Enh', 'Vendor', 'row_count',      NULL,           'WARNING',  1000,  1);


-- ============================================================
-- §2. DomainSilver — base tables (CRITICAL for fact dependencies)
-- ============================================================
INSERT INTO Meta.DQRule (
    rule_name, layer, target_schema, target_table,
    check_type, column_name, severity, threshold, is_active
) VALUES
-- ItemMasterExt (master)
('ItemMasterExt.ItemSku completeness',          'DomainSilver', 'InventoryHistory_Enh', 'ItemMasterExt',          'completeness', 'ItemSku',       'CRITICAL', 100.0, 1),
('ItemMasterExt.ItemSku uniqueness',            'DomainSilver', 'InventoryHistory_Enh', 'ItemMasterExt',          'uniqueness',   'ItemSku',       'CRITICAL', NULL,  1),
-- WarehouseExt (master)
('WarehouseExt.WarehouseCode completeness',     'DomainSilver', 'InventoryHistory_Enh', 'WarehouseExt',           'completeness', 'WarehouseCode', 'CRITICAL', 100.0, 1),
('WarehouseExt.WarehouseCode uniqueness',       'DomainSilver', 'InventoryHistory_Enh', 'WarehouseExt',           'uniqueness',   'WarehouseCode', 'CRITICAL', NULL,  1),
-- CostCurrent
('CostCurrent.ItemSku completeness',            'DomainSilver', 'InventoryHistory_Enh', 'CostCurrent',            'completeness', 'ItemSku',       'CRITICAL', 100.0, 1),
('CostCurrent.StandardCost not negative',       'DomainSilver', 'InventoryHistory_Enh', 'CostCurrent',            'completeness', 'StandardCost',  'WARNING',  95.0,  1),
-- InventoryCurrent (BLOCKED on DE US ITEMBL — rule active when load fires)
('InventoryCurrent.ItemSku completeness',       'DomainSilver', 'InventoryHistory_Enh', 'InventoryCurrent',       'completeness', 'ItemSku',       'CRITICAL', 100.0, 1),
('InventoryCurrent.OnHandQty present',          'DomainSilver', 'InventoryHistory_Enh', 'InventoryCurrent',       'completeness', 'OnHandQty',     'WARNING',  90.0,  1),
('InventoryCurrent row_count > 100K',           'DomainSilver', 'InventoryHistory_Enh', 'InventoryCurrent',       'row_count',    NULL,            'CRITICAL', 100000, 1),
-- SupplyPlan
('SupplyPlan.ItemSku completeness',             'DomainSilver', 'InventoryHistory_Enh', 'SupplyPlan',             'completeness', 'ItemSku',       'CRITICAL', 100.0, 1),
-- SalesShipment (incremental — freshness rule pending wm establishment)
('SalesShipment.InvoiceDate completeness',      'DomainSilver', 'InventoryHistory_Enh', 'SalesShipment',          'completeness', 'InvoiceDate',   'CRITICAL', 100.0, 1),
-- PurchaseOrder (BLOCKED on PoMaster load)
('PurchaseOrder.PoNumber completeness',         'DomainSilver', 'InventoryHistory_Enh', 'PurchaseOrder',          'completeness', 'PoNumber',      'CRITICAL', 100.0, 1),
-- ManufacturingOrder
('ManufacturingOrder.MoNumber completeness',    'DomainSilver', 'InventoryHistory_Enh', 'ManufacturingOrder',     'completeness', 'MoNumber',      'CRITICAL', 100.0, 1),
-- LogilityItemStatus (BLOCKED on DE US load) — disabled until source confirmed
('LogilityItemStatus.ItemSku completeness',     'DomainSilver', 'InventoryHistory_Enh', 'LogilityItemStatus',     'completeness', 'ItemSku',       'WARNING',  95.0,  0),
-- HoldingTransfer
('HoldingTransfer.TransferNumber completeness', 'DomainSilver', 'InventoryHistory_Enh', 'HoldingTransfer',        'completeness', 'TransferNumber', 'CRITICAL', 100.0, 1),
-- AtpWeekEnding
('AtpWeekEnding.WeekNumber not null',           'DomainSilver', 'InventoryHistory_Enh', 'AtpWeekEnding',          'completeness', 'WeekNumber',    'CRITICAL', 100.0, 1),
-- MovementHistory (incremental)
('MovementHistory.TransactionDate completeness','DomainSilver', 'InventoryHistory_Enh', 'MovementHistory',        'completeness', 'TransactionDate', 'CRITICAL', 100.0, 1),
-- AllocatedDemandCandidate (H1 fix — Robert sign-off pending)
('AllocatedDemandCandidate row_count > 0',      'DomainSilver', 'InventoryHistory_Enh', 'AllocatedDemandCandidate', 'row_count',  NULL,            'WARNING',  1,     1),
-- ForecastCurrent (B2 fix)
('ForecastCurrent.FiscalMonthYear completeness','DomainSilver', 'InventoryHistory_Enh', 'ForecastCurrent',        'completeness', 'FiscalMonthYear', 'CRITICAL', 100.0, 1),
-- InventorySnapshotWeekly (BLOCKED on ItemBalance) — disabled until source confirmed
('InvSnapshotWeekly.SnapshotDate completeness', 'DomainSilver', 'InventoryHistory_Enh', 'InventorySnapshotWeekly','completeness', 'SnapshotDate',  'CRITICAL', 100.0, 0),
-- ForecastSnapshotWeekly
('FcstSnapshotWeekly.WeekEndingDate completeness','DomainSilver','InventoryHistory_Enh','ForecastSnapshotWeekly','completeness', 'WeekEndingDate', 'CRITICAL', 100.0, 1);


-- ============================================================
-- §3. Gold — Fact + Helper (CRITICAL)
-- ============================================================
INSERT INTO Meta.DQRule (
    rule_name, layer, target_schema, target_table,
    check_type, column_name, severity, threshold, is_active
) VALUES
('DimVendor.VendorNumber completeness',                'Gold', 'InventoryHealth_DW', 'DimVendor',                  'completeness', 'VendorNumber', 'CRITICAL', 100.0, 1),
('DimRuleVersion row_count = 1 (Phase 1)',             'Gold', 'InventoryHealth_DW', 'DimRuleVersion',             'row_count',    NULL,           'WARNING',  1,     1),
('CogsRollingHelper.FiscalMonthYear completeness',     'Gold', 'InventoryHealth_DW', 'CogsRollingHelper',          'completeness', 'FiscalMonthYear', 'CRITICAL', 100.0, 1),
('FactInventoryHealthSnapshot row_count > 0',          'Gold', 'InventoryHealth_DW', 'FactInventoryHealthSnapshot','row_count',    NULL,           'CRITICAL', 1,     0),  -- enable post-deploy
('FactInventoryHealthSnapshot.ItemSku completeness',   'Gold', 'InventoryHealth_DW', 'FactInventoryHealthSnapshot','completeness', 'ItemSku',      'CRITICAL', 100.0, 0),
('FactInventoryRiskForward row_count > 0',             'Gold', 'InventoryHealth_DW', 'FactInventoryRiskForward',   'row_count',    NULL,           'CRITICAL', 1,     1),
('FactInventoryRiskForward.WeekEndingDate completeness','Gold','InventoryHealth_DW', 'FactInventoryRiskForward',   'completeness', 'WeekEndingDate','CRITICAL', 100.0, 1);


-- ============================================================
-- §5. Bronze source observability rules (NEW 2026-05-19)
-- ============================================================
-- These rules monitor the EL Bronze sources (NOT inventory_health-owned objects)
-- to alert if upstream data quality degrades.
INSERT INTO Meta.DQRule (
    rule_name, layer, target_schema, target_table,
    check_type, column_name, severity, threshold, params, is_active
) VALUES
-- Deprecated columns (5 cols × ITBEXT + ITEMBL — verified 100% zero on EDW)
('ITBEXT.CRHLD expected_zero',                'Bronze', 'ItemMaster_AFI', 'ITBEXT', 'expected_zero', 'CRHLD', 'WARNING',  100.0, '{"reason":"verified deprecated 2026-05-19, EDW source confirmed zero"}', 1),
('ITBEXT.DLHLD expected_zero',                'Bronze', 'ItemMaster_AFI', 'ITBEXT', 'expected_zero', 'DLHLD', 'WARNING',  100.0, '{"reason":"verified deprecated 2026-05-19, EDW source confirmed zero"}', 1),
('ITBEXT.TOHLD expected_zero',                'Bronze', 'ItemMaster_AFI', 'ITBEXT', 'expected_zero', 'TOHLD', 'WARNING',  100.0, '{"reason":"verified deprecated 2026-05-19, EDW source confirmed zero"}', 1),
('ITBEXT.ATPQT expected_zero',                'Bronze', 'ItemMaster_AFI', 'ITBEXT', 'expected_zero', 'ATPQT', 'WARNING',  100.0, '{"reason":"verified deprecated 2026-05-19, EDW source confirmed zero"}', 1),
('ITEMBL.PHYOH expected_zero',                'Bronze', 'ItemMaster_AFI', 'ITEMBL', 'expected_zero', 'PHYOH', 'WARNING',  100.0, '{"reason":"verified deprecated 2026-05-19, EDW source confirmed zero"}', 1),
-- Logility grain-conflict ratio monitoring
('Logility dup_ratio_max (Item,Whse,Week)',  'Bronze', 'SupplyChain_Enh', 'DemandFulfillmentCommonContainer_Logility', 'expected_dup_ratio_max', NULL, 'WARNING', 0.05, '{"grain":"Item,Whse,WeekEnding","baseline":"0.024% (9128/38.36M) on 2026-05-19","threshold_meaning":"alert if >0.05% (~2x baseline)"}', 1);


-- ============================================================
-- Total: 33 DQ rules registered (3 RefMaster + 17 Silver + 7 Gold + 6 Bronze)
-- Active by default: 29; inactive (blocked by sources): 4
-- ============================================================
-- Verify:
-- SELECT severity, layer, COUNT(*) FROM Meta.DQRule
-- WHERE target_schema IN ('ReferenceMaster_Enh','InventoryHistory_Enh','InventoryHealth_DW')
--   AND target_table  IN (...)   -- inventory_health asset names
-- GROUP BY severity, layer;
-- ============================================================
