CREATE PROCEDURE [dbo].[usp_Refresh_Retail_FactView]
AS

BEGIN

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'FactOrderHeader';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'FactCloses';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'FactPayments';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'FactOrderDetailTrans';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'FactPPPSales';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'DimBeddingItemMaster';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'MarketingJobSummary';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'FactMBSConversion';

END