-- no changes needed

CREATE   PROCEDURE [MasterData_HR_UKG_Enh].[usp_Refresh_TimesheetETL] 
AS
BEGIN

	DECLARE
        @String VARCHAR(5000),
        @DateValue DATETIME,
        @User VARCHAR(500),
		@DestinationDatabase VARCHAR(150),
		@DestinationSchema VARCHAR(150),
		@DestinationTable VARCHAR(150);
			      
    SET @String = 'MasterData_HR_UKG_Enh.usp_Refresh_TimesheetETL' ;
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'MasterData_HR_UKG_Enh'
	SET @DestinationTable = 'TimesheetETL';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

	BEGIN TRY

		TRUNCATE TABLE [MasterData_HR_UKG_Enh].[TimesheetETL];

		--DECLARE @FromDate DATE = '2025-12-01';

		DECLARE @FromDate DATE = CAST(GETDATE()-30 AS DATE)
				, @ToDate DATE = GETDATE();

		INSERT INTO [MasterData_HR_UKG_Enh].[TimesheetETL]
		(
			SourceDataID
			, SourceSystemID
			, PeopleID
			, EmployeeNumber
			, PayPeriod
			, TransDateKey
			, SourceLocationID
			, TimeIn
			, [TimeOut]
			, [Time]
			, SourcePayCodeID
			, PaymentCodeName
			, SourceTaskCodeID
			, TaskCodeName
			, DateCreated
			, ExtCost
			, LocationID
			, ApprovedByManager
			, DataSource
		)

		SELECT 
			CONCAT(SegmentID, '-', PayCodeID, '-', SegmentPaycodeIndex) AS SourceDataID
			, 4 AS SourceSystemID
			, NULL AS PeopleID
			, EmployeeNumber
			, NULL AS PayPeriod
			, CAST(CONVERT(VARCHAR(8), WorkDate, 112) AS INT) AS TransDateKey
			, LocationID AS SourceLocationID
			, CAST(TimeIn AS DATETIME2(3)) AS TimeIn
			, CAST(TimeOut AS DATETIME2(3)) AS [TimeOut]
			, WorkHours * 60 AS [Time]
			, PayCodeID AS SourcePayCodeID
			, PayCodeName AS PaymentCodeName
			, TaskID AS SourceTaskCodeID
			, CAST(TaskCodeDescription AS VARCHAR(100)) AS TaskCodeName
			, CAST(GETDATE() AS DATE) AS DateCreated
			, NULL AS ExtCost
			, LocationID
			, ApprovedByManager
			, DataSource
		FROM [MasterData_HR_UKG_Enh].[Timesheet]
		WHERE WorkDate BETWEEN @FromDate AND @ToDate
		GROUP BY CONCAT(SegmentID, '-', PayCodeID, '-', SegmentPaycodeIndex)
				 , EmployeeNumber
				 , CAST(CONVERT(VARCHAR(8), WorkDate, 112) AS INT)
				 , LocationID
				 , CONVERT(DATETIME2(3), TimeIn)
				 , CONVERT(DATETIME2(3), TimeOut)
				 , WorkHours * 60
				 , PayCodeID
				 , PayCodeName
				 , TaskID
				 , CONVERT(VARCHAR(100), TaskCodeDescription)
				 , ApprovedByManager
				 , DataSource;

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