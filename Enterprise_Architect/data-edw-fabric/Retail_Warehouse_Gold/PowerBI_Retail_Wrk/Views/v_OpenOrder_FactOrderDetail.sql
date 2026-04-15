-- Auto Generated (Do not modify) 5623EB7ACB2E449B7E542D8A8265389290103DBD450A582C8DFB693530DE02E5
CREATE     VIEW [PowerBI_Retail_Wrk].[v_OpenOrder_FactOrderDetail]
AS
with Autotrans as (
SELECT SUBSTRING(od.AutoTransOrderItemID, 0,CHARINDEX('*',od.AutoTransOrderItemID,1))   AS OrderID,
       SUBSTRING(od.AutoTransOrderItemID, CHARINDEX('*',od.AutoTransOrderItemID)+1,LEN(od.AutoTransOrderItemID)) AS ItemID,
	   od.SKU,od.ProductKey,od.QuantityCommitted as Qtytrans,oh.RouteCodeID as RouteCodeID
--INTO #Autotrans
FROM [Retail_DW_Core].[FactOrderDetail] od
left join [Retail_DW_Core].[FactSalesOrderHeader] oh
on od.SourceOrderID = oh.SourceOrderID
where oh.TransCodeID = 63
and od.LineStatus = 'Written'
)

select 
od.SourceOrderID as OrderID,
oh.OrderDate, 
od.LineStatus,
od.LineNumber as ItemID,
od.SKU as ProductID,
od.ProductKey,
od.UnitSellPrice,
od.DeliveryDate,
od.DeliveryStatus,
od.DeliveryType,
t.Description,
od.QuantityOrdered as QtyOrdered,
od.QuantityCommitted as QtyCommitted,
--aut.Qtytrans,
od.QuantityDelivered as QtyDelivered,
od.OrderFulfillmentID,
od.ShipLocationID as ShpLocationID,
od.StockLocationID as StkLocationID,
oh.RouteCodeID,
p.DeliveryVolume, 
aut.RouteCodeID as TransRoute, 
f.DeliveryContactStatusID,
f.DeliveryContactDate,
f.FulfillmentDate,  --need to check
case 
	when QuantityOrdered = QuantityCommitted then 'Y' else 'N' end as Filled,
case when aut.Qtytrans is null then 0 else aut.Qtytrans end as Qtytrans,
CASE 
    WHEN QuantityOrdered = (SUM(od.QuantityCommitted) + COALESCE(aut.Qtytrans, 0)) THEN 'Y' 
    ELSE 'N' 
END AS Dfilled
FROM [Retail_DW_Core].[FactOrderDetail] od
left join [Retail_DW_Core].[FactSalesOrderHeader] oh
on cast(od.SourceOrderID AS VARCHAR(50))  = cast(oh.SourceOrderID AS VARCHAR(50)) 
left join Autotrans aut
on od.SourceOrderID = aut.OrderID and od.LineNumber=aut.ItemID
left JOIN [Retail_DW_Core].[DimProductMaster]  AS p
        ON cast(od.SKU AS VARCHAR(50))  = cast(p.SKU AS VARCHAR(50)) 
left JOIN [Retail_DW_Core].[DimGroupMaster]   AS g
        ON cast(p.GroupID AS VARCHAR(50))  = cast(g.GroupID AS VARCHAR(50)) 
left join [Retail_DW_Core].[DimTransCodeMap] t
		on cast(od.TransCodeID AS VARCHAR(50))   = cast(t.TransCodeID AS VARCHAR(50)) 
     left join [$(Source_Data)].[Retail_Corporate].[OrderFulfillment] f 
		on f.OrderFulfillmentID  = od.OrderFulfillmentID 
where od.LineStatus in ('Written')
  AND OD.DeliveryType IN ('D','P')
  AND g.CategoryID NOT IN ( 'MST', 'MSI', 'SVCPTS' )
  and p.ProductTypeID NOT IN ( '3', '6' )
   AND od.TransCodeID IN (0, 1, 7, 30, 31)
AND P.IsMaster = 1
and od.ShipLocationID in ('401','444','902','904','906','912','913','915','917','919','921','924','933','939','941','944','954','981','983','929','990','991','992','993','994','995','996','997','998','999')
group by 
od.SourceOrderID,oh.OrderDate, od.LineStatus,od.LineNumber,od.SKU,od.ProductKey,od.UnitSellPrice,od.DeliveryDate,od.DeliveryStatus,DeliveryType,t.Description,od.QuantityOrdered,od.QuantityCommitted,--aut.Qtytrans,
od.QuantityDelivered,od.OrderFulfillmentID,
od.ShipLocationID,od.StockLocationID,oh.RouteCodeID,p.DeliveryVolume, aut.RouteCodeID, f.DeliveryContactStatusID, aut.qtytrans, f.DeliveryContactDate, f.FulfillmentDate
;