CREATE PROCEDURE [dbo].[usp_Refresh_Retail_DimProductAndRollUpView]
AS

BEGIN

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] '$(Retail_Warehouse)','Retail_DW_Core' , 'DimProduct';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] '$(Retail_Warehouse)','Retail_DW_Core' , 'DimRollUps';

END