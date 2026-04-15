-- Auto Generated (Do not modify) 39FEB47A8F62BD0088EC3C24EB3299550169C5C6C66DBCB86062A58FEB9E86DE


CREATE   VIEW [MasterData_HR_UKG_Enh_Wrk].[v_Employees]
AS
SELECT 
	e.PersonDetailKey
    , p.EmployeeID
    , e.EmployeeNumber
    , p.FirstName AS EmployeeFirstName
    , p.MiddleName AS EmployeeMiddleName
    , p.LastName AS EmployeeLastName
    , TRIM(COALESCE(NULLIF(TRIM(COALESCE(p.PreferredName, p.FirstName)), '') + ' ', '') + COALESCE(NULLIF(TRIM(p.MiddleName), '') + ' ', '') 
	+ COALESCE(NULLIF(TRIM(p.LastName), ''), '')) AS EmployeeFullName
    , TRIM(COALESCE(NULLIF(TRIM(p.FirstName), '') + ' ', '') + COALESCE(NULLIF(TRIM(p.MiddleName), '') + ' ', '') 
	+ COALESCE(NULLIF(TRIM(p.LastName), ''), '')) AS EmployeeFullLegalName
    , p.PreferredName AS EmployeePreferredName
    , p.FormerName AS EmployeeFormerName
    , p.Username AS EmployeeUserName
    , p.EmailAddress AS EmployeeEmail
    , p.EmailAddressAlternate AS EmployeePersonalEmail
    , e.EmployeeStatus
    , CASE e.EmployeeStatus WHEN 'A' THEN 'Active' WHEN 'L' THEN 'Leave' WHEN 'T' THEN 'Terminated' ELSE NULL END EmployeeStatusName
    , c.CompanyCode
    , c.CompanyName
    , ol1.OrgLevelKey AS DivisionKey
    , ol1.OrgCode AS DivisionCode
    , ol1.OrgDescription AS Division
    , ol2.OrgLevelKey AS DepartmentKey
    , ol2.OrgCode AS DepartmentCode
    , ol2.OrgDescription AS Department
    , ol3.OrgLevelKey AS RegionKey
    , ol3.OrgCode AS RegionID
    , ol3.OrgDescription AS Region
    , ol4.OrgLevelKey AS EmployeeTypeKey
    , ol4.OrgCode AS EmployeeTypeCode
    , ol4.OrgDescription EmployeeTypeDescription
    , LTRIm(e.LocationGLSegment, '0') AS LocationID
    , w.WHSE_NAME AS [Location]
    , j.JobKey AS PositionKey
    , j.JobKey AS JobID
    , j.JobCode AS PositionCode
    , j.LongDescription AS Position
    , j.JobTitle AS PositionTitle
    , e.OriginalHireDate
    , e.LastHireDate AS HireDate
    , e.DateInJob
    , e.DateLastWorked
    , e.JobChangeReasonCode
    , e.LeaveReasonCode
    , e.DateOfTermination AS TerminationDate
    , e.TerminationReason AS TerminationReasonCode
    , e.TerminationReasonDescription AS TerminationReason
    , e.TerminationType AS TerminationType
    , e.PayGroup
    , e.PayGroupDescription
    , e.PayPeriod
    , e.SalaryOrHourly
    , e.SupervisorEmployeeNumber
    , c.CompanyID
    , CASE WHEN e.FullTimeOrPartTimeCode IS NOT NULL THEN e.FullTimeOrPartTimeCode ELSE 'F' END AS FullTimeOrPartTimeCode
	, e.DateCreated
	, CASE WHEN (e.DateChanged>p.DateChanged) THEN e.DateChanged ELSE p.DateChanged END DateChanged
	, p.Generation
	, e.DataSource
FROM 
(
	SELECT *
	FROM [MasterData_HR_UKG_Enh].[EmploymentDetails]
	WHERE ISNUMERIC(LocationGLSegment) = 1
) e
LEFT JOIN [MasterData_HR_UKG_Enh].[PersonDetails] p
ON p.PersonDetailKey = e.PersonDetailKey
LEFT JOIN [MasterData_HR_UKG_Enh].[CompanyDetails] c
ON c.CompanyDetailKey = e.CompanyKey
LEFT JOIN [MasterData_HR_UKG_Enh].[Jobs] j
ON j.JobKey = e.PrimaryJobKey
LEFT JOIN [MasterData_HR_UKG_Enh].[OrgLevel] ol1
ON ol1.OrgLevelKey = e.OrgLevel1Key
LEFT JOIN [MasterData_HR_UKG_Enh].[OrgLevel] ol2
ON ol2.OrgLevelKey = e.OrgLevel2Key
LEFT JOIN [MasterData_HR_UKG_Enh].[OrgLevel] ol3
ON ol3.OrgLevelKey = e.OrgLevel3Key
LEFT JOIN [MasterData_HR_UKG_Enh].[OrgLevel] ol4
ON ol4.OrgLevelKey = e.OrgLevel4Key
LEFT JOIN
(
	SELECT 
		LTRIM(ID, '0') AS ID
		, WHSE_NAME
    FROM [$(Source_Data)].[Retail_Miniapps].[WarehouseLocation]
	WHERE ISNUMERIC(ID) = 1
) w
ON w.ID = e.LocationGLSegment;