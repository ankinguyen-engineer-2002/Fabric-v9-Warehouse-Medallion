CREATE PROCEDURE [Retail_Sales_Enh].[usp_ProtectionPlanSalesTrans_Insert] 
	@_OrderID VARCHAR(50),
	@_ItemID INT,
	@_TransDate DATE
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Enh.usp_ProtectionPlanSalesTrans_Insert';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_Sales_Enh';
	SET @DestinationTable = 'ProtectionPlanSalesTrans';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		DECLARE	
				@OrderID VARCHAR(50),
				@ItemID INT,
				@TransDate DATE;

		SELECT 
			   @OrderID = @_OrderID, 
			   @ItemID = @_ItemID, 
			   @TransDate = @_TransDate;

		--INSERT INTO dbo.ErrorLog (PageId, MethodName, ErrorDetails)
		--VALUES (0, 'proc_ProtectionPlanSalesTrans_Insert', '@OrderID = ' + ISNULL(@OrderID,'NULL')+', @ItemID' + ISNULL(CAST(@ItemID AS VARCHAR),'NULL') + ',@TransDate=' + ISNULL(CONVERT(VARCHAR(10),@TransDate,120), 'NULL'))
	
		SELECT @OrderID

		DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(PPSalesKey),0) FROM [Retail_Sales_Enh].[ProtectionPlanSalesTrans])

		INSERT INTO [Retail_Sales_Enh].[ProtectionPlanSalesTrans]
		(	
			PPSalesKey,
			SalesDataTypeKey,
			ProtectionPlanID,
			OrderID,
			ItemID,
			LocationID,
			BaseOrderID,
			SalesPersonID,
			TransDate,
			TransCodeID,
			Sales,
			Cost,
			Units,
			Source,
			CustomerID,
			CurrentRec,
			DateCreated
		)

		SELECT	
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY ProtectionPlanID) AS BIGINT),
			ppst.SalesDataTypeKey,
			ppst.ProtectionPlanID,
			ppst.OrderID,
			ppst.ItemID,
			ppst.LocationID,
			ppst.BaseOrderID,
			ppst.SalesPersonID,
			@TransDate AS TransDate,
			ppst.TransCodeID,
			ppst.Sales * -1,
			ppst.Cost * -1,
			ppst.Units * -1,
			ppst.Source,
			ppst.CustomerID,
			0 AS CurrentRec,
			GETDATE()
			FROM [Retail_Sales_Enh].[ProtectionPlanSalesTrans] AS ppst
			WHERE ppst.OrderID = @OrderID
			AND ppst.ItemID = @ItemID
			AND ppst.SalesDataTypeKey = 10
			AND ppst.CurrentRec = 1;

		/* Change Current Record Status */
		UPDATE	[Retail_Sales_Enh].[ProtectionPlanSalesTrans]
		SET CurrentRec = 0
		WHERE	OrderID = @OrderID
		AND ItemID = @ItemID
		AND SalesDataTypeKey = 10
		AND CurrentRec = 1;

		INSERT INTO [Retail_Sales_Enh].[ProtectionPlanSalesTrans]
		(	
			PPSalesKey,
			SalesDataTypeKey,
			ProtectionPlanID,
			OrderID,
			ItemID,
			LocationID,
			BaseOrderID,
			SalesPersonID,
			TransDate,
			TransCodeID,
			Sales,
			Cost,
			Units,
			Source,
			CustomerID,
			CurrentRec,
			DateCreated
		)

		SELECT	
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY ProtectionPlanID) AS BIGINT),
			10 AS SalesDataTypeKey,
			wppt.ProtectionPlanID,
			wppt.OrderID,
			wppt.ItemID,
			wppt.LocationID,
			wppt.OrderID,
			wppt.SalesPersonID,
			@TransDate TransDate,
			wppt.TransCodeID,
			wppt.Sales,
			wppt.Cost,
			wppt.Units,
			'W' AS Source,
			wppt.CustomerID,
			1 AS CurrentRec,
			GETDATE()
		FROM [Retail_Sales_Wrk].[ProtectionPlanTrans] AS wppt
		WHERE wppt.OrderID = @OrderID
		AND wppt.ItemID = @ItemID;

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