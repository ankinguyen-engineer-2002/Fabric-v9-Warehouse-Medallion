CREATE VIEW [Retail_DW_Core_Wrk].[v_FactFinancialBudget]
AS
SELECT 
    [fbf_storetype] as StoreType,
	[fbf_accountNum] as AccountNumber,
	[fbf_database] as [Database],
	[fbf_storeID] as StoreID,
	[fbf_unit] as Unit,
	[fbf_storeLocation] as StoreLocation,
	[fbf_year] as BudgetYear,
	[fbf_period] as Period,
	[fbf_date] as BudgetDate,
	[fbf_budget_wrt_cogs] as BudgetWrittenCogs,
	[fbf_budget_wrt_sales] as BudgetWrittenSales,
	[fbf_derivedups] as Derivedups,
	[fbf_closeratio] as CloseRatio,
	[fbf_avg_tkt] as AverageTicket,
	[fbf_spg] as SalesPerGuest,
	[fbf_budget_inv_cogs] as BudgetInvoicedCogs,
	[fbf_budget_inv_sales] as BudgetInvoicedSales,
	[fbf_budget_deliveryincome_rate] as BudgetDeliveryIncomeRate,
	[fbf_budget_deliveryincome_wrt_sales] as BudgetDeliveryIncomeWrittenSales,
	[fbf_budget_deliveryincome_inv_sales] as BudgetDeliveryIncomeInvoicedSales,
	[fbf_budget_finance_fees_rate] as BudgetFinanceFeesRate,
	[fbf_budget_finance_fees_wrt_sales] as BudgetFinanceFeesWrittenSales,
	[fbf_budget_finance_fees_inv_sales] as BudgetFinanceFeesInvoicedSales,
	[LastUpdateDate] as LastUpdateDate
FROM [$(Source_Data)].[Retail_Miniapps].[FinancialBudgetForecast];