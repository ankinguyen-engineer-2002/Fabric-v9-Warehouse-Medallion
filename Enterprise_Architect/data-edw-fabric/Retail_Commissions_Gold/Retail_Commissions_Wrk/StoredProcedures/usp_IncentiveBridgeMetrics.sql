--exec Retail_Commissions_Wrk.usp_IncentiveBridgeMetrics '01-02-2026', '01-05-2026'
CREATE   Proc Retail_Commissions_Wrk.usp_IncentiveBridgeMetrics 
  @FromDate Date,
  @ToDate Date
AS   

--DECLARE @FromDate Date, @ToDate Date

--SET @FromDate = DateAdd(Day,-3,Cast(Getdate() as Date))
--SET @ToDate = Cast(Getdate() as Date) 

WITH CTE_DateLocations AS
    ( SELECT StoreID as LocationID, DateID
      FROM [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimDate] 
      CROSS JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].DimStoreLocation
      WHERE DateID BETWEEN @FromDate AND @ToDate
    ),

-- get sales metrics
CTE_COMM_FactSalesData
AS 
(
SELECT
    sdt.SourceDataID,
	sdt.OrderID,
	sdt.ItemID,
    sdt.TransCodeID,
    pm.SKU AS ProductID,
    pm.SKUName AS ProductName,
    pm.VendorID,
    pm.SubGroupID,
    sp.SalesPersonID,
    cm.FullName AS CustomerName,
    sp.SalesPersonName,
    sp.HomeStore,
    d.DateID,
    gm.CategoryID,
    gm.GroupID,
    lm.StoreID,
    lm.LocationName AS StoreName,
    lm.HomestoreOwnerGroup AS OwnerGroup,
    sdt.AsIsReasonCodeID,
    '' AS ItemCommCategory,
    CASE
        WHEN sdt.SalesType = 'W' AND sdt.SalesDataTypeKey IN (1, 10) THEN sdt.Sales
        ELSE 0
    END AS WrittenSales,
    CASE
        WHEN sdt.SalesType = 'W' THEN sdt.Cost
        ELSE 0
    END AS WrittenCost,
    CASE
        WHEN sdt.SalesType = 'W' THEN sdt.Units
        ELSE 0
    END AS WrittenUnits,
    0 AS WrittenTaxes,
    CASE
        WHEN sdt.SalesType = 'W'  AND sdt.SalesDataTypeKey = 2 THEN sdt.Sales
        ELSE 0
    END AS WrittenCharges,
    0 AS WrittenRebates,
    CASE
        WHEN sdt.SalesType = 'D' THEN sdt.Sales
        ELSE 0
    END AS DeliveredSales,
    CASE
        WHEN sdt.SalesType = 'D' THEN sdt.Cost
        ELSE 0
    END AS DeliveredCost,
    CASE
        WHEN sdt.SalesType = 'D' THEN sdt.Units
        ELSE 0
    END AS DeliveredUnits,
    0 AS DeliveredRebates,
    0 AS OrderClose,
    0 AS FinancedAmt,
    0 AS OtherPaymentAmt,
    sdt.DeliveryStatus,
    sdt.ProductDiscountCode AS ProdDiscntCode,
    sdt.PVEReasonCodeID AS PriceVarianceExceptionReasonCodeID,
    cm.LastName AS CustomerLastName,
    sdt.SalesDataTypeKey,
    sdt.TransDateKey,
    od.DateID AS OrderDate,
    0 AS CommCostAddonPct,
    '' AS FinPaymentTypeID, --oh.FinPaymentTypeID,
    0 AS FinancedAmount, --oh.FinancedAmount,
    --os.SplitPercent,
    sdt.InvSubBucketID
FROM [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[FactSales] sdt 
    INNER JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimProduct] pm ON sdt.ProductKey = pm.ProductKey
    INNER JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimDate] d ON sdt.TransDateKey = d.DateKey
    INNER JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimSalesPerson] sp ON sdt.SalesPersonKey = sp.SalesPersonKey
    INNER JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimGroupMaster] gm on pm.GroupID = gm.GroupID
    INNER JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimStoreLocation] lm ON lm.LocationKey = sdt.LocationKey
    INNER JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimCustomerMaster] cm ON cm.CustomerKey = sdt.CustomerKey
    INNER JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimDate] od ON sdt.OrderDateKey = od.DateKey
    INNER JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[FactOrderHeader] oh ON oh.SourceOrderID = sdt.OrderID
