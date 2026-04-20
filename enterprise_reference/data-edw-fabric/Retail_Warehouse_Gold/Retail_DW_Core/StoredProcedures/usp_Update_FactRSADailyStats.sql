CREATE   PROCEDURE [Retail_DW_Core].[usp_Update_FactRSADailyStats]
AS
BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Update_FactRSADailyStats';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'FactRSADailyStats';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		-- TRUNCATE TABLE [Retail_DW_Core].[FactRSADailyStats];
	
		DECLARE @StartDate DATE = GETDATE()-30
				, @EndDate DATE = GETDATE();

		DROP TABLE IF EXISTS [Retail_DW_Core].[FactRSADailyStatsHolding];

		CREATE TABLE [Retail_DW_Core].[FactRSADailyStatsHolding]
		(
			[ID] [bigint] NOT NULL,
			[Source] [varchar](5) NOT NULL,
			[StoreID] [int] NOT NULL,
			[SalesPersonID] [varchar](30) NOT NULL,
			[TransDate] [date] NOT NULL,
			[RecordedUps] [int] NULL,
			[Prospects] [int] NULL,
			[Treat] [int] NULL,
			[Quotes] [int] NULL,
			[Sold] [int] NULL,
			[Worked] [int] NULL,
			[BeBack] [int] NULL,
			[DateCreated] [datetime2](3) NULL,
			[CreatedBy] [varchar](10) NULL,
			[DateChanged] [datetime2](3) NULL,
			[ChangedBy] [varchar](10) NULL,
			[StrikeOuts] [int] NULL,
			[HotRotations] [int] NULL,
			[Shots] [int] NULL
		);

		INSERT INTO [Retail_DW_Core].[FactRSADailyStatsHolding]
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
			, DateCreated
			, CreatedBy
			, DateChanged 
			, ChangedBy 
			, StrikeOuts 
			, HotRotations 
			, Shots
		)

		SELECT 
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
			, DateCreated
			, CreatedBy
			, DateChanged 
			, ChangedBy 
			, StrikeOuts 
			, HotRotations 
			, Shots
		FROM [$(Retail_Warehouse)].[Retail_Sales_Enh].[SalesPersonDailyStats]
		WHERE TransDate BETWEEN @StartDate AND @EndDate;

		DELETE FROM [Retail_DW_Core].[FactRSADailyStats]
		WHERE TransDate BETWEEN @StartDate AND @EndDate;

		INSERT INTO [Retail_DW_Core].[FactRSADailyStats]
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
			, DateCreated
			, CreatedBy
			, DateChanged 
			, ChangedBy 
			, StrikeOuts 
			, HotRotations 
			, Shots
		)

		SELECT 
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
			, DateCreated
			, CreatedBy
			, DateChanged 
			, ChangedBy 
			, StrikeOuts 
			, HotRotations 
			, Shots
		FROM [Retail_DW_Core].[FactRSADailyStatsHolding];

		DROP TABLE [Retail_DW_Core].[FactRSADailyStatsHolding];

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