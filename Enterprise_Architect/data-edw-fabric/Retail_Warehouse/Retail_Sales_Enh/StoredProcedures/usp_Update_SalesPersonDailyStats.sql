CREATE PROCEDURE [Retail_Sales_Enh].[usp_Update_SalesPersonDailyStats]
AS

BEGIN
	
	DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
    SET @String = 'Retail_Sales_Enh.usp_Update_SalesPersonDailyStats' ;
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'Retail_Sales_Enh'
	SET @DestinationTable = 'SalesPersonDailyStats';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

	BEGIN TRY

		--TRUNCATE TABLE [Retail_Sales_Enh].[SalesPersonDailyStats];

		DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(ID),0) FROM [Retail_Sales_Enh].[SalesPersonDailyStats]);

		--update all data for dates for which someone has modified in the past 2 days

		IF OBJECT_ID('tempdb..#TransDate') IS NOT NULL 
		DROP TABLE #TransDate;

		SELECT	DISTINCT TransDate
		INTO #TransDate
		FROM [Retail_Sales_Enh].[SalesPersonHourlyStats]
		WHERE DateChanged >= CAST(DATEADD(DAY, -2, GETDATE()) AS DATE)
		AND LiveIND = 1;

		--update all data for the past X dates (based on 
		INSERT INTO #TransDate (TransDate)
		SELECT DISTINCT TransDate
		FROM [Retail_Sales_Enh].[SalesPersonHourlyStats]
		WHERE TransDate >= CAST(DATEADD(DAY, -2, GETDATE()) AS DATE)
		AND TransDate NOT IN 
		(
			SELECT DISTINCT TransDate 
			FROM #TransDate
		);

		--update the UP counts on any existing SPDailyStats rows

		UPDATE ds
		SET RecordedUps = hs.ups
			, StrikeOuts = hs.StrikeOuts
			, HotRotations = hs.HotRotations
			, DateChanged = GETDATE()
		FROM [Retail_Sales_Enh].[SalesPersonDailyStats] ds
		INNER JOIN 
		(
			SELECT DISTINCT 
				Source
				, StoreID
				, SalesPersonID
				, TransDate
				, SUM(Ups) AS Ups
				, SUM(StrikeOuts) AS StrikeOuts
				, SUM(HotRotations) AS HotRotations
			FROM [Retail_Sales_Enh].[SalesPersonHourlyStats]
			WHERE TransDate IN 
			(
				SELECT DISTINCT TransDate 
				FROM #TransDate
			)
			AND LiveIND = 1
			GROUP BY Source
					, StoreID
					, SalesPersonID
					, TransDate
		) hs 
		ON (ds.StoreID = hs.StoreID
		AND ds.SalesPersonID = hs.SalesPersonID
		AND ds.TransDate = hs.TransDate);

		--insert any new rows into daily stats where we have UP data in the hourly table but no corresponding row in the daily table

		INSERT INTO [Retail_Sales_Enh].[SalesPersonDailyStats]
		( 
			ID
			, Source
			, StoreID
			, SalesPersonID
			, TransDate
			, RecordedUps
			, Prospects
			, Treat
			, Quotes
			, Sold
			, Worked
			, BeBack
			, StrikeOuts
			, HotRotations
			, DateCreated
			, CreatedBy
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY hs.StoreID, hs.SalesPersonID, hs.TransDate) AS BIGINT) AS ID
			, hs.Source
			, hs.StoreID
			, hs.SalesPersonID
			, hs.TransDate
			, hs.Ups AS RecordedUps
			, 0 AS Prospects
			, 0 AS Treat
			, NULL AS Quotes
			, NULL AS Sold
			, NULL AS Worked
			, NULL AS BeBack
			, hs.StrikeOuts
			, hs.HotRotations
			, GETDATE()
			, 'SYS'
		FROM
		(
			SELECT DISTINCT
				Source
				, StoreID
				, SalesPersonID
				, TransDate
				, SUM(Ups) AS Ups
				, SUM(StrikeOuts) AS StrikeOuts
				, SUM(HotRotations) AS HotRotations
			FROM [Retail_Sales_Enh].[SalesPersonHourlyStats]
			WHERE TransDate IN 
			(
				SELECT DISTINCT TransDate 
				FROM #TransDate
			)
			AND LiveIND = 1
			GROUP BY Source
					, StoreID
					, SalesPersonID
					, TransDate
		) hs
		LEFT JOIN [Retail_Sales_Enh].[SalesPersonDailyStats] ds 
		ON (ds.StoreID = hs.StoreID
		AND ds.SalesPersonID = hs.SalesPersonID 
		AND ds.TransDate = hs.TransDate)
		WHERE ds.ID IS NULL;

	DROP TABLE #TransDate;

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