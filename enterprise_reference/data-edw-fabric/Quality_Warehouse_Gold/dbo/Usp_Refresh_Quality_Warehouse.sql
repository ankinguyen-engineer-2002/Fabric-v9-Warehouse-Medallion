create Procedure dbo.Usp_Refresh_Quality_Warehouse as

EXEC [Quality_DW].[usp_Refresh_FactProductList]
EXEC [Quality_DW].[usp_Update_FactReplacementPartHistory]
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Quality_Warehouse','Quality_DW','FactCalculatedColumns'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Quality_Warehouse','Quality_DW','FactInWarehouseItems'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Quality_Warehouse','Quality_DW','FactVendorSplit'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Quality_Warehouse','Quality_DW','FactWarehouseSerials'  
