CREATE PROCEDURE [Retail_Sales_Wrk].[usp_ProtectionPlanTrans_Bulk]
AS

BEGIN

    SET NOCOUNT ON;

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Wrk.usp_ProtectionPlanTrans_Bulk';
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

		SELECT DISTINCT 
			OrderID, 
			TransDate
		INTO #QueuedOrders
		FROM [Retail_Sales_Wrk].[ProtectionPlanQueue];

		IF NOT EXISTS 
		(
			SELECT 1 
			FROM #QueuedOrders
		)

		BEGIN

			DROP TABLE #QueuedOrders;

			RETURN

		END

		SELECT DISTINCT 
			q.OrderID,
			q.TransDate,
			itm.ItemID
		INTO #ItemsToProcess
		FROM #QueuedOrders q
		CROSS APPLY 
		(
			SELECT ItemID
			FROM (
				-- Items in production that aren't in working table (deletions/changes)
				SELECT 
					ppst.ProtectionPlanID,
					ppst.OrderID,
					ppst.ItemID,
					ppst.SalesPersonID,
					ppst.Sales,
					ppst.Cost
				FROM [Retail_Sales_Enh].[ProtectionPlanSalesTrans] AS ppst
				WHERE ppst.CurrentRec = 1
					AND ppst.OrderID = q.OrderID
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
				WHERE wppt.OrderID = q.OrderID
			) a

			UNION ALL
            
			-- Items in working table that aren't in production (additions/changes)
			SELECT ItemID
			FROM (
				SELECT 
					wppt.ProtectionPlanID,
					wppt.OrderID,
					wppt.ItemID,
					wppt.SalesPersonID,
					wppt.Sales,
					wppt.Cost
				FROM [Retail_Sales_Wrk].[ProtectionPlanTrans] AS wppt
				WHERE wppt.OrderID = q.OrderID

				EXCEPT

				SELECT 
					ppst.ProtectionPlanID,
					ppst.OrderID,
					ppst.ItemID,
					ppst.SalesPersonID,
					ppst.Sales,
					ppst.Cost
				FROM [Retail_Sales_Enh].[ProtectionPlanSalesTrans] AS ppst
				WHERE ppst.CurrentRec = 1
					AND ppst.OrderID = q.OrderID
					AND ppst.SalesDataTypeKey = 10
			) b
		) itm;


		IF EXISTS 
		(
			SELECT 1 
			FROM #ItemsToProcess
		)

		BEGIN

			DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(PPSalesKey), 0) FROM [Retail_Sales_Enh].[ProtectionPlanSalesTrans]);

			DECLARE @RowCount INT = (SELECT COUNT(*) FROM #ItemsToProcess);


			INSERT INTO [Retail_Sales_Enh].[ProtectionPlanSalesTrans]
			(
				PPSalesKey
				, SalesDataTypeKey
				, ProtectionPlanID
				, OrderID
				, ItemID
				, LocationID
				, BaseOrderID
				, SalesPersonID
				, TransDate
				, TransCodeID
				, Sales
				, Cost
				, Units
				, Source
				, CustomerID
				, CurrentRec
				, DateCreated
			)
			SELECT @MaxID + ROW_NUMBER() OVER (ORDER BY OrderID, ItemID, ProtectionPlanID), * 
			FROM 
			(
				SELECT
					ppst.SalesDataTypeKey
					, ppst.ProtectionPlanID
					, ppst.OrderID
					, ppst.ItemID
					, LTRIM(ppst.LocationID, '0') AS LocationID
					, ppst.BaseOrderID
					, ppst.SalesPersonID
					, itp.TransDate
					, ppst.TransCodeID
					, ppst.Sales * -1 AS Sales
					, ppst.Cost * -1 AS Cost
					, ppst.Units * -1 Units
					, ppst.Source
					, ppst.CustomerID
					, 0 AS CurrentRec
					, GETDATE() AS DateCreated
				FROM [Retail_Sales_Enh].[ProtectionPlanSalesTrans] AS ppst
				INNER JOIN #ItemsToProcess itp 
				ON itp.OrderID = ppst.OrderID 
				AND itp.ItemID = ppst.ItemID
				WHERE ppst.SalesDataTypeKey = 10
				AND ppst.CurrentRec = 1
			) AS a;

			SET @MaxID = @MaxID + @@ROWCOUNT;

			UPDATE ppst
			SET CurrentRec = 0
			FROM [Retail_Sales_Enh].[ProtectionPlanSalesTrans] ppst
			INNER JOIN #ItemsToProcess itp 
			ON itp.OrderID = ppst.OrderID 
			AND itp.ItemID = ppst.ItemID
			WHERE ppst.SalesDataTypeKey = 10
			AND ppst.CurrentRec = 1;

			SET  @MaxID = (SELECT ISNULL(MAX(PPSalesKey), 0) FROM [Retail_Sales_Enh].[ProtectionPlanSalesTrans]);
			SET  @RowCount = (SELECT COUNT(*) FROM #ItemsToProcess);


			INSERT INTO [Retail_Sales_Enh].[ProtectionPlanSalesTrans]
			(
				PPSalesKey
				, SalesDataTypeKey
				, ProtectionPlanID
				, OrderID
				, ItemID
				, LocationID
				, BaseOrderID
				, SalesPersonID
				, TransDate
				, TransCodeID
				, Sales
				, Cost
				, Units
				, Source
				, CustomerID
				, CurrentRec
				, DateCreated
			)
			SELECT @MaxID + ROW_NUMBER() OVER (ORDER BY OrderID, ItemID, ProtectionPlanID),* 
			FROM 
			(
				SELECT 
					10 AS SalesDataTypeKey
					, wppt.ProtectionPlanID
					, wppt.OrderID
					, wppt.ItemID
					, LTRIM(wppt.LocationID, '0') AS LocationID
					, wppt.OrderID AS Base_OrderID
					, wppt.SalesPersonID
					, itp.TransDate
					, wppt.TransCodeID
					, wppt.Sales
					, wppt.Cost
					, wppt.Units
					, 'W' AS Source
					, wppt.CustomerID
					, 1 AS CurrentRec
					, GETDATE() AS DateCreated
				FROM [Retail_Sales_Wrk].[ProtectionPlanTrans] AS wppt
				INNER JOIN #ItemsToProcess itp 
				ON itp.OrderID = wppt.OrderID 
				AND itp.ItemID = wppt.ItemID
			) AS a;

		END

		DROP TABLE #QueuedOrders;

		DROP TABLE #ItemsToProcess;

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