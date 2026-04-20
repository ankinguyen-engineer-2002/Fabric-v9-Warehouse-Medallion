CREATE   PROCEDURE [Retail_Sales_Enh].[usp_Update_SalesPersonHourlyStats]
AS

BEGIN
	
	DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
    SET @String = 'Retail_Sales_Enh.usp_Update_SalesPersonHourlyStats' ;
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'Retail_Sales_Enh'
	SET @DestinationTable = 'SalesPersonHourlyStats';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

	BEGIN TRY

		--TRUNCATE TABLE [Retail_Sales_Enh].[SalesPersonHourlyStats];

		DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(ID),0) FROM [Retail_Sales_Enh].[SalesPersonHourlyStats]);

		DECLARE @StartTransDate DATE
				, @EndTransDate DATE;

		SELECT @EndTransDate = MAX(SalespersonUPBoardHistoryStatusStart)
		FROM [$(Source_Data)].[MasterData_Retail].[SalespersonUPBoardHistoryAGR];

		SET @StartTransDate = DATEADD(DAY, -1, @EndTransDate);

		IF OBJECT_ID('tempdb..#results') IS NOT NULL 
		DROP TABLE #results;

		SELECT	
			Source
			, StoreID
			, RecordedUpDate AS TransDate
			, SalesPersonID
			, SalesPersonName
			, RecordedUpHour
			, SUM(IIF(SPUBStatusID IN (2, 3, 9, 10), 1, 0)) AS RecordedUpCount
			, SUM(IIF(SPUBStatusID = 99, 1, 0)) AS ManualRecordedUpCount
			, 0 AS RecordedUpCountTotal
			, SUM(CASE StrikeCount WHEN 3 THEN 1 ELSE 0 END) AS StrikeOuts
			, SUM(isSale) AS HotRotations
			, SUM(Shot) AS Shot
			, SUM(FinApp) AS FinApp
		INTO #results
		FROM [Retail_Sales_Enh].[SalesPersonUPBoardHistory]
		WHERE RecordedUpDate BETWEEN @StartTransDate AND  @EndTransDate
		AND SalespersonID IS NOT NULL
		AND (SPUBStatusID <> 11 AND DATEDIFF(SECOND, StatusStartTime, StatusEndTime) >= 60)
		GROUP BY Source
				, StoreID
				, RecordedUpDate
				, SalesPersonID
				, SalesPersonName
				, RecordedUpHour;

		UPDATE #results
		SET RecordedUpCountTotal = RecordedUpCount + ManualRecordedUpCount;

		UPDATE hs
		SET Ups = ISNULL(r.RecordedUpCountTotal, 0)
			, StrikeOuts = r.StrikeOuts
			, hs.HotRotations = r.HotRotations
			, DateChanged = GETDATE()
			, ChangedBy = 'Scoreboard'
			, LiveIND = 1
		FROM [Retail_Sales_Enh].[SalesPersonHourlyStats] hs
		INNER JOIN 
		(
			SELECT DISTINCT StoreID 
			FROM #results
		) st
		ON st.StoreID = hs.StoreID
		LEFT JOIN #results r 
		ON r.SalesPersonID = hs.SalesPersonID 
		AND r.TransDate = CAST(hs.TransDate AS DATE) 
		AND r.RecordedUpHour = hs.Hour 
		AND hs.StoreID = r.StoreID
		WHERE hs.TransDate BETWEEN @StartTransDate AND  @EndTransDate
		AND hs.Ups <> ISNULL(r.RecordedUpCountTotal, 0);

		INSERT INTO [Retail_Sales_Enh].[SalesPersonHourlyStats]
		(
			ID
			, Source
			, StoreID
			, SalesPersonID
			, TransDate
			, Hour
			, Ups
			, DateCreated
			, CreatedBy
			, DateChanged
			, ChangedBy
			, Worked
			, HourlyStatsSourceID
			, LiveIND
			, StrikeOuts
			, HotRotations
			, Shots
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY hs.StoreID, hs.SalesPersonID, hs.TransDate) AS BIGINT) AS ID
			, r.Source
			, r.StoreID
			, r.SalesPersonID
			, r.TransDate
			, r.RecordedUpHour AS Hour
			, r.RecordedUpCountTotal AS Ups
			, GETDATE() AS DateCreated
			, 'Scoreboard' AS CreatedBy
			, NULL AS DateChanged
			, NULL AS ChangedBy
			, 0 AS Worked
			, 2 AS HourlyStatsSourceID
			, 1 AS LiveIND
			, r.StrikeOuts
			, r.HotRotations
			, r.Shot
		FROM #results r
		LEFT JOIN [Retail_Sales_Enh].[SalesPersonHourlyStats] hs 
		ON r.SalesPersonID = hs.SalesPersonID
		AND r.TransDate = CAST(hs.TransDate AS DATE) 
		AND r.RecordedUpHour = hs.Hour 
		AND hs.StoreID = r.StoreID
		WHERE hs.StoreID IS NULL
		AND r.TransDate IS NOT NULL
		AND r.SalesPersonID IS NOT NULL;

		DROP TABLE #results;

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
		EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase,@DestinationSchema,@DestinationTable
		
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