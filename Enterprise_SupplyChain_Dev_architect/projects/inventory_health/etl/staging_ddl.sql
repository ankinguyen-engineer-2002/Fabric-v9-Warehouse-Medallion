-- ============================================================
-- inventory_health — Staging DDL (skeleton)
-- ============================================================
-- Target: SupplyChain_Processing_Warehouse.Staging_Wrk
-- Use only if EDW supplement needed (hub shortcut not yet available).
-- Each Staging_Wrk.*Edw table fed by Staging_Wrk.usp_RefreshEdwTables.
-- ============================================================

-- TBD: confirm whether EDW supplement is needed (see _open_questions_for_bob.md Q1)
-- If yes, uncomment + complete column list to match source.

/*
CREATE TABLE Staging_Wrk.InventorySnapshotEdw (
    ItemSKU            NVARCHAR(50)    NOT NULL,
    WarehouseCode      NVARCHAR(20)    NOT NULL,
    SnapshotDate       DATE            NOT NULL,
    OnHandQty          DECIMAL(18,4)   NULL,
    InTransitQty       DECIMAL(18,4)   NULL,
    AllocatedQty       DECIMAL(18,4)   NULL,
    AvailableQty       DECIMAL(18,4)   NULL,
    SafetyStock        DECIMAL(18,4)   NULL,
    ReorderPoint       DECIMAL(18,4)   NULL,
    LoadDT             DATETIME2(6)    NOT NULL DEFAULT CAST(GETUTCDATE() AS DATETIME2(6))
);

CREATE TABLE Staging_Wrk.InventoryMovementEdw (
    MovementID         BIGINT          NOT NULL,
    MovementTS         DATETIME2(6)    NOT NULL,
    MovementType       NVARCHAR(20)    NOT NULL,  -- Receipt / Shipment / Transfer / Adjust / Cycle
    ItemSKU            NVARCHAR(50)    NOT NULL,
    WarehouseCode      NVARCHAR(20)    NOT NULL,
    QtyChange          DECIMAL(18,4)   NOT NULL,  -- signed: +receipt / -shipment
    ReferenceDocNum    NVARCHAR(50)    NULL,
    UserCode           NVARCHAR(50)    NULL,
    LoadDT             DATETIME2(6)    NOT NULL DEFAULT CAST(GETUTCDATE() AS DATETIME2(6))
);
*/

-- See _open_questions_for_bob.md Q1 / Q4 for resolution before deploying.
