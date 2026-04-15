-- Auto Generated (Do not modify) 62E330093A8AE40D8F9BDDE755B2699923E21712869AED4CB185E90D4134F13F
CREATE VIEW [Retail_DW_Core_Wrk].[v_FactOrderDetailTrans]
AS
SELECT 
	sdh.OrderID
    , sdh.ItemID
    , CASE WHEN sdh.SalesType = 'W' THEN sdh.Sales ELSE 0
    END AS WrittenSales
    , CASE WHEN sdh.SalesType = 'W' THEN sdh.Cost ELSE 0
    END AS WrittenCost
    , CASE WHEN sdh.SalesType = 'W' THEN sdh.Units ELSE 0
    END AS WrittenUnits
    , CASE WHEN sdh.SalesType = 'D' THEN sdh.Sales ELSE 0
    END AS DeliveredSales
    , CASE WHEN sdh.SalesType = 'D' THEN sdh.Cost ELSE 0
    END AS DeliveredCost
    , CASE WHEN sdh.SalesType = 'D' THEN sdh.Units ELSE 0
    END AS DeliveredUnits
    , sdh.TransCodeID
    , sdh.UpdateTypeID
    , sdh.AsIsReasonCodeID
    , sdh.VoidedReasonCodeID
    , sdh.ItemCommCategory
    , sdh.DeliveryStatus
    , sdh.ProductDiscountCode
    , sdh.PVEReasonCodeID
    , sdh.Sales
    , sdh.Cost
    , sdh.Units
    , sdh.SalesType
    , pm.SKU
    , lm.StoreBrandID
    , pm.SKUName AS ProductName
    , pm.VendorModelNumber
    , pm.VendorID
    , pm.GroupID
    , pm.SubGroupID
    , tgm.CategoryID
    , dm.DateID AS TransDate
    , tsp.SalesPersonID
    , tsp.SalesPersonName
    , tsp.CommissionRate
    , tsp.SalesPersonTypeID
    , tcm.CustomerID
    , tcm.FirstName CustomerFirstName
    , tcm.LastName CustomerLastName
    , lm.StoreID
    , lm.LocationName
	, sdh.PPPOpp
	, sdh.PPPClose
	, pm.PPPGroupID
	, tgm.PrimaryCategory
	, tcm.IsRetail
	, tcm.CustomerClass
FROM [Retail_DW_Core].[FactSales]  AS sdh
INNER JOIN [Retail_DW_Core].[DimProductMaster] AS pm
ON pm.ProductKey = sdh.ProductKey
INNER JOIN [Retail_DW_Core].[DimGroupMaster] AS tgm
ON tgm.GroupID = pm.GroupID
INNER JOIN [Retail_DW_Core].[DimDate] AS dm
ON dm.DateKey = sdh.TransDateKey
INNER JOIN [Retail_DW_Core].[DimSalesPerson] AS tsp
ON tsp.SalesPersonKey = sdh.SalesPersonKey
INNER JOIN [Retail_DW_Core].[DimCustomerMaster] AS tcm
ON tcm.CustomerKey = sdh.CustomerKey
INNER JOIN [Retail_DW_Core].[DimStoreLocation] AS lm
ON lm.LocationKey = sdh.LocationKey;