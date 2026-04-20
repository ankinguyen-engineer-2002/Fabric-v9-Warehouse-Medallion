CREATE PROCEDURE [Retail_Sales_Enh].[usp_Update_SalesAssociateCommission]
AS
BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Enh.usp_Update_SalesAssociateCommission';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_Sales_Enh';
	SET @DestinationTable = 'SalesAssociateCommission';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		--TRUNCATE TABLE [Retail_Sales_Enh].[SalesOrderProductInfo];

		INSERT INTO [Retail_Sales_Enh].[SalesAssociateCommission]
		(
			SourceSystem
			, SalesPersonID
			, SourceOrderID
			, SKU
			, LineNumber
			, PosID
			, ItemCommCategory
			, CommissionStatus
			, PercentCommission
			, DateChanged
			, DateCreated
			, RecStatus
		)
	
		SELECT	
			src.SourceSystem
			, src.SalesPersonID
			, src.SourceOrderID
			, src.SKU
			, src.LineNumber
			, src.PosID
			, src.ItemCommCategory
			, src.CommissionStatus
			, src.PercentCommission
			, src.DateChanged
			, src.DateCreated
			, src.RecStatus
		FROM [Retail_Sales].[SalesAssociateCommission] AS src
		WHERE NOT EXISTS
		(
			SELECT 1
			FROM [Retail_Sales_Enh].[SalesAssociateCommission] dst
			WHERE dst.SourceOrderID = src.SourceOrderID
			AND dst.SKU = src.SKU
			AND dst.SalesPersonID = src.SalesPersonID
			AND dst.PosID = src.PosID
		);

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