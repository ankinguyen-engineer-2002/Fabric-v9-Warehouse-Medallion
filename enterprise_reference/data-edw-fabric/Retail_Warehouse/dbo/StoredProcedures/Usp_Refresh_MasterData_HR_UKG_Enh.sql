CREATE PROCEDURE [dbo].[Usp_Refresh_MasterData_HR_UKG_Enh]
AS

BEGIN

EXEC [MasterData_HR_UKG_Enh].[usp_Update_CompanyDetails];

EXEC [MasterData_HR_UKG_Enh].[usp_Update_Jobs];

EXEC [MasterData_HR_UKG_Enh].[usp_Update_LaborCategory];

EXEC [MasterData_HR_UKG_Enh].[usp_Update_OrgLevel];

EXEC [MasterData_HR_UKG_Enh].[usp_Update_PayCodes];

EXEC [MasterData_HR_UKG_Enh].[usp_Update_WorkRules];

EXEC [MasterData_HR_UKG_Enh].[usp_Update_PersonDetails];

EXEC [MasterData_HR_UKG_Enh].[usp_Update_EmploymentDetails];

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'MasterData_HR_UKG_Enh', 'EmployeeSupervisor';

END