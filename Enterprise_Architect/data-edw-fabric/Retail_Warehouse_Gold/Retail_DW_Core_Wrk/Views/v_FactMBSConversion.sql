CREATE   VIEW [Retail_DW_Core_Wrk].[v_FactMBSConversion]
AS  
WITH CTE_MBSConversion AS (
select
loc.StoreID
, loc.StoreBrandID
, fs.CustomerKey
, fs.TransDateKey
, fs.GroupID
, sum(case when SalesType = 'W' then Sales*PrimaryCategory end ) as WrittenSales

from Retail_DW_Core.FactSales fs
join Retail_DW_Core.DimStoreLocation loc on fs.LocationKey = loc.LocationKey
join Retail_DW_Core.DimProduct p on fs.ProductKey = p.ProductKey
where StoreBrandID is not null
AND TransDateKey >= 20230101 -- and fs.GroupID = 'MBS'
and SalesType = 'W'
group by 
loc.StoreID
, loc.StoreBrandID
, fs.CustomerKey
, fs.TransDateKey
, fs.GroupID
)

SELECT * FROM CTE_MBSConversion WHERE writtensales >1;
GO

