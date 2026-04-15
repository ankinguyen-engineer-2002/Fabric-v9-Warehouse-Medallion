CREATE PROCEDURE [Retail_Sales_Wrk].[usp_OrderSplit_ProcessOrder_Bulk] 
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Wrk.usp_OrderSplit_ProcessOrder_Bulk';
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

		TRUNCATE TABLE [Retail_Sales_Wrk].[SP]

		TRUNCATE TABLE [Retail_Sales_Wrk].[SPHist] 

		INSERT INTO [Retail_Sales_Wrk].[SP] 
		(
			SalesPersonID
			, NetSales
			, SplitPercent
			, OrderID
		)
    
		SELECT
			wos.SalesPersonID
			, SUM(wos.NetSales)
			, 0 AS SplitPercent
			, wos.OrderID
		FROM [Retail_Sales_Wrk].[OrderSplit] AS wos
		INNER JOIN [Retail_Sales_Wrk].[OrderHeader] oh
		ON wos.OrderID = oh.OrderID
		AND wos.TransDateKey <= oh.TransDateKey
		WHERE wos.DataSource = 'bta'
		GROUP BY wos.SalesPersonID
				 , wos.OrderID;

		INSERT INTO [Retail_Sales_Wrk].[SP] 
		(
			SalesPersonID 
			, NetSales
			, SplitPercent
			, OrderID
		)
	
		SELECT
			wos.SalesPersonID
			, SUM(wos.NetSales)
			, 0 AS SplitPercent
			, wos.OrderID
		FROM [Retail_Sales_Wrk].[OrderSplit] AS wos
		INNER JOIN [Retail_Sales_Wrk].[OrderHeader] oh
        ON wos.OrderID = oh.OrderID
        AND wos.TransDateKey <= oh.TransDateKey
        WHERE wos.DataSource = 'oi'
        AND NOT EXISTS
		(
            SELECT 1
            FROM [Retail_Sales_Wrk].[SP] sp
            WHERE sp.OrderID = wos.OrderID
        )
        GROUP BY wos.SalesPersonID
				, wos.OrderID;

		INSERT INTO [Retail_Sales_Wrk].[SP]
		(
			SalesPersonID
			, NetSales
			, SplitPercent
			, OrderID
		)
			
		SELECT DISTINCT
			'ZZZ' AS SalesPersonID
            , 1 AS NetSales
            , 0 AS SplitPercent
            , oh.OrderID
        FROM [Retail_Sales_Wrk].[OrderHeader] oh
        WHERE NOT EXISTS 
		(
            SELECT 1 
            FROM [Retail_Sales_Wrk].[SP] sp 
            WHERE sp.OrderID = oh.OrderID
        );

		; WITH OrderNetSales AS 
		(
			SELECT 
				OrderID
				, SUM(NetSales) AS NetSales
			FROM [Retail_Sales_Wrk].[SP]
			GROUP BY OrderID
		)
        
		, OrdersWithZeroTotal AS 
		(
            SELECT OrderID
            FROM OrderNetSales
            WHERE NetSales = 0
        )

        UPDATE sp
        SET NetSales = 1
        FROM [Retail_Sales_Wrk].[SP] sp
        INNER JOIN OrdersWithZeroTotal oz 
		ON sp.OrderID = oz.OrderID;

		WITH OrderTotals AS 
		(
			SELECT 
				OrderID
				, SUM(NetSales) AS TotalNetSales
			FROM [Retail_Sales_Wrk].[SP]
			GROUP BY OrderID
		)

		UPDATE sp
		SET SplitPercent = ROUND(sp.NetSales / ot.TotalNetSales * 100, 2)
		FROM [Retail_Sales_Wrk].[SP] sp
		INNER JOIN OrderTotals ot 
		ON sp.OrderID = ot.OrderID
		WHERE ot.TotalNetSales <> 0;

		INSERT INTO [Retail_Sales_Wrk].[SPHist] 
		(
			SalesPersonID
			, SplitPercent
			, OrderID
		)

		SELECT DISTINCT
			os.SalesPersonID
			, os.SplitPercent
			, os.OrderID
		FROM [Retail_Sales_Enh].[OrderSplit] AS os
		INNER JOIN [Retail_Sales_Wrk].[OrderHeader] oh
        ON os.OrderID = oh.OrderID
        WHERE os.CurrentRec = 1;
	
		IF OBJECT_ID('tempdb..#OrdersToProcess') IS NOT NULL 
		DROP TABLE #OrdersToProcess;

		;WITH ChangedOrders AS 
		(
			--New or changed splits (in SP but not in SPHist)
			SELECT DISTINCT sp.OrderID
			FROM [Retail_Sales_Wrk].[SP] sp
			WHERE NOT EXISTS 
			(
				SELECT 1 
				FROM [Retail_Sales_Wrk].[SPHist] hist
				WHERE hist.OrderID = sp.OrderID
				AND hist.SalesPersonID = sp.SalesPersonID
				AND ISNULL(hist.SplitPercent, 0) = ISNULL(sp.SplitPercent, 0)
			)
    
			UNION
    
			--Removed splits (in SPHist but not in SP)
			SELECT DISTINCT hist.OrderID
			FROM [Retail_Sales_Wrk].[SPHist] hist
			WHERE NOT EXISTS 
			(
				SELECT 1 
				FROM [Retail_Sales_Wrk].[SP] sp
				WHERE sp.OrderID = hist.OrderID
				AND sp.SalesPersonID = hist.SalesPersonID
				AND ISNULL(sp.SplitPercent, 0) = ISNULL(hist.SplitPercent, 0)
			)
		)

		SELECT OrderID 
		INTO #OrdersToProcess 
		FROM ChangedOrders;

		--Mark old splits as non-current (ALL splits for changed orders)
		UPDATE wos
		SET CurrentRec = 0
		FROM [Retail_Sales_Enh].[OrderSplit] wos
		INNER JOIN #OrdersToProcess otp 
		ON wos.OrderID = otp.OrderID;

		DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(OrderSplitID), 0) FROM [Retail_Sales_Enh].[OrderSplit]);

		INSERT INTO [Retail_Sales_Enh].[OrderSplit] 
		(
			OrderSplitID
			, OrderKey
			, SalesPersonID
			, SplitPercent
			, CurrentRec
			, DateCreated
			, OrderID
		)
		
		SELECT  
			@MaxID + ROW_NUMBER() OVER (ORDER BY sp.OrderID, sp.SalesPersonID) AS OrderSplitID
			, so.OrderKey
			, sp.SalesPersonID
			, CASE WHEN sp.SplitPercent > 100 THEN 100
				   WHEN sp.SplitPercent < -100 THEN -100
			  ELSE sp.SplitPercent
			  END AS SplitPercent
			, 1 AS CurrentRec
			, GETDATE() AS DateCreated 
			, sp.OrderID
		FROM [Retail_Sales_Wrk].[SP] sp
		INNER JOIN [Retail_Sales_Enh].[SalesOrderHeader] so 
		ON so.SourceOrderID = sp.OrderID
		INNER JOIN #OrdersToProcess otp 
		ON sp.OrderID = otp.OrderID
		WHERE sp.SplitPercent <> 0;

		DROP TABLE #OrdersToProcess;

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