CREATE PROC [MasterData_HR_UKG_Enh].[usp_Refresh_PayMatrix] AS
BEGIN

    DECLARE
        @String VARCHAR(5000),
        @DateValue DATETIME,
        @User VARCHAR(500),
        @DestinationDatabase VARCHAR(150),
        @DestinationSchema VARCHAR(150),
        @DestinationTable VARCHAR(150);

    SET @String = 'MasterData_HR_UKG_Enh.usp_Refresh_PayMatrix';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE();
    SET @DestinationDatabase = 'Retail_Warehouse';
    SET @DestinationSchema = 'MasterData_HR_UKG_Enh';
    SET @DestinationTable = 'PayMatrix';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    BEGIN TRY

        TRUNCATE TABLE [MasterData_HR_UKG_Enh].[PayMatrix];

		DECLARE @FromDate DATE = CAST(GETDATE()-30 AS DATE)
				, @ToDate DATE = GETDATE();

        IF OBJECT_ID('tempdb..#paycodes_overtime') IS NOT NULL 
		DROP TABLE #paycodes_overtime;

        SELECT * 
		INTO #paycodes_overtime
		FROM 
		(
			SELECT 102 AS PayCodeID 
			UNION
			SELECT 451 AS PayCodeID 
			UNION
			SELECT 304 AS PayCodeID 
			UNION
			SELECT 361 AS PayCodeID 
			UNION
			SELECT 715 AS PayCodeID 
			UNION
			SELECT 254 AS PayCodeID
			UNION
			SELECT 363 AS PayCodeID 
        ) dfg;

        -- Insert PayMatrix data
        INSERT INTO [MasterData_HR_UKG_Enh].[PayMatrix]
        (
            PayMatrixID
            , TimeID
            , SourceLocationID
            , SourceTaskCodeID
            , SourcePayCodeID
            , SourceTimeCodeID
            , [Hours]
            , PayAmount
            , TransDate
			, TransDateKey
            , ApprovedByManager
			, DataSource
		)

        SELECT
            (CAST(t.SegmentID AS BIGINT) * 1000 + t.PayCodeID) * 10 + t.SegmentPaycodeIndex AS PayMatrixID
            , (CAST(t.SegmentID AS BIGINT) * 1000 + t.PayCodeID) * 10 + t.SegmentPaycodeIndex AS TimeID
            , t.LocationID AS SourceLocationID
            , t.TaskID AS SourceTaskCodeID
            , t.PayCodeID AS SourcePayCodeID
            , 'REG' AS SourceTimeCodeID
            , t.WorkHours AS [Hours]
            , t.Wage AS PayAmount
            , t.WorkDate AS TransDate
			, CAST(CONVERT(VARCHAR(8), t.WorkDate, 112) AS INT) AS TransDateKey
            , t.ApprovedByManager
			, t.DataSource
        FROM [MasterData_HR_UKG_Enh].[Timesheet] t
        LEFT JOIN #paycodes_overtime po 
		ON po.PayCodeID = t.PayCodeID
        WHERE t.WorkDate BETWEEN @FromDate AND @ToDate
		AND po.PayCodeID IS NULL

        UNION ALL

        SELECT
            (CAST(t.SegmentID AS BIGINT) * 1000 + t.PayCodeID) * 10 + t.SegmentPaycodeIndex AS PayMatrixID
            , (CAST(t.SegmentID AS BIGINT) * 1000 + t.PayCodeID) * 10 + t.SegmentPaycodeIndex AS TimeID
            , t.LocationID AS SourceLocationID
            , t.TaskID AS SourceTaskCodeID
            , t.PayCodeID AS SourcePayCodeID
            , 'OTH' AS SourceTimeCodeID
            , t.WorkHours AS [Hours]
            , t.Wage AS PayAmount
            , t.WorkDate AS TransDate
			, CAST(CONVERT(VARCHAR(8), t.WorkDate, 112) AS INT) AS TransDateKey
            , t.ApprovedByManager
			, t.DataSource
        FROM [MasterData_HR_UKG_Enh].[Timesheet] t
        INNER JOIN #paycodes_overtime po 
		ON po.PayCodeID = t.PayCodeID
        WHERE t.WorkDate BETWEEN @FromDate AND @ToDate;
		
		UPDATE pm
		SET pm.TaskCodeID = tcm.TaskCodeID
		FROM [MasterData_HR_UKG_Enh].[PayMatrix] AS pm
		INNER JOIN [$(Source_Data)].[Retail_External].[TATaskCodeMap] tcm 
		ON tcm.SourceTaskCodeID = pm.SourceTaskCodeID
		WHERE tcm.SourceSystemID = 4;

		UPDATE pts
		SET pts.PayCodeID = pcm.PayCodeID
		FROM [MasterData_HR_UKG_Enh].[PayMatrix] pts
		INNER JOIN [$(Source_Data)].[Retail_External].[TAPayCodeMap] pcm 
		ON pcm.SourcePayCodeID = pts.SourcePayCodeID
		WHERE pcm.SourceSystemID = 4;

		UPDATE [MasterData_HR_UKG_Enh].[PayMatrix]
		SET TimeCodeID = CASE WHEN SourceTimeCodeID LIKE '%OT%' THEN 1 ELSE 0 END;

        SET @DateValue = GETDATE();

        SELECT
            @DateValue = CSTDateValue
        FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

        INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
        VALUES
        (
            @String, @DateValue, @User, 'Process Complete'
        );

        -- Update last modified in Table Dictionary
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