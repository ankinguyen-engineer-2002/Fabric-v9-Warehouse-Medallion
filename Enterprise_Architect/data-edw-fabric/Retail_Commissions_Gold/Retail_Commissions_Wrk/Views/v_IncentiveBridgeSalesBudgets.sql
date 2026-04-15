Create View [Retail_Commissions_Wrk].v_IncentiveBridgeSalesBudgets
as
SELECT 
    b.StoreID,
    b.StoreLocation,
    d.FiscalYear,
    d.FiscalMonth,
    d.FiscalMonthName,
    d.FiscalMonthYear,
    -- Aggregated Budget Metrics
    SUM(b.BudgetWrittenCogs) AS BudgetWrittenCogs,
    SUM(b.BudgetWrittenSales) AS BudgetWrittenSales,
    SUM(b.BudgetInvoicedCogs) AS BudgetInvoicedCogs,
    SUM(b.BudgetInvoicedSales) AS BudgetInvoicedSales,
    SUM(b.BudgetDeliveryIncomeWrittenSales) AS BudgetDeliveryIncomeWrittenSales,
    SUM(b.BudgetDeliveryIncomeInvoicedSales) AS BudgetDeliveryIncomeInvoicedSales,
    SUM(b.BudgetFinanceFeesWrittenSales) AS BudgetFinanceFeesWrittenSales,
    SUM(b.BudgetFinanceFeesInvoicedSales) AS BudgetFinanceFeesInvoicedSales,
    SUM(b.Derivedups) AS DerivedUps,
    SUM(b.CloseRatio * b.Derivedups) / NULLIF(SUM(b.Derivedups), 0) AS CloseRatio,  -- Weighted Close Ratio
    SUM(b.BudgetWrittenSales) / NULLIF(SUM(b.Derivedups), 0) AS SalesPerGuest, --Sales Per Guest
    SUM(b.CloseRatio * b.Derivedups) AS SuperOrderCount,  -- Super Order Count = Close Ratio × Derived Ups
    SUM(b.BudgetWrittenSales) / NULLIF(SUM(b.CloseRatio * b.Derivedups), 0) AS AverageTicket, -- Average Ticket = Budget Written Sales / Orders
    SUM(b.BudgetDeliveryIncomeWrittenSales) / NULLIF(SUM(b.BudgetWrittenSales), 0) AS BudgetDeliveryIncomeRate,
    SUM(b.BudgetFinanceFeesWrittenSales) / NULLIF(SUM(b.BudgetWrittenSales), 0) AS BudgetFinanceFeesRate
FROM [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[FactFinancialBudget] b
LEFT JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimDate] d
    ON b.BudgetDate = d.DateID
GROUP BY 
    b.StoreID,
    b.StoreLocation,
    d.FiscalYear,
    d.FiscalMonth,
    d.FiscalMonthName,
    d.FiscalMonthYear

 