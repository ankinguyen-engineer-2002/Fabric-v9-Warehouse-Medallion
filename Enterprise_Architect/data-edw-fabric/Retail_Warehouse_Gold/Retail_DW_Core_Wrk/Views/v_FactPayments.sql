-- Auto Generated (Do not modify) 17E445DAA3EE76DC7DBE66E4A70699682BE32B77287C85B24DBF9B56EA797C5C
CREATE VIEW [Retail_DW_Core_Wrk].[v_FactPayments]
AS 
SELECT
	toh.StoreBrandID
	, toh.SourceOrderID
	, toh.CustomerID
	, toh.StoreID
	, toh.OrderDate
	, dm.DateID AS TransDate
	, sp.SalesPersonID
	, sp.SalesPersonName
	, soh.SalesDataTypeKey
	, CASE WHEN soh.SalesDataTypeKey = 5 THEN soh.TransValue
	ELSE 0 END - CASE WHEN soh.SalesDataTypeKey = 2 THEN soh.TransValue
	ELSE 0 END - CASE WHEN soh.SalesDataTypeKey = 9 THEN soh.TransValue
	ELSE 0 END AS Sales
	, CASE WHEN soh.SalesDataTypeKey = 2 THEN soh.TransValue ELSE 0
	END AS Charges
	, CASE WHEN soh.SalesDataTypeKey = 9 THEN soh.TransValue ELSE 0
	END AS Taxes
	, CASE WHEN soh.SalesDataTypeKey = 5 THEN soh.TransValue ELSE 0
	END AS Payments
	, CASE WHEN soh.SalesDataTypeKey = 5 THEN soh.TransValue * pt.IsFinanced * pt.FinanceUseFee
	ELSE 0 END AS FinanceFees
	, pt.PaymentTypeGroupID
	, pt.IsFinanced
	, pt.FinanceUseFee
	, CASE WHEN soh.TransKey = 'BAL' THEN soh.TransValue ELSE 0
	END AS Balance
	, pt.PaymentTypeID
	, toh.IsFinanced AS OrderIsFinanced
	, CAST(soh.DateCreated AS DATETIME2(3)) AS DateCreated
FROM [Retail_DW_Core].[FactSalesOrderTrans] AS soh 
LEFT JOIN [Retail_DW_Core].[FactSalesOrderHeader] AS toh
ON toh.OrderKey = soh.OrderKey
LEFT JOIN [Retail_DW_Core].DimDate AS dm 
ON dm.DateKey = soh.TransDateKey
LEFT JOIN [Retail_DW_Core].[DimSalesPerson] AS sp 
ON sp.SalesPersonID = soh.SalesPersonID
LEFT OUTER JOIN [Retail_DW_Core].[DimPaymentType] AS pt 
ON soh.TransKey = pt.PaymentTypeID
WHERE soh.SalesDataTypeKey IN (2, 5, 9)
AND DateID >= '2023-01-01';