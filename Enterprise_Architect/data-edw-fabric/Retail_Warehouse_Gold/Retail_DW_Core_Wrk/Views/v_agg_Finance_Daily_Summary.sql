CREATE VIEW [Retail_DW_Core_Wrk].[v_agg_Finance_Daily_Summary]
AS
WITH
-- 1. Aggregate Sales data
Sales_Agg AS (
    SELECT
        CAST(s.TransDateTime AS DATE) AS AggDate,
        l.StoreID,
        r.SalesPersonID,
        SUM(CASE WHEN s.SalesType = 'W' THEN s.Sales ELSE 0 END) AS WrittenSales,
        SUM(CASE WHEN oh.IsFinanced = 1 AND s.SalesType = 'W' THEN s.Sales ELSE 0 END) AS FinancedWrittenSales,
        SUM(CASE WHEN s.SalesType = 'W' THEN s.Cost ELSE 0 END) AS WrittenCost,
        COUNT(DISTINCT s.OrderID) AS WrittenOrderCount
    FROM Retail_DW_Core.FactSales AS s
    LEFT JOIN Retail_DW_Core.FactOrderHeader AS oh ON s.OrderID = oh.SourceOrderID
    LEFT JOIN Retail_DW_Core.DimStoreLocation AS l ON s.LocationKey = l.LocationKey
    LEFT JOIN Retail_DW_Core.DimSalesPerson AS r ON s.SalesPersonKey = r.SalesPersonKey
    WHERE CAST(s.TransDateTime AS DATE) >= '2024-01-01' -- Date Filter Added
    GROUP BY
        CAST(s.TransDateTime AS DATE),
        l.StoreID,
        r.SalesPersonID
        
),

-- 2. Aggregate Closes data
Closes_Agg AS (
    SELECT
        CAST(CAST(c.TransDateKey AS VARCHAR(8)) AS DATE) AS AggDate,
        l.StoreID,
        r.SalesPersonID,
        SUM(c.SuperOrderClose) AS TotalSUOrders,
        SUM(CASE WHEN oh.IsFinanced = 1 THEN c.SuperOrderClose ELSE 0 END) AS FinancedSuperOrders
    FROM Retail_DW_Core.FactCloses AS c
    LEFT JOIN Retail_DW_Core.FactOrderHeader AS oh ON c.SuperOrderID = oh.SuperOrderID
    LEFT JOIN Retail_DW_Core.DimStoreLocation AS l ON c.LocationKey = l.LocationKey
    LEFT JOIN Retail_DW_Core.DimSalesPerson AS r ON c.SalesPersonKey = r.SalesPersonKey
    WHERE CAST(CAST(c.TransDateKey AS VARCHAR(8)) AS DATE) >= '2024-01-01' -- Date Filter Added
    GROUP BY
        CAST(CAST(c.TransDateKey AS VARCHAR(8)) AS DATE),
        l.StoreID,
        r.SalesPersonID
),

-- 3. Aggregate Payments data
Payments_Agg AS (
    SELECT
        CAST(p.TransDate AS DATE) AS AggDate,
        p.StoreID,
        p.SalespersonID AS SalesPersonID,
        SUM(p.Payments) AS TotalPayments,
        SUM(p.Charges) AS TotalCharges,
        SUM(p.Taxes) AS TotalTaxes,
        SUM(p.FinanceFees) AS TotalFinanceFees,
        SUM(CASE WHEN oh.IsFinanced = 1 THEN p.Payments ELSE 0 END) AS FinancedPayments,
        SUM(CASE WHEN pt.PaymentTypeGroupID = 'DP' THEN p.Payments ELSE 0 END) AS DownPayments
    FROM Retail_DW_Core.FactPayments AS p
    LEFT JOIN Retail_DW_Core.FactOrderHeader AS oh ON p.OrderID = oh.SourceOrderID
    LEFT JOIN Retail_DW_Core.DimPaymentType AS pt ON p.PaymentTypeID = pt.PaymentTypeID
    WHERE CAST(p.TransDate AS DATE) >= '2024-01-01' -- Date Filter Added
    GROUP BY
        CAST(p.TransDate AS DATE),
        p.StoreID,
        p.SalespersonID
),

-- 4. Aggregate Credit Review data
Credit_Agg AS (
    SELECT
        CAST(CAST(cr.TransDateKey AS VARCHAR(8)) AS DATE) AS AggDate,
        cr.StoreID,
        cr.SalesPersonID,
        SUM(cr.AppCount) AS TotalApps,
        SUM(CASE WHEN cr.AdjustedStatusCodeID = 7 THEN cr.AppCount ELSE 0 END) AS ApprovedApps
    FROM Retail_DW_Core.FactCreditReview AS cr
    WHERE CAST(CAST(cr.TransDateKey AS VARCHAR(8)) AS DATE) >= '2024-01-01' -- Date Filter Added
    GROUP BY
        CAST(CAST(cr.TransDateKey AS VARCHAR(8)) AS DATE),
        cr.StoreID,
        cr.SalesPersonID
),

