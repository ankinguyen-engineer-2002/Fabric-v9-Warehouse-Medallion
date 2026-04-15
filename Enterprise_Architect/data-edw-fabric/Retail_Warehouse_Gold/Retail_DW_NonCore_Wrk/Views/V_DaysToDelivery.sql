-- Auto Generated (Do not modify) 72735ED011CDDDCD48EF40199BA8385BB235093ED04F9033DB1EBE58FA41D336
CREATE VIEW [Retail_DW_NonCore_Wrk].[V_DaysToDelivery] AS (SELECT ot.SourceOrderID as OrderID
     , ot.OrderDate
     , ot.StoreID
     , ot.RouteCodeID
     , ot.SFMCFulfillmentStatus
     , otd.SKU as ProductID
     , otd.UnitSellPrice
     , otd.WrittenDate
	 , OTD.OrderFulfillmentID
     , otd.QuantityOrdered as QtyOrdered
     , otd.DeliveryDate
     , otd.DeliveryType
     , otd.LineStatus
     , otd.ShipLocationID as LocationID
     , DATEDIFF(DAY, ot.OrderDate, DeliveryDate) AS DaysToDelivery
     , g.CategoryID
FROM [Retail_DW_Core].[FactSalesOrderHeader]       AS ot
    INNER JOIN Retail_DW_Core.FactOrderDetail    AS otd
        ON ot.SourceOrderID = otd.SourceOrderID
    INNER JOIN Retail_DW_Core.DimProductMaster  AS p
        ON otd.SKU = p.SKU
    INNER JOIN Retail_DW_Core.DimGroupMaster    AS g
        ON p.GroupID = g.GroupID
    INNER JOIN Retail_DW_Core.DimStoreLocationGroup AS lg
        ON lg.StoreID = otd.StoreID
WHERE ot.OrderDate >= DATEADD(month,-3,getdate())
      --AND otd.DeliveryDate >= '2022-01-01'
      AND otd.TransCodeID IN ( 0, 1, 7 )
      AND g.CategoryID NOT IN ( 'MST', 'MSI', 'SVCPTS' )
      AND lg.LocationGroupID like '%DC%'
      AND otd.DeliveryType IN ( 'D', 'P' )
      AND otd.LineStatus <> 'Cancelled'
      --AND LEFT(ot.SourceOrderID, 3) <> LG.StoreID
      AND p.ProductTypeID NOT IN ( '3', '6' )
      AND P.IsMaster=1
      AND otd.ShipLocationID IN 
('994', '993', '991', '998', '990', '997', '995', '999', '996', '992', 
'401', '444', '902', '904', '906', '913', '915', '917', '919', '921', 
'924', '929', '933', '939', '941', '944', '954', '972', '981', '983'))