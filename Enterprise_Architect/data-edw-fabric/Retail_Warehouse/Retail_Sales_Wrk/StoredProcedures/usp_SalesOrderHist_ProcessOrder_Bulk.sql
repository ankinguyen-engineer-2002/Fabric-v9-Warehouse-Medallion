CREATE PROCEDURE [Retail_Sales_Wrk].[usp_SalesOrderHist_ProcessOrder_Bulk]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Wrk.usp_SalesOrderHist_ProcessOrder_Bulk';
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

		TRUNCATE TABLE [Retail_Sales_Wrk].[OrderHeaderBulk];

		INSERT INTO [Retail_Sales_Wrk].[OrderHeaderBulk] 
		(
			OrderKey
			, OrderDate
			, TransCodeID
			, OrdCount
			, TransKey
			, SalesDataTypeKey
			, MerchSubTot
			, TotalCharges
			, TotalTax
			, TotalInvoice
			, NetUnits
			, NetSales
			, OrderID
		)

		SELECT DISTINCT
            oh.OrderKey
            , oh.OrderDate
            , oh.TransCodeID
            , CASE WHEN ISNULL(os.NetUnits, 0) <> 0 THEN os.NetUnits / ABS(os.NetUnits)
                   WHEN ISNULL(os.NetSales, 0) <> 0 THEN os.NetSales / ABS(os.NetSales)
			  ELSE 0 END AS OrdCount
            , NULL AS TransKey
            , NULL AS SalesDataTypeKey
            , oh.TotalSales AS MerchSubTot
            , oh.TotalCharges
            , oh.TotalTaxes AS TotalTax
            , (oh.TotalSales + oh.TotalCharges + oh.TotalTaxes) AS TotalInvoice
            , ISNULL(os.NetUnits, 0) AS NetUnits
            , ISNULL(os.NetSales, 0) AS NetSales
            , oh.OrderID
        FROM [Retail_Sales_Wrk].[OrderHeader] oh
        LEFT JOIN 
		(
            SELECT
                wos.OrderID
                , SUM(wos.NetSales) AS NetSales
                , SUM(wos.NetUnits) AS NetUnits
            FROM [Retail_Sales_Wrk].[OrderSplit] wos
            INNER JOIN [Retail_Sales_Wrk].[OrderHeader] sq 
            ON wos.OrderID = sq.OrderID
            AND wos.TransDateKey <= sq.TransDateKey
            WHERE wos.DataSource = 'bta'
            AND wos.SalesType = 'W'
            GROUP BY wos.OrderID
        ) os
		ON oh.OrderID = os.OrderID;

		EXEC [Retail_Sales_Wrk].[usp_OrderSplit_ProcessOrder_Bulk];
	
		TRUNCATE TABLE [Retail_Sales_Wrk].[SOHistOrderSplit]

		INSERT INTO [Retail_Sales_Wrk].[SOHistOrderSplit]
		(
			OrderSplitID
			, OrderKey
			, SalesPersonID
			, SplitPercent
			, CurrentRec
			, OrderID
		 )

		 SELECT 
			wos.OrderSplitID
			, wos.OrderKey
			, wos.SalesPersonID
			, wos.SplitPercent
			, wos.CurrentRec
			, wos.OrderID
		FROM [Retail_Sales_Enh].[OrderSplit] wos
		WHERE wos.CurrentRec = 1
        AND EXISTS 
		(
			SELECT 1
			FROM [Retail_Sales_Wrk].[OrderHeader] oh
			WHERE oh.OrderID = wos.OrderID
        );

		/*
		SET @TransKey = 'TransCount';
		SET @SalesDataTypeKey = 4;
		EXEC tdsg.proc_SalesOrderHist_ProcessValue @OrderKey,
		                                           @TransKey,
		                                           @SalesDataTypeKey,
		                                           @OrdCount,
		                                           @TransDateKey;
		*/

		EXEC [Retail_Sales_Wrk].[usp_SalesOrderHist_Insert_Bulk];

		EXEC [Retail_Sales_Wrk].[usp_SalesOrderHist_Payments_Bulk];

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