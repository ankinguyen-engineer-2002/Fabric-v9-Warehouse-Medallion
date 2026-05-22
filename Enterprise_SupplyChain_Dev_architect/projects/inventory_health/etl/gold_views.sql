-- ============================================================
-- Gold Views — InventoryHealth_DW Serving Layer (project='inventory_health')
-- ============================================================
-- Target: SupplyChain_Gold_Warehouse (98e2a911-...) schema InventoryHealth_DW
-- Pattern: cross-DB 3-part name from Processing WH + Direct Lake-compatible CAST.
-- Cross-DB CTAS executed by pl_sc_gold pipeline (registry-driven) — Fabric WH
-- restriction: cross-DB CREATE TABLE cannot run from SP, so the pipeline bridges
-- via separate WH connections.
-- ============================================================
-- Track A fixes preserved:
--   H4 ORDER BY FiscalMonthYear (CogsRollingHelper)
--   H5 WeekFourFlag exact week (FactInventoryRiskForward, Robert sign-off pending)
--   M3 Cogs52W → Cogs52M rename (Robert sign-off pending re: keep 52M or rewrite weekly)
--   M4 SLOB NULL guard on LastInvoiceDate
-- ============================================================
-- 6 NEW views (Gold artifacts for inventory_health mart):
--   1. InventoryHealth_DW.v_DimItem                  — derived from InventoryHistory_Enh.ItemMasterExt
--   2. InventoryHealth_DW.v_DimWarehouse             — derived from InventoryHistory_Enh.WarehouseExt
--   3. InventoryHealth_DW.v_DimVendor                — derived from ReferenceMaster_Enh.Vendor
--   4. InventoryHealth_DW.v_CogsRollingHelper        — 52M + 12M rolling COGS (H4 + M3)
--   5. InventoryHealth_DW.v_FactInventoryHealthSnapshot
--   6. InventoryHealth_DW.v_FactInventoryRiskForward (H5)
-- DROPPED 2026-05-22 (round 1): DimRuleVersion (over-engineering — Aric decision).
-- DROPPED 2026-05-22 (round 2): DimDate (duplication with ForecastAccuracy_DW.DimCalendar).
--   Inventory_health TMDL now rebinds to ForecastAccuracy_DW.DimCalendar (single shared
--   date dim across both marts). Fact views already JOIN to that table for fiscal cols.
-- Shared date dim: see ForecastAccuracy_DW.v_DimCalendar (75 cols, lives in mart A schema).
-- DESIGN NOTE: Per deliverable v1, the TMDL semantic model expects all 7 user-facing
-- tables (5 Dims + 2 Facts) under InventoryHealth_DW. We DO NOT bind DirectLake to
-- ForecastAccuracy_DW dims because their column schemas differ from the deliverable's
-- design (e.g. DimProduct vs DimItem, DimCalendar vs DimDate). Source layer reuse is
-- still applied (ItemMasterExt reads ReferenceMaster_Enh.ItemMaster).
-- ============================================================


-- ---- InventoryHealth_DW.v_DimDate ----  [DROPPED 2026-05-22]
-- Reason: duplicate of ForecastAccuracy_DW.DimCalendar (same source ReferenceMaster_Enh.Calendar).
-- Inv_health TMDL now binds directly to ForecastAccuracy_DW.DimCalendar via column-name
-- aliases (DateKey→DateSK, FiscalMonth→FSCMonthNum, etc.). Single shared date dim.
-- IsCurrentDate/IsCurrentWeek/IsMonthEnd flag cols deferred — compute report-level DAX if needed.
-- See git history pre-2026-05-22 for restoration if Phase 2 needs them as physical cols.

-- (Full v_DimDate CREATE VIEW body removed — recoverable from git pre-2026-05-22)


