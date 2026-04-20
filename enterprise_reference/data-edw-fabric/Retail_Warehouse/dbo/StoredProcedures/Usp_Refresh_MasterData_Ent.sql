CREATE PROCEDURE [dbo].[Usp_Refresh_MasterData_Ent]
AS

BEGIN

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'MasterData_Ent', 'CustomerInfo';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'MasterData_Ent', 'PaymentType';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'MasterData_Ent', 'ReasonCode';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'MasterData_Ent', 'VendorInfo';

END