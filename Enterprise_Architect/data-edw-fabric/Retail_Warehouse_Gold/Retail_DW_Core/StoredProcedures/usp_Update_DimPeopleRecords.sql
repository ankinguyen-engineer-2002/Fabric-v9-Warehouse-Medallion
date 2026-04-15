CREATE   PROCEDURE [Retail_DW_Core].[usp_Update_DimPeopleRecords]
AS
BEGIN

	DECLARE
        @String VARCHAR(5000),
        @DateValue DATETIME,
        @User VARCHAR(500),
		@DestinationDatabase VARCHAR(150),
		@DestinationSchema VARCHAR(150),
		@DestinationTable VARCHAR(150);
			      
    SET @String = 'Retail_DW_Core.usp_Update_DimPeopleRecords';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'Retail_DW_Core'
	SET @DestinationTable = 'DimPeopleRecords';
	
	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

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
		FROM [Retail_DW_Core].[DimPeopleRecords] AS dst
		INNER JOIN [$(Retail_Warehouse)].[MasterData_HR_UKG_Enh].[PeopleRecords] AS src 
		ON dst.EmployeeNumber = src.EmployeeNumber;
		--WHERE src.EmployeeNumber NOT IN ('120121');

		INSERT INTO [Retail_DW_Core].[DimPeopleRecords]
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
			, LocationKey
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
			, st.LocationKey
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
		FROM [$(Retail_Warehouse)].[MasterData_HR_UKG_Enh].[PeopleRecords] AS src
		LEFT JOIN [Retail_DW_Core].[DimPeopleRecords] AS dst 
		ON src.EmployeeNumber = dst.EmployeeNumber
		LEFT JOIN [Retail_DW_Core].[DimStoreLocation] st
		ON src.LocationID = st.StoreID
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