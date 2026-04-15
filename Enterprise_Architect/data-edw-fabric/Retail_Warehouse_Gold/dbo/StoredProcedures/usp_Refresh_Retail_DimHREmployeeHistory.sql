CREATE     PROCEDURE [dbo].[usp_Refresh_Retail_DimHREmployeeHistory]
AS

BEGIN

--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'DimHREmployeeHistory';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','PowerBI_Retail','DimPeopleRecord'

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','PowerBI_Retail','PeopleRecord' 

END
GO

