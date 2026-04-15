CREATE PROCEDURE [Retail_Sales_Wrk].[usp_SalesOrderHist_Insert_Bulk]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Wrk.usp_SalesOrderHist_Insert_Bulk';
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

		TRUNCATE TABLE [Retail_Sales_Wrk].[CurrentCalculatedValues];
		
		INSERT INTO [Retail_Sales_Wrk].[CurrentCalculatedValues] 
		(
			OrderKey
			, OrderID
			, SalesDataTypeKey
			, TransKey
			, SalesPersonID
			, TransValue
		)

		SELECT
			os.OrderKey
			, os.OrderID
			, 2 AS SalesDataTypeKey
			, 'Charges' AS TransKey
			, os.SalesPersonID
			, ROUND(oh.TotalCharges * os.SplitPercent / 100, 2) AS TransValue
		FROM [Retail_Sales_Wrk].[SOHistOrderSplit] os
		INNER JOIN [Retail_Sales_Wrk].[OrderHeaderBulk] oh 
        ON os.OrderID = oh.OrderID
        WHERE os.CurrentRec = 1

		UNION ALL

		SELECT 
			os.OrderKey
			, os.OrderID
			, 9 AS SalesDataTypeKey
			, 'Tax' AS TransKey
			, os.SalesPersonID
			, ROUND(oh.TotalTax * os.SplitPercent / 100, 2) AS TransValue
		FROM [Retail_Sales_Wrk].[SOHistOrderSplit] os
		INNER JOIN [Retail_Sales_Wrk].[OrderHeaderBulk] oh 
        ON os.OrderID = oh.OrderID
        WHERE os.CurrentRec = 1;

		IF OBJECT_ID('tempdb..#ChangedOrderTransactions') IS NOT NULL 
		DROP TABLE #ChangedOrderTransactions;

		WITH ChangedOrderTransactions AS 
		(
			SELECT DISTINCT
			   ccv.OrderID
			   , ccv.SalesDataTypeKey
			   , ccv.TransKey
			   , ccv.SalesPersonID
			FROM [Retail_Sales_Wrk].[CurrentCalculatedValues] ccv
			WHERE NOT EXISTS 
			(
				SELECT 1 
				FROM [Retail_Sales_Wrk].[SOrderHist] soh
				WHERE soh.OrderID = ccv.OrderID
				AND soh.SalesDataTypeKey = ccv.SalesDataTypeKey
				AND soh.TransKey = ccv.TransKey
				AND soh.SalesPersonID = ccv.SalesPersonID
				AND ROUND(ISNULL(soh.TransValue, 0), 2) = ROUND(ISNULL(ccv.TransValue, 0), 2)
				AND soh.CurrentRec = 1
			)
    
			UNION
    
			SELECT DISTINCT
			   soh.OrderID
			   , soh.SalesDataTypeKey
			   , soh.TransKey
			   , soh.SalesPersonID
			FROM [Retail_Sales_Wrk].[SOrderHist] soh
			WHERE soh.CurrentRec = 1
			AND soh.SalesDataTypeKey IN (2, 9)
			AND NOT EXISTS
			(
				SELECT 1 
				FROM [Retail_Sales_Wrk].[CurrentCalculatedValues] ccv
				WHERE ccv.OrderID = soh.OrderID
				AND ccv.SalesDataTypeKey = soh.SalesDataTypeKey
				AND ccv.TransKey = soh.TransKey
				AND ccv.SalesPersonID = soh.SalesPersonID
				AND ROUND(ISNULL(ccv.TransValue, 0), 2) = ROUND(ISNULL(soh.TransValue, 0), 2)
			)
		)
	
		SELECT * 
		INTO #ChangedOrderTransactions 
		FROM ChangedOrderTransactions;

		INSERT INTO [Retail_Sales_Wrk].[SOrderHist]
		(
			OrderKey
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
			soh.OrderKey
			, soh.OrderID
			, soh.SalesDataTypeKey
			, oh.TransDateKey
			, soh.SalesPersonID
			, soh.TransValue * -1
			, soh.TransKey
			, 0
			, GETDATE()
		FROM [Retail_Sales_Wrk].[SOrderHist] soh
		INNER JOIN #ChangedOrderTransactions cst 
        ON soh.OrderID = cst.OrderID 
        AND soh.SalesDataTypeKey = cst.SalesDataTypeKey 
        AND soh.TransKey = cst.TransKey
        AND soh.SalesPersonID = cst.SalesPersonID
        INNER JOIN [Retail_Sales_Wrk].[OrderHeader] oh
        ON soh.OrderID = oh.OrderID
        WHERE soh.CurrentRec = 1;

		UPDATE soh 
		SET CurrentRec = 0
		FROM [Retail_Sales_Wrk].[SOrderHist] soh
		INNER JOIN #ChangedOrderTransactions cst 
        ON soh.OrderID = cst.OrderID 
        AND soh.SalesDataTypeKey = cst.SalesDataTypeKey 
        AND soh.TransKey = cst.TransKey
        AND soh.SalesPersonID = cst.SalesPersonID
        WHERE soh.CurrentRec = 1;
	
		INSERT INTO [Retail_Sales_Wrk].[SOrderHist]
		(
			OrderID
			, OrderKey
			, SalesDataTypeKey
			, TransDateKey
			, SalesPersonID
			, TransValue
			, TransKey
			, CurrentRec
			, DateCreated
		)

		SELECT
			ccv.OrderID
			, ccv.OrderKey
			, ccv.SalesDataTypeKey
			, oh.TransDateKey
			, ccv.SalesPersonID
			, ccv.TransValue
			, ccv.TransKey
			, 1
			, GETDATE()
		FROM [Retail_Sales_Wrk].[CurrentCalculatedValues] ccv
		INNER JOIN #ChangedOrderTransactions cst 
        ON ccv.OrderID = cst.OrderID 
        AND ccv.SalesDataTypeKey = cst.SalesDataTypeKey 
        AND ccv.TransKey = cst.TransKey
        AND ccv.SalesPersonID = cst.SalesPersonID
        INNER JOIN [Retail_Sales_Wrk].[OrderHeader] oh
        ON ccv.OrderID = oh.OrderID
        WHERE ccv.TransValue <> 0;

		DROP TABLE #ChangedOrderTransactions;

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