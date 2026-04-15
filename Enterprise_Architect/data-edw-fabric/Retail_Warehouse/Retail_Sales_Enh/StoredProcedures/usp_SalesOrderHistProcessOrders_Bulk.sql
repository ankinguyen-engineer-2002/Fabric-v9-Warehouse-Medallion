CREATE PROCEDURE [Retail_Sales_Enh].[usp_SalesOrderHistProcessOrders_Bulk]
AS
BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Enh.usp_SalesOrderHistProcessOrders_Bulk';
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

        TRUNCATE TABLE [Retail_Sales_Wrk].[OrderDates];
        TRUNCATE TABLE [Retail_Sales_Wrk].[OrderHeader];
        TRUNCATE TABLE [Retail_Sales_Wrk].[SOrderHist];

        INSERT INTO [Retail_Sales_Wrk].[OrderDates] 
		(
			TransDateKey
		)

        SELECT DISTINCT TransDateKey
        FROM [Retail_Sales_Wrk].[SalesOrderHistDateQueue];

        INSERT INTO [Retail_Sales_Wrk].[OrderHeader]
        (
            OrderKey
            , OrderDate
            , TransCodeID
            , TotalCharges
            , TotalTaxes
            , TotalSales
            , OrderID
            , TransDateKey
        )

        SELECT 
            soh.OrderKey
            , soh.OrderDate
            , soh.TransCodeID
            , soh.TotalCharges
            , soh.TotalTaxes
            , soh.TotalSales
            , soh.SourceOrderID AS OrderID
            , sd.TransDateKey
        FROM [Retail_Sales_Enh].[SalesOrderHeader] soh
        INNER JOIN
		(
			SELECT 
				OrderID
				, MIN(TransDateKey) AS TransDateKey
			FROM [Retail_Sales_Wrk].[SalesOrderHistDateQueue]
			GROUP BY OrderID
		) sd
        ON soh.SourceOrderID = sd.OrderID;

        INSERT INTO [Retail_Sales_Wrk].[SOrderHist]
        (
            SalesOrderHistKey
            , OrderKey
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
            soh.SalesOrderHistKey
            , soh.OrderKey
			, soh.OrderID
            , soh.SalesDataTypeKey
            , soh.TransDateKey
            , soh.SalesPersonID
            , soh.TransValue
            , soh.TransKey
            , soh.CurrentRec
            , soh.DateCreated
        FROM [Retail_Sales_Enh].[SalesOrderHist] soh
        WHERE soh.CurrentRec = 1
        AND EXISTS 
		(
            SELECT 1
            FROM [Retail_Sales_Wrk].[OrderHeader] oh
            WHERE oh.OrderID = soh.OrderID
        );

        EXEC [Retail_Sales_Wrk].[usp_SalesOrderHist_ProcessOrder_Bulk];

        IF EXISTS 
		(
			SELECT 1
            FROM [Retail_Sales_Wrk].[SOrderHist] woh
            WHERE woh.SalesOrderHistKey IS NULL
		)

        BEGIN
                   
            UPDATE soh
            SET soh.CurrentRec = 0
            FROM [Retail_Sales_Enh].[SalesOrderHist] soh
            WHERE soh.CurrentRec = 1
			AND EXISTS 
			(
				SELECT 1
				FROM [Retail_Sales_Wrk].[SOrderHist] swh
				WHERE swh.SalesOrderHistKey = soh.SalesOrderHistKey
				AND swh.OrderKey = soh.OrderKey
				AND swh.CurrentRec = 0
				AND EXISTS 
				(
					SELECT 1
					FROM [Retail_Sales_Wrk].[OrderHeader] sq
					WHERE sq.OrderID = soh.OrderID
				)
			);
			  
			DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(SalesOrderHistKey), 0) FROM [Retail_Sales_Enh].[SalesOrderHist]);

            INSERT INTO [Retail_Sales_Enh].[SalesOrderHist]
			(
				SalesOrderHistKey
				, OrderID
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
				@MaxID + ROW_NUMBER() OVER (ORDER BY OrderID, SalesPersonID, SalesDataTypeKey, TransKey) AS SalesOrderHistKey
				, OrderID
				, OrderKey
				, SalesDataTypeKey
				, TransDateKey
				, SalesPersonID
				, TransValue
				, TransKey
				, CurrentRec
				, DateCreated
			FROM [Retail_Sales_Wrk].[SOrderHist]
			WHERE SalesOrderHistKey IS NULL;

            UPDATE woh
            SET woh.SalesOrderHistKey = enh.SalesOrderHistKey
            FROM [Retail_Sales_Wrk].[SOrderHist] woh
            INNER JOIN [Retail_Sales_Enh].[SalesOrderHist] enh
            ON woh.OrderKey = enh.OrderKey
            AND woh.SalesPersonID = enh.SalesPersonID
            AND woh.SalesDataTypeKey = enh.SalesDataTypeKey
            AND woh.TransKey = enh.TransKey
            AND woh.TransDateKey = enh.TransDateKey
            AND woh.TransValue = enh.TransValue
            WHERE woh.SalesOrderHistKey IS NULL;

        END

        --DELETE FROM [Retail_Sales_Wrk].[SalesOrderHistDateQueue];

        --DELETE FROM [Retail_Sales_Wrk].[SalesOrderHistQueue];

        --DELETE FROM [Retail_Sales_Wrk].[OrderSplit];

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