-- Auto Generated (Do not modify) 085C19583234A32AFA2AF2B96D96B96EEDDFD1E5AD926A6C5C2A2B793FF153E4
CREATE VIEW [Retail_DW_NonCore_Wrk].[V_PD_OrderBillStatus] AS (select
od.SourceOrderID as OrderID, 
od.UnitSellPrice,
oh.OrderDate,
t.Description as OrderType, 
od.SKU as ProductID,
od.DeliveryDate,
od.DeliveryStatus,
od.DeliveryType,
od.QuantityOrdered as QtyOrdered,
od.ShipLocationID as ShpLocationID,
od.OrderFulfillmentID
FROM Retail_DW_Core.[FactOrderDetail] od
left join Retail_DW_Core.[FactOrderHeader] oh
on od.SourceOrderID = oh.SourceOrderID
left JOIN Retail_DW_Core.DimProductMaster  AS p
ON od.SKU = p.SKU
left join Retail_DW_Core.[DimTransCodeMap] as t
on od.TransCodeID = t.TransCodeID
where od.SourceOrderID not like 'T%' 
AND od.LineStatus in ('written') 
AND OD.DeliveryStatus in ('EST','SCD','ASAP','CWC') 
AND od.TransCodeID IN ( 0, 1, 7, 30, 31) 
AND P.IsMaster = 1
)