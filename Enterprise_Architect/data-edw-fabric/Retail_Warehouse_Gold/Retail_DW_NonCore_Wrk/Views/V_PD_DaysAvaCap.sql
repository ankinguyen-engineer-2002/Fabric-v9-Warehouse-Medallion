-- Auto Generated (Do not modify) F9B0E141FFF34AB1762B2C46435D4E10E2539C2887F986CB81C4FC67DE7C03B3
CREATE VIEW [Retail_DW_NonCore_Wrk].[V_PD_DaysAvaCap] AS (SELECT  ot.SourceOrderID as OrderID,
        ot.OrderDate,
		ot.RouteCodeID,
		ot.SFMCLastFulfillmentDate AS DlvyCapAvailDate,
		ot.SFMCFulfillmentStatus,
		DATEDIFF(DAY, ot.OrderDate, ot.SFMCLastFulfillmentDate) AS DaysToDlvyCapAvailDate,
		ot.StoreID
FROM  [Retail_DW_Core].[FactSalesOrderHeader] AS ot
    INNER JOIN Retail_DW_Core.[FactOrderDetail] AS otd
        ON ot.SourceOrderID = otd.SourceOrderID
    INNER JOIN Retail_DW_Core.DimProductMaster AS p
        ON otd.SKU = p.SKU
    INNER JOIN Retail_DW_Core.DimGroupMaster AS g
        ON p.GroupID = g.GroupID
    INNER JOIN [Retail_DW_Core].[DimStoreLocationGroup] AS lg 
    ON lg.StoreID = otd.ShipLocationID
WHERE ot.OrderDate>='2024-01-01'      
        AND otd.TransCodeID IN ( 0, 1, 7 )
        AND g.CategoryID NOT IN ( 'MST', 'MSI', 'SVCPTS' )
        AND lg.LocationGroupID = 'DC'
		AND otd.DeliveryType='D'
        AND P.IsMaster=1
        AND lg.StoreID NOT IN ('901','907','909','910', '911', '932','935', '943','945')
        and ot.OrderDate <= ot.SFMCLastFulfillmentDate
GROUP by ot.SourceOrderID, ot.OrderDate, ot.RouteCodeID,ot.SFMCLastFulfillmentDate,ot.SFMCFulfillmentStatus,ot.StoreID)