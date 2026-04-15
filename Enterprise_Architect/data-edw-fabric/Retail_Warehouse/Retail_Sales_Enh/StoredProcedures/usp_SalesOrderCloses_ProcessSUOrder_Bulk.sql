CREATE         PROCEDURE [Retail_Sales_Enh].[usp_SalesOrderCloses_ProcessSUOrder_Bulk]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Enh.usp_SalesOrderCloses_ProcessSUOrder_Bulk';
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

		DECLARE @CountTypeID VARCHAR(10) = 'ORD';

		SELECT DISTINCT 
			SUOrderID AS SuperOrderID,
			TransDateKey AS TransDateKey
		INTO #QueuedOrders
		FROM [Retail_Sales_Wrk].[SUOrderDateQueue];

		SELECT 
			sdt.SuperOrderID,
			sdt.CustomerID,
			sdt.StoreID,
			CONVERT(VARCHAR(8), COALESCE(sdt.OrderDate, sdt.TransDate), 112) AS OrderDateKey,
			sdt.SalesPersonID,
			SUM(COALESCE(sdt.NetPrice, 0)) AS Sales,
			SIGN(SUM(COALESCE(sdt.NetPrice, 0))) AS SPClose,
			CAST(0.0 AS DECIMAL(18, 2)) AS SUClose,
			CAST(0.0 AS DECIMAL(18, 2)) AS SOClose,
			CAST(0.0 AS DECIMAL(18, 2)) AS SUOpp,
			CAST(0.0 AS DECIMAL(18, 2)) AS SOOpp,
			1 AS CurrentRec,
			q.TransDateKey,
			sdt.SourceOrderID AS OrderID
		INTO #SDT_Bulk
		FROM [Retail_Sales_Enh].[SalesOrderLineHistory] AS sdt
		INNER JOIN #QueuedOrders q 
		ON q.SuperOrderID = sdt.SuperOrderID
		-- WHERE CONVERT(VARCHAR(8), sdt.OrderDate, 112) <= q.TransDateKey
		WHERE sdt.TransDateKey <= q.TransDateKey
		-- AND sdt.Source = 'W'
		AND sdt.Source = 'W'
		GROUP BY sdt.SuperOrderID,
				 sdt.CustomerID,
				 sdt.StoreID,
				 CONVERT(VARCHAR(8), COALESCE(sdt.OrderDate, sdt.TransDate), 112),
				 sdt.SalesPersonID,
				 q.TransDateKey,
				 sdt.SourceOrderID;

		SELECT soc.*
		INTO #SOC_Bulk
		FROM [Retail_Sales_Enh].[SalesOrderCloses] AS soc
		INNER JOIN #QueuedOrders q ON q.SuperOrderID = soc.SuperOrderID
		WHERE soc.CountTypeID = @CountTypeID
		AND soc.CurrentRec = 1;

		-- Update SUClose and SOClose calculations
		UPDATE sdt
		SET sdt.SUClose = CASE WHEN cls.SUTot = 0 THEN 0 ELSE sdt.SPClose / ABS(cls.SUTot) END,
			sdt.SOClose = CASE WHEN cls.SOTot = 0 THEN 0 ELSE sdt.SPClose / ABS(cls.SOTot) END
		FROM #SDT_Bulk AS sdt
		INNER JOIN 
		(
			SELECT 
				sdt2.SuperOrderID,
				sdt2.OrderID,
				sdt2.SalesPersonID,
				SUM(sdt2.SPClose) OVER (PARTITION BY sdt2.SuperOrderID) AS SUTot,
				SUM(sdt2.SPClose) OVER (PARTITION BY sdt2.OrderID) AS SOTot
			FROM #SDT_Bulk sdt2
		) cls 
		ON cls.SuperOrderID = sdt.SuperOrderID 
		AND cls.SalesPersonID = sdt.SalesPersonID
		AND cls.OrderID = sdt.OrderID;

		SELECT DISTINCT 
			SuperOrderID,
			OrderID,
			TransDateKey
		INTO #ChangedOrders
		FROM 
		(
			SELECT 
				sdt.SuperOrderID,
				sdt.OrderID,
				sdt.TransDateKey
			FROM #SDT_Bulk AS sdt
			LEFT JOIN #SOC_Bulk AS soc 
			ON sdt.SuperOrderID = soc.SuperOrderID 
			AND sdt.SalesPersonID = soc.SalesPersonID
			WHERE soc.SuperOrderID IS NULL 
			OR sdt.Sales != soc.SPSales
    
			UNION
    
			SELECT 
				soc.SuperOrderID,
				soc.OrderID,
				soc.TransDateKey
			FROM #SOC_Bulk AS soc
			LEFT JOIN #SDT_Bulk AS sdt 
			ON soc.SuperOrderID = sdt.SuperOrderID 
			AND soc.SalesPersonID = sdt.SalesPersonID
			WHERE sdt.SuperOrderID IS NULL
		) changes;

		IF EXISTS 
		(
			SELECT 1 
			FROM #ChangedOrders
		)

		BEGIN
    
			UPDATE soc
			SET CurrentRec = 0
			FROM [Retail_Sales_Enh].[SalesOrderCloses] soc
			INNER JOIN #ChangedOrders co
			ON co.SuperOrderID = soc.SuperOrderID
			WHERE soc.CurrentRec = 1
			AND soc.CountTypeID = @CountTypeID;

    
			INSERT INTO [Retail_Sales_Enh].[SalesOrderCloses]
			(
				SuperOrderID,
				CountTypeID,
				CustomerID, 
				LocationID, 
				SalesPersonID,
				OrderDateKey, 
				TransDateKey, 
				SPSales, 
				SPClose, 
				SUClose,
				SUOpp, 
				SOOpp,
				CurrentRec, 
				DateChanged,
				OrderID,
				SOClose
			)

			SELECT DISTINCT
				soc.SuperOrderID,
				soc.CountTypeID,
				soc.CustomerID, 
				soc.LocationID,
				soc.SalesPersonID, 
				soc.OrderDateKey, 
				co.TransDateKey,
				soc.SPSales * -1, 
				soc.SPClose * -1, 
				soc.SUClose * -1,
				0 AS SUOpp, 
				0 AS SOOpp, 
				0 AS CurrentRec,
				GETDATE(),
				soc.OrderID,
				soc.SOClose * -1
			FROM #SOC_Bulk AS soc
			INNER JOIN #ChangedOrders co 
			ON co.SuperOrderID = soc.SuperOrderID;

    
			INSERT INTO [Retail_Sales_Enh].[SalesOrderCloses]
			(
				SuperOrderID,
				CountTypeID,
				CustomerID,
				LocationID, 
				SalesPersonID,
				OrderDateKey,
				TransDateKey, 
				SPSales, 
				SPClose, 
				SUClose, 
				SUOpp, 
				SOOpp,
				CurrentRec, 
				DateChanged,
				OrderID,
				SOClose
			)
			SELECT DISTINCT
				s.SuperOrderID,
				@CountTypeID, 
				s.CustomerID, 
				s.StoreID, 
				s.SalesPersonID,
				s.OrderDateKey, 
				s.TransDateKey,
				s.Sales,
				COALESCE(s.SPClose, 0) AS SPClose,
				s.SUClose, 
				s.SUOpp, 
				s.SOOpp, 
				s.CurrentRec,
				GETDATE(),
				s.OrderID,
				s.SOClose
			FROM #SDT_Bulk AS s
			INNER JOIN #ChangedOrders co 
			ON co.SuperOrderID = s.SuperOrderID;

		END

		DROP TABLE #QueuedOrders;

		DROP TABLE #SDT_Bulk;

		DROP TABLE #SOC_Bulk;

		DROP TABLE #ChangedOrders;

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