-- ---- InventoryHealth_DW.v_DimItem ----
-- Derived from InventoryHistory_Enh.ItemMasterExt + computed LifecycleStatus.
-- Schema matches deliverable v1 gold.DimItem (downstream DAX measures depend on these cols).
CREATE VIEW InventoryHealth_DW.v_DimItem AS
SELECT
    CAST(im.ItemSku                AS VARCHAR(50))    AS ItemSku,
    CAST(im.ItemDescription        AS VARCHAR(200))   AS ItemDescription,
    CAST(im.ItemClassCode          AS VARCHAR(50))    AS ItemClassCode,
    CAST(im.ItemClassName          AS VARCHAR(100))   AS ItemClassName,
    CAST(im.CategoryName           AS VARCHAR(100))   AS CategoryName,
    CAST(im.CategoryCode           AS VARCHAR(50))    AS CategoryCode,
    CAST(im.CollectiveClass        AS VARCHAR(50))    AS CollectiveClass,
    CAST(im.SeriesNumber           AS VARCHAR(50))    AS SeriesNumber,
    CAST(im.SeriesName             AS VARCHAR(100))   AS SeriesName,
    CAST(im.AfiItemStatus          AS VARCHAR(10))    AS AfiItemStatus,
    CAST(CASE
        WHEN im.DiscontinuedFlag = 1      THEN 'Discontinued'
        WHEN im.AfiItemStatus = 'N'       THEN 'New'
        WHEN im.AfiItemStatus = 'A'       THEN 'Active'
        WHEN im.AfiItemStatus IN ('D','R') THEN 'Inactive'
        ELSE 'Other'
    END AS VARCHAR(20))                              AS LifecycleStatus,
    CAST(im.PrimaryVendorNumber    AS VARCHAR(50))    AS PrimaryVendorNumber,
    CAST(im.PrimaryVendorName      AS VARCHAR(200))   AS PrimaryVendorName,
    CAST(im.Cubes                  AS DECIMAL(18,4))  AS Cubes,
    CAST(im.FobArcPrice            AS DECIMAL(18,4))  AS FobArcPrice,
    CAST(im.IsFinishedGoodsItem    AS BIT)            AS IsFinishedGoodsItem,
    CAST(im.DiscontinuedFlag       AS BIT)            AS DiscontinuedFlag,
    CAST(im.NewItemFlag            AS BIT)            AS NewItemFlag,
    CAST(im.StatusCodeChangeDate   AS DATE)           AS StatusCodeChangeDate,
    CAST(im.UnavailableFlag        AS BIT)            AS UnavailableFlag