-- 5. Aggregate Traffic data
Traffic_Agg AS (
    SELECT
        CAST(t.TransDate AS DATE) AS AggDate,
        t.StoreID,
        SUM(t.TrafficGuest) AS TotalTraffic
    FROM Retail_DW_Core.FactTraffic AS t
    WHERE CAST(t.TransDate AS DATE) >= '2024-01-01' -- Date Filter Added
    GROUP BY
        CAST(t.TransDate AS DATE),
        t.StoreID
),

-- 6. Aggregate RSA Daily Stats
RSA_Stats_Agg AS (
    SELECT
        CAST(rs.TransDate AS DATE) AS AggDate,
        rs.StoreID,
        rs.SalesPersonID,
        SUM(rs.RecordedUps) AS RecordedUps
    FROM Retail_DW_Core.FactRSADailyStats AS rs
    WHERE CAST(rs.TransDate AS DATE) >= '2024-01-01' -- Date Filter Added
    GROUP BY
        CAST(rs.TransDate AS DATE),
        rs.StoreID,
        rs.SalesPersonID
),

-- 7. Create a comprehensive scaffold of all unique combinations
ActivityScaffold AS (
    SELECT AggDate, StoreID, SalesPersonID FROM Sales_Agg
    UNION
    SELECT AggDate, StoreID, SalesPersonID FROM Closes_Agg
    UNION
    SELECT AggDate, StoreID, SalesPersonID FROM Payments_Agg
    UNION
    SELECT AggDate, StoreID, SalesPersonID FROM Credit_Agg
    UNION
    SELECT AggDate, StoreID, SalesPersonID FROM RSA_Stats_Agg
)

-- 8. Final Join to create the wide aggregated view
SELECT
    s.AggDate,
    s.StoreID,
    s.SalesPersonID,
    COALESCE(sa.WrittenSales, 0) AS WrittenSales,
    COALESCE(sa.FinancedWrittenSales, 0) AS FinancedWrittenSales,
    COALESCE(sa.WrittenCost, 0) AS WrittenCost,
    COALESCE(sa.WrittenOrderCount, 0) AS WrittenOrderCount,
    COALESCE(ca.TotalSUOrders, 0) AS TotalSUOrders,
    COALESCE(ca.FinancedSuperOrders, 0) AS FinancedSuperOrders,
    COALESCE(pa.TotalPayments, 0) AS TotalPayments,
    COALESCE(pa.TotalCharges, 0) AS TotalCharges,
    COALESCE(pa.TotalTaxes, 0) AS TotalTaxes,
    COALESCE(pa.TotalFinanceFees, 0) AS TotalFinanceFees,
    COALESCE(pa.FinancedPayments, 0) AS FinancedPayments,
    COALESCE(pa.DownPayments, 0) AS DownPayments,
    COALESCE(cra.TotalApps, 0) AS TotalApps,
    COALESCE(cra.ApprovedApps, 0) AS ApprovedApps,
    COALESCE(ta.TotalTraffic, 0) AS TotalTraffic,
    COALESCE(rsa.RecordedUps, 0) AS RecordedUps
FROM
    ActivityScaffold s
LEFT JOIN Sales_Agg sa
    ON s.AggDate = sa.AggDate AND s.StoreID = sa.StoreID AND s.SalesPersonID = sa.SalesPersonID
LEFT JOIN Closes_Agg ca
    ON s.AggDate = ca.AggDate AND s.StoreID = ca.StoreID AND s.SalesPersonID = ca.SalesPersonID
LEFT JOIN Payments_Agg pa
    ON s.AggDate = pa.AggDate AND s.StoreID = pa.StoreID AND s.SalesPersonID = pa.SalesPersonID
LEFT JOIN Credit_Agg cra
    ON s.AggDate = cra.AggDate AND s.StoreID = cra.StoreID AND s.SalesPersonID = cra.SalesPersonID
LEFT JOIN Traffic_Agg ta
    ON s.AggDate = ta.AggDate AND s.StoreID = ta.StoreID
LEFT JOIN RSA_Stats_Agg rsa
    ON s.AggDate = rsa.AggDate AND s.StoreID = rsa.StoreID AND s.SalesPersonID = rsa.SalesPersonID;
GO

