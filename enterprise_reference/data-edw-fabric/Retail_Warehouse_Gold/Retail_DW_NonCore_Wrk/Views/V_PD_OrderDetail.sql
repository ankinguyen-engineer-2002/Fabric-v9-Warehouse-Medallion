-- Auto Generated (Do not modify) 6D2DB4272E5C0778D23C63EA7DFE67B565B5D6660A7105E10F390B911E02BE5D
CREATE   VIEW [Retail_DW_NonCore_Wrk].[V_PD_OrderDetail] AS
with Autotrans as (
SELECT SUBSTRING(AutoTransOrderItemID, 0,CHARINDEX('*',AutoTransOrderItemID,1))   AS OrderID,
       SUBSTRING(AutoTransOrderItemID, CHARINDEX('*',AutoTransOrderItemID)+1,LEN(AutoTransOrderItemID)) AS ItemID,
       SKU,ProductKey,QuantityCommitted as Qtytrans
FROM Retail_DW_Core.FactOrderDetail od
left join [Retail_DW_Core].[FactSalesOrderHeader] oh
on od.SourceOrderID = oh.SourceOrderID
where oh.TransCodeID = 63
and od.LineStatus = 'O'
)
select 
    od.SourceOrderID as orderid, od.LineStatus,od.ServiceOrderItemID as itemid,od.SKU as productid,od.ProductKey,od.DeliveryDate,od.DeliveryStatus,
    DeliveryType,od.QuantityOrdered as qtyordered,od.QuantityCommitted as qtycommitted,aut.Qtytrans,od.QuantityDelivered as qtydelivered,od.OrderFulfillmentID,
    od.ShipLocationID as shplocationid,od.UnitSellPrice, oh.StoreID, oh.RouteCodeID
FROM Retail_DW_Core.FactOrderDetail od
left JOIN [Retail_DW_Core].[FactSalesOrderHeader] oh
on od.SourceOrderID = oh.SourceOrderID
left join Autotrans aut
on od.SourceOrderID = aut.OrderID and od.ServiceOrderItemID=aut.ItemID
left JOIN Retail_DW_Core.DimProductMaster  AS p
        ON od.SKU = p.SKU
left JOIN Retail_DW_Core.DimGroupMaster    AS g
        ON p.GroupID = g.GroupID
where od.LineStatus in ('written')
AND OD.DeliveryStatus = 'EST'
AND OD.DeliveryType = 'D'
AND g.CategoryID NOT IN ( 'MST', 'MSI', 'SVCPTS' )
and p.ProductTypeID NOT IN ( '3', '6' )
AND od.TransCodeID IN ( 0, 1, 7 )
AND P.IsMaster = 1
and od.ShipLocationID in 
('994', '993', '991', '998', '990', '997', '995', '999', '996', '992', 
'401', '444', '902', '904', '906', '913', '915', '917', '919', '921', 
'924', '929', '933', '939', '941', '944', '954', '972', '981', '983')