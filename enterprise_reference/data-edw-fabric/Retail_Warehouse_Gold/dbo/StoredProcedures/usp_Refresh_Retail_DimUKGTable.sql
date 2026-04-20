CREATE PROCEDURE [dbo].[usp_Refresh_Retail_DimUKGTable]
AS

BEGIN

EXEC [Retail_DW_Core].[usp_Refresh_DimHRJobs];

EXEC [Retail_DW_Core].[usp_Refresh_DimEmployeeSupervisor]

EXEC [Retail_DW_Core].[usp_Update_DimPeopleRecords];

EXEC [Retail_DW_Core].[usp_Update_DimHREmployeeHistory];

EXEC [Retail_DW_Core].[usp_Update_DimPeopleTimeSheet];

EXEC [Retail_DW_Core].[usp_Update_DimTimeSheetSummary];

--EXEC [Retail_DW_Core].[usp_Update_DimTimeSheetHours];

END