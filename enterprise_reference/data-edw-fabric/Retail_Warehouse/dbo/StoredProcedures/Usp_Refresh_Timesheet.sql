CREATE PROCEDURE [dbo].[Usp_Refresh_Timesheet]
AS

BEGIN

EXEC [MasterData_HR_UKG_Enh].[usp_Update_WFMTimesheet];
 
EXEC [MasterData_HR_UKG_Enh].[usp_Refresh_TimesheetETL];
 
EXEC [MasterData_HR_UKG_Enh].[usp_Update_PeopleTimeSheet];
 
EXEC [MasterData_HR_UKG_Enh].[usp_Refresh_PayMatrix];
 
EXEC [MasterData_HR_UKG_Enh].[usp_Refresh_DTRContractorData];
 
EXEC [MasterData_HR_UKG_Enh].[usp_Update_TimeSheetSummary];
 
--EXEC [MasterData_HR_UKG_Enh].[usp_Update_TimeSheetHours];

END