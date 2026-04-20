CREATE PROCEDURE [dbo].[Usp_Refresh_EmployeeHistory]
AS

BEGIN

EXEC [MasterData_HR_UKG_Enh].[usp_Update_PeopleRecords];
 
EXEC [MasterData_HR_UKG_Enh].[usp_Update_HREmployeeHistory];

END