-- Auto Generated (Do not modify) 742EE47ED1C9063DD19F87B4F2C30146507A30FE901507A216D0C355523FC620
CREATE     VIEW [MasterData_HR_UKG_Enh_Wrk].[v_EmployeeSupervisor]
AS
SELECT	
	e.EmployeeNumber
	, e.SupervisorEmployeeNumber
	, TRIM(COALESCE(NULLIF(TRIM(COALESCE(pSup.PreferredName, pSup.FirstName)),'') + ' ', '') 
	+ COALESCE(NULLIF(TRIM(pSup.MiddleName),'') + ' ', '') + COALESCE(NULLIF(TRIM(pSup.LastName),''), '')) AS SupervisorFullName
	, e.DataSource	
FROM [MasterData_HR_UKG_Enh].[Employees] e 
INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] eSup 
ON eSup.EmployeeNumber = e.SupervisorEmployeeNumber
INNER JOIN [MasterData_HR_UKG_Enh].[PersonDetails] pSup 
ON pSup.PersonDetailKey = eSup.PersonDetailKey;