WHERE sdt.TransCodeID <> 3 and d.DateID BETWEEN @FromDate AND @ToDate
),

CTE_Sales AS 
    ( SELECT	
        ci.DateID,
        StoreID as LocationId, 
        SUM(IIF(ci.SalesDataTypeKey IN (1, 2, 10),WrittenSales,0)) AS WrittenSales,
        SUM(IIF(ci.SalesDataTypeKey IN (1, 2, 10),WrittenCharges,0)) AS WrittenCharges,
        SUM(IIF(ci.SalesDataTypeKey IN (1, 2, 10),WrittenSales + WrittenCharges,0)) AS WrittenCharges_WChrg,
        SUM(CASE WHEN gm.FamilyName = 'OTHER' THEN 0 ELSE WrittenSales END) AS PrimaryWrittenSales,
        SUM(CASE WHEN gm.FamilyName = 'OTHER' THEN 0 ELSE WrittenCost END) AS PrimaryWrittenCost,
        SUM(IIF(ci.SalesDataTypeKey IN (1, 2, 10) AND ci.CategoryID = 'BEDDI', WrittenSales, 0)) AS BeddingSales,
        SUM(IIF(ci.SalesDataTypeKey IN (1, 2, 10) AND ci.CategoryID = 'BEDDI', WrittenUnits, 0)) AS BeddingUnits,
        SUM(IIF(ci.SalesDataTypeKey IN (1, 2, 10) AND ci.CategoryID = 'BEDDI', WrittenSales - WrittenCost, 0)) AS BeddingGMDollars,
        SUM(IIF(ci.SalesDataTypeKey IN (1, 2, 10) AND ci.CategoryID IN ('WARRI','WARRT'), WrittenSales, 0)) AS ProtectionSales,
        SUM(IIF(ci.SalesDataTypeKey IN (1, 2, 10) AND ci.CategoryID IN ('WARRI','WARRT'), WrittenSales - WrittenCost, 0)) AS ProtectionGMDollars,
        SUM(IIF(SalesDataTypeKey = 1 AND AsIsReasonCodeID IN ('CLA', 'CLC', 'CLR', 'CLU', 'FLR'), WrittenSales, 0)) AS ClearanceSales,
        SUM(IIF(SalesDataTypeKey = 1 AND AsIsReasonCodeID IN ('CLA', 'CLC', 'CLR', 'CLU', 'FLR'), WrittenSales - WrittenCost, 0)) AS ClearanceGMDollars,
        SUM(IIF(SalesDataTypeKey = 6 AND AsIsReasonCodeID IN ('CLA', 'CLC', 'CLR', 'CLU', 'FLR'), DeliveredUnits, 0)) AS DeliveredClearanceUnits        
    FROM CTE_COMM_FactSalesData ci
        INNER JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimGroupMaster] gm ON gm.GroupID = ci.GroupID
    WHERE ci.DateID BETWEEN @FromDate AND @ToDate
        AND (ci.SalesDataTypeKey IN (1, 2, 10) OR ci.SalesDataTypeKey=6 and ci.AsIsReasonCodeID IN ('CLA', 'CLC', 'CLR', 'CLU', 'FLR'))
        AND ci.CategoryID <> 'ELECT'
    GROUP BY ci.DateID, StoreID 

    ),



-- Subquery to get the total number of closed orders for the same period.

 CTE_Conversions AS
    ( SELECT	
            soc.StoreID AS LocationID,
            dd.DateID as DateID,
            SUM(soc.SUClose) AS OrdersCount
        FROM [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[FactSalesOrderCloses] soc
	     INNER JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimDate] dd
              ON dd.DateKey = soc.TransDateKey
            	
        WHERE 
            dd.DateID BETWEEN @FromDate AND @ToDate
        GROUP BY 
            soc.StoreID, 
            dd.DateID
    ),


    --- Get UPS ---
CTE_UPS AS
    (SELECT
        CAST(rs.TransDate AS DATE) AS DateID,
          rs.StoreID as LocationID,
          Sum(RecordedUps) AS RecordedUps
        FROM [$(Retail_Warehouse_Gold)].Retail_DW_Core.FactRSADailyStats AS rs
        WHERE CAST(rs.TransDate AS DATE)  BETWEEN @FromDate AND @ToDate
        GROUP BY
     CAST(rs.TransDate AS DATE),
         rs.StoreID
    ),


     --- Get Traffic ---
