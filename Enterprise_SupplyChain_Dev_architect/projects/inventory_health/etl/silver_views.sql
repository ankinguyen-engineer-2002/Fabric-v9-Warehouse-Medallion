-- ============================================================
-- inventory_health — Silver Views (skeleton)
-- ============================================================
-- Target schemas: InventoryHistory_Enh, InventoryMovementHistory_Enh, StockoutHistory_Enh
-- View prefix v_* per ADR-008 Bob alignment
-- Each view materialized into table via Meta.usp_GenericLoad (overwrite/incremental/upsert)
-- ============================================================

-- TBD: fill once source mapping confirmed (see _open_questions_for_bob.md).

/*
-- ── InventoryHistory_Enh ─────────────────────────────────────
CREATE OR ALTER VIEW InventoryHistory_Enh.v_InventoryDailySnapshot AS
SELECT
    s.ItemSKU,
    s.WarehouseCode,
    s.SnapshotDate           AS SnapshotDT,
    s.OnHandQty,
    s.InTransitQty,
    s.AllocatedQty,
    (s.OnHandQty - s.AllocatedQty) AS AvailableQty,
    s.SafetyStock,
    s.ReorderPoint,
    CASE WHEN s.OnHandQty <= s.SafetyStock THEN 1 ELSE 0 END AS BelowSafetyFlag
FROM Staging_Wrk.InventorySnapshotEdw s;

-- ── InventoryMovementHistory_Enh ─────────────────────────────
CREATE OR ALTER VIEW InventoryMovementHistory_Enh.v_MovementEventLevel AS
SELECT
    m.MovementID,
    m.MovementTS,
    m.MovementType,
    m.ItemSKU,
    m.WarehouseCode,
    m.QtyChange,
    m.ReferenceDocNum
FROM Staging_Wrk.InventoryMovementEdw m;

-- ── StockoutHistory_Enh ──────────────────────────────────────
-- Cross-mart: joins forecast SalesHistory + this mart's Inventory
CREATE OR ALTER VIEW StockoutHistory_Enh.v_StockoutEvents AS
SELECT
    inv.SnapshotDT,
    inv.ItemSKU,
    inv.WarehouseCode,
    inv.OnHandQty,
    inv.AvailableQty,
    COALESCE(oo.OpenOrderQty, 0) AS OpenOrderQty,
    COALESCE(ad.AvgDailyDemand, 0) AS AvgDailyDemand,
    CASE
        WHEN inv.AvailableQty <= 0 AND COALESCE(oo.OpenOrderQty, 0) > 0 THEN 1
        ELSE 0
    END AS StockoutFlag
FROM InventoryHistory_Enh.v_InventoryDailySnapshot inv
LEFT JOIN OpenOrderHistory_Enh.OpenOrderLineLevel oo
    ON inv.ItemSKU = oo.ItemSKU AND inv.WarehouseCode = oo.WarehouseCode
LEFT JOIN (
    SELECT ItemSKU, WarehouseCode, AVG(ActualQty) AS AvgDailyDemand
    FROM SalesHistory_Enh.ActualDemandMonthly
    GROUP BY ItemSKU, WarehouseCode
) ad ON inv.ItemSKU = ad.ItemSKU AND inv.WarehouseCode = ad.WarehouseCode;
*/

-- See _open_questions_for_bob.md Q3 (stockout definition) before deploying StockoutEvents.
