CREATE PROCEDURE [Retail_Sales_Enh].[usp_ProtectionPlanTrans_Insert]
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
			      
	SET @String = 'Retail_Sales_Enh.usp_ProtectionPlanTrans_Insert';
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

		DECLARE @_TransDate DATE = GETDATE()-1

		DECLARE @TransDate DATE;

		SELECT @TransDate  = @_TransDate;

		TRUNCATE TABLE [Retail_Sales_Wrk].[ProtectionPlanTrans];

		TRUNCATE TABLE [Retail_Sales_Wrk].[ProtectionPlanQueue];

		IF OBJECT_ID('tempdb..#TransCode') IS NOT NULL 
		DROP TABLE #TransCode;

		SELECT 
			TransCodeID
			, CASE 
				WHEN TransCodeID BETWEEN 0 AND 9 THEN 1
				WHEN TransCodeID = 20 THEN 1
				WHEN TransCodeID IN (30, 31, 34, 37, 50) THEN -1
				WHEN TransCodeID IN (60, 61, 63, 66) THEN 0
				ELSE NULL
			END AS TransCodeMultiplier
			, Description
		INTO #TransCode
		FROM [$(Source_Data)].[Retail_Corporate].[TransCode]
		WHERE Description <> '<Unknown>';
		
		IF OBJECT_ID('tempdb..#ORD') IS NOT NULL 
		DROP TABLE #ORD;

		SELECT	
			OrderID
			, MAX(TransDate) AS TransDate
		INTO #ORD
		FROM
		(
			SELECT	
				o.OrderID
				, CAST(COALESCE(MAX(o.DateChanged), MAX(o.DateCreated)) AS DATE) AS TransDate
			FROM [$(Source_Data)].[Retail_Corporate].[Orders] AS o
			WHERE CAST(COALESCE(o.DateChanged, o.DateCreated) AS DATE) >= @TransDate
			AND o.TransCodeID NOT IN (3, 6, 63)
			AND o.TransactionSaveTime IS NOT NULL
			GROUP BY o.OrderID
			
			UNION
			
			SELECT	
				o.Base_OrderID AS OrderID
				, CAST(COALESCE(MAX(o.DateChanged), MAX(o.DateCreated)) AS DATE) AS TransDate
			FROM [$(Source_Data)].[Retail_Corporate].[Invoice] AS o
			WHERE CAST(COALESCE(o.DateChanged, o.DateCreated) AS DATE) >= @TransDate
			AND o.TransCodeID NOT IN (3, 6, 63)
			AND o.TransactionSaveTime IS NOT NULL
			GROUP BY o.Base_OrderID
		) OI
		GROUP BY OI.OrderID;

		/* SO Convert to Layaway */
		INSERT INTO #ORD 
		(
			OrderID
			, TransDate
		)

		SELECT
			o.OrderID
			, CAST(COALESCE(MAX(o.DateChanged), MAX(o.DateCreated)) AS DATE) AS TransDate
		FROM [$(Source_Data)].[Retail_Corporate].[Orders] AS o
		WHERE CAST(COALESCE(o.DateChanged, o.DateCreated) AS DATE) >= @TransDate
		AND o.TransCodeID IN (3)
		AND o.TransactionSaveTime IS NOT NULL
		AND o.OrderID IN 
		(
			SELECT OrderID 
			FROM [Retail_Sales_Enh].[ProtectionPlanSalesTrans] AS ppst
		)
		GROUP BY o.OrderID;

		INSERT INTO [Retail_Sales_Wrk].[ProtectionPlanTrans]
		(
			LocationID
			, ProtectionPlanID
			, OrderID
			, ItemID
			, TransCodeID
			, SalesPersonID
			, TransDate
			, Sales
			, Cost
			, Units
			, CustomerID
		)
		
		SELECT 
			ord.LocationID
			, ord.ProtectionPlanID
			, ord.OrderID
			, ord.ItemID
			, ord.TransCodeID
			, ord.SalesPersonID
			, MAX(ord.TransDate) AS TransDate
			, SUM(COALESCE(ord.Sales, 0)) AS Sales
			, SUM(COALESCE(ord.Cost, 0)) AS Cost
			, 0 AS Units
			, ord.CustomerID
		FROM	
		(
			SELECT
				o.OrderBookedStoreID AS LocationID
				, oi.ProtectionPlanID
				, o.OrderID
				, oi.ItemID
				, oi.TransCodeID
				, oici.SalesPersonID
				, CAST(COALESCE(o.DateChanged , o.DateCreated) AS DATE) AS TransDate
				, oi.ProtectionPlanPrice * oici.SplitPct / 100 * tc.TransCodeMultiplier AS Sales
				, oi.ProtectionPlanCost * oici.SplitPct / 100 * tc.TransCodeMultiplier AS Cost
				, o.CustomerID
			FROM [$(Source_Data)].[Retail_Corporate].[Orders] AS o
			INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderItem] AS oi 
			ON oi.OrderID = o.OrderID
			INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderItem_CommissionInfo] AS oici 
			ON oici.OrderID = oi.OrderID
			AND	oici.ItemID = oi.ItemID
			INNER JOIN #TransCode AS tc 
			ON tc.TransCodeID = oi.TransCodeID
			WHERE oi.ProtectionPlanID IS NOT NULL
			AND oi.RecStatus <> 'D'
			AND o.OrderID IN
			(
				SELECT OrderID
				FROM #ORD AS o2
			)
			AND oi.TransCodeID NOT IN (3, 6, 63)

			UNION ALL

			SELECT 
				o.OrderBookedStoreID AS LocationID
				, oi.ProtectionPlanID
				, o.Base_OrderID AS OrderID
				, oi.ItemID
				, oi.TransCodeID
				, oici.SalesPersonID
				, CAST(COALESCE(o.DateChanged , o.DateCreated) AS DATE) AS TransDate
				, oi.ProtectionPlanPrice * oici.SplitPct / 100 * tc.TransCodeMultiplier AS Sales
				, oi.ProtectionPlanCost * oici.SplitPct / 100 * tc.TransCodeMultiplier AS Cost
				, o.CustomerID
			FROM [$(Source_Data)].[Retail_Corporate].[Invoice] AS o
			INNER JOIN [$(Source_Data)].[Retail_Corporate].[InvoiceItem] AS oi
			ON oi.OrderID = o.OrderID
			INNER JOIN [$(Source_Data)].[Retail_Corporate].[InvoiceItem_CommissionInfo] AS oici 
			ON oici.OrderID = oi.OrderID
			AND oici.ItemID = oi.ItemID
			INNER JOIN #TransCode AS tc 
			ON tc.TransCodeID = oi.TransCodeID
			WHERE oi.ProtectionPlanID IS NOT NULL
			AND o.Base_OrderID IN 
			(
				SELECT OrderID 
				FROM #ORD AS o2
			)
			AND oi.TransCodeID NOT IN (3, 6, 63)
			) ord
			GROUP BY ord.LocationID
					 , ord.ProtectionPlanID
					 , ord.OrderID
					 , ord.ItemID
					 , ord.TransCodeID
					 , ord.SalesPersonID
					 , ord.CustomerID;

		IF OBJECT_ID('tempdb..#MDate') IS NOT NULL 
		DROP TABLE #MDate;
		
		SELECT 
			OrderID
			, MAX(wppt.TransDate) AS TransDate
		INTO #MDate
		FROM [Retail_Sales_Wrk].[ProtectionPlanTrans] AS wppt
		GROUP BY wppt.OrderID;

		UPDATE wppt
		SET wppt.TransDate = md.TransDate
		FROM [Retail_Sales_Wrk].[ProtectionPlanTrans] AS wppt
		INNER JOIN #MDate AS md 
		ON md.OrderID = wppt.OrderID;

		IF OBJECT_ID('tempdb..#TotSales') IS NOT NULL 
		DROP TABLE #TotSales;

		SELECT 
			wppt.OrderID
			, wppt.ProtectionPlanID
			, SUM(wppt.Sales) AS TotalSales
		INTO #TotSales
		FROM [Retail_Sales_Wrk].[ProtectionPlanTrans] AS wppt
		GROUP BY wppt.OrderID,
				 wppt.ProtectionPlanID;

		UPDATE wppt
		SET wppt.Units = CASE WHEN TotalSales = 0 THEN 0 ELSE wppt.Sales / TotalSales END
		FROM [Retail_Sales_Wrk].[ProtectionPlanTrans] AS wppt
		INNER JOIN #TotSales AS ts 
		ON ts.OrderID = wppt.OrderID
		AND	ts.ProtectionPlanID = wppt.ProtectionPlanID;

		INSERT INTO [Retail_Sales_Wrk].[ProtectionPlanQueue] 
		(
			OrderID
			, TransDate
			, ProcessStatus
		)

		SELECT
			wppq.OrderID
			, wppq.TransDate
			, 0
		FROM [Retail_Sales_Wrk].[ProtectionPlanTrans] AS wppq
		WHERE wppq.OrderID NOT IN
		(
			SELECT q.OrderID 
			FROM [Retail_Sales_Wrk].[ProtectionPlanQueue] AS q
		) 
		AND wppq.TransDate >= @_TransDate 
		GROUP BY wppq.OrderID,
				 wppq.TransDate;

		INSERT INTO [Retail_Sales_Wrk].[ProtectionPlanQueue]
		(
			OrderID
			, TransDate
			, ProcessStatus
		)

		SELECT 
			wppq.OrderID
			, wppq.TransDate
			, 0
		FROM #ORD AS wppq
		WHERE wppq.OrderID NOT IN 
		(
			SELECT OrderID 
			FROM [Retail_Sales_Wrk].[ProtectionPlanQueue] AS q
		)
		AND wppq.TransDate >= @_TransDate 
		GROUP BY wppq.OrderID,
				 wppq.TransDate;

		DROP TABLE #TotSales;

		DROP TABLE #MDate;

		/* Orverride TransDate to avoid backdating lines that didn't change. Will need to add logic to exclude store conversion*/

		UPDATE [Retail_Sales_Wrk].[ProtectionPlanQueue]
		SET TransDate = CAST(GETDATE() AS DATE);

		/*
		UPDATE wppq
		SET wppq.TransDate = o.OrderDate
		FROM [Retail_Sales_Wrk].[ProtectionPlanQueue] AS wppq
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[Invoice] AS o
		ON o.OrderID = wppq.OrderID
		WHERE o.OrderID NOT IN
		(
			SELECT ppst.OrderID
			FROM [Retail_Sales_Enh].[ProtectionPlanSalesTrans] AS ppst
			WHERE ppst.SalesDataTypeKey = 10
		);
		*/

		UPDATE wppq
		SET wppq.TransDate = o.OrderDate
		FROM [Retail_Sales_Wrk].[ProtectionPlanQueue] AS wppq
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[Orders] AS o
		ON o.OrderID = wppq.OrderID
		WHERE o.OrderID NOT IN
        (
            SELECT ppst.OrderID
            FROM [Retail_Sales_Enh].[ProtectionPlanSalesTrans] AS ppst
            WHERE ppst.SalesDataTypeKey = 10
        );

		/* Remove Orders without PPP*/
		IF OBJECT_ID('tempdb..#PPP') IS NOT NULL 
		DROP TABLE #PPP;
		
		SELECT ppp.OrderID
		INTO #PPP
		FROM
		(
			SELECT wppq.OrderID
			FROM [Retail_Sales_Wrk].[ProtectionPlanQueue] AS wppq
			INNER JOIN [Retail_Sales_Enh].[ProtectionPlanSalesTrans] AS ppst 
			ON ppst.OrderID = wppq.OrderID

			UNION

			SELECT ipp.OrderID
			FROM [$(Source_Data)].[Retail_Corporate].[invoice_protectionplan] AS ipp
			INNER JOIN [Retail_Sales_Wrk].[ProtectionPlanQueue] AS wppq
			ON wppq.OrderID = ipp.OrderID

			UNION

			SELECT ipp.OrderID
			FROM [$(Source_Data)].[Retail_Corporate].[order_protectionplan] AS ipp
			INNER JOIN [Retail_Sales_Wrk].[ProtectionPlanQueue] AS wppq
			ON wppq.OrderID = ipp.OrderID
		) ppp;

		DELETE FROM wppq
		FROM [Retail_Sales_Wrk].[ProtectionPlanQueue]AS wppq
		LEFT OUTER JOIN #PPP AS p 
		ON p.OrderID = wppq.OrderID
		WHERE p.OrderID IS NULL;

		DROP TABLE #PPP;

		/* Remove Orders without PPP*/

		EXEC [Retail_Sales_Wrk].[usp_ProtectionPlanTrans_Bulk];

		EXEC [Retail_Sales_Wrk].[usp_ProtectionPlanTrans_Delivered_Bulk];

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

	SET NOCOUNT OFF;

END

