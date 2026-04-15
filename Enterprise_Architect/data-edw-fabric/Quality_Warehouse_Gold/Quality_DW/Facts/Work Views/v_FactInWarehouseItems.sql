CREATE VIEW [Quality_DW_Wrk].[v_FactInWarehouseItems] AS with TotalItems as
( select count(serialNumber) as Total 
, Warehouse,ItemNumber , B.TDAPO# as PONumber from [Quality_DW].[FactWarehouseItemStatus] A
 INNER JOIN [$(Databricks)].[manufacturing_inventory_afi].[taginvd] B
                       On B.[TDITEM] = A.ItemNumber and [TDTAG#] = A.serialNumber
where Warehouse <> ' ' and B.[TDTSTS] = 'R'
      AND B.[TDAREA] <> ''
      AND B.[TDAREA] <> 'HS'
      AND B.[TDTIER] > 0
      AND B.[TDMDAT_DATE] >= DATEADD(month, -12, GETDATE())
	  and (B.TDTAG# not like '7%' and B.TDTAG# not like '8%' )
	   and Warehouse <> '70'
	  --and [TDITEM]= 'B139-57' and TDWHSE = '15'
group by Warehouse , ItemNumber, TDAPO#
),
OnHold as
(
Select case when [Status] = 'H' then Count(serialNumber) else 0 end as OnHold , Warehouse,ItemNumber , B.TDAPO# as PONumber from [Quality_DW].[FactWarehouseItemStatus] A
 INNER JOIN [$(Databricks)].[manufacturing_inventory_afi].[taginvd] B
                       On B.[TDITEM] = A.ItemNumber and [TDTAG#] = A.serialNumber

where  [Status] = 'H' and  Warehouse <> ' '  and B.[TDTSTS] = 'R'
      AND B.[TDAREA] <> ''
      AND B.[TDAREA] <> 'HS'
      AND B.[TDTIER] > 0
      AND B.[TDMDAT_DATE] >= DATEADD(month, -12, GETDATE())
	  and (B.TDTAG# not like '7%' and B.TDTAG# not like '8%')
	  and Warehouse <> '70'
group by Warehouse,ItemNumber,[Status],TDAPO# )

Select 
--(TotalItems.Total - OnHold.OnHold) as InWarehouseCount, 
case when TotalItems.Total > OnHold.OnHold then (TotalItems.Total - OnHold.OnHold) 
else (OnHold.OnHold - TotalItems.Total) end as InWarehouseCount
,TotalItems.Warehouse, TotalItems.ItemNumber,
Null as [Status] , TotalItems.PONumber
from TotalItems
inner join OnHold on TotalItems.ItemNumber=OnHold.ItemNumber;