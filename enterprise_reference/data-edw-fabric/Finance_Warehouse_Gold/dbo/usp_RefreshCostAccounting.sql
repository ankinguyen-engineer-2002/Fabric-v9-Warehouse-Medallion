create Procedure usp_RefreshCostAccounting AS 

EXEC [$(ETL_Framework)].[DW_Developer].[usp_DropConstraints] 'Finance_Warehouse'


EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Finance_Warehouse','CostAccounting_DW','DimCustomerDetails' --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Finance_Warehouse','CostAccounting_DW','DimDateFile'  -- good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Finance_Warehouse','CostAccounting_DW','DimDiscountAdjDetails'   --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Finance_Warehouse','CostAccounting_DW','DimItemDetail'   --good
--- 
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Finance_Warehouse','CostAccounting_DW','DimMarginDetails'  -- good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Finance_Warehouse','CostAccounting_DW','DimSecurity'   --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Finance_Warehouse','CostAccounting_DW','DimShippedHistoryDetails'  ---good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Finance_Warehouse','CostAccounting_DW','DimWarehouseDetails'  --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Finance_Warehouse','CostAccounting_DW','FactDiscountAdjustments'  -- good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Finance_Warehouse','CostAccounting_DW','FactMargins'  --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Finance_Warehouse','CostAccounting_DW','FactShippedHistoryCost'   --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Finance_Warehouse','CostAccounting_DW','FactShippedHistoryDetail'  --good

GO
