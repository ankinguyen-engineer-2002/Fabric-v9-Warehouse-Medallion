CREATE     VIEW [Retail_DW_Core_Wrk].[v_DimRSAHomeStoreLocation]
AS
SELECT Distinct a.HomeStore
, concat(a.HomeStore,'-',b.LocationName) as HomeStoreLocationName
 from Retail_DW_Core.DimSalesPerson a
 left join Retail_DW_Core.DimStoreLocation b on cast(a.HomeStore as int) = b.StoreID
 where a.HomeStore is not null;
GO

