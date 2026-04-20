CREATE PROCEDURE [Retail_DW_Core].[usp_Update_FactScoreboardManagerNotes]
AS
BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Update_FactScoreboardManagerNotes';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'FactScoreboardManagerNotes';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		--TRUNCATE TABLE [Retail_DW_Core].[FactScoreboardManagerNotes];
	
		DECLARE @StartDate DATE = GETDATE()-30
				, @EndDate DATE = GETDATE();

		DROP TABLE IF EXISTS [Retail_DW_Core].[FactScoreboardManagerNotesHolding];

		CREATE TABLE [Retail_DW_Core].[FactScoreboardManagerNotesHolding]
		(
			[Source] [varchar](5) NULL,
			[IsUP] [varchar](1) NULL,
			[StatusName] [varchar](100) NULL,
			[SalesPersonID] [varchar](20) NULL,
			[SalesPersonName] [varchar](50) NULL,
			[StoreID] [int] NULL,
			[ScoreboardStoreID] [int] NULL,
			[StatusStartDate] [date] NULL,
			[StartTime] [varchar](8) NULL,
			[EndTime] [varchar](8) NULL,
			[ManagerNotes] [varchar](600) NULL,
			[IsClosed] [varchar](3) NULL,
			[StrikeCount] [int] NULL,
			[IsStrike] [int] NULL,
			[IsStrikeOut] [int] NULL,
			[ConsecutiveStrikes] [varchar](20) NULL,
			[ConsecutiveStrikeOuts] [varchar](20) NULL,
			[Shot] [int] NULL,
			[FinApp] [int] NULL			
		);

		INSERT INTO [Retail_DW_Core].[FactScoreboardManagerNotesHolding]
		(
			Source
			, IsUP
			, StatusName
			, SalesPersonID
			, SalesPersonName
			, StoreID
			, ScoreboardStoreID
			, StatusStartDate
			, StartTime
			, EndTime
			, ManagerNotes
			, IsClosed
			, StrikeCount
			, IsStrike
			, IsStrikeOut
			, ConsecutiveStrikes
			, ConsecutiveStrikeOuts
			, Shot
			, FinApp
		)

		SELECT
			sbm.Source
			, sbm.IsUP
			, sbm.StatusName
			, sbm.SalesPersonID
			, sbm.SalesPersonName
			, sbm.StoreID
			, sbm.ScoreboardStoreID
			, sbm.StatusStartDate
			, sbm.StartTime
			, sbm.EndTime
			, sbm.ManagerNotes
			, sbm.IsClosed
			, sbm.StrikeCount
			, sbm.IsStrike
			, sbm.IsStrikeOut
			, sbm.ConsecutiveStrikes
			, sbm.ConsecutiveStrikeOuts
			, sbm.Shot
			, sbm.FinApp
		FROM [$(Retail_Warehouse)].[Retail_Sales_Enh].[ScoreboardManagerNotes] sbm
		WHERE StatusStartDate BETWEEN @StartDate AND @EndDate;

		DELETE FROM [Retail_DW_Core].[FactScoreboardManagerNotes]
		WHERE StatusStartDate BETWEEN @StartDate AND @EndDate;

		INSERT INTO [Retail_DW_Core].[FactScoreboardManagerNotes]
		(
			Source
			, IsUP
			, StatusName
			, SalesPersonID
			, SalesPersonName
			, StoreID
			, ScoreboardStoreID
			, StatusStartDate
			, StartTime
			, EndTime
			, ManagerNotes
			, IsClosed
			, StrikeCount
			, IsStrike
			, IsStrikeOut
			, ConsecutiveStrikes
			, ConsecutiveStrikeOuts
			, Shot
			, FinApp
		)

		SELECT 
			Source
			, IsUP
			, StatusName
			, SalesPersonID
			, SalesPersonName
			, StoreID
			, ScoreboardStoreID
			, StatusStartDate
			, StartTime
			, EndTime
			, ManagerNotes
			, IsClosed
			, StrikeCount
			, IsStrike
			, IsStrikeOut
			, ConsecutiveStrikes
			, ConsecutiveStrikeOuts
			, Shot
			, FinApp
		FROM [Retail_DW_Core].[FactScoreboardManagerNotesHolding];

		DROP TABLE [Retail_DW_Core].[FactScoreboardManagerNotesHolding];

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