FROM [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[ItemMasterExt] im

GO


-- ---- InventoryHealth_DW.v_DimWarehouse ----
-- Derived from InventoryHistory_Enh.WarehouseExt.
CREATE VIEW InventoryHealth_DW.v_DimWarehouse AS
SELECT
    CAST(w.WarehouseCode                  AS VARCHAR(50))   AS WarehouseCode,
    CAST(w.WarehouseName                  AS VARCHAR(50))   AS WarehouseName,
    CAST(w.WarehouseType                  AS VARCHAR(100))  AS WarehouseType,
    CAST(w.WarehouseOrderGroup            AS VARCHAR(50))   AS WarehouseOrderGroup,
    CAST(w.WarehouseSourceId              AS VARCHAR(50))   AS WarehouseSourceId,
    CAST(w.SellableWarehouseFlag          AS BIT)           AS SellableWarehouseFlag,
    CAST(w.ControlledFlag                 AS BIT)           AS ControlledFlag,
    CAST(w.WhereMadeCode                  AS VARCHAR(50))   AS WhereMadeCode,
    CAST(w.ManufacturingSite              AS VARCHAR(50))   AS ManufacturingSite,
    CAST(w.IntransitWarehouseCode         AS VARCHAR(50))   AS IntransitWarehouseCode,
    CAST(w.IsFinishedGoodsWarehouse       AS BIT)           AS IsFinishedGoodsWarehouse,
    CAST(w.IsManufacturingWarehouse       AS BIT)           AS IsManufacturingWarehouse,
    CAST(w.TotalAvailableWarehouseCube    AS DECIMAL(18,4)) AS TotalAvailableWarehouseCube
FROM [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[WarehouseExt] w

GO


-- ---- InventoryHealth_DW.v_DimVendor ----
CREATE VIEW InventoryHealth_DW.v_DimVendor AS
SELECT
    CAST(v.VendorNumber  AS VARCHAR(50))   AS VendorNumber,
    CAST(v.VendorName    AS VARCHAR(200))  AS VendorName
FROM [SupplyChain_Processing_Warehouse].[ReferenceMaster_Enh].[Vendor] v
WHERE v.VendorNumber IS NOT NULL

GO


-- ---- InventoryHealth_DW.v_CogsRollingHelper ----
-- Hidden helper. Monthly COGS + 52M/12M rolling.
-- H4 FIX (2026-05-17): ORDER BY FiscalMonthYear (chronological YYYYMM), NOT FiscalMonth (1-12 cycle).
-- M3 FIX (2026-05-17): renamed Cogs52W → Cogs52M (monthly grain).
--   Robert sign-off pending: keep 52M (current) or rewrite weekly grain.
CREATE VIEW InventoryHealth_DW.v_CogsRollingHelper AS
WITH monthly AS (
    SELECT
        s.ItemSku,
        s.WarehouseCode,
        d.FSCMonthYearNum                                                  AS FiscalMonthYear,
        SUM(s.QuantityShipped * ISNULL(c.StandardCost, 0))                 AS PeriodCogs,
        SUM(s.QuantityShipped)                                             AS PeriodShippedQty
    FROM [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[SalesShipment] s
    JOIN [SupplyChain_Gold_Warehouse].[ForecastAccuracy_DW].[DimCalendar] d
         ON d.[Date] = s.InvoiceDate
    LEFT JOIN [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[CostCurrent] c
         ON c.ItemSku = s.ItemSku
    GROUP BY s.ItemSku, s.WarehouseCode, d.FSCMonthYearNum
)
SELECT
    CAST(ItemSku           AS VARCHAR(50))   AS ItemSku,
    CAST(WarehouseCode     AS VARCHAR(50))   AS WarehouseCode,
    CAST(FiscalMonthYear   AS INT)           AS FiscalMonthYear,
    CAST(PeriodCogs        AS DECIMAL(18,4)) AS PeriodCogs,
    CAST(PeriodShippedQty  AS DECIMAL(18,4)) AS PeriodShippedQty,
    CAST(SUM(PeriodCogs) OVER (
        PARTITION BY ItemSku, WarehouseCode
        ORDER BY FiscalMonthYear  -- H4 FIX: chronological YYYYMM, not 1-12 cycle
        ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
    ) AS DECIMAL(18,4))                      AS Cogs12M,
    CAST(SUM(PeriodCogs) OVER (
        PARTITION BY ItemSku, WarehouseCode
        ORDER BY FiscalMonthYear  -- H4 FIX
        ROWS BETWEEN 51 PRECEDING AND CURRENT ROW
    ) AS DECIMAL(18,4))                      AS Cogs52M   -- M3 FIX: renamed from Cogs52W
FROM monthly

GO


-- ---- InventoryHealth_DW.v_FactInventoryHealthSnapshot ----
-- Grain: (ItemSku, WarehouseCode, SnapshotDate, SnapshotType)
-- SnapshotType ∈ ('Current', 'Weekly').
-- v10 conversion: deliverable's 2-pass procedure (CTAS Pass 1 + UPDATE Pass 2) collapsed
-- into a SINGLE view with CTEs handling rolling COGS + AvgInv12M inline (Meta.usp_GenericLoad
-- does CTAS only — no UPDATE). Logic identical to deliverable's gold.usp_Build_FactInventoryHealthSnapshot.
-- M4 FIX (2026-05-17): SLOB + ObsoleteValue require LastInvoiceDate IS NOT NULL guard.
CREATE VIEW InventoryHealth_DW.v_FactInventoryHealthSnapshot AS
WITH base AS (
    -- Current daily rows (rolling 7d)
    SELECT
        CAST('Current'                          AS VARCHAR(10))  AS SnapshotType,
        ic.SnapshotDate                                          AS SnapshotDate,
        ic.ItemSku, ic.WarehouseCode,
        ic.OnHandQty,
        CAST('ItemMaster_AFI' AS VARCHAR(64))                    AS SourceSystem,
        CAST('ITEMBL'         AS VARCHAR(128))                   AS SourceTable
    FROM [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[InventoryCurrent] ic
    WHERE ic.SnapshotDate >= DATEADD(day, -7, CAST(SYSUTCDATETIME() AS DATE))

    UNION ALL

    -- Weekly history rows
    SELECT
        CAST('Weekly'                                AS VARCHAR(10)),
        iw.SnapshotDate,
        iw.ItemSku, iw.WarehouseCode,
        iw.OnHandQty,
        CAST('SupplyChain_Enh_1'                     AS VARCHAR(64)),
        CAST('DemandInventorySnapshotWeekly'         AS VARCHAR(128))
    FROM [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[InventorySnapshotWeekly] iw
),
latest_current_date AS (
    SELECT MAX(SnapshotDate) AS MaxDate
    FROM [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[InventoryCurrent]
),
-- Snapshot-aware PO/MO/Hold aggregates
po_curr AS (
    SELECT ItemSku, WarehouseCode,
        SUM(POOnOrderQty) AS POOnOrderQty,
        SUM(POInTransitQty) AS POInTransitQty
    FROM [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[PurchaseOrder]
    GROUP BY ItemSku, WarehouseCode
),
po_snap AS (
    SELECT SnapshotDate, ItemSku, WarehouseCode,
        SUM(POOnOrderQty) AS POOnOrderQty,
        SUM(POInTransitQty) AS POInTransitQty
    FROM [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[PurchaseOrderSnapshotDaily]
    GROUP BY SnapshotDate, ItemSku, WarehouseCode
),
mo_curr AS (
    SELECT ItemSku, WarehouseCode,
        SUM(MOOnOrderQty) AS MOOnOrderQty
    FROM [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[ManufacturingOrder]
    GROUP BY ItemSku, WarehouseCode
),
mo_snap AS (
    SELECT SnapshotDate, ItemSku, WarehouseCode,
        SUM(MOOnOrderQty) AS MOOnOrderQty
    FROM [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[ManufacturingOrderSnapshotDaily]
    GROUP BY SnapshotDate, ItemSku, WarehouseCode
),
hold_snap AS (
    SELECT SnapshotDate, ItemSku, WarehouseCode,
        SUM(TransferQty) AS OnHoldQty,
        SUM(TransferCube) AS OnHoldCube
    FROM [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[HoldingTransferSnapshotDaily]
    GROUP BY SnapshotDate, ItemSku, WarehouseCode
),
hold_curr AS (
    SELECT ItemSku, WarehouseCode,
        SUM(TransferQty) AS OnHoldQty,
        SUM(TransferCube) AS OnHoldCube
    FROM [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[HoldingTransfer]
    GROUP BY ItemSku, WarehouseCode
),
-- Transfer-in InTransit (paired warehouse from ITEMBL)
ti_curr AS (
    SELECT
        TRIM(b.ITNBR)         AS ItemSku,
        TRIM(w.WarehouseCode) AS WarehouseCode,
        SUM(CAST(b.MOHTQ AS DECIMAL(18,4)))   AS TransferInInTransitQty
    FROM [Enterprise_Lakehouse].[ItemMaster_AFI].[ITEMBL] b
    JOIN [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[WarehouseExt] w
         ON TRIM(w.IntransitWarehouseCode) = TRIM(b.HOUSE)
    WHERE b.ITNBR IS NOT NULL AND b.HOUSE IS NOT NULL
      AND TRIM(b.ITNBR) <> '' AND TRIM(b.HOUSE) <> ''
    GROUP BY TRIM(b.ITNBR), TRIM(w.WarehouseCode)
),
-- Pre-derive InventoryValueAtCost for AvgInv12M computation
ivc_monthly AS (
    SELECT DISTINCT
        b.ItemSku, b.WarehouseCode, d.FSCMonthYearNum AS FiscalMonthYear,
        ISNULL(b.OnHandQty,0) * ISNULL(cc.StandardCost,0) AS InventoryValueAtCost
    FROM base b
    JOIN [SupplyChain_Gold_Warehouse].[ForecastAccuracy_DW].[DimCalendar] d
         ON d.[Date] = b.SnapshotDate
    LEFT JOIN [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[CostCurrent] cc
         ON cc.ItemSku = b.ItemSku
    WHERE d.[Date] = (
        SELECT MAX(d2.[Date])
        FROM [SupplyChain_Gold_Warehouse].[ForecastAccuracy_DW].[DimCalendar] d2
        WHERE d2.FSCMonthYearNum = d.FSCMonthYearNum
    )  -- month-end approximation
),
avg_ivc12 AS (
    SELECT
        ItemSku, WarehouseCode, FiscalMonthYear,
        AVG(InventoryValueAtCost) OVER (
            PARTITION BY ItemSku, WarehouseCode
            ORDER BY FiscalMonthYear
            ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
        ) AS AvgInvValue12M
    FROM ivc_monthly
)
SELECT
    -- Grain
    CAST(b.ItemSku           AS VARCHAR(50))  AS ItemSku,
    CAST(b.WarehouseCode     AS VARCHAR(50))  AS WarehouseCode,
    CAST(b.SnapshotDate      AS DATE)         AS SnapshotDate,
    CAST(b.SnapshotType      AS VARCHAR(10))  AS SnapshotType,
    CAST(d.FSCWeekLast       AS DATE)         AS WeekEndingDate,
    CAST(d.DateSK            AS INT)          AS DateKey,    -- FIX 2026-05-19: DimCalendar (Gold) uses DateSK; Calendar (Silver) uses SKDate
    CAST(d.FSCMonthNum       AS INT)          AS FiscalMonth,
    CAST(d.FSCMonthYearNum   AS INT)          AS FiscalMonthYear,
    CAST(CASE WHEN b.SnapshotType = 'Current'
              AND b.SnapshotDate = (SELECT MaxDate FROM latest_current_date)
              THEN 1 ELSE 0 END AS BIT)        AS IsLatestSnapshot,
    CAST(b.SourceSystem      AS VARCHAR(64))   AS SourceSystem,
    CAST(b.SourceTable       AS VARCHAR(128))  AS SourceTable,

    -- Base supply qty
    CAST(ISNULL(b.OnHandQty, 0)                          AS DECIMAL(18,4)) AS OnHandQty,
    CAST(ISNULL(ti.TransferInInTransitQty, 0)            AS DECIMAL(18,4)) AS TransferInInTransitQty,

    -- Snapshot-aware PO / MO / Hold pull
    CAST(CASE WHEN b.SnapshotType = 'Current'
              THEN ISNULL(pc.POInTransitQty, 0)
              ELSE ISNULL(ps.POInTransitQty, 0) END     AS DECIMAL(18,4)) AS POInTransitQty,
    CAST(CASE WHEN b.SnapshotType = 'Current'
              THEN ISNULL(pc.POOnOrderQty, 0)
              ELSE ISNULL(ps.POOnOrderQty, 0) END       AS DECIMAL(18,4)) AS POOnOrderQty,
    CAST(CASE WHEN b.SnapshotType = 'Current'
              THEN ISNULL(mc.MOOnOrderQty, 0)
              ELSE ISNULL(ms.MOOnOrderQty, 0) END       AS DECIMAL(18,4)) AS MOOnOrderQty,

    -- Derived totals
    CAST(ISNULL(ti.TransferInInTransitQty,0) +
         CASE WHEN b.SnapshotType='Current' THEN ISNULL(pc.POInTransitQty,0)
              ELSE ISNULL(ps.POInTransitQty,0) END
         AS DECIMAL(18,4))                              AS InTransitQty,
    CAST(CASE WHEN b.SnapshotType='Current'
              THEN ISNULL(pc.POOnOrderQty,0) + ISNULL(mc.MOOnOrderQty,0)
              ELSE ISNULL(ps.POOnOrderQty,0) + ISNULL(ms.MOOnOrderQty,0) END
         AS DECIMAL(18,4))                              AS OnOrderQty,

    -- Demand & coverage
    CAST(awd.AwdQty         AS DECIMAL(18,4))           AS AwdQty,
    CAST(awd.AwdSource      AS VARCHAR(20))             AS AwdSource,
    CAST(CASE WHEN awd.AwdQty > 0
              THEN b.OnHandQty / awd.AwdQty END
         AS DECIMAL(18,4))                              AS WeeksOfSupply,
    CAST(ss.SafetyStockTarget AS DECIMAL(18,4))         AS SafetyStockTargetQty,
    CAST(CASE WHEN ss.SafetyStockTarget > 0
              THEN b.OnHandQty / ss.SafetyStockTarget END
         AS DECIMAL(18,4))                              AS SafetyStockMultiple,

    -- Inventory classification (BRD v1)
    CAST(CASE
        WHEN dim.AfiItemStatus IN ('D','R')
         AND (ISNULL(b.OnHandQty,0)
            + CASE WHEN b.SnapshotType='Current' THEN ISNULL(pc.POOnOrderQty,0) ELSE ISNULL(ps.POOnOrderQty,0) END
            + CASE WHEN b.SnapshotType='Current' THEN ISNULL(mc.MOOnOrderQty,0) ELSE ISNULL(ms.MOOnOrderQty,0) END) = 0
            THEN 'Inactive'
        WHEN ss.SafetyStockTarget > 0 AND b.OnHandQty <= 0.5 * ss.SafetyStockTarget THEN 'Below Target'
        WHEN ss.SafetyStockTarget > 0 AND b.OnHandQty <= 1.5 * ss.SafetyStockTarget THEN 'Sweet Spot'
        WHEN awd.AwdQty > 0 AND b.OnHandQty <= 17  * awd.AwdQty THEN 'Over Target'
        WHEN awd.AwdQty > 0 AND b.OnHandQty <= 52  * awd.AwdQty THEN 'Excess'
        WHEN awd.AwdQty > 0 AND b.OnHandQty <= 104 * awd.AwdQty THEN 'Aggressive Excess'
        ELSE 'TB Inventory'
    END AS VARCHAR(30))                                 AS InventoryClassification,

    -- Financial
    CAST(cc.StandardCost  AS DECIMAL(18,4))             AS StandardCost,
    CAST(dim.FobArcPrice  AS DECIMAL(18,4))             AS FobArcPrice,
    CAST(dim.Cubes        AS DECIMAL(18,4))             AS Cubes,
    CAST(ISNULL(b.OnHandQty,0) * ISNULL(cc.StandardCost,0) AS DECIMAL(18,4)) AS InventoryValueAtCost,
    CAST(ISNULL(b.OnHandQty,0) * ISNULL(dim.FobArcPrice,0) AS DECIMAL(18,4)) AS InventoryValueAtRevenue,
    CAST(ISNULL(b.OnHandQty,0) * ISNULL(dim.Cubes,0)       AS DECIMAL(18,4)) AS UsedStorageCube,

    -- Rolling COGS (Pass 2 inlined via JOIN to v_CogsRollingHelper)
    CAST(coh.PeriodCogs AS DECIMAL(18,4))               AS PeriodCogs,
    CAST(coh.Cogs52M    AS DECIMAL(18,4))               AS Cogs52M,
    CAST(coh.Cogs12M    AS DECIMAL(18,4))               AS Cogs12M,
    CAST(aiv.AvgInvValue12M AS DECIMAL(18,4))           AS AverageInventoryValueAtCost,

    -- Status flags
    CAST(lh.LastInvoiceDate AS DATE)                    AS LastInvoiceDate,
    CAST(dim.LifecycleStatus AS VARCHAR(20))            AS LifecycleStatus,
    CAST(CASE WHEN dim.AfiItemStatus IN ('D','R')
              AND (ISNULL(b.OnHandQty,0)
                + CASE WHEN b.SnapshotType='Current' THEN ISNULL(pc.POOnOrderQty,0) ELSE ISNULL(ps.POOnOrderQty,0) END
                + CASE WHEN b.SnapshotType='Current' THEN ISNULL(mc.MOOnOrderQty,0) ELSE ISNULL(ms.MOOnOrderQty,0) END) = 0
              THEN 1 ELSE 0 END
         AS BIT)                                        AS InactiveFlag,
    -- M4 FIX (2026-05-17): require LastInvoiceDate IS NOT NULL to avoid false-positive SLOB on new items.
    CAST(CASE WHEN dim.AfiItemStatus <> 'N'
              AND lh.LastInvoiceDate IS NOT NULL
              AND lh.LastInvoiceDate < DATEADD(week, -17, b.SnapshotDate)
              THEN 1 ELSE 0 END
         AS BIT)                                        AS SlobFlag,
    CAST(CASE WHEN ISNULL(mf.HasMovementLast17W, 0) = 0
              THEN 1 ELSE 0 END
         AS BIT)                                        AS NoMovementFlag,
    CAST(dim.UnavailableFlag AS BIT)                    AS UnavailableFlag,

    -- Hold (snapshot-aware)
    CAST(CASE WHEN b.SnapshotType='Current'
              THEN ISNULL(hc.OnHoldQty, 0)
              ELSE ISNULL(hs.OnHoldQty, 0) END
         AS DECIMAL(18,4))                              AS OnHoldQty,
    CAST(CASE WHEN (CASE WHEN b.SnapshotType='Current' THEN ISNULL(hc.OnHoldQty,0) ELSE ISNULL(hs.OnHoldQty,0) END) > 0
              THEN 1 ELSE 0 END
         AS BIT)                                        AS OnHoldFlag,

    -- Obsolete (SLOB-flagged inventory value at cost)
    -- M4 FIX: same NULL handling as SlobFlag
    CAST(CASE WHEN dim.AfiItemStatus <> 'N'
              AND lh.LastInvoiceDate IS NOT NULL
              AND lh.LastInvoiceDate < DATEADD(week, -17, b.SnapshotDate)
              THEN ISNULL(b.OnHandQty,0) * ISNULL(cc.StandardCost,0)
              ELSE 0 END
         AS DECIMAL(18,4))                              AS ObsoleteValue
FROM base b
LEFT JOIN [SupplyChain_Gold_Warehouse].[ForecastAccuracy_DW].[DimCalendar] d
       ON d.[Date] = b.SnapshotDate
-- DimItem reused from forecast's DimProduct + augmented inline with InventoryHistory ItemMasterExt fields
LEFT JOIN [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[ItemMasterExt] dim_ext
       ON dim_ext.ItemSku = b.ItemSku
LEFT JOIN (
    -- Mirror deliverable's DimItem layout: select needed cols from ItemMasterExt + lifecycle case
    SELECT
        ItemSku, AfiItemStatus, FobArcPrice, Cubes, UnavailableFlag,
        CASE
            WHEN DiscontinuedFlag = 1     THEN 'Discontinued'
            WHEN AfiItemStatus = 'N'      THEN 'New'
            WHEN AfiItemStatus = 'A'      THEN 'Active'
            WHEN AfiItemStatus IN ('D','R') THEN 'Inactive'
            ELSE 'Other'
        END AS LifecycleStatus
    FROM [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[ItemMasterExt]
) dim ON dim.ItemSku = b.ItemSku
LEFT JOIN [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[CostCurrent] cc
       ON cc.ItemSku = b.ItemSku
LEFT JOIN ti_curr ti                  ON ti.ItemSku=b.ItemSku AND ti.WarehouseCode=b.WarehouseCode
LEFT JOIN po_curr pc                  ON pc.ItemSku=b.ItemSku AND pc.WarehouseCode=b.WarehouseCode
LEFT JOIN po_snap ps                  ON ps.ItemSku=b.ItemSku AND ps.WarehouseCode=b.WarehouseCode AND ps.SnapshotDate=b.SnapshotDate
LEFT JOIN mo_curr mc                  ON mc.ItemSku=b.ItemSku AND mc.WarehouseCode=b.WarehouseCode
LEFT JOIN mo_snap ms                  ON ms.ItemSku=b.ItemSku AND ms.WarehouseCode=b.WarehouseCode AND ms.SnapshotDate=b.SnapshotDate
LEFT JOIN hold_curr hc                ON hc.ItemSku=b.ItemSku AND hc.WarehouseCode=b.WarehouseCode
LEFT JOIN hold_snap hs                ON hs.ItemSku=b.ItemSku AND hs.WarehouseCode=b.WarehouseCode AND hs.SnapshotDate=b.SnapshotDate
LEFT JOIN [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[AwdHelper] awd
       ON awd.ItemSku=b.ItemSku AND awd.WarehouseCode=b.WarehouseCode AND awd.AsOfDate=b.SnapshotDate
LEFT JOIN [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[LastInvoiceHelper] lh
       ON lh.ItemSku=b.ItemSku AND lh.WarehouseCode=b.WarehouseCode AND lh.AsOfDate=b.SnapshotDate
LEFT JOIN [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[MovementFlagHelper] mf
       ON mf.ItemSku=b.ItemSku AND mf.WarehouseCode=b.WarehouseCode AND mf.AsOfDate=b.SnapshotDate
LEFT JOIN [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[SafetyStockHelper] ss
       ON ss.ItemSku=b.ItemSku AND ss.WarehouseCode=b.WarehouseCode AND ss.AsOfDate=b.SnapshotDate
-- Rolling COGS (Pass 2 inlined): join CogsRollingHelper on FiscalMonthYear of SnapshotDate
LEFT JOIN [SupplyChain_Gold_Warehouse].[InventoryHealth_DW].[CogsRollingHelper] coh
       ON coh.ItemSku=b.ItemSku AND coh.WarehouseCode=b.WarehouseCode
      AND coh.FiscalMonthYear=d.FSCMonthYearNum
LEFT JOIN avg_ivc12 aiv
       ON aiv.ItemSku=b.ItemSku AND aiv.WarehouseCode=b.WarehouseCode
      AND aiv.FiscalMonthYear=d.FSCMonthYearNum

GO


-- ---- InventoryHealth_DW.v_FactInventoryRiskForward ----
-- Grain: (ItemSku, WarehouseCode, WeekEndingDate)
-- Source: InventoryHistory_Enh.SupplyPlan (latest snapshot per WeekEnding) + AtpWeekEnding (Week2) + AllocatedDemand
-- H5 FIX (2026-05-17): WeekFourFlag = exact week-4 ending only (Saturday + 28 days). Robert sign-off pending.
CREATE VIEW InventoryHealth_DW.v_FactInventoryRiskForward AS
WITH latest_plan AS (
    SELECT
        ItemSku, WarehouseCode, WeekEndingDate,
        BeginningBalanceQty, FirmDemandQty, NetForecastQty,
        FirmPurchaseOrderQty, PlannedPurchaseOrderQty,
        OnOrderTransferInQty, ShippableInventoryQty,
        SafetyStockTargetQty, MonthsOfSupply, SINegQty,
        ROW_NUMBER() OVER (
            PARTITION BY ItemSku, WarehouseCode, WeekEndingDate
            ORDER BY SnapshotDate DESC
        ) AS rn
    FROM [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[SupplyPlan]
),
atp_w2 AS (
    SELECT ItemSku, WarehouseCode, AtpQty
    FROM [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[AtpWeekEnding]
    WHERE WeekNumber = 2
),
alloc AS (
    SELECT
        ItemSku, WarehouseCode,
        SUM(AllocatedDemandQty) AS AllocatedDemandQty
    FROM [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[AllocatedDemandCandidate]
    GROUP BY ItemSku, WarehouseCode
)
SELECT
    CAST(lp.ItemSku            AS VARCHAR(50))   AS ItemSku,
    CAST(lp.WarehouseCode      AS VARCHAR(50))   AS WarehouseCode,
    CAST(lp.WeekEndingDate     AS DATE)          AS WeekEndingDate,
    CAST(d.DateSK              AS INT)           AS DateKey,    -- FIX 2026-05-19: DimCalendar (Gold) uses DateSK
    CAST(lp.BeginningBalanceQty       AS DECIMAL(18,4)) AS BeginningBalanceQty,
    CAST(lp.FirmDemandQty             AS DECIMAL(18,4)) AS FirmDemandQty,
    CAST(lp.NetForecastQty            AS DECIMAL(18,4)) AS NetForecastQty,
    CAST(lp.FirmPurchaseOrderQty      AS DECIMAL(18,4)) AS FirmPurchaseOrderQty,
    CAST(lp.PlannedPurchaseOrderQty   AS DECIMAL(18,4)) AS PlannedPurchaseOrderQty,
    CAST(lp.OnOrderTransferInQty      AS DECIMAL(18,4)) AS OnOrderTransferInQty,
    CAST(lp.ShippableInventoryQty     AS DECIMAL(18,4)) AS ShippableInventoryQty,
    CAST(lp.SafetyStockTargetQty      AS DECIMAL(18,4)) AS SafetyStockTargetQty,
    CAST(lp.MonthsOfSupply            AS DECIMAL(18,4)) AS MonthsOfSupply,
    -- 14-day demand/inbound derived
    CAST(lp.FirmDemandQty * (14.0/7.0)                                 AS DECIMAL(18,4)) AS ExpectedDemand14DQty,
    CAST((lp.FirmPurchaseOrderQty + lp.OnOrderTransferInQty) * (14.0/7.0) AS DECIMAL(18,4)) AS Inbound14DQty,
    CAST(ISNULL(al.AllocatedDemandQty, 0)        AS DECIMAL(18,4))      AS AllocatedDemandQty,
    CAST(ISNULL(at.AtpQty, 0)                    AS DECIMAL(18,4))      AS ATPQty,
    CAST(CASE WHEN ISNULL(at.AtpQty, 0) > 0 THEN 1 ELSE 0 END AS BIT)   AS ATPInStockFlag,
    CAST(CASE WHEN lp.ShippableInventoryQty > 0 THEN 1 ELSE 0 END AS BIT) AS ShippableInStockFlag,
    CAST(lp.SINegQty                             AS DECIMAL(18,4))      AS SINegQty,
    CAST(lp.SINegQty * ISNULL(dim.FobArcPrice, 0) AS DECIMAL(18,4))     AS RevenueAtRiskValue,
    -- H5 FIX (2026-05-17): exact week-4 ending only (Saturday + 28 days).
    -- BRD §6.3 "At Week Four Ending" = single week. Robert sign-off pending.
    CAST(CASE WHEN lp.WeekEndingDate = (
                  DATEADD(day,
                          ((7 - DATEPART(weekday, SYSUTCDATETIME()) + 7) % 7) + 28,
                          CAST(SYSUTCDATETIME() AS DATE))
              )
              THEN 1 ELSE 0 END AS BIT)                                 AS WeekFourFlag,
    CAST(dim.FobArcPrice                         AS DECIMAL(18,4))      AS FobArcPrice
FROM latest_plan lp
LEFT JOIN [SupplyChain_Gold_Warehouse].[ForecastAccuracy_DW].[DimCalendar] d
       ON d.[Date] = lp.WeekEndingDate
LEFT JOIN [SupplyChain_Processing_Warehouse].[InventoryHistory_Enh].[ItemMasterExt] dim
       ON dim.ItemSku = lp.ItemSku
LEFT JOIN atp_w2 at  ON at.ItemSku=lp.ItemSku AND at.WarehouseCode=lp.WarehouseCode
LEFT JOIN alloc al   ON al.ItemSku=lp.ItemSku AND al.WarehouseCode=lp.WarehouseCode
WHERE lp.rn = 1

GO


-- ============================================================
-- END gold_views.sql
-- Total: 5 views in InventoryHealth_DW
-- ============================================================