CTE_Traffic AS
    (
     SELECT	
        t.StoreID as LocationID,
        SUM(t.TransCount) AS TrafficGuests,
        dd.DateID as DateID
    
    FROM [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[FactTraffic] t
	     INNER JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimDate] dd
              ON dd.DateKey = t.TransDateKey
    
    WHERE 
        t.IsOpen = 1 -- Only count traffic when the store is open.
        AND t.TransDate BETWEEN @FromDate AND @ToDate
    GROUP BY 
        t.StoreID,
        dd.DateID
    )  ,
--- Finance Fees
CTE_FinanceFees AS 
    (SELECT	
            StoreID as LocationID,
            TransDate as DateID,
            SUM(FinanceFees) AS FinanceFees
        FROM [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[FactPayments]
        WHERE SalesDataTypeKey = 5
            AND IsFinanced = 1
            AND TransDate BETWEEN  @FromDate AND @ToDate
        GROUP BY StoreID, TransDate
    ),

--- AUSP--
CTE_BtaData_AUSP_Bedding
AS
(
    SELECT	
        StoreID as LocationID,
        CAST(b.TransDate AS DATE) AS DateID,
          -- Calculate AUSP: Avg Mattress Price + Avg Foundation/Power Base Price (must be 
         NetSalesMattress, 
         NetUnitsMattress,
         NetSalesBoxSpringPowerBase, 
         NetUnitsBoxSpringPowerBase,
         ( COALESCE(CAST(NetSalesMattress / NULLIF(NetUnitsMattress, 0) AS NUMERIC(18, 5)), 0) )
        + ( COALESCE(CAST(NetSalesBoxSpringPowerBase / NULLIF(NetUnitsBoxSpringPowerBase, 0) AS NUMERIC(18, 5)), 0) ) AS AUSP
   FROM (
        -- The inner query aggregates sales data by store and salesperson, separating bedding components.
        SELECT	
            b.StoreID,
            b.TransDate ,
             -- Sum sales and units specifically for Mattresses (MBS)
            SUM(CASE WHEN pc.Group_ID = 'MBS' THEN b.NetSales ELSE 0 END) AS NetSalesMattress,
            SUM(CASE WHEN pc.Group_ID = 'MBS' THEN b.NetUnits ELSE 0 END) AS NetUnitsMattress,
            -- Sum sales and units specifically for Foundations/Power Bases (FND, PBS)
            SUM(CASE WHEN pc.Group_ID IN ('FND','PBS') THEN b.NetSales ELSE 0 END) AS NetSalesBoxSpringPowerBase,
            SUM(CASE WHEN pc.Group_ID IN ('FND','PBS') THEN b.NetUnits ELSE 0 END) AS NetUnitsBoxSpringPowerBase
        FROM [$(Source_Data)].[Retail_Corporate].[BtaData] AS b
            INNER JOIN [$(Source_Data)].[Retail_External].[LocationGroups] lg ON lg.LocationID = b.StoreID
            INNER JOIN [$(Source_Data)].[Retail_External].[TransCodeMap] AS tg ON b.TransCodeID = tg.TransCodeID
            INNER JOIN [$(Source_Data)].[Retail_Miniapps].[Product] AS pc ON b.ProductID = pc.Product_ID
        WHERE 
            TransCodeGroup = 'SREA'   -- replacement for this filter 'tg.TCGroupID = 1'
            AND b.[Source] = 'W'
            AND b.TransDate BETWEEN @FromDate AND @ToDate
            AND pc.Group_ID IN ('PBS','MBS','FND') -- Filter for bedding components

        GROUP BY 
            b.StoreID,b.TransDate 
    ) b
),

/*
=============================================
Business Logic:
-   This function counts the number of distinct customer transactions for products in the 'MBS' (Mattress By Appointment) group.
-   It only considers "Written" sales (`SalesType = 'W'`).
-   A transaction is only counted if the total sales for that customer, on that day, for that product group, at that location, exceeds $1.
-   The final result is a summary of these customer counts grouped by location.
=============================================
*/
 CTE_CustomerCountMBS
AS

(
    SELECT	
        c.LocationID,
        c.DateID,
        -- Calculate the conversion rate as a percentage
        c.CustomerCount,
        t.TotalGuest,
        CAST(Round(100 * c.CustomerCount / NULLIF(t.TotalGuest, 0),2) as DECIMAL(6,2)) AS ConversionRateMBS
     FROM 
      (

    -- The outer SELECT counts the results from the inner subquery, grouped by location.
    SELECT	
        LocationID,
        DateID,
        COUNT(*) AS CustomerCount
    FROM (
        -- The inner subquery identifies each unique customer transaction for MBS products.
        SELECT	
            sl.StoreID as LocationID,
            sdttp.CustomerKey,
            sl.StoreBrandID,
            dd.DateID 
        FROM [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[FactSales] AS sdttp
			INNER JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimDate] AS dd ON dd.DateKey = sdttp.TransDateKey
            INNER JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimProduct] AS pm ON pm.ProductKey = sdttp.ProductKey
			INNER JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimStoreLocation] AS sl ON sl.LocationKey = sdttp.LocationKey
         WHERE 
            sdttp.SalesType = 'W'  -- Only written sales
            AND pm.GroupID = 'MBS'     -- Only Mattress By Appointment products
            AND sdttp.CustomerKey IS NOT NULL
            AND dd.DateID BETWEEN @FromDate AND @ToDate
       GROUP BY 
            sl.StoreID,
			sdttp.CustomerKey,
            sl.StoreBrandID,
            dd.DateID 
        HAVING	
            -- Only count transactions where the total sales for that day/customer/group is greater than $1.
            SUM(sdttp.Sales) > 1
    ) AS slsData
    GROUP BY 
        slsData.LocationID, DateID
       
) c
  INNER JOIN (
            -- Subquery to calculate the total number of guests (traffic)
            SELECT	
                dt.StoreID as LocationID,
                dt.TransDate AS DateID,
                SUM(dt.TrafficGuest) AS TotalGuest
            FROM [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[FactTraffic] AS dt
            WHERE  dt.TransDate BETWEEN @FromDate AND @ToDate
           GROUP BY 
                dt.StoreID, dt.TransDate
        ) t 
        ON t.LocationID = c.LocationID
          AND t.DateID= c.DateID

  
)

---- Return results
    SELECT	
        d.DateID, 
        d.LocationID,  
        s.WrittenSales,
        s.WrittenCharges,
        s.WrittenCharges_WChrg,
        s.PrimaryWrittenSales,
        s.PrimaryWrittenCost,
        s.BeddingSales,
        s.BeddingGMDollars,
        s.ProtectionSales,
        s.ProtectionGMDollars,
        s.ClearanceSales,
        s.ClearanceGMDollars,
        t.TrafficGuests, 
        c.OrdersCount, 
        u.RecordedUps,
        ROUND(c.OrdersCount / NULLIF(t.TrafficGuests, 0), 3) AS ConversionRate,  -- Round to 3 decimas
        f.FinanceFees,
        GMDollars = s.PrimaryWrittenSales - s.PrimaryWrittenCost,
        GM = (s.PrimaryWrittenSales - s.PrimaryWrittenCost) / NULLIF(s.PrimaryWrittenSales, 0),
        GMFF = (s.PrimaryWrittenSales - s.PrimaryWrittenCost - f.FinanceFees) / NULLIF(s.PrimaryWrittenSales, 0),
        s.DeliveredClearanceUnits,
        NetSalesMattress = s.BeddingSales, 
        NetUnitsMattress = s.BeddingUnits,
        NetSalesBoxSpringPowerBase = 0, 
        NetUnitsBoxSpringPowerBase = 0,
        m.ConversionRateMBS,
        m.CustomerCount,
        m.TotalGuest,
        Cast(Getdate() as date) as UpdatedDate

    FROM CTE_DateLocations d
    LEFT JOIN CTE_Sales s
        ON s.LocationID = d.LocationID and s.DateID = d.DateID
    Left JOIN CTE_Conversions c
        ON c.LocationID = d.LocationID and c.DateID = d.DateID    
    LEFT JOIN CTE_Ups u
        ON u.LocationID = d.LocationID and u.DateID = d.DateID
    LEFT JOIN CTE_Traffic t
        ON t.LocationID = d.LocationID and t.DateID = d.DateID   
    LEFT JOIN CTE_FinanceFees f
        ON f.LocationID = d.LocationID and f.DateID = d.DateID   
    LEFT JOIN CTE_BtaData_AUSP_Bedding a
        ON a.LocationID = d.LocationID and a.DateID = d.DateID   
    LEFT JOIN CTE_CustomerCountMBS m
       ON m.LocationID = d.LocationID and m.DateID = d.DateID