-- Auto Generated (Do not modify) 9AA76C55B3B8C2579BAFBC6F506EBA2EA6D0F6389C610C676DA0368A9DC63CC8
CREATE     VIEW [Retail_DW_Core_Wrk].[v_DimBeddingItemMaster] AS

SELECT 
 ItemID
, VendorName
, Series
, BeddingDescription
, BeddingType
, Comfort
, Technology
, [Size] 
FROM [$(Source_Data)].Retail_ExternalFiles.beddingitemmaster