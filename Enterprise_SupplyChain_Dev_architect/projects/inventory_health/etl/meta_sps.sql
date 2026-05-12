-- ============================================================
-- inventory_health — Meta registry rows (skeleton)
-- ============================================================
-- No new SPs needed — reuse Meta.usp_GenericLoad + Meta.usp_LogRun.
-- This file = INSERT statements to register inventory_health assets in
-- Meta.AssetRegistry so multi-mart pipeline picks them up.
-- ============================================================

-- TBD: complete asset list once schemas/tables finalized.
-- Pattern: 1 row per Silver target + 1 row per Gold target.
-- project='inventory_health' triggers multi-mart ForEach in pl_sc_master.

/*
-- ── Silver — InventoryHistory_Enh ────────────────────────────
INSERT INTO Meta.AssetRegistry (
    asset_id, project, canonical_layer, physical_workspace, physical_item,
    physical_schema, physical_object, legacy_view_name, load_type, frequency,
    cron_expression, source_objects, depends_on, is_active
) VALUES (
    'InventoryHistory_Enh.InventoryDailySnapshot',
    'inventory_health',
    'DomainSilver',
    'c8d9fc83-18b6-4e1d-8264-0b49eed36fe0',
    'SupplyChain_Processing_Warehouse',
    'InventoryHistory_Enh',
    'InventoryDailySnapshot',
    'InventoryHistory_Enh.v_InventoryDailySnapshot',
    'overwrite',  -- or 'daterange' once stable
    'daily',
    '0 2 * * *',
    '["Staging_Wrk.InventorySnapshotEdw"]',
    NULL,
    1
);

-- ── Silver — InventoryMovementHistory_Enh ────────────────────
INSERT INTO Meta.AssetRegistry (...) VALUES (
    'InventoryMovementHistory_Enh.MovementEventLevel',
    'inventory_health', 'DomainSilver', ...
    'incremental',   -- append-only watermark
    'daily', ...
    '["Staging_Wrk.InventoryMovementEdw"]',
    NULL, 1
);

-- ── Silver — StockoutHistory_Enh (cross-mart deps) ───────────
INSERT INTO Meta.AssetRegistry (...) VALUES (
    'StockoutHistory_Enh.StockoutEvents',
    'inventory_health', 'DomainSilver', ...
    'overwrite', 'daily', ...
    -- Cross-mart source_objects (forecast + this mart)
    '["InventoryHistory_Enh.InventoryDailySnapshot","OpenOrderHistory_Enh.OpenOrderLineLevel","SalesHistory_Enh.ActualDemandMonthly"]',
    'InventoryHistory_Enh.InventoryDailySnapshot',  -- DAG dep within this mart
    1
);

-- ── Gold — InventoryHealth_DW ────────────────────────────────
INSERT INTO Meta.AssetRegistry (...) VALUES (
    'InventoryHealth_DW.FactInventorySnapshot',
    'inventory_health', 'Gold', ...,
    'overwrite', 'daily', ...,
    '["InventoryHistory_Enh.InventoryDailySnapshot"]',
    NULL, 1
);
-- ... 2 more Fact rows + 1-5 Dim rows depending on Q2 decision
*/

-- After INSERT: run these to regenerate derived tables:
-- EXEC Meta.usp_ComputeSilverWaves;   -- recompute DAG waves
-- EXEC Meta.usp_BuildLineage;          -- rebuild lineage edges
