CREATE PROCEDURE [Retail_DW_Core].[usp_Update_FactSalesOrderTrans]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Update_FactSalesOrderTrans';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'FactSalesOrderTrans';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		--TRUNCATE TABLE [Retail_DW_Core].[FactSalesOrderTrans];

		DECLARE @TransDate DATE = GETDATE();

		UPDATE sot
		SET sot.OrderKey = soh.OrderKey
		FROM [Retail_DW_Core].[FactSalesOrderTrans] sot
		INNER JOIN [$(Retail_Warehouse)].[Retail_Sales_Enh].[SalesOrderHist] soh
		ON sot.OrderID = soh.OrderID;

		DROP TABLE IF EXISTS [Retail_DW_Core].[FactSalesOrderTransHolding];

		CREATE TABLE [Retail_DW_Core].[FactSalesOrderTransHolding]
		(
			[SalesOrderHistKey] [bigint] NULL,
			[OrderKey] [bigint] NULL,
			[OrderID] [varchar](30) NULL,
			[SalesDataTypeKey] [int] NOT NULL,
			[TransDateKey] [int] NOT NULL,
			[SalesPersonID] [varchar](50) NOT NULL,
			[TransValue] [decimal](18, 2) NULL,
			[TransKey] [varchar](50) NOT NULL,
			[CurrentRec] [bit] NULL,
			[DateCreated] [datetime2](3) NULL
		)

		INSERT INTO [Retail_DW_Core].[FactSalesOrderTransHolding]
		(	
			SalesOrderHistKey
			, OrderKey
			, OrderID
			, SalesDataTypeKey
			, TransDateKey
			, SalesPersonID
			, TransValue
			, TransKey
			, CurrentRec
			, DateCreated
		)

		SELECT 
			SalesOrderHistKey
			, OrderKey
			, OrderID
			, SalesDataTypeKey
			, TransDateKey
			, SalesPersonID
			, TransValue
			, TransKey
			, CurrentRec
			, DateCreated  
		FROM [$(Retail_Warehouse)].[Retail_Sales_Enh].[SalesOrderHist]
		WHERE CAST(DateCreated AS DATE) >= @TransDate;

		DELETE FROM [Retail_DW_Core].[FactSalesOrderTrans]
		WHERE CAST(DateCreated AS DATE) >= @TransDate;

		INSERT INTO [Retail_DW_Core].[FactSalesOrderTrans]
		(	
			SalesOrderHistKey
			, OrderKey
			, OrderID
			, SalesDataTypeKey
			, TransDateKey
			, SalesPersonID
			, TransValue
			, TransKey
			, CurrentRec
			, DateCreated 
		)

		SELECT
			SalesOrderHistKey
			, OrderKey
			, OrderID
			, SalesDataTypeKey
			, TransDateKey
			, SalesPersonID
			, TransValue
			, TransKey
			, CurrentRec
			, DateCreated
		FROM [Retail_DW_Core].[FactSalesOrderTransHolding];

       DROP TABLE IF EXISTS [Retail_DW_Core].[FactSalesOrderTransHolding];

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