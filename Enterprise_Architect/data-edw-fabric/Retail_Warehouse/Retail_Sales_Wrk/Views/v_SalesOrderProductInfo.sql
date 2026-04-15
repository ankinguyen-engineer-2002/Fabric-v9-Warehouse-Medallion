-- Auto Generated (Do not modify) 5A0EA0DB771521830F8FD6235DD640A5BFC9F68B04840CB9D5D6619EED02982D
CREATE VIEW [Retail_Sales_Wrk].[v_SalesOrderProductInfo]
AS
SELECT
	CASE WHEN oip.OrderID NOT LIKE '%[A-Z][A-Z][0-9]%' THEN 'STORIS_DSG'
	WHEN oip.OrderID LIKE '%[A-Z][A-Z][0-9]%' THEN 'HOMES_CORPORATE'
	ELSE 'Unknown' END AS SourceSystem
	, oip.OrderID AS SourceOrderID
	, 'Written' AS InfoStatus
	, oip.ProductID AS SKU
	, oip.ItemID AS LineNumber
	, oip.PieceID
	, oip.ReasonCodeID
	, oip.SerialNbr AS SerialNumber
	, oip.TotCost AS TotalCost
	, oip.DateChanged
	, oip.DateCreated
	, oip.RecStatus
FROM [$(Source_Data)].[Retail_Corporate].[OrderItem_ProductInfo] oip
WHERE oip.OrderID IN
(
	SELECT DataSetKeyValue
	FROM [MasterData_Retail_Ent].[DataSetKey]
)

UNION ALL

SELECT
	CASE WHEN iip.OrderID NOT LIKE '%[A-Z][A-Z][0-9]%' THEN 'STORIS_DSG'
	WHEN iip.OrderID LIKE '%[A-Z][A-Z][0-9]%' THEN 'HOMES_CORPORATE'
	ELSE 'Unknown' END AS SourceSystem
	, iip.OrderID AS SourceOrderID
	, 'Invoiced' AS InfoStatus
	, iip.ProductID AS SKU
	, iip.ItemID AS LineNumber
	, iip.PieceID
	, iip.ReasonCodeID
	, iip.SerialNbr AS SerialNumber
	, iip.TotCost AS TotalCost
	, iip.DateChanged
	, iip.DateCreated
	, iip.RecStatus
FROM [$(Source_Data)].[Retail_Corporate].[Invoice] i
INNER JOIN [$(Source_Data)].[Retail_Corporate].[InvoiceItem_ProductInfo] iip
ON iip.OrderID = i.OrderID
WHERE i.Base_OrderID IN
(
	SELECT DataSetKeyValue
	FROM [MasterData_Retail_Ent].[DataSetKey]
);