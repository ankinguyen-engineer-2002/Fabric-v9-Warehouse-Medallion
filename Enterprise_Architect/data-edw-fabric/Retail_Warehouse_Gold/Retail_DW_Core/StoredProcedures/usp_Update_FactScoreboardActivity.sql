CREATE PROCEDURE [Retail_DW_Core].[usp_Update_FactScoreboardActivity]
AS
BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Update_FactScoreboardActivity';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'FactScoreboardActivity';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		--TRUNCATE TABLE [Retail_DW_Core].[FactScoreboardActivity];
	
		DECLARE @StartDate DATE = GETDATE()-30 
				, @EndDate DATE = GETDATE();

		DROP TABLE IF EXISTS [Retail_DW_Core].[FactScoreboardActivityHolding];

		CREATE TABLE [Retail_DW_Core].[FactScoreboardActivityHolding]
		(
			[Source] [varchar](5) NULL,
			[StoreID] [int] NULL,
			[ScoreboardStoreID] [int] NULL,
			[LocationName] [varchar](255) NULL,
			[SalesPersonID] [varchar](20) NULL,
			[SalesPersonName] [varchar](50) NULL,
			[StatusStartDate] [date] NULL,
			[TotalStatusLength] [int] NULL,
			[RecordCount] [int] NULL,
			[RecordedUps] [int] NULL,
			[RecordedClosed] [int] NULL,
			[Strikes] [int] NULL,
			[StrikeOuts] [int] NULL,
			[Shots] [int] NULL,
			[FinApps] [int] NULL,
			[MaxConsecutiveStrikes] [int] NULL,
			[MaxConsecutiveStrikeOuts] [int] NULL,
			[LastConsecutiveStrikes] [int] NULL,
			[LastConsecutiveStrikeOuts] [int] NULL,
			[RedLineCrossedCount] [int] NULL		
		);

		INSERT INTO [Retail_DW_Core].[FactScoreboardActivityHolding]
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
			sba.Source
			, sba.StoreID
			, sba.ScoreboardStoreID
			, sba.LocationName
			, sba.SalesPersonID
			, sba.SalesPersonName
			, sba.StatusStartDate
			, sba.TotalStatusLength
			, sba.RecordCount
			, sba.RecordedUps
			, sba.RecordedClosed
			, sba.Strikes
			, sba.StrikeOuts
			, sba.Shots
			, sba.FinApps
			, sba.MaxConsecutiveStrikes
			, sba.MaxConsecutiveStrikeOuts
			, sba.LastConsecutiveStrikes
			, sba.LastConsecutiveStrikeOuts
			, sba.RedLineCrossedCount
		FROM [$(Retail_Warehouse)].[Retail_Sales_Enh].[ScoreboardActivity] sba
		WHERE StatusStartDate BETWEEN @StartDate AND @EndDate;

		DELETE FROM [Retail_DW_Core].[FactScoreboardActivity]
		WHERE StatusStartDate BETWEEN @StartDate AND @EndDate;

		INSERT INTO [Retail_DW_Core].[FactScoreboardActivity]
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
		FROM [Retail_DW_Core].[FactScoreboardActivityHolding];

		DROP TABLE [Retail_DW_Core].[FactScoreboardActivityHolding];

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
		EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase, @DestinationSchema, @DestinationTable
	
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