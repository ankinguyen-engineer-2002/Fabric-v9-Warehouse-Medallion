CREATE PROCEDURE [Retail_Sales_Wrk].[usp_OrderSplit_ProcessOrder] 
(
	@OrderID VARCHAR(50), 
	@OrderKey BIGINT, 
	@TransDateKey INT
)
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Wrk.usp_OrderSplit_ProcessOrder';
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

		DECLARE @NetUnits DECIMAL(18, 2),
				@NetSales DECIMAL(18, 2);

		DECLARE @Rows INT;

		-- Create temp tables instead of table variables
		TRUNCATE TABLE [Retail_Sales_Wrk].[SP];

		TRUNCATE TABLE [Retail_Sales_Wrk].[SPHist];

		INSERT INTO [Retail_Sales_Wrk].[SP] 
		(
			SalesPersonID, 
			NetSales, 
			SplitPercent
		)
	
		SELECT
			SalesPersonID,
			SUM(NetSales),
			0 AS SplitPercent
		FROM [Retail_Sales_Wrk].[OrderSplit] AS wos
		WHERE OrderID = @OrderID
		AND wos.TransDateKey <= @TransDateKey
		AND wos.DataSource = 'bta'
		GROUP BY SalesPersonID;
		--HAVING SUM(wos.NetSales) <> 0;

		SELECT @Rows = @@ROWCOUNT;

		IF @Rows = 0

		BEGIN

			INSERT INTO [Retail_Sales_Wrk].[SP] 
			(
				SalesPersonID, 
				NetSales, 
				SplitPercent
			)
		
			SELECT
				SalesPersonID,
				SUM(NetSales),
				0 AS SplitPercent
			FROM [Retail_Sales_Wrk].[OrderSplit] AS wos
			WHERE  OrderID = @OrderID
			AND wos.TransDateKey <= @TransDateKey
			AND wos.DataSource = 'oi'
			GROUP BY SalesPersonID;
			--HAVING SUM(wos.NetSales) <> 0;

			/* Insert House if no Sales Person exists */
			SELECT @Rows = @@ROWCOUNT;

			IF @Rows = 0

				INSERT INTO [Retail_Sales_Wrk].[SP]
				(
					SalesPersonID,
					NetSales, 
					SplitPercent
				)
				VALUES 
				(
					'ZZZ', 
					1, 
					0
				);

		END

		SELECT @NetSales = SUM(NetSales) 
		FROM [Retail_Sales_Wrk].[SP];

		IF @NetSales = 0

		BEGIN

			UPDATE [Retail_Sales_Wrk].[SP] 
			SET NetSales = 1;
			SELECT @NetSales = SUM(NetSales) 
			FROM [Retail_Sales_Wrk].[SP];

		END

		IF @NetSales <> 0

			UPDATE [Retail_Sales_Wrk].[SP]
			SET SplitPercent = NetSales / @NetSales * 100;

		DECLARE @ChangeCount INT = 0;

		--PRINT 'Change Count ' + CAST(@ChangeCount AS VARCHAR(100));

		INSERT INTO [Retail_Sales_Wrk].[SPHist] 
		(
			SalesPersonID, 
			SplitPercent
		)
	
		SELECT  
			SalesPersonID,
			os.SplitPercent
		FROM [Retail_Sales_Enh].[OrderSplit] AS os
		WHERE os.OrderKey = @OrderKey
		AND os.CurrentRec = 1;

		SELECT  @ChangeCount = COUNT(*)
		FROM 
		(
			SELECT  SalesPersonID,
					SplitPercent
			FROM
			(   
				SELECT 
					SalesPersonID, 
					SplitPercent 
				FROM [Retail_Sales_Wrk].[SP]
			
				EXCEPT
			
				SELECT 
					SalesPersonID, 
					SplitPercent 
					FROM [Retail_Sales_Wrk].[SPHist] AS sh
			) a
		
			UNION
		
			SELECT  
				SalesPersonID,
				SplitPercent
			FROM 
			(   
				SELECT
					SalesPersonID, 
					SplitPercent
				FROM [Retail_Sales_Wrk].[SPHist] 
                
				EXCEPT   
                
				SELECT 
					SalesPersonID, 
					SplitPercent 
				FROM [Retail_Sales_Wrk].[SP]
			) b
		) sp;

		--PRINT 'Change Count ' + CAST(@ChangeCount AS VARCHAR(100));

		IF @ChangeCount > 0

		BEGIN

			UPDATE [Retail_Sales_Enh].[OrderSplit]
			SET CurrentRec = 0
			WHERE OrderKey = @OrderKey;
            
			DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(OrderSplitID),0) FROM [Retail_Sales_Enh].[OrderSplit]);
        
			INSERT INTO [Retail_Sales_Enh].[OrderSplit] 
			(
				OrderSplitID,
				OrderKey, 
				SalesPersonID,
				SplitPercent, 
				CurrentRec
			)
		
			SELECT 
				@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS BIGINT) AS OrderSplitID,
				@OrderKey,
				SalesPersonID,
				--SplitPercent,
				 CASE WHEN SplitPercent > 100 THEN 100
					  WHEN SplitPercent < -100 THEN -100
					  ELSE SplitPercent
					  END AS spp,
				 1 AS CurrentRec
		   FROM [Retail_Sales_Wrk].[SP]
		   WHERE SplitPercent <> 0;

		END

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