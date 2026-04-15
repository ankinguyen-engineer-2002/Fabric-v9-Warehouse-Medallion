-- Auto Generated (Do not modify) C9839FE57B6152593407502FDABBFD173C48841F5F159548B34CEBE540FEC1AC
CREATE   VIEW [Retail_DW_Core_Wrk].[v_FinanceSalesAttributionorders] AS

WITH 
-- 1. CLEAN PAYMENTS (Fixes Amount Inflation)
-- Sum payments by OrderID first to handle line-item duplication
CleanPayments AS (
    SELECT 
        OrderID,
        CustomerID,
        SUM(Payments) AS FinancedAmount,
        MAX(PaymentTypeID) AS FinPaymentTypeID
    FROM [Retail_DW_Core].[FactPayments]
    GROUP BY OrderID, CustomerID
),

-- 2. UNIQUE SALES & DIMENSIONS (Fixes Record Count Inflation)
-- We join Dimensions HERE and take MAX() to force 1 row per Order
UniqueSales AS (
    SELECT 
        foh.SourceOrderID AS OrderID,
        foh.CustomerID,
        foh.OrderDate,
        -- Sales Amounts
        MAX(foh.TotalSales + foh.TotalTaxes + foh.TotalCharges) AS TotalSales,
        MAX(ISNULL(cp.FinancedAmount, 0)) AS FinancedAmount,
        -- Dimensions (Flattened)
        MAX(cp.FinPaymentTypeID) AS FinPaymentTypeID,
        MAX(foh.SFMCFulfillmentStatus) AS SFMCFulfillmentStatus,
        MAX(foh.TransCodeID) AS TransCodeID,
        MAX(dpt.FinanceUseFee) AS FinanceUseFee,
        MAX(tcm.Description) AS OrderType  
    FROM [Retail_DW_Core].[FactSalesOrderHeader] foh
    LEFT JOIN CleanPayments cp 
        ON foh.SourceOrderID = cp.OrderID 
        AND foh.CustomerID = cp.CustomerID
    -- Join Dimensions HERE and aggregate
    LEFT JOIN [Retail_DW_Core].[DimPaymentType] dpt 
        ON cp.FinPaymentTypeID = dpt.PaymentTypeID
    LEFT JOIN [Retail_DW_Core].[DimTransCodeMap] tcm 
        ON foh.TransCodeID = tcm.TransCodeID
    WHERE foh.OrderDate > '2024-07-01'
    GROUP BY foh.SourceOrderID, foh.CustomerID, foh.OrderDate
    HAVING MAX(foh.TotalSales + foh.TotalTaxes + foh.TotalCharges) > 0
),

-- 3. CREDIT WITH ORDER MATCHING (Matches DSG Red Logic)
-- ✅ FIXED: Removed ROW_NUMBER, calculate OrderID/OrderID2 here
CreditWithOrders AS (
    SELECT 
        CAST(fcr.RequestDateTime AS DATE) AS RequestDate,
        fcr.CustomerID,
        dcm.EmailAddress,
        fcr.FinanceProviderID,
        fp.Name AS ApprovedByLendor,
        fcr.SalesPersonID,
        fcr.StoreID,
        fcr.AmountApproved,
        (SELECT MIN(r.RollUp)
         FROM [Retail_DW_Core].[DimRollUps] r
         WHERE r.RollUpFilter = 'Region'
           AND r.StoreID = fcr.StoreID) AS Region,
        (SELECT MIN(r.RollUp)
         FROM [Retail_DW_Core].[DimRollUps] r
         WHERE r.RollUpFilter = 'Division'
           AND r.StoreID = fcr.StoreID) AS Division,
        -- Find first order within 30 days
        (SELECT MIN(s.OrderID) 
         FROM UniqueSales s 
         WHERE s.CustomerID = fcr.CustomerID 
           AND s.OrderDate BETWEEN CAST(fcr.RequestDateTime AS DATE) AND DATEADD(DAY, 30, fcr.RequestDateTime)
           AND s.TotalSales <> 0) AS OrderID,
        -- Find second order (2-30 days later)
        (SELECT MAX(s.OrderID) 
         FROM UniqueSales s 
         WHERE s.CustomerID = fcr.CustomerID 
           AND s.OrderDate BETWEEN DATEADD(DAY, 2, CAST(fcr.RequestDateTime AS DATE)) AND DATEADD(DAY, 30, fcr.RequestDateTime)
           AND s.TotalSales <> 0) AS OrderID2
    FROM [Retail_DW_Core].[FactCreditReview] fcr
    INNER JOIN [Retail_DW_Core].[FinanceProvider] fp 
        ON fcr.FinanceProviderID = fp.FinanceProviderID
    INNER JOIN [Retail_DW_Core].[DimCustomerMaster] dcm 
        ON dcm.CustomerID = fcr.CustomerID
    WHERE fcr.RequestDateTime >= '2024-07-01'
      AND fcr.CreditRequestStatusCodeID = 7
      --AND fcr.RecStatus <> 'D'
),

