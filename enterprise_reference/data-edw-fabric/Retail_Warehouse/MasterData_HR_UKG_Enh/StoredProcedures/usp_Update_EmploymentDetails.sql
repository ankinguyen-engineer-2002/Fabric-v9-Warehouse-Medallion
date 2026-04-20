CREATE   PROCEDURE [MasterData_HR_UKG_Enh].[usp_Update_EmploymentDetails]
AS

BEGIN

	DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
    SET @String = 'MasterData_HR_UKG_Enh.usp_Update_EmploymentDetails' ;
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'MasterData_HR_UKG_Enh'
	SET @DestinationTable = 'EmploymentDetails';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    BEGIN TRY

		IF OBJECT_ID('tempdb..#wrk_EmploymentDetails') IS NOT NULL 
		DROP TABLE #wrk_EmploymentDetails;

		SELECT	
			  wed.id
            , wed.employeeID
            , wed.employeeNumber
            , wed.employeeStatusCode
            , wed.originalHireDate
            , wed.lastHireDate
            , wed.dateInJob
            , wed.dateLastWorked
            , wed.companyID
            , wed.primaryJobCode
            , wed.orgLevel1Code
            , wed.orgLevel2Code
            , wed.orgLevel3Code
            , wed.orgLevel4Code
            , wed.jobChangeReasonCode
            , wed.leaveReasonCode
            , wed.plannedLeaveReason
            , wed.dateOfTermination
            , wed.termReason
            , wed.terminationReasonDescription
            , wed.termType
            , wed.supervisorEmployeeNumber
            , wed.payGroup
            , wed.payGroupDescription
            , wed.payPeriod
            , wed.salaryOrHourly
            , wed.dateTimeCreated
            , wed.dateTimeChanged
            , wed.companyGLSegment
            , wed.locationGLSegment
            , wed.fullTimeOrPartTimeCode
            , wed.dataSource
			, ROW_NUMBER() OVER (PARTITION BY wed.employeeNumber ORDER BY wed.employeeStatusCode, wed.dateTimeCreated DESC) AS indexx
			, ROW_NUMBER() OVER (PARTITION BY wed.employeeID ORDER BY wed.employeeStatusCode, wed.dateTimeCreated DESC) AS indexx2
		INTO #wrk_EmploymentDetails
		FROM [$(Source_Data)].[MasterData_HR_UKG_DSG].[EmploymentDetails] wed;


		DELETE FROM #wrk_EmploymentDetails 
		WHERE indexx>1;

		DELETE FROM #wrk_EmploymentDetails 
		WHERE indexx2>1;

		IF OBJECT_ID('tempdb..#EmploymentDetailsRaw') IS NOT NULL 
		DROP TABLE #EmploymentDetailsRaw;

		SELECT	
			wed.*
			, pd.PersonDetailKey
			, cd.CompanyDetailKey AS CompanyKey
			, j.JobKey AS PrimaryJobKey
			, ol1.OrgLevelKey AS OrgLevel1Key
			, ol2.OrgLevelKey AS OrgLevel2Key
			, ol3.OrgLevelKey AS OrgLevel3Key
			, ol4.OrgLevelKey AS OrgLevel4Key
			, 0 AS IsModified
 		INTO #EmploymentDetailsRaw
		FROM #wrk_EmploymentDetails wed
		LEFT JOIN [MasterData_HR_UKG_Enh].[PersonDetails] pd 
		ON pd.EmployeeID = wed.employeeID
		LEFT JOIN [MasterData_HR_UKG_Enh].[CompanyDetails] cd 
		ON cd.CompanyID = wed.companyID
		LEFT JOIN [MasterData_HR_UKG_Enh].[Jobs] j 
		ON j.JobCode = wed.primaryJobCode
		LEFT JOIN [MasterData_HR_UKG_Enh].[OrgLevel] ol1 
		ON ol1.OrgCode = wed.orgLevel1Code 
		AND ol1.OrgLevel = 1 
		LEFT JOIN [MasterData_HR_UKG_Enh].[OrgLevel] ol2 
		ON ol2.OrgCode = wed.orgLevel2Code 
		AND ol2.OrgLevel = 2 
		LEFT JOIN [MasterData_HR_UKG_Enh].[OrgLevel] ol3 
		ON ol3.OrgCode = wed.orgLevel3Code 
		AND ol3.OrgLevel = 3 
		LEFT JOIN [MasterData_HR_UKG_Enh].[OrgLevel] ol4 
		ON ol4.OrgCode = wed.orgLevel4Code 
		AND ol4.OrgLevel = 4;

		--update existing records (if changed)

		UPDATE wed
		SET IsModified = 1
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed 
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE wed.CompanyKey <> ed.CompanyKey
		OR wed.employeeNumber <> ed.EmployeeNumber
		OR wed.employeeStatusCode <> ed.EmployeeStatus
		OR ISNULL(wed.PrimaryJobKey, 0) <> ISNULL(ed.PrimaryJobKey, 0)
		OR ISNULL(wed.OrgLevel1Key, 0) <> ISNULL(ed.OrgLevel1Key, 0)
		OR ISNULL(wed.OrgLevel2Key, 0) <> ISNULL(ed.OrgLevel2Key, 0)
		OR ISNULL(wed.OrgLevel3Key, 0) <> ISNULL(ed.OrgLevel3Key, 0)
		OR ISNULL(wed.OrgLevel4Key, 0) <> ISNULL(ed.OrgLevel4Key, 0)
		OR ISNULL(wed.originalHireDate, '1900-01-01') <> ISNULL(ed.OriginalHireDate, '1900-01-01')
		OR ISNULL(wed.lastHireDate, '1900-01-01') <> ISNULL(ed.LastHireDate, '1900-01-01')
		OR ISNULL(wed.dateLastWorked, '1900-01-01') <> ISNULL(ed.DateLastWorked, '1900-01-01')
		OR ISNULL(wed.dateInJob, '1900-01-01') <> ISNULL(ed.DateInJob, '1900-01-01')
		OR ISNULL(wed.jobChangeReasonCode, '') <> ISNULL(ed.JobChangeReasonCode, '')
		OR ISNULL(wed.leaveReasonCode, '') <> ISNULL(ed.LeaveReasonCode, '')
		OR ISNULL(wed.plannedLeaveReason, '') <> ISNULL(ed.PlannedLeaveReason, '')
		OR ISNULL(wed.dateOfTermination, '1900-01-01') <> ISNULL(ed.DateOfTermination, '1900-01-01')
		OR ISNULL(wed.termReason, '') <> ISNULL(ed.TerminationReason, '')
		OR ISNULL(wed.terminationReasonDescription, '') <> ISNULL(ed.TerminationReasonDescription, '')
		OR ISNULL(wed.termType, '') <> ISNULL(ed.TerminationType, '')
		OR ISNULL(wed.supervisorEmployeeNumber, '') <> ISNULL(ed.SupervisorEmployeeNumber, '')
		OR ISNULL(wed.payGroup, '') <> ISNULL(ed.PayGroup, '')
		OR ISNULL(wed.payGroupDescription, '') <> ISNULL(ed.PayGroupDescription, '')
		OR ISNULL(wed.payPeriod, '') <> ISNULL(ed.PayPeriod, '')
		OR ISNULL(wed.salaryOrHourly, '') <> ISNULL(ed.SalaryOrHourly, '')
		OR ISNULL(wed.locationGLSegment, '') <> ISNULL(ed.LocationGLSegment, '');

		--log new records

		DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(ChangeLogID),0) FROM [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]);
	
		--'New Hire'

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.employeeNumber) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 1
			, NULL
			, wed.employeeNumber
			, wed.dataSource
		FROM #EmploymentDetailsRaw wed
		LEFT JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed 
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 0
		AND ed.PersonDetailKey IS NULL
		AND wed.PersonDetailKey IS NOT NULL;

		--EmployeeNumber

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY ed.EmployeeNumber) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 2
			, TRIM(ed.EmployeeNumber)
			, TRIM(wed.employeeNumber)		
			, wed.dataSource
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed 
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 1
		AND TRIM(wed.employeeNumber) <> TRIM(ed.EmployeeNumber);

		--EmployeeStatus

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.employeeStatusCode) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 3
			, TRIM(ed.EmployeeStatus)
			, TRIM(wed.employeeStatusCode)	
			, wed.dataSource	
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 1
		AND TRIM(wed.employeeStatusCode) <> TRIM(ed.EmployeeStatus);

		--CompanyKey

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.companyID) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 4
			, cd.CompanyCode
			, wed.companyID
			, wed.dataSource
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		INNER JOIN [MasterData_HR_UKG_Enh].[CompanyDetails] cd 
		ON cd.[CompanyDetailKey] = ed.CompanyKey
		WHERE IsModified = 1
		AND wed.CompanyKey <> ed.CompanyKey;
	
		--PrimaryJob

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.primaryJobCode) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 5
			, j.JobCode
			, wed.primaryJobCode
			, wed.dataSource		
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		INNER JOIN [MasterData_HR_UKG_Enh].[Jobs] j 
		ON j.JobKey = ed.PrimaryJobKey
		WHERE IsModified = 1
		AND ISNULL(j.JobCode, '') <> ISNULL(wed.primaryJobCode, '');

		--OrgLevel1Key

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.orgLevel1Code) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 6
			, ol.OrgCode
			, wed.orgLevel1Code	
			, wed.dataSource
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		INNER JOIN [MasterData_HR_UKG_Enh].[OrgLevel] ol 
		ON ol.OrgLevelKey = ed.OrgLevel1Key 
		AND ol.OrgLevel = 1
		WHERE IsModified = 1
		AND ISNULL(wed.OrgLevel1Key, 0) <> ISNULL(ed.OrgLevel1Key, 0);

		--Department

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.orgLevel2Code) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 7
			, ol.OrgCode
			, wed.orgLevel2Code	
			, wed.dataSource	
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		INNER JOIN [MasterData_HR_UKG_Enh].[OrgLevel] ol 
		ON ol.OrgLevelKey = ed.OrgLevel2Key 
		AND ol.OrgLevel = 2
		WHERE IsModified = 1
		AND ISNULL(wed.OrgLevel2Key, 0) <> ISNULL(ed.OrgLevel2Key, 0);

		--Region

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.orgLevel3Code) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 8
			, ol.OrgCode
			, wed.orgLevel3Code
			, wed.dataSource			
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		INNER JOIN [MasterData_HR_UKG_Enh].[OrgLevel] ol 
		ON ol.OrgLevelKey = ed.OrgLevel3Key 
		AND ol.OrgLevel = 3
		WHERE IsModified = 1
		AND ISNULL(wed.OrgLevel3Key, 0) <> ISNULL(ed.OrgLevel3Key, 0);

		--Location

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.locationGLSegment) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 9
			, ed.LocationGLSegment
			, wed.locationGLSegment
			, wed.dataSource
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 1
		AND ISNULL(wed.locationGLSegment, 0) <> ISNULL(ed.LocationGLSegment, 0);


		--OriginalHireDate

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.originalHireDate) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 10
			, CONVERT(VARCHAR(10), ed.OriginalHireDate, 120)
			, CONVERT(VARCHAR(10), CAST(wed.originalHireDate AS DATE), 120)
			, wed.dataSource
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 1
		AND ISNULL(wed.originalHireDate, '1900-01-01') <> ISNULL(CAST(ed.OriginalHireDate AS DATE), '1900-01-01');

		--LastHireDate

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.lastHireDate) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 11
			, CONVERT(VARCHAR(10), ed.LastHireDate, 120)
			, CONVERT(VARCHAR(10), CAST(wed.lastHireDate AS DATE), 120)
			, wed.dataSource
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 1
		AND ISNULL(wed.lastHireDate, '1900-01-01') <> ISNULL(CAST(ed.LastHireDate AS DATE), '1900-01-01');

		--DateInJob

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.dateInJob) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 12
			, CONVERT(VARCHAR(10), ed.DateInJob, 120)
			, CONVERT(VARCHAR(10), CAST(wed.dateInJob AS DATE), 120)
			, wed.dataSource
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 1
		AND ISNULL(wed.dateInJob, '1900-01-01') <> ISNULL(CAST(ed.DateInJob AS DATE), '1900-01-01');

		--JobChangeReason

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.jobChangeReasonCode) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 13
			, ed.JobChangeReasonCode
			, wed.jobChangeReasonCode
			, wed.dataSource		
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 1
		AND ISNULL(wed.jobChangeReasonCode, '') <> ISNULL(ed.JobChangeReasonCode, '');

		--LeaveReasonCode

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.leaveReasonCode) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 14
			, ed.LeaveReasonCode
			, wed.leaveReasonCode
			, wed.dataSource		
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 1
		AND ISNULL(wed.leaveReasonCode, '') <> ISNULL(ed.LeaveReasonCode, '');

		--PlannedLeaveReason

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.plannedLeaveReason) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 15
			, ed.PlannedLeaveReason
			, wed.plannedLeaveReason
			, wed.dataSource		
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 1
		AND ISNULL(wed.plannedLeaveReason, '') <> ISNULL(ed.PlannedLeaveReason, '');

		--DateOfTermination

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.dateOfTermination) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 16
			, CONVERT(VARCHAR(10), ed.DateOfTermination, 120)
			, CONVERT(VARCHAR(10), CAST(wed.dateOfTermination AS DATE), 120)
			, wed.dataSource
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 1
		AND ISNULL(wed.dateOfTermination, '1900-01-01') <> ISNULL(CAST(ed.DateOfTermination AS DATE), '1900-01-01');

		--TerminationReason

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.termReason) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 17
			, ed.TerminationReason
			, wed.termReason
			, wed.dataSource		
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 1
		AND ISNULL(wed.termReason, '') <> ISNULL(ed.TerminationReason, '');

		--TerminationReasonDescription

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.terminationReasonDescription) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 18
			, ed.TerminationReasonDescription
			, wed.terminationReasonDescription
			, wed.dataSource		
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 1
		AND ISNULL(wed.terminationReasonDescription, '') <> ISNULL(ed.TerminationReasonDescription, '');

		--TerminationType

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.termType) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 19
			, ed.TerminationType
			, wed.termType
			, wed.dataSource		
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 1
		AND ISNULL(wed.termType, '') <> ISNULL(ed.TerminationType, '');

		--SupervisorEmployeeNumber

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.supervisorEmployeeNumber) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 20
			, ed.SupervisorEmployeeNumber
			, wed.supervisorEmployeeNumber
			, wed.dataSource		
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 1
		AND ISNULL(wed.supervisorEmployeeNumber, '') <> ISNULL(ed.SupervisorEmployeeNumber, '');

		--PayGroup

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.payGroup) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 21
			, ed.PayGroup
			, wed.payGroup
			, wed.dataSource		
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 1
		AND ISNULL(wed.payGroup, '') <> ISNULL(ed.PayGroup, '');

		--PayGroupDescription

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.payGroupDescription) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 22
			, ed.PayGroupDescription
			, wed.payGroupDescription
			, wed.dataSource		
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 1
		AND ISNULL(wed.payGroupDescription, '') <> ISNULL(ed.PayGroupDescription, '');

		--PayPeriod

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.payPeriod) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 23
			, ed.PayPeriod
			, wed.payPeriod
			, wed.dataSource		
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 1
		AND ISNULL(wed.payPeriod, '') <> ISNULL(ed.PayPeriod, '');

		--SalaryOrHourly

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.salaryOrHourly) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 24
			, ed.SalaryOrHourly
			, wed.salaryOrHourly
			, wed.dataSource		
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 1
		AND ISNULL(wed.salaryOrHourly, '') <> ISNULL(ed.SalaryOrHourly, '');

		--FullTimeOrPartTimeCode

		INSERT INTO [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData]
		(
			ChangeLogID
			, LogDate
			, PersonDetailKey
			, FieldID
			, OldValue
			, NewValue
			, DataSource
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wed.fullTimeOrPartTimeCode) AS BIGINT)
			, GETDATE()
			, wed.PersonDetailKey
			, 25
			, ed.FullTimeOrPartTimeCode
			, wed.fullTimeOrPartTimeCode
			, wed.dataSource		
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 1
		AND ISNULL(wed.fullTimeOrPartTimeCode, '') <> ISNULL(ed.FullTimeOrPartTimeCode, '');

		UPDATE ed
		SET	ed.CompanyKey = wed.CompanyKey
			, ed.EmployeeNumber = wed.employeeNumber
			, ed.EmployeeStatus = wed.employeeStatusCode
			, ed.PrimaryJobKey = wed.PrimaryJobKey
			, ed.OrgLevel1Key = wed.OrgLevel1Key
			, ed.OrgLevel2Key = wed.OrgLevel2Key
			, ed.OrgLevel3Key = wed.OrgLevel3Key
			, ed.OrgLevel4Key = wed.OrgLevel4Key
			, ed.OriginalHireDate = wed.originalHireDate
			, ed.LastHireDate = wed.lastHireDate
			, ed.DateLastWorked = wed.dateLastWorked
			, ed.DateInJob = wed.dateInJob
			, ed.JobChangeReasonCode = wed.jobChangeReasonCode
			, ed.LeaveReasonCode = wed.leaveReasonCode
			, ed.PlannedLeaveReason = wed.plannedLeaveReason
			, ed.DateOfTermination = wed.dateOfTermination
			, ed.TerminationReason = wed.termReason
			, ed.TerminationReasonDescription = wed.terminationReasonDescription
			, ed.TerminationType = wed.termType
			, ed.SupervisorEmployeeNumber = wed.supervisorEmployeeNumber
			, ed.PayGroup = wed.payGroup
			, ed.PayGroupDescription = wed.payGroupDescription
			, ed.PayPeriod = wed.payPeriod
			, ed.SalaryOrHourly = wed.salaryOrHourly
			, ed.DateChanged = wed.dateTimeChanged
			, ed.CompanyGLSegment = wed.companyGLSegment
			, ed.LocationGLSegment = wed.locationGLSegment
			,ed.DataSource = wed.dataSource
		FROM #EmploymentDetailsRaw wed
		INNER JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 1;
	
		INSERT INTO [MasterData_HR_UKG_Enh].[EmploymentDetails]
		(
			EmployeeKey
			, PersonDetailKey
			, EmployeeNumber
			, EmployeeStatus
			, CompanyKey
			, PrimaryJobKey
			, OrgLevel1Key
			, OrgLevel2Key
			, OrgLevel3Key
			, OrgLevel4Key
			, OriginalHireDate
			, LastHireDate
			, DateInJob
			, DateLastWorked
			, JobChangeReasonCode
			, LeaveReasonCode
			, PlannedLeaveReason
			, DateOfTermination
			, TerminationReason
			, TerminationReasonDescription
			, TerminationType
			, SupervisorEmployeeNumber
			, PayGroup
			, PayGroupDescription
			, PayPeriod
			, SalaryOrHourly
			, DateCreated
			, DateChanged
			, CompanyGLSegment
			, LocationGLSegment
			, FullTimeOrPartTimeCode
			, DataSource
		)
	
		SELECT	
			wed.id
			, wed.PersonDetailKey
			, wed.employeeNumber
			, wed.employeeStatusCode
			, wed.CompanyKey
			, wed.PrimaryJobKey
			, wed.OrgLevel1Key
			, wed.OrgLevel2Key
			, wed.OrgLevel3Key
			, wed.OrgLevel4Key
			, wed.originalHireDate
			, wed.lastHireDate
			, wed.dateInJob
			, wed.dateLastWorked
			, wed.jobChangeReasonCode
			, wed.leaveReasonCode
			, wed.plannedLeaveReason
			, wed.dateOfTermination
			, wed.termReason
			, wed.terminationReasonDescription
			, wed.termType
			, wed.supervisorEmployeeNumber
			, wed.payGroup
			, wed.payGroupDescription
			, wed.payPeriod
			, wed.salaryOrHourly
			, wed.dateTimeCreated
			, wed.dateTimeChanged
			, wed.companyGLSegment
			, wed.locationGLSegment
			, wed.fullTimeOrPartTimeCode
			, wed.dataSource
		FROM #EmploymentDetailsRaw wed
		LEFT JOIN [MasterData_HR_UKG_Enh].[EmploymentDetails] ed
		ON ed.PersonDetailKey = wed.PersonDetailKey
		WHERE IsModified = 0
		AND ed.PersonDetailKey IS NULL
		AND wed.PersonDetailKey IS NOT NULL;

		EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'MasterData_HR_UKG_Enh', 'Employees';

		SET @DateValue = GETDATE();

		SELECT
			@DateValue = CSTDateValue
		FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

		INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
		VALUES
		(
			@String, @DateValue, @User, 'Process Complete'
		);

		--- Update last modified in Table Dictionary 
		EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase, @DestinationSchema, @DestinationTable;
		
	END TRY

    BEGIN CATCH
        
		DECLARE
            @ErrorMessage  VARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState    INT;

        SET @ErrorMessage = ERROR_MESSAGE();
        SET @ErrorSeverity = ISNULL(ERROR_SEVERITY(), 16);
        SET @ErrorState = ISNULL(ERROR_STATE(), 0);
        SET @DateValue = GETDATE();

        SELECT
            @DateValue = CSTDateValue
        FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

        INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
        VALUES
        (
            @String, @DateValue, @User, @ErrorMessage
        );

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

    END CATCH
	 
END