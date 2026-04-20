CREATE     PROCEDURE [dbo].[Usp_Refresh_Retail_NonCore_FactView] 
AS 

BEGIN

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_NonCore' , 'InventoryDailyOpen';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_NonCore' , 'GLAccount';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_NonCore' , 'GLTransactions';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_NonCore' , 'OpenOrderSummary';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_NonCore' , 'OpenOrderSummaryDetail';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','PowerBI_Retail','OpenOrder_FactOrderDetail';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_NonCore','DMDespIsedInvActivity';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','PowerBI_Retail','PPH_Staff';

END