-- 4. AGGREGATE CREDIT (Matches DSG Red GROUP BY)
-- ✅ FIXED: Group by the same columns as DSG Red
UniqueCredit AS (
    SELECT 
        RequestDate,
        CustomerID,
        EmailAddress,
        StoreID,
        OrderID,
        OrderID2,
        Region,
        Division,
        MIN(SalesPersonID) AS SalesPersonID,
        MIN(FinanceProviderID) AS FinanceProviderID,
        MIN(ApprovedByLendor) AS ApprovedByLendor,
        SUM(AmountApproved) AS AmountApproved
    FROM CreditWithOrders
    GROUP BY 
        RequestDate,
        CustomerID,
        EmailAddress,
        StoreID,
        OrderID,
        OrderID2,
        Region,
        Division
),

-- 5. COMBINE CREDIT WITH ORDER DETAILS
FinalSet AS (
    SELECT 
        uc.RequestDate,
        uc.CustomerID,
        uc.EmailAddress,
        uc.ApprovedByLendor,
        uc.SalesPersonID,
        uc.StoreID,
        uc.AmountApproved,
        uc.Region,
        uc.Division,
        uc.OrderID,
        uc.OrderID2,
        
        -- Get first order details
        s1.OrderDate AS FirstOrderDate,
        s1.FinancedAmount AS FirstOrderFinanced,
        s1.FinPaymentTypeID,
        s1.SFMCFulfillmentStatus,
        s1.FinanceUseFee,
        s1.TotalSales AS FirstOrderTotalSales,
        s1.OrderType,
        
        -- Get second order details
        s2.OrderDate AS SecondOrderDate,
        s2.FinancedAmount AS SecondOrderFinanced,
        s2.TotalSales AS SecondOrderTotalSales
           
    FROM UniqueCredit uc
    -- First order
    LEFT JOIN UniqueSales s1 ON s1.OrderID = uc.OrderID AND s1.CustomerID = uc.CustomerID
    -- Second order  
    LEFT JOIN UniqueSales s2 ON s2.OrderID = uc.OrderID2 AND s2.CustomerID = uc.CustomerID
),

-- 6. SALES AGGREGATES (for TotSalesOrder and TotSalesCustomerDate)
OrderSalesSummary AS (
    SELECT 
        LEFT(OrderID, 10) as BaseOrder, 
        SUM(TotalSales) as TotalSales
    FROM UniqueSales 
    GROUP BY LEFT(OrderID, 10)
),

CustomerDateSalesSummary AS (
    SELECT 
        CustomerID, 
        OrderDate, 
        SUM(TotalSales) as TotalSales
    FROM UniqueSales
    GROUP BY CustomerID, OrderDate
)

