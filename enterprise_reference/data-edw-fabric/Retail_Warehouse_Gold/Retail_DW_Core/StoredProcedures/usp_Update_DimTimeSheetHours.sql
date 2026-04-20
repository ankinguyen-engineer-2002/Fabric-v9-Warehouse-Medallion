CREATE   PROCEDURE [Retail_DW_Core].[usp_Update_DimTimeSheetHours]
AS
BEGIN

	DECLARE
        @String VARCHAR(5000),
        @DateValue DATETIME,
        @User VARCHAR(500),
		@DestinationDatabase VARCHAR(150),
		@DestinationSchema VARCHAR(150),
		@DestinationTable VARCHAR(150);
			      
    SET @String = 'Retail_DW_Core.usp_Update_DimTimeSheetHours';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'Retail_DW_Core'
	SET @DestinationTable = 'DimTimeSheetHours';
	
	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

    BEGIN TRY

		DECLARE @StartDate DATE = CAST(GETDATE()-30 AS DATE)
				, @EndDate DATE = GETDATE();
		
		DELETE ts
		FROM [Retail_DW_Core].[DimTimeSheetHours] ts
		WHERE ts.TransDate BETWEEN @StartDate AND @EndDate;
		
		INSERT INTO [Retail_DW_Core].[DimTimeSheetHours]
		(
			EmployeeNumber
			, LocationID
			, LocationKey
			, TransDate
			, TransHour
			, TimeIn
			, [TimeOut]
			, MinutesWorked
			, IsOpen
			, ApprovedByManager
			, DataSource
		)

		SELECT
			ts.EmployeeNumber
			, ts.LocationID
			, st.LocationKey
			, CONVERT(DATE, CAST(ts.TransDateKey AS VARCHAR(8)), 112) AS TransDate
			, ts.TransHour
			, ts.TimeIn
			, ts.[TimeOut]
			, ts.MinutesWorked
			, ts.IsOpen
			, ts.ApprovedByManager
			, ts.DataSource
		FROM [$(Retail_Warehouse)].[MasterData_HR_UKG_Enh].[TimeSheetHours] ts
		LEFT JOIN [Retail_DW_Core].[DimStoreLocation] st
        ON st.StoreID = ts.LocationID
		WHERE CONVERT(DATE, CAST(ts.TransDateKey AS VARCHAR(8)), 112) BETWEEN @StartDate AND @EndDate;

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