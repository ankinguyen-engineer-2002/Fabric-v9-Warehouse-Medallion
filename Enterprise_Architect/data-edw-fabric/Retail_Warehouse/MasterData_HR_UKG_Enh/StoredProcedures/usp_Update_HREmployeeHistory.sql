CREATE   PROCEDURE [MasterData_HR_UKG_Enh].[usp_Update_HREmployeeHistory]
AS

BEGIN

	DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
    SET @String = 'MasterData_HR_UKG_Enh.usp_Update_HREmployeeHistory' ;
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'MasterData_HR_UKG_Enh'
	SET @DestinationTable = 'HREmployeeHistory';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    BEGIN TRY

		DECLARE @TransDate DATE = DATEADD(DAY, -1, GETDATE());

		DELETE FROM [MasterData_HR_UKG_Enh].[HREmployeeHistory]
		WHERE TransDate = @TransDate;

		INSERT INTO [MasterData_HR_UKG_Enh].[HREmployeeHistory]
		(
			  PeopleID
			, EmployeeID
			, EmployeeNumber
			, SupervisorID
			, EmployeeFirstName
			, EmployeeLastName
			, EmployeeStatus
			, EmployeeEmail
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
			, SeparationReason
			, SeparationDate
			, TransDate
			, DataSource
		)

		SELECT
			  pr.PeopleID 
			, pr. EmployeeID
			, pr.EmployeeNumber
			, pr.SupervisorID
			, pr.EmployeeFirstName
			, pr.EmployeeLastName
			, pr.EmployeeStatus
			, pr.EmployeeEmail
			, pr.EmployeeHourlySalary
			, pr.EmployeeFTPT
			, pr.HireDate
			, pr.Generation
			, pr.LocationID
			, pr.JobID
			, pr.DivisionID
			, pr.DepartmentID
			, pr.RegionID
			, pr.EmployeeTypeID
			, pr.SeparationCode
			, pr.SeparationType
			, pr.SeparationReason
			, pr.SeparationDate
			, @TransDate
			, DataSource
		FROM [MasterData_HR_UKG_Enh].[PeopleRecords] AS pr
		WHERE pr.InHRSystem = 1;

		UPDATE theh
		SET theh.SeparationReason = pr.SeparationReason
		FROM [MasterData_HR_UKG_Enh].[HREmployeeHistory] AS theh
		INNER JOIN [MasterData_HR_UKG_Enh].[PeopleRecords] AS pr
		ON pr.EmployeeNumber = theh.EmployeeNumber
		WHERE theh.SeparationReason IS NULL
		AND pr.SeparationReason IS NOT NULL;

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