-- 7. FINAL OUTPUT - REPLICATE DSG RED LOGIC EXACTLY
SELECT 
    -- BuySameDay: 'Yes' if first order is same day or next day, 'No' otherwise
    CASE 
        WHEN f.FirstOrderDate BETWEEN f.RequestDate AND DATEADD(DAY, 1, f.RequestDate) THEN 'Yes' 
        ELSE 'No' 
    END AS BuySameDay,
    
    f.AmountApproved,
    f.CustomerID,
    f.EmailAddress,
    f.ApprovedByLendor,
    f.RequestDate,
    f.SalesPersonID,
    f.StoreID,
    
    -- OrderID: If same-day purchase, show second order (or first if no second), else show first order
    CASE 
        WHEN f.FirstOrderDate BETWEEN f.RequestDate AND DATEADD(DAY, 1, f.RequestDate) 
        THEN COALESCE(f.OrderID2, f.OrderID)
        ELSE f.OrderID 
    END AS OrderID,
    
    -- OrderDate: Corresponding date for the OrderID shown above
    CASE 
        WHEN f.FirstOrderDate BETWEEN f.RequestDate AND DATEADD(DAY, 1, f.RequestDate) 
        THEN COALESCE(f.SecondOrderDate, f.FirstOrderDate)
        ELSE f.FirstOrderDate 
    END AS OrderDate,
    
    -- BaseOrder: First 10 chars of OrderID
    LEFT(CASE 
        WHEN f.FirstOrderDate BETWEEN f.RequestDate AND DATEADD(DAY, 1, f.RequestDate) 
        THEN COALESCE(f.OrderID2, f.OrderID)
        ELSE f.OrderID 
    END, 10) AS BaseOrder,
    
    -- FinancedAmount: Amount for the order being shown
    CASE 
        WHEN f.FirstOrderDate BETWEEN f.RequestDate AND DATEADD(DAY, 1, f.RequestDate) 
        THEN COALESCE(f.SecondOrderFinanced, f.FirstOrderFinanced, 0)
        ELSE COALESCE(f.FirstOrderFinanced, 0)
    END AS FinancedAmount,
    
    f.FinPaymentTypeID,
    f.SFMCFulfillmentStatus,
    f.FinanceUseFee,
    
    -- TotalSales: Sales for the order being shown
    CASE 
        WHEN f.FirstOrderDate BETWEEN f.RequestDate AND DATEADD(DAY, 1, f.RequestDate) 
        THEN COALESCE(f.SecondOrderTotalSales, f.FirstOrderTotalSales)
        ELSE f.FirstOrderTotalSales
    END AS TotalSales,
    
    f.OrderType,
    f.Region,
    f.Division,
    
    -- OrderSameDay: First order ID if it was same-day, else NULL
    CASE 
        WHEN f.FirstOrderDate BETWEEN f.RequestDate AND DATEADD(DAY, 1, f.RequestDate) 
        THEN f.OrderID 
        ELSE NULL 
    END AS OrderSameDay,
    
    -- FinancedSameDay: Financed amount of first order if same-day, else 0
    CASE 
        WHEN f.FirstOrderDate BETWEEN f.RequestDate AND DATEADD(DAY, 1, f.RequestDate) 
        THEN COALESCE(f.FirstOrderFinanced, 0)
        ELSE 0 
    END AS FinancedSameDay,
    
    -- TotSalesOrder: Categorize total sales by base order
    CASE 
        WHEN oss.TotalSales IS NULL THEN NULL
        WHEN oss.TotalSales = 0 THEN 'Order - No Sales'
        WHEN oss.TotalSales < 0 THEN 'Order - Negative Sales'
        WHEN oss.TotalSales > 0 THEN 'Order - Positive Sales'
    END AS TotSalesOrder,
    
    -- TotSalesCustomerDate: Categorize total sales by customer and date
    CASE 
        WHEN cds.TotalSales IS NULL THEN NULL
        WHEN cds.TotalSales = 0 THEN 'Order - No Sales'
        WHEN cds.TotalSales < 0 THEN 'Order - Negative Sales'
        WHEN cds.TotalSales > 0 THEN 'Order - Positive Sales'
    END AS TotSalesCustomerDate,
    
    -- Sends: Check if any Finance_OTB emails were sent within 30 days
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM [Retail_DW_Core].[FinanceSalesAttributionSends] fs 
            WHERE fs.EmailAddress = f.EmailAddress 
              AND fs.EventDate BETWEEN f.RequestDate AND DATEADD(DAY, 30, f.RequestDate) 
              AND fs.EmailName LIKE 'Finance_OTB%'
        ) THEN 'Y' 
        ELSE 'N' 
    END AS Sends,
    
    -- SendForOTB: Check if Finance_OTB emails were sent between request and order date
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM [Retail_DW_Core].[FinanceSalesAttributionSends] fs 
            WHERE fs.EmailAddress = f.EmailAddress 
              AND fs.EventDate BETWEEN f.RequestDate AND COALESCE(f.FirstOrderDate, DATEADD(DAY, 30, f.RequestDate))
              AND fs.EmailName LIKE 'Finance_OTB%'
        ) THEN 'Y' 
        ELSE 'N' 
    END AS SendForOTB,
    
    -- Classification: Recheck vs Approved No Buys
    CASE 
        -- If bought same day AND remaining OTB >= 1000, it's a Recheck
        WHEN (CASE WHEN f.FirstOrderDate BETWEEN f.RequestDate AND DATEADD(DAY, 1, f.RequestDate) THEN 'Yes' ELSE 'No' END) = 'Yes' 
             AND (f.AmountApproved - COALESCE(f.FirstOrderFinanced, 0)) >= 1000 
        THEN 'Recheck'
        -- If did NOT buy same day, it's Approved No Buys
        WHEN (CASE WHEN f.FirstOrderDate BETWEEN f.RequestDate AND DATEADD(DAY, 1, f.RequestDate) THEN 'Yes' ELSE 'No' END) = 'No' 
        THEN 'Approved No Buys'
        -- Otherwise, OTB is less than 1000
        ELSE 'OTB Less than 1000'
    END AS [Recheck or Approve No Buy - 1000]

FROM FinalSet f
LEFT JOIN OrderSalesSummary oss 
    ON LEFT(CASE 
            WHEN f.FirstOrderDate BETWEEN f.RequestDate AND DATEADD(DAY, 1, f.RequestDate) 
            THEN COALESCE(f.OrderID2, f.OrderID)
            ELSE f.OrderID 
        END, 10) = oss.BaseOrder
LEFT JOIN CustomerDateSalesSummary cds 
    ON f.CustomerID = cds.CustomerID 
    AND (CASE 
            WHEN f.FirstOrderDate BETWEEN f.RequestDate AND DATEADD(DAY, 1, f.RequestDate) 
            THEN COALESCE(f.SecondOrderDate, f.FirstOrderDate)
            ELSE f.FirstOrderDate 
        END) = cds.OrderDate;