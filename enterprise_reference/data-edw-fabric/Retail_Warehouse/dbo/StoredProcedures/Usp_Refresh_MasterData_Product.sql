CREATE PROCEDURE [dbo].[Usp_Refresh_MasterData_Product]
AS

BEGIN

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'MasterData_Product', 'ProductGroup'

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'MasterData_Product', 'ProductSeries'

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'MasterData_Product', 'ProductInfo'

END