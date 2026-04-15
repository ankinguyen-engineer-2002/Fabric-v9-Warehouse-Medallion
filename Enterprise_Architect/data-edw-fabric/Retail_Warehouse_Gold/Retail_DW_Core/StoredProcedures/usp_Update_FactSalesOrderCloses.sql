CREATE   PROCEDURE [Retail_DW_Core].[usp_Update_FactSalesOrderCloses]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Update_FactSalesOrderCloses';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'FactSalesOrderCloses';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		--TRUNCATE TABLE [Retail_DW_Core].[FactSalesOrderCloses];

		DECLARE @TransDate DATE = GETDATE();

	    DROP TABLE IF EXISTS [Retail_DW_Core].[FactSalesOrderClosesHolding];

		CREATE TABLE [Retail_DW_Core].[FactSalesOrderClosesHolding]
		(
			[SuperOrderID] [varchar](50) NOT NULL,
			[SourceOrderID] [varchar](100) NULL,
			[CountTypeID] [varchar](10) NULL,
			[CustomerID] [varchar](30) NOT NULL,
			[StoreID] [int] NOT NULL,
			[SalesPersonID] [varchar](30) NOT NULL,
			[OrderDateKey] [int] NOT NULL,
			[TransDateKey] [int] NOT NULL,
			[SPSales] [decimal](19,4) NULL,
			[SPClose] [decimal](19,4) NULL,
			[SUClose] [decimal](19,4) NULL,
			[SUOpp] [decimal](19,4) NULL,
			[SOClose] [decimal](19,4) NULL,
			[SOOpp] [decimal](19,4) NULL,
			[CurrentRec] [int] NULL,
			[DateChanged] [datetime2](3) NULL
		);

		INSERT INTO [Retail_DW_Core].[FactSalesOrderClosesHolding]
		(
			SuperOrderID
			, SourceOrderID
			, CountTypeID
			, CustomerID
			, StoreID
			, SalesPersonID
			, OrderDateKey
			, TransDateKey
			, SPSales
			, SPClose
			, SUClose
			, SUOpp
			, SOClose
			, SOOpp
			, CurrentRec
			, DateChanged
		)

		SELECT
			SuperOrderID
			, OrderID AS SourceOrderID
			, CountTypeID
			, CustomerID
			, LocationID AS StoreID
			, SalesPersonID
			, OrderDateKey
			, TransDateKey
			, SPSales
			, SPClose
			, SUClose
			, SUOpp
			, SOClose
			, SOOpp
			, CurrentRec
			, DateChanged
		FROM [$(Retail_Warehouse)].[Retail_Sales_Enh].[SalesOrderCloses]
		WHERE CAST(DateChanged AS DATE) >= @TransDate;

		DELETE FROM [Retail_DW_Core].[FactSalesOrderCloses]
		WHERE CAST(DateChanged AS DATE) >= @TransDate;

		INSERT INTO [Retail_DW_Core].[FactSalesOrderCloses]
		(
			SuperOrderID
			, SourceOrderID
			, CountTypeID
			, CustomerID
			, StoreID
			, SalesPersonID
			, OrderDateKey
			, TransDateKey
			, SPSales
			, SPClose
			, SUClose
			, SUOpp
			, SOClose
			, SOOpp
			, CurrentRec
			, DateChanged
		)

		SELECT
			SuperOrderID
			, SourceOrderID
			, CountTypeID
			, CustomerID
			, StoreID
			, SalesPersonID
			, OrderDateKey
			, TransDateKey
			, SPSales
			, SPClose
			, SUClose
			, SUOpp
			, SOClose
			, SOOpp
			, CurrentRec
			, DateChanged
		FROM [Retail_DW_Core].[FactSalesOrderClosesHolding];

	    DROP TABLE IF EXISTS [Retail_DW_Core].[FactSalesOrderClosesHolding];

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