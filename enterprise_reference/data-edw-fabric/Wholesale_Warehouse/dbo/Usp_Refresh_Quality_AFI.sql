CREATE   Procedure [dbo].[Usp_Refresh_Quality_AFI] as
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Quality_AFI','DamageCodes'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Quality_AFI','QualityCostsDetail' --no view
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Quality_AFI','ReplacementPartDetail'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Quality_AFI','ReplacementPartHeader'  -- conversionfailed
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Quality_AFI','ReplacementPartsMaster'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Quality_AFI','ScrapCategoryCodes'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Quality_AFI','ScrapCodes'  
GO

