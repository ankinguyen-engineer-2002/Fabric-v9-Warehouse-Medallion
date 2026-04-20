CREATE      PROCEDURE [MasterData_HR_UKG_Enh].[usp_Update_PeopleTimeSheet]
AS
BEGIN
	DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
    SET @String = 'MasterData_HR_UKG_Enh.usp_Update_PeopleTimeSheet' ;
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'MasterData_HR_UKG_Enh'
	SET @DestinationTable = 'PeopleTimeSheet';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

BEGIN TRY

		DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(TimeSheetID),0) FROM [MasterData_HR_UKG_Enh].[PeopleTimeSheet]);
	
		UPDATE src
		SET src.PeopleID = pr.PeopleID
		FROM [MasterData_HR_UKG_Enh].[TimesheetETL] src
		INNER JOIN [MasterData_HR_UKG_Enh].[PeopleRecords] pr
		ON pr.EmployeeNumber = src.EmployeeNumber
		OR pr.EmployeeNumber = src.EmployeeNumber;

		DELETE pts
		FROM [MasterData_HR_UKG_Enh].[PeopleTimeSheet] pts
		WHERE EXISTS 
		(
			SELECT DISTINCT TransDateKey 
			FROM [MasterData_HR_UKG_Enh].[TimesheetETL] etl 
			WHERE pts.TransDateKey = etl.TransDateKey
		);

		INSERT INTO [MasterData_HR_UKG_Enh].[PeopleTimeSheet]
		(
			TimeSheetID
			, SourceDataID
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
			, PayCodeName
			, SourceTaskCodeID
			, TaskCodeName
			, ExtCost
			, DateCreated
			, ApprovedByManager
			, DataSource
		)
		
		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY SourceDataID, SourceSystemID, EmployeeNumber, TransDateKey) AS BIGINT) AS TimeSheetID
			, SourceDataID
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
			, ExtCost
			, DateCreated
			, ApprovedByManager
			, DataSource
		FROM [MasterData_HR_UKG_Enh].[TimesheetETL]
		WHERE NOT (EmployeeNumber = '104098' AND TransDateKey = 20241012)
		AND NOT (EmployeeNumber = '127086' AND TransDateKey = 20241014);

		UPDATE pts
		SET pts.TaskCodeID = tcm.TaskCodeID
		FROM [MasterData_HR_UKG_Enh].[PeopleTimeSheet] pts
		INNER JOIN [MasterData_HR_UKG_Enh].[TimesheetETL] ets
		ON ets.SourceDataID = pts.SourceDataID
		INNER JOIN [$(Source_Data)].[Retail_External].[TATaskCodeMap] tcm 
		ON tcm.SourceSystemID = pts.SourceSystemID
		AND tcm.SourceTaskCodeID = pts.SourceTaskCodeID
		WHERE ISNULL(pts.TaskCodeID, -1) <> tcm.TaskCodeID;

		UPDATE pts
		SET pts.PayCodeID = pcm.PayCodeID
		FROM [MasterData_HR_UKG_Enh].[PeopleTimeSheet] pts
		INNER JOIN [MasterData_HR_UKG_Enh].[TimesheetETL] ets 
		ON ets.SourceDataID = pts.SourceDataID
		INNER JOIN [$(Source_Data)].[Retail_External].[TAPayCodeMap] pcm
		ON pcm.SourceSystemID = pts.SourceSystemID
		AND pcm.SourcePayCodeID = pts.SourcePayCodeID
		WHERE ISNULL(pts.PayCodeID, -1) <> pcm.PayCodeID;

		UPDATE pts
		SET [Time] = NULL
		FROM [MasterData_HR_UKG_Enh].[PeopleTimeSheet] pts
		INNER JOIN [MasterData_HR_UKG_Enh].[TimesheetETL] ts
		ON ts.SourceDataID = pts.SourceDataID
		WHERE pts.[Time] < -5000;

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