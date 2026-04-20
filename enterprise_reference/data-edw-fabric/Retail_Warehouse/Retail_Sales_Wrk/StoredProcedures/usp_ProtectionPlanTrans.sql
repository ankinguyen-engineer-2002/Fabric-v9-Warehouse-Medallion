CREATE PROCEDURE [Retail_Sales_Wrk].[usp_ProtectionPlanTrans] 
    @_OrderID VARCHAR(50),
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
			      
	SET @String = 'Retail_Sales_Wrk.usp_ProtectionPlanTrans';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		DECLARE @OrderID VARCHAR(50),
				@TransDate DATE;

		SELECT @OrderID = @_OrderID, 
			   @TransDate = @_TransDate;

		TRUNCATE TABLE Retail_Sales_Wrk.ItemsToProcess;

		--Create temp table to hold ItemIDs to process
		SELECT @_OrderID, @_TransDate

		--Insert distinct ItemIDs that need processing
		INSERT INTO [Retail_Sales_Wrk].[ItemsToProcess] 
		(
			ItemID,
			RowNum
		)

		SELECT DISTINCT
			ItemID,
			RANK() OVER(Order BY ItemID ASC)
		FROM 
		(
			SELECT ItemID
			FROM 
			(
				SELECT 
					ppst.ProtectionPlanID,
					ppst.OrderID,
					ppst.ItemID,
					ppst.SalesPersonID,
					ppst.Sales,
					ppst.Cost
				FROM [Retail_Sales_Enh].[ProtectionPlanSalesTrans] AS ppst
				WHERE CurrentRec = 1
				AND ppst.OrderID = @OrderID
				AND ppst.SalesDataTypeKey = 10

				EXCEPT

				SELECT 
					wppt.ProtectionPlanID,
					wppt.OrderID,
					wppt.ItemID,
					wppt.SalesPersonID,
					wppt.Sales,
					wppt.Cost
				FROM [Retail_Sales_Wrk].[ProtectionPlanTrans] AS wppt
				WHERE wppt.OrderID = @OrderID
			) a

			UNION ALL

			SELECT ItemID
			FROM 
			(
				SELECT
					wppt.ProtectionPlanID,
					wppt.OrderID,
					wppt.ItemID,
					wppt.SalesPersonID,
					wppt.Sales,
					wppt.Cost
				FROM [Retail_Sales_Wrk].[ProtectionPlanTrans] AS wppt
				WHERE wppt.OrderID = @OrderID

				EXCEPT

				SELECT 
					ppst.ProtectionPlanID,
					ppst.OrderID,
					ppst.ItemID,
					ppst.SalesPersonID,
					ppst.Sales,
					ppst.Cost
				FROM [Retail_Sales_Enh].[ProtectionPlanSalesTrans] AS ppst
				WHERE CurrentRec = 1
				AND ppst.OrderID = @OrderID
				AND ppst.SalesDataTypeKey = 10
			) b
		) itm;

		-- Process each ItemID using WHILE loop
		DECLARE @ItemID INT;
		DECLARE @CurrentRow INT = 1;
		DECLARE @MaxRows INT;

		SELECT @MaxRows = COUNT(*) 
		FROM Retail_Sales_Wrk.ItemsToProcess;

		WHILE @CurrentRow <= @MaxRows

		BEGIN
			-- Get the next ItemID
			SELECT @ItemID = ItemID 
			FROM Retail_Sales_Wrk.ItemsToProcess 
			WHERE RowNum = @CurrentRow;

			-- Process this ItemID
			 EXEC [Retail_Sales_Enh].[usp_ProtectionPlanSalesTrans_Insert] @OrderID, @ItemID, @TransDate;

			SET @CurrentRow = @CurrentRow + 1;

		END

		-- Clean up
		--DROP TABLE [Retail_Sales_Wrk].[ItemsToProcess];

		SET @DateValue = GETDATE();

		SELECT
			@DateValue = CSTDateValue
		FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

		INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
		VALUES
		(
			@String, @DateValue, @User, 'Process Complete'
		);
	
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