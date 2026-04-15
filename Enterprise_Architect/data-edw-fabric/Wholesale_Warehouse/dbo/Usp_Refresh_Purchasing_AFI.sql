CREATE   Procedure [dbo].[Usp_Refresh_Purchasing_AFI] as
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Purchasing_AFI','VendorMaster' 
go 
 
