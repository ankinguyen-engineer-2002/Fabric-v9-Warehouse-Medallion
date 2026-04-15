CREATE PROCEDURE [Retail_Sales_Wrk].[usp_SalesOrderHist_Payments_Bulk]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Wrk.usp_SalesOrderHist_Payments_Bulk';
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

		DECLARE @SalesDataTypeKey INT = 5;
		
		TRUNCATE TABLE [Retail_Sales_Wrk].[Pay];
		
		INSERT INTO [Retail_Sales_Wrk].[Pay]
        ( 
            OrderKey
            , OrderID
            , PaymentTypeID
            , PaymentAmt
        )

        SELECT 
            oh.OrderKey
            , wohp.OrderID
            , wohp.FinancePaymentTypeID
            , wohp.TotalAmt
        FROM [Retail_Sales_Wrk].[OrderHistPayments] wohp
        INNER JOIN [Retail_Sales_Wrk].[OrderHeaderBulk] oh
        ON oh.OrderID = wohp.OrderID;

		WITH PaymentTotals AS
        (
            SELECT 
                p.OrderKey
                , p.OrderID
                , ISNULL(SUM(p.PaymentAmt), 0) AS PaymentTotal
            FROM [Retail_Sales_Wrk].[Pay] p
            GROUP BY p.OrderKey
					, p.OrderID
        )

        , OrderTotals AS 
        (
            SELECT 
                oh.OrderKey
                , oh.OrderID
                , oh.TotalInvoice
            FROM [Retail_Sales_Wrk].[OrderHeaderBulk] oh
        )

        UPDATE soh
        SET TotalPayment = ISNULL(pt.PaymentTotal, 0)
            , BalanceDue = ot.TotalInvoice - ISNULL(pt.PaymentTotal, 0)
        FROM [Retail_Sales_Enh].[SalesOrderHeader] soh
        INNER JOIN OrderTotals ot 
        ON soh.SourceOrderID = ot.OrderID
        LEFT JOIN PaymentTotals pt 
        ON soh.SourceOrderID = pt.OrderID;

		INSERT INTO [Retail_Sales_Wrk].[Pay]
        (
            OrderKey
            , OrderID
            , PaymentTypeID
            , PaymentAmt
        )

        SELECT 
            soh.OrderKey
            , soh.SourceOrderID AS OrderID
            , 'BAL' AS PaymentTypeID
            , (ot.TotalInvoice - ISNULL(pt.PaymentTotal, 0)) AS PaymentAmt
        FROM [Retail_Sales_Enh].[SalesOrderHeader] soh
        INNER JOIN 
		(
            SELECT 
                oh.OrderKey
                , oh.OrderID
                , oh.TotalInvoice
            FROM [Retail_Sales_Wrk].[OrderHeaderBulk] oh
        ) ot 
        ON soh.SourceOrderID = ot.OrderID
        LEFT JOIN 
		(
            SELECT 
                OrderKey
				, OrderID
                , SUM(PaymentAmt) AS PaymentTotal
            FROM [Retail_Sales_Wrk].[Pay]
            WHERE PaymentTypeID <> 'BAL'
            GROUP BY OrderKey
					, OrderID
        ) pt 
        ON soh.SourceOrderID = pt.OrderID
        WHERE (ot.TotalInvoice - ISNULL(pt.PaymentTotal, 0)) <> 0;

		TRUNCATE TABLE [Retail_Sales_Wrk].[CurrentPaymentValues];

		INSERT INTO [Retail_Sales_Wrk].[CurrentPaymentValues] 
		(
			OrderKey
			, OrderID
			, SalesDataTypeKey
			, SalesPersonID
			, TransKey
			, TransValue
		)
		
		SELECT DISTINCT
			p.OrderKey
			, ots.OrderID
			, 5 AS SalesDataTypeKey
			, ots.SalesPersonID
			, p.PaymentTypeID AS TransKey
			, p.PaymentAmt * ots.SplitPercent / 100 AS TransValue
		FROM [Retail_Sales_Wrk].[SOHistOrderSplit] ots
		INNER JOIN [Retail_Sales_Wrk].[Pay] p 
		ON p.OrderID = ots.OrderID
		WHERE ots.CurrentRec = 1;

		IF OBJECT_ID('tempdb..#ChangedPaymentTransactions') IS NOT NULL 
		DROP TABLE #ChangedPaymentTransactions;

		WITH ChangedPaymentTransactions AS
        (
            -- New or changed rows: exist in calc but not in current SOrderHist
            SELECT DISTINCT
                cpv.OrderID
                , cpv.SalesPersonID
                , cpv.TransKey
            FROM [Retail_Sales_Wrk].[CurrentPaymentValues] cpv
            WHERE NOT EXISTS
            (
                SELECT 1
                FROM [Retail_Sales_Wrk].[SOrderHist] soh
                WHERE soh.OrderID = cpv.OrderID
                AND soh.SalesDataTypeKey = 5
                AND soh.SalesPersonID = cpv.SalesPersonID
                AND soh.TransKey = cpv.TransKey
                AND ROUND(ISNULL(soh.TransValue, 0), 0) = ROUND(ISNULL(cpv.TransValue, 0), 0)
                AND soh.CurrentRec = 1
            )

            UNION

            -- Removed rows: exist in current SOrderHist but not in calc
            SELECT DISTINCT
                soh.OrderID
                , soh.SalesPersonID
                , soh.TransKey
            FROM [Retail_Sales_Wrk].[SOrderHist] soh
            WHERE soh.CurrentRec = 1
            AND soh.SalesDataTypeKey = 5
            AND NOT EXISTS
            (
                SELECT 1
                FROM [Retail_Sales_Wrk].[CurrentPaymentValues] cpv
                WHERE cpv.OrderID = soh.OrderID
				AND cpv.SalesDataTypeKey = 5
                AND cpv.SalesPersonID = soh.SalesPersonID
                AND cpv.TransKey = soh.TransKey
                AND ROUND(ISNULL(cpv.TransValue, 0), 0) = ROUND(ISNULL(soh.TransValue, 0), 0)
            )
        )

		SELECT * 
		INTO #ChangedPaymentTransactions 
		FROM ChangedPaymentTransactions;

		INSERT INTO [Retail_Sales_Wrk].[SOrderHist]
		(
			OrderKey
			, OrderID
			, SalesPersonID
			, TransDateKey
			, TransKey
			, SalesDataTypeKey
			, TransValue
			, CurrentRec
			, DateCreated
		)

		SELECT
			soh.OrderKey
			, soh.OrderID
			, soh.SalesPersonID
			, oh.TransDateKey
			, soh.TransKey
			, soh.SalesDataTypeKey
			, soh.TransValue * -1
			, 0 AS CurrentRec
			, GETDATE()
		FROM [Retail_Sales_Wrk].[SOrderHist] soh
		INNER JOIN #ChangedPaymentTransactions cpt 
		ON soh.OrderID = cpt.OrderID
		AND soh.SalesPersonID = cpt.SalesPersonID
        AND soh.TransKey = cpt.TransKey
		INNER JOIN [Retail_Sales_Wrk].[OrderHeader] oh
        ON soh.OrderID = oh.OrderID
		WHERE soh.CurrentRec = 1 
		AND soh.SalesDataTypeKey = 5;

		UPDATE soh
		SET CurrentRec = 0
		FROM [Retail_Sales_Wrk].[SOrderHist] soh
		INNER JOIN #ChangedPaymentTransactions cpt 
		ON soh.OrderID = cpt.OrderID
		AND soh.SalesPersonID = cpt.SalesPersonID
        AND soh.TransKey = cpt.TransKey
		WHERE soh.CurrentRec = 1 
		AND soh.SalesDataTypeKey = 5;

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
			cpv.OrderKey
			, cpv.OrderID
			, cpv.SalesDataTypeKey
			, oh.TransDateKey
			, cpv.SalesPersonID
			, cpv.TransValue
			, cpv.TransKey
			, 1 AS CurrentRec
			, GETDATE()
		FROM [Retail_Sales_Wrk].[CurrentPaymentValues] cpv
		INNER JOIN #ChangedPaymentTransactions cpt 
		ON cpv.OrderID = cpt.OrderID
		AND cpv.SalesPersonID = cpt.SalesPersonID
        AND cpv.TransKey = cpt.TransKey
		INNER JOIN [Retail_Sales_Wrk].[OrderHeader] oh
        ON cpv.OrderID = oh.OrderID;

		DROP TABLE #ChangedPaymentTransactions;

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