CREATE   PROCEDURE [dbo].[Usp_Refresh_MasterData_Retail_Ent]
AS

BEGIN

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'MasterData_Retail_Ent', 'SalesPerson';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'MasterData_Retail_Ent', 'Staff';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'MasterData_Retail_Ent', 'StoreLocation';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'MasterData_Retail_Ent', 'StoreLocationGroup';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'MasterData_Retail_Ent', 'StoreLocationCalendar';

END