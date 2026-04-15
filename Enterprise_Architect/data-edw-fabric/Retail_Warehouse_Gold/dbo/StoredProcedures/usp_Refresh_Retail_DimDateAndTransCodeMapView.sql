CREATE PROCEDURE [dbo].[usp_Refresh_Retail_DimDateAndTransCodeMapView]
AS

BEGIN

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] '$(Retail_Warehouse)','Retail_DW_Core' , 'DimDate';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] '$(Retail_Warehouse)','Retail_DW_Core' , 'DimTransCodeMap';

END