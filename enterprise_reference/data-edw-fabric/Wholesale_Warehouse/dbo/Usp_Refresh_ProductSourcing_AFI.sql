create   Procedure [dbo].[Usp_Refresh_ProductSourcing_AFI] as
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','ProductSourcing_AFI','ControlAllocationItems'  -- no view
 
GO
