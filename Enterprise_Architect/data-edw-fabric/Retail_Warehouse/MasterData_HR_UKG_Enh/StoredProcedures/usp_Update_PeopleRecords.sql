CREATE   PROCEDURE [MasterData_HR_UKG_Enh].[usp_Update_PeopleRecords]
AS

BEGIN

	DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
    SET @String = 'MasterData_HR_UKG_Enh.usp_Update_PeopleRecords';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'MasterData_HR_UKG_Enh'
	SET @DestinationTable = 'PeopleRecords';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    BEGIN TRY

		IF OBJECT_ID('tempdb..#PeopleRecordsETL') IS NOT NULL 
		DROP TABLE #PeopleRecordsETL;

		SELECT	
			  pr.PeopleID
			, e.EmployeeID
			, e.EmployeeNumber
			, CASE WHEN e.EmployeeStatusName = 'Active' THEN 1 ELSE 0 END AS ActiveStatus
			, e.EmployeeFullName AS EmployeeName
			, CAST(e.EmployeeUserName AS VARCHAR(20)) AS EmployeeLogin
			, CAST(e.EmployeeEmail AS VARCHAR(50)) AS EmployeeEmail
			, e.SupervisorEmployeeNumber AS SupervisorID
			, COALESCE(e.EmployeeFirstName, e.EmployeePreferredName) AS EmployeeFirstName
			, e.EmployeeLastName
			, e.EmployeeStatus
			, e.SalaryOrHourly AS EmployeeHourlySalary
			, e.FullTimeOrPartTimeCode AS EmployeeFTPT
			, e.HireDate
			, e.Generation
			, e.LocationID
			, e.JobID
			, e.DivisionKey AS DivisionID
			, e.DepartmentKey AS DepartmentID
			, e.RegionKey AS RegionID
			, e.EmployeeTypeKey AS EmployeeTypeID
			, e.TerminationReasonCode AS SeparationCode
			, e.TerminationType AS SeparationType
			, e.TerminationDate AS SeparationDate
			, e.TerminationReason AS SeparationReason
			, 1 AS InHRSystem
			, e.DateCreated
			, e.DateChanged
			, e.DataSource
		INTO #PeopleRecordsETL
		FROM [MasterData_HR_UKG_Enh].[Employees] e 
		LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[PeopleRecords] pr
		ON RIGHT('00000000'+e.EmployeeNumber, 9) = pr.EmployeeNumber;

		UPDATE	dst
		SET	dst.ActiveStatus = src.ActiveStatus
			, dst.EmployeeName = src.EmployeeName
			, dst.EmployeeLogin = src.EmployeeLogin
			, dst.EmployeeEmail = src.EmployeeEmail
			, dst.SupervisorID = src.SupervisorID
			, dst.EmployeeFirstName = src.EmployeeFirstName
			, dst.EmployeeLastName = src.EmployeeLastName
			, dst.EmployeeStatus = src.EmployeeStatus
			, dst.EmployeeHourlySalary = src.EmployeeHourlySalary
			, dst.EmployeeFTPT = src.EmployeeFTPT
			, dst.HireDate = src.HireDate
			, dst.Generation = src.Generation
			, dst.LocationID = src.LocationID
			, dst.JobID = src.JobID
			, dst.DivisionID = src.DivisionID
			, dst.DepartmentID = src.DepartmentID
			, dst.RegionID = src.RegionID
			, dst.EmployeeTypeID = src.EmployeeTypeID
			, dst.SeparationCode = src.SeparationCode
			, dst.SeparationType = src.SeparationType
			, dst.SeparationDate = src.SeparationDate
			, dst.SeparationReason = src.SeparationReason
			, dst.DateChanged = src.DateChanged
			, dst.InHRSystem = src.InHRSystem
			, dst.DataSource = src.DataSource
		FROM [MasterData_HR_UKG_Enh].[PeopleRecords] AS dst
		INNER JOIN #PeopleRecordsETL AS src 
		ON dst.EmployeeNumber = src.EmployeeNumber;
		--WHERE src.EmployeeNumber NOT IN('120121');

		INSERT INTO [MasterData_HR_UKG_Enh].[PeopleRecords]
		(
			PeopleID
			, EmployeeID
			, EmployeeNumber
			, ActiveStatus
			, EmployeeName
			, EmployeeLogin
			, EmployeeEmail
			, DateCreated
			, DateChanged
			, SupervisorID
			, EmployeeFirstName
			, EmployeeLastName
			, EmployeeStatus
			, EmployeeHourlySalary
			, EmployeeFTPT
			, HireDate
			, Generation
			, LocationID
			, JobID
			, DivisionID
			, DepartmentID
			, RegionID
			, EmployeeTypeID
			, SeparationCode
			, SeparationType
			, SeparationDate
			, SeparationReason
			, InHRSystem
			, DataSource
		)

		SELECT
			src.PeopleID
			, src.EmployeeID
			, src.EmployeeNumber
			, src.ActiveStatus
			, src.EmployeeName
			, src.EmployeeLogin
			, src.EmployeeEmail
			, src.DateCreated
			, src.DateChanged
			, src.SupervisorID
			, src.EmployeeFirstName
			, src.EmployeeLastName
			, src.EmployeeStatus
			, src.EmployeeHourlySalary
			, src.EmployeeFTPT
			, src.HireDate
			, src.Generation
			, src.LocationID
			, src.JobID
			, src.DivisionID
			, src.DepartmentID
			, src.RegionID
			, src.EmployeeTypeID
			, src.SeparationCode
			, src.SeparationType
			, src.SeparationDate
			, src.SeparationReason
			, src.InHRSystem
			, src.DataSource
		FROM #PeopleRecordsETL AS src
		LEFT JOIN [MasterData_HR_UKG_Enh].[PeopleRecords] AS dst 
		ON src.EmployeeNumber = dst.EmployeeNumber
		WHERE dst.EmployeeNumber IS NULL;
		--AND src.EmployeeNumber NOT IN ('120121');

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