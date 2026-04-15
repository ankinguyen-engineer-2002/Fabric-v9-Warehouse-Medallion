-- Auto Generated (Do not modify) B7ED1D6456133AC978C9FF962B1AED0F5FC8D21C7E4A357028F5D471851285DA
CREATE VIEW [Retail_DW_Core_Wrk].[v_FactPPPSales]
AS
SELECT
	StoreID
    , TransDate
    , OrderID
    , PPPGroupID
	, SalesPersonID
    , SIGN(SUM(PPPOpp)) AS Opp
    , SIGN(SUM(PPPClose)) AS Closes
FROM [Retail_DW_Core].[FactOrderDetailTrans]
WHERE SalesType = 'W'
GROUP BY 
	StoreID
    , TransDate
    , OrderID
    , PPPGroupID
	, SalespersonID
HAVING SUM(PPPClose) <> 0
OR SUM(PPPOpp) <> 0;