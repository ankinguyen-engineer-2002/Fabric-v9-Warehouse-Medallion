CREATE PROCEDURE [Retail_Sales_Enh].[usp_Update_ScoreboardActivity]
AS

BEGIN
	
	DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
    SET @String = 'Retail_Sales_Enh.usp_Update_ScoreboardActivity' ;
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'Retail_Sales_Enh'
	SET @DestinationTable = 'ScoreboardActivity';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

	BEGIN TRY

		--TRUNCATE TABLE [Retail_Sales_Enh].[ScoreboardActivity];

		DECLARE @StartDate DATE = GETDATE()-1, 
				@EndDate DATE = GETDATE();

		IF OBJECT_ID('tempdb..#activity') IS NOT NULL 
		DROP TABLE #activity;

		SELECT
			rg.Source
			, rg.StoreID
			, rg.ScoreboardStoreID
			, rg.SalesPersonID
			, rg.SalesPersonName
			, rg.SalesPersonUserName
			, rg.StatusStartTime
			, rg.StatusEndTime
			, DATEDIFF(SECOND, rg.StatusStartTime, rg.StatusEndTime) AS StatusLength
			, rg.StatusStartDate
			, rg.StatusStartHour
			, rg.RecordedUpDate
			, rg.RecordedUpHour
			, rg.SPUBStatusID
			, rg.GuestName
			, rg.isCountedAsUP
			, rg.isSale
			, rg.StrikeCount
			, rg.Shot
			, rg.FinApp
			, rg.ReasonManagerAddWith
			, rg.ReasonManagerAddSP
			, rg.ReasonManagerAddUps
			, rg.ReasonManagerRemoveSP
			, rg.ManagerCoachingNotes
			, rg.ManagerCoachingNotesTime
			, rg.IsStrike
			, rg.IsStrikeOut
			, rg.ConsecutiveStrikes
			, rg.ConsecutiveStrikeOuts
		INTO #activity
		FROM [Retail_Sales_Enh].[SalesPersonUPBoardHistory] rg
		INNER JOIN [Retail_Sales].[ScoreboardUpBoardStatuses] s 
		ON s.StatusID = rg.SPUBStatusID
		WHERE RecordedUpDate BETWEEN @StartDate AND @EndDate;

		IF OBJECT_ID('tempdb..#max_values') IS NOT NULL 
		DROP TABLE #max_values;

		SELECT
			Source
			, StoreID
			, ScoreboardStoreID
			, SalesPersonID
			, RecordedUpDate
			, MAX(ConsecutiveStrikes) AS MaxConsecutiveStrikes
			, MAX(ConsecutiveStrikeOuts) AS MaxConsecutiveStrikeOuts
		INTO #max_values
		FROM [Retail_Sales_Enh].[SalesPersonUPBoardHistory]
		WHERE ConsecutiveStrikes IS NOT NULL
		AND RecordedUpDate BETWEEN @StartDate AND @EndDate
		GROUP BY
			Source
			, StoreID
			, ScoreboardStoreID
			, SalesPersonID
			, RecordedUpDate;

		IF OBJECT_ID('tempdb..#last_values') IS NOT NULL 
		DROP TABLE #last_values;

		SELECT
			Source
			, StoreID
			, ScoreboardStoreID
			, SalesPersonID
			, RecordedUpDate
			, ConsecutiveStrikes AS LastConsecutiveStrikes
			, ConsecutiveStrikeOuts AS LastConsecutiveStrikeOuts
		INTO #last_values
		FROM 
		(
			SELECT
				Source
				, StoreID
				, ScoreboardStoreID
				, SalesPersonID
				, RecordedUpDate
				, ConsecutiveStrikes
				, ConsecutiveStrikeOuts
				, ROW_NUMBER() OVER (PARTITION BY Source, StoreID, SalesPersonID, RecordedUpDate ORDER BY StatusEndTime DESC) AS row_num
			FROM [Retail_Sales_Enh].[SalesPersonUPBoardHistory]
			WHERE ConsecutiveStrikes IS NOT NULL
			AND RecordedUpDate BETWEEN @StartDate AND @EndDate
		) a
		WHERE row_num = 1;

		DELETE FROM [Retail_Sales_Enh].[ScoreboardActivity]
		WHERE StatusStartDate BETWEEN @StartDate AND @EndDate;

		INSERT INTO [Retail_Sales_Enh].[ScoreboardActivity]
		(
			Source
			, StoreID
			, ScoreboardStoreID
			, LocationName
			, SalesPersonID
			, SalesPersonName
			, StatusStartDate
			, TotalStatusLength
			, RecordCount
			, RecordedUps
			, RecordedClosed
			, Strikes
			, StrikeOuts
			, Shots
			, FinApps
			, MaxConsecutiveStrikes
			, MaxConsecutiveStrikeOuts
			, LastConsecutiveStrikes
			, LastConsecutiveStrikeOuts
			, RedLineCrossedCount
		)

		SELECT
			a.Source
			, a.StoreID
			, a.ScoreboardStoreID
			, sn.LocationName
			, a.SalesPersonID AS SalesPersonID
			, UPPER(a.SalesPersonName) AS SalesPersonName
			, a.RecordedUpDate AS StatusDate
			, SUM(StatusLength) TotalStatusLength
			, COUNT(*) AS RecordedCount
			, SUM(CASE WHEN SPUBStatusID = 99 THEN 1 
					 WHEN isCountedAsUP = 1 AND DATEDIFF(SECOND, StatusStartTime, StatusEndTime) > 60 THEN 1 
					 ELSE 0 END) AS RecordedUps
			, SUM(isSale) AS Closed
			, SUM(CASE a.IsStrike WHEN 1 THEN 1 ELSE 0 END) AS Strikes
			, SUM(CASE a.IsStrikeOut WHEN 1 THEN 1 ELSE 0 END) AS StrikeOuts
			, SUM(Shot) AS Shots
			, SUM(FinApp) AS FinApps
			, MAX(ISNULL(mv.MaxConsecutiveStrikes, 0)) AS MaxConsecutiveStrikes
			, MAX(ISNULL(mv.MaxConsecutiveStrikeOuts, 0)) AS MaxConsecutiveStrikeOuts
			, MAX(ISNULL(lv.LastConsecutiveStrikes, 0)) AS LastConsecutiveStrikes
			, MAX(ISNULL(lv.LastConsecutiveStrikeOuts, 0)) AS LastConsecutiveStrikeOuts
			, SUM(CASE WHEN IsStrike = 1 AND ConsecutiveStrikes = 9 THEN 1 ELSE 0 END) AS RedLineCrossedCount
		FROM #activity a
		INNER JOIN [MasterData_Retail_Ent].[StoreLocation] sn 
		ON sn.StoreID = a.StoreID
		LEFT JOIN #max_values mv 
		ON mv.StoreID = a.StoreID 
		AND mv.SalesPersonID = a.SalesPersonID 
		AND mv.RecordedUpDate = a.RecordedUpDate
		LEFT JOIN #last_values lv 
		ON lv.StoreID = a.StoreID 
		AND lv.SalesPersonID = a.SalesPersonID 
		AND lv.RecordedUpDate = a.RecordedUpDate
		GROUP BY 
			a.Source
			, a.StoreID
			, a.ScoreboardStoreID
			, sn.LocationName
			, a.SalesPersonID
			, a.SalesPersonName
			, a.RecordedUpDate
		ORDER BY
			a.StoreID
			, a.SalesPersonName
			, a.RecordedUpDate;

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
		Exec [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase,@DestinationSchema,@DestinationTable
		
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