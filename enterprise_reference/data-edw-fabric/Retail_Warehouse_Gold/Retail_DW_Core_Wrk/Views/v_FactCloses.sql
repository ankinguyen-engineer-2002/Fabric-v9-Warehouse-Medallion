-- Auto Generated (Do not modify) C8D6E17E8F2F66A4119A1E4C67DD25B819EFE2963562ABE52824F8C1B43152BD
CREATE   VIEW [Retail_DW_Core_Wrk].[v_FactCloses]
AS
SELECT
	soc.SuperOrderID
	, soc.SourceOrderID
	, soc.CountTypeID
	, cm.CustomerKey
	, sl.LocationKey
	, sp.SalesPersonKey
	, soc.OrderDateKey
	, dd.DateKey AS TransDateKey
	, soc.SPSales
	, soc.SPClose
	, soc.SUClose AS SuperOrderClose
	, soc.SUOpp
	, soc.SOClose
	, soc.SOOpp
	, soc.CurrentRec
	, slc.LYComp
	, slc.TYComp
	, soc.DateChanged
FROM [Retail_DW_Core].[FactSalesOrderCloses] soc
LEFT JOIN [Retail_DW_Core].[DimStoreLocation] sl
ON soc.StoreID = sl.StoreID
LEFT JOIN [Retail_DW_Core].[DimDate] dd
ON dd.DateKey = soc.TransDateKey
LEFT JOIN [Retail_DW_Core].[DimSalesPerson] sp
ON sp.SalesPersonID = soc.SalesPersonID
LEFT JOIN [Retail_DW_Core].[DimCustomerMaster] cm
ON cm.CustomerID = soc.CustomerID
LEFT JOIN [Retail_DW_Core].[DimDMLocationCalendar] slc
ON slc.StoreID = sl.StoreID
AND slc.TransDate = dd.DateID
WHERE soc.StoreID NOT IN (469, 499, 699);