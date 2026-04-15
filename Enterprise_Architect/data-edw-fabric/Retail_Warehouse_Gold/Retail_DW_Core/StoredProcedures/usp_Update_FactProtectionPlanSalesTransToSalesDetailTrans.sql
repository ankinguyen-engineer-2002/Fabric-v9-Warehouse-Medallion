CREATE   PROCEDURE [Retail_DW_Core].[usp_Update_FactProtectionPlanSalesTransToSalesDetailTrans]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Update_FactProtectionPlanSalesTransToSalesDetailTrans';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'FactSales';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY
	
		DECLARE @TransDateKey AS INT = CONVERT(VARCHAR(8), DATEADD(DAY, -1, GETDATE()), 112);

		DELETE [Retail_DW_Core].[FactSales]
		WHERE SalesDataTypeKey IN (10, 11)
		AND TransDateKey = @TransDateKey;

		INSERT INTO [Retail_DW_Core].[FactSales]
		(
			SourceSystem
			, SourceDataID
			, SalesDataTypeKey
			, TransDateKey
			, ProductKey
			, CustomerKey
			, SalesPersonKey
			, LocationKey
			, OrderDateKey
			, SUOrderID
			, BaseOrderID
			, OrderID
			, ItemID
			, TransCodeID
			, TransDateTime
			, UpdateTypeID
			, Cost
			, SalesType
			, DateCreated
			, Sales
			, Units
			, ShipLocationID
			, FRLocationID
			, ItemCommCategory
			, PPPOpp
			, PPPClose
			, GrossMultiplier
			, SalesLeadSourceID
		)

		SELECT 
			CASE WHEN v.OrderID NOT LIKE '%[A-Z][A-Z][0-9]%' THEN 'STORIS_DSG'
			WHEN v.OrderID LIKE '%[A-Z][A-Z][0-9]%' THEN 'HOMES_CORPORATE'
			ELSE 'Unknown' END AS SourceSystem
			, v.ProtectionPlanID + CAST(v.PPSalesKey AS VARCHAR(20)) AS SourceDataID
			, v.SalesDataTypeKey
			, v.TransDateKey
			, v.ProductKey
			, v.CustomerKey
			, v.SalesPersonKey
			, v.LocationKey
			, v.OrderDateKey
			, v.SuperOrderID
			, v.BaseOrderID
			, v.OrderID
			, v.ItemID
			, v.TransCodeID
			, v.TransDate AS TransDateTime
			, v.UpdateTypeID
			, v.Cost
			, v.Source AS SalesType
			, v.DateCreated
			, v.Sales
			, v.Units
			, v.DeliveryStoreID
			, v.FRLocationID
			, v.ItemCommCategory
			, v.PPPOpp
			, v.PPPClose
			, v.GrossMultiplier
			, v.SalesLeadSourceID
		FROM [Retail_DW_Core].[FactProtectionPlanSalesTrans] AS v
		WHERE TransDateKey >= @TransDateKey;

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