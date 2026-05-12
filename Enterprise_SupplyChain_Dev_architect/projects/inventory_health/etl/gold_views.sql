-- ============================================================
-- inventory_health — Gold Views (skeleton)
-- ============================================================
-- Target: SupplyChain_Gold_Warehouse.InventoryHealth_DW
-- Cross-DB CTAS from Silver via Meta.usp_GenericLoad in pl_sc_gold pipeline
-- Star schema — Fact + Dim (Dims may reuse from ForecastAccuracy_DW per Q2)
-- ============================================================

-- TBD: confirm Dim sharing strategy (see _open_questions_for_bob.md Q2)

/*
-- ── Fact tables ──────────────────────────────────────────────
CREATE OR ALTER VIEW InventoryHealth_DW.vw_FactInventorySnapshot AS
SELECT
    inv.SnapshotDT,
    inv.ItemSKU,
    inv.WarehouseCode,
    inv.OnHandQty,
    inv.InTransitQty,
    inv.AllocatedQty,
    inv.AvailableQty,
    inv.SafetyStock,
    inv.ReorderPoint,
    inv.BelowSafetyFlag,
    CASE WHEN inv.OnHandQty > inv.ReorderPoint * 1.5 THEN 1 ELSE 0 END AS ExcessStockFlag,
    CAST(GETUTCDATE() AS DATETIME2(6)) AS LoadDT
FROM SupplyChain_Processing_Warehouse.InventoryHistory_Enh.InventoryDailySnapshot inv;

CREATE OR ALTER VIEW InventoryHealth_DW.vw_FactInventoryMovement AS
SELECT
    m.MovementID,
    m.MovementTS,
    CAST(m.MovementTS AS DATE) AS MovementDT,
    m.MovementType,
    m.ItemSKU,
    m.WarehouseCode,
    m.QtyChange,
    m.ReferenceDocNum,
    CAST(GETUTCDATE() AS DATETIME2(6)) AS LoadDT
FROM SupplyChain_Processing_Warehouse.InventoryMovementHistory_Enh.MovementEventLevel m;

CREATE OR ALTER VIEW InventoryHealth_DW.vw_FactStockoutEvent AS
SELECT
    s.SnapshotDT,
    s.ItemSKU,
    s.WarehouseCode,
    s.OnHandQty,
    s.OpenOrderQty,
    s.AvgDailyDemand,
    s.StockoutFlag,
    CAST(GETUTCDATE() AS DATETIME2(6)) AS LoadDT
FROM SupplyChain_Processing_Warehouse.StockoutHistory_Enh.StockoutEvents s
WHERE s.StockoutFlag = 1;

-- ── Dim tables (option a: duplicate from ForecastAccuracy_DW) ──
-- Decide per Q2 — if option (a), uncomment below.
-- If option (b) cross-DB or (c) promote to MasterData_DW, leave commented.

-- CREATE OR ALTER VIEW InventoryHealth_DW.vw_DimProduct AS
-- SELECT * FROM SupplyChain_Gold_Warehouse.ForecastAccuracy_DW.DimProduct;

-- CREATE OR ALTER VIEW InventoryHealth_DW.vw_DimWarehouse AS
-- SELECT * FROM SupplyChain_Gold_Warehouse.ForecastAccuracy_DW.DimWarehouse;

-- CREATE OR ALTER VIEW InventoryHealth_DW.vw_DimCalendar AS
-- SELECT * FROM SupplyChain_Gold_Warehouse.ForecastAccuracy_DW.DimCalendar;

-- ── New Dim ──────────────────────────────────────────────────
CREATE OR ALTER VIEW InventoryHealth_DW.vw_DimMovementType AS
SELECT * FROM (VALUES
    (1, 'Receipt',  'Stock received into warehouse'),
    (2, 'Shipment', 'Stock shipped to customer / external'),
    (3, 'Transfer', 'Inter-warehouse transfer'),
    (4, 'Adjust',   'Manual adjustment'),
    (5, 'Cycle',    'Cycle count correction')
) AS t(MovementTypeID, MovementType, Description);
*/

-- See _open_questions_for_bob.md Q2 (Dim sharing strategy) before deploying.
