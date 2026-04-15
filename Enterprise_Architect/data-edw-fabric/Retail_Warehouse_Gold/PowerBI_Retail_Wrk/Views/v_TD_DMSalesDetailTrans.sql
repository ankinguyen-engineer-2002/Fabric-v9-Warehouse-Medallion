-- Auto Generated (Do not modify) 90804C2BFCC290F536A5F0722B96F007445BA0B9716E67405059E792E26BB514
--select top 5 * from [Retail_DW_Wrk].[v_TD_DMSalesDetailTrans]
CREATE   VIEW [PowerBI_Retail_Wrk].[v_TD_DMSalesDetailTrans] AS

-- Use a series of Common Table Expressions (CTEs) to replace the temporary table and structure the logic.
WITH
-- CTE 1: Replicates the logic for the #shiplocation temporary table.
-- This stage gathers original and current shipping locations for relevant orders.
ShipLocation_Source AS (
    SELECT
        d.OrderID,
        d.ItemID,
        od.ShipLocationID AS OriShpLocation,
        od1.ShipLocationID AS ShiplocationFromOD
    FROM
        [Retail_DW_Core].[FactSales] AS d
    LEFT JOIN
        [Retail_DW_Core].FactSalesOrderHeader AS oh ON d.OrderID = oh.SourceOrderID
   LEFT JOIN
        [Retail_DW_Core].FactOrderDetail AS od ON LEFT(oh.OriginalInvoiceID, LEN(oh.OriginalInvoiceID) - 1)  = od.SourceOrderID 
        AND d.ItemID = od.LineNumber
    LEFT JOIN
        [Retail_DW_Core].FactOrderDetail AS od1 ON d.OrderID = od1.SourceOrderID AND d.ItemID  = od1.LineNumber 
    WHERE
        d.SalesType = 'D'
        --AND d.ItemCommCategory = '1'
        AND d.TransDateTime >= datefromparts(year(getdate())-1,1,1)
        AND  (d.ShipLocationID = '<No Value>' or d.ShipLocationID IN ('090', '101', '599', '600'))
    GROUP BY
        d.OrderID, d.ItemID, 
        od.ShipLocationID,
         od1.ShipLocationID
),

-- CTE 2: Replicates your Q1, calculating initial sales splits.
-- This stage aggregates sales data and categorizes it into DC and non-DC buckets.
Q1_Sales_Split AS (
    SELECT
        d.OrderID,
        CAST(d.TransDateTime AS DATE) AS TransDate,
        FORMAT(d.TransDateTime, 'MM-yyyy') AS MonthYear,
        d.ShipLocationID,
        sloc.OriShpLocation,
        sloc.ShiplocationFromOD,
        d.FRLocationID,
        lg.LocationGroupID,
        SUM(d.Units) AS DeliveredUnits,
        SUM(CASE WHEN d.SalesType = 'D' THEN d.Cost ELSE 0 END) AS DeliveredCost,
        SUM(CASE WHEN d.SalesType = 'W' THEN d.Cost ELSE 0 END) AS WrittenCost,
        CASE WHEN d.ShipLocationID IN ('401', '444', '902', '904', '906', '911', '912', '913', '915', '917', '919', '924', '929', '933', '939', '935', '954', '941', '943', '944', '945', '972', '981', '983', '921', '815', '814') THEN SUM(d.Sales) ELSE 0 END AS DCdeliveredsales,
        CASE WHEN d.ShipLocationID NOT IN ('401', '444', '902', '904', '906', '911', '912', '913', '915', '917', '919', '924', '929', '933', '939', '935', '954', '941', '943', '944', '945', '972', '981', '983', '921', '815', '814') THEN SUM(d.Sales) ELSE 0 END AS nonDCdeliveredsales
    FROM
        [Retail_DW_Core].[FactSales] AS d
    LEFT JOIN
        [Retail_DW_Core].DimStoreLocationGroup AS lg ON d.FRLocationID = lg.StoreID AND lg.LocationGroupID LIKE 'FD[0-9][0-9][0-9]'
    -- Join to the first CTE instead of the temporary table
    LEFT JOIN
        ShipLocation_Source AS sloc ON d.OrderID = sloc.OrderID AND d.ItemID = sloc.ItemID
    WHERE
        d.SalesType = 'D'
        --AND d.ItemCommCategory = 1
        AND d.TransDateTime >= datefromparts(year(getdate())-1,1,1)
        AND d.FRLocationID NOT IN ('090')
        AND d.ShipLocationID NOT IN ('996', '992', '998')
    GROUP BY
        d.OrderID, CAST(d.TransDateTime AS DATE), FORMAT(d.TransDateTime, 'MM-yyyy'), d.ShipLocationID, sloc.OriShpLocation, 
        sloc.ShiplocationFromOD, d.FRLocationID, lg.LocationGroupID
),

-- CTE 3: Replicates your Q2, calculating monthly totals using window functions.
Q2_Monthly_Totals AS (
    SELECT
        Q1.*,
        SUM(Q1.DCdeliveredsales) OVER (PARTITION BY Q1.MonthYear) AS TotalDCdeliveredsales,
        SUM(Q1.nonDCdeliveredsales) OVER (PARTITION BY Q1.MonthYear) AS TotalNonDCdeliveredsales,
        SUM(Q1.DCdeliveredsales + Q1.nonDCdeliveredsales) OVER (PARTITION BY Q1.MonthYear) AS TotalSalesForDate
    FROM
        Q1_Sales_Split AS Q1
),

-- CTE 4: Replicates your Q3, performing the primary allocation logic.
Q3_Allocation AS (
    SELECT
        Q2.*,
        (Q2.DCdeliveredsales * COALESCE(NULLIF(Q2.TotalNonDCdeliveredsales / NULLIF(Q2.TotalDCdeliveredsales, 0), 0), 0)) + Q2.DCdeliveredsales AS Deliveredsales
    FROM
        Q2_Monthly_Totals AS Q2
),

-- CTE 5: Replicates your Q4, calculating the final totals and differences.
Q4_Final_Calc AS (
    SELECT
        Q3.*,
        SUM(Q3.Deliveredsales) OVER (PARTITION BY Q3.MonthYear) AS TotalDeliveredsales,
        Q3.TotalSalesForDate - SUM(Q3.Deliveredsales) OVER (PARTITION BY Q3.MonthYear) AS Differencesales
    FROM
        Q3_Allocation AS Q3
)

-- Final SELECT statement to present the results from the last CTE.
SELECT
    *
FROM
    Q4_Final_Calc;