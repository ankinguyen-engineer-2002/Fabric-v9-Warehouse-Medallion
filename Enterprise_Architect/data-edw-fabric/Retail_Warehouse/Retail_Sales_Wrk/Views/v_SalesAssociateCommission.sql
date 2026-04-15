-- Auto Generated (Do not modify) 659436FC76D491E6D02FE79B90D889D3B860637F4BB9A6EB337494582F0C6FA4
CREATE VIEW [Retail_Sales_Wrk].[v_SalesAssociateCommission]
AS
SELECT 
	CASE WHEN oic.OrderID NOT LIKE '%[A-Z][A-Z][0-9]%' THEN 'STORIS_DSG'
	WHEN oic.OrderID LIKE '%[A-Z][A-Z][0-9]%' THEN 'HOMES_CORPORATE'
	ELSE 'Unknown' END AS SourceSystem
	, oic.SalesPersonID
	, oic.OrderID AS SourceOrderID
	, oic.ProductID AS SKU
	, oic.ItemID AS LineNumber
	, oic.PosID
	, oic.ItemCommCategory
	, 'Written' AS CommissionStatus
	, oic.SplitPct AS PercentCommission
	, oic.DateChanged
	, oic.DateCreated
	, oic.RecStatus
FROM [$(Source_Data)].[Retail_Corporate].[OrderItem_CommissionInfo] oic
WHERE oic.OrderID IN
(
	SELECT DataSetKeyValue
	FROM [MasterData_Retail_Ent].[DataSetKey]
)

UNION ALL

SELECT 
	CASE WHEN iic.OrderID NOT LIKE '%[A-Z][A-Z][0-9]%' THEN 'STORIS_DSG'
	WHEN iic.OrderID LIKE '%[A-Z][A-Z][0-9]%' THEN 'HOMES_CORPORATE'
	ELSE 'Unknown' END AS SourceSystem
	, iic.SalesPersonID
	, iic.OrderID AS SourceOrderID
	, iic.ProductID AS SKU
	, iic.ItemID AS LineNumber
	, iic.PosID
	, iic.ItemCommCategory
	, 'Invoiced' AS CommissionStatus
	, iic.SplitPct AS PercentCommission
	, iic.DateChanged
	, iic.DateCreated
	, iic.RecStatus
FROM [$(Source_Data)].[Retail_Corporate].[Invoice] i
INNER JOIN [$(Source_Data)].[Retail_Corporate].[InvoiceItem_CommissionInfo] iic
ON i.OrderID = iic.OrderID
WHERE i.Base_OrderID IN
(
	SELECT DataSetKeyValue
	FROM [MasterData_Retail_Ent].[DataSetKey]
);