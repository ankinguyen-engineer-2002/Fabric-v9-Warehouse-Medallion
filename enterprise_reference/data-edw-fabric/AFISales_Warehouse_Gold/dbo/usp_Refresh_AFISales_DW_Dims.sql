
create proc usp_Refresh_AFISales_DW_Dims AS 

EXEC [$(ETL_Framework)].[DW_Developer].[usp_DropConstraints] 'AFISales_Warehouse'


EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'AFISales_Warehouse','AFISales_DW','DimADLogins'   --Good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'AFISales_Warehouse','AFISales_DW','DimAdNoticeDetails'   --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'AFISales_Warehouse','AFISales_DW','DimAsscoiateSecurity'   --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'AFISales_Warehouse','AFISales_DW','DimBuyGroupDetails'   -- good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'AFISales_Warehouse','AFISales_DW','DimCustmers'   --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'AFISales_Warehouse','AFISales_DW','DimGeographicLocations'  -- 	good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'AFISales_Warehouse','AFISales_DW','DimInvoiceHeader'      --  good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'AFISales_Warehouse','AFISales_DW','DimItemMaster'  --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'AFISales_Warehouse','AFISales_DW','DimItemWarehouse'  --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'AFISales_Warehouse','AFISales_DW','DimMarketingAdFundsDetails'     --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'AFISales_Warehouse','AFISales_DW','DimMarketingSpecialists'  -- good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'AFISales_Warehouse','AFISales_DW','DimOrderHistoryDetails'  --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'AFISales_Warehouse','AFISales_DW','DimSalesTerritories'  --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'AFISales_Warehouse','AFISales_DW','DimSpecialChargeDetails'  --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'AFISales_Warehouse','AFISales_DW','DimTerritory'  --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'AFISales_Warehouse','AFISales_DW','DimWarehouseMaster'  --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'AFISales_Warehouse','AFISales_DW','DimWarRoomPackageDetails'  --good