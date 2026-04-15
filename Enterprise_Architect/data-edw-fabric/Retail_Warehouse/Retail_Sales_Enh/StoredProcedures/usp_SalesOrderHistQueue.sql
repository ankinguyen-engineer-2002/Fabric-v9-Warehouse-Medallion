CREATE PROCEDURE [Retail_Sales_Enh].[usp_SalesOrderHistQueue]
AS
BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Enh.usp_SalesOrderHistQueue';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_Sales_Enh';
	SET @DestinationTable = 'SalesOrderHist';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		DECLARE @TransDate DATE = GETDATE()-1
				, @DataSetName VARCHAR(50) = 'ORDERS'
				, @DataSetType VARCHAR(5) = 'PROD';

		--EXEC [MasterData_Retail_Ent].[usp_Refresh_DataSetKey];
		
		TRUNCATE TABLE [Retail_Sales_Wrk].[SalesOrderHistDateQueue];

		TRUNCATE TABLE [Retail_Sales_Wrk].[SalesOrderHistQueue];

		IF OBJECT_ID('tempdb..#TransCodes') IS NOT NULL 
		DROP TABLE #TransCodes;

		SELECT TransCodeID
		INTO #TransCodes
		FROM [$(Source_data)].[Retail_External].[TransCodeMap] AS tcm
		WHERE tcm.TransCodeGroup = 'SREA';

		/* Get Order Date for orders not already processed*/
		
		IF OBJECT_ID('tempdb..#ORDate') IS NOT NULL 
		DROP TABLE #ORDate;

		SELECT *
		INTO #ORDate
		FROM
		(
			SELECT 
				o.OrderID
				, o.OrderDate AS TransDate
				, o.TransCodeID
				, o.OrderBookedStoreID AS StoreID
			FROM [$(Source_data)].[Retail_Corporate].[Orders] o
			INNER JOIN [MasterData_Retail_Ent].[DataSetKey] dwi
			ON o.OrderID = dwi.DataSetKeyValue
			WHERE dwi.DataSetName = @DataSetName
			AND dwi.DataSetType = @DataSetType
			AND 
			(
				o.DateCreated >= @TransDate
				OR o.DateChanged >= @TransDate
			)

			UNION

			/* Order Date from Invocies */
			SELECT
				i.Base_OrderID AS OrderID
				, MAX(i.OrderDate) AS TransDate
				, i.TransCodeID
				, i.OrderBookedStoreID
			FROM [$(Source_data)].[Retail_Corporate].[Invoice] i
			INNER JOIN [MasterData_Retail_Ent].[DataSetKey] dwi
			ON i.Base_OrderID = dwi.DataSetKeyValue
			WHERE dwi.DataSetName = @DataSetName
			AND dwi.DataSetType = @DataSetType
			AND 
			(
				i.DateCreated >= @TransDate
				OR i.DateChanged >= @TransDate
			)
			GROUP BY i.Base_OrderID
					, i.TransCodeID
					, i.OrderBookedStoreID
		) ord;

		DELETE FROM od
		FROM #ORDate AS od
		INNER JOIN [Retail_Sales_Enh].[SalesOrderHeader] AS oh
		ON oh.SourceOrderID = od.OrderID
		INNER JOIN [Retail_Sales_Enh].[SalesOrderHist] AS tsot
		ON tsot.OrderID = oh.SourceOrderID;

		/*END  Get Order Date for orders not already processed*/
		
		IF OBJECT_ID('tempdb..#DateQ') IS NOT NULL 
		DROP TABLE #DateQ;

		SELECT 
			OrderID
            , CONVERT(VARCHAR(8), TransDate, 112) AS TransDateKey
            , ord.TransCodeID
            , ord.StoreID
		INTO #DateQ
		FROM
		(
			/* Bta Changes */
			SELECT
				bd.Base_OrderID AS OrderID
				, bd.TransDate
				, bd.TransCodeID
				, bd.StoreID
			FROM [$(Source_data)].[Retail_Corporate].[BtaData] bd
			INNER JOIN [MasterData_Retail_Ent].[DataSetKey] dwi
			ON bd.OrderID = dwi.DataSetKeyValue
			WHERE dwi.DataSetName = @DataSetName
			AND dwi.DataSetType = @DataSetType
			AND (
					  bd.DateCreated >= @TransDate
					  OR bd.DateChanged >= @TransDate
				  )
			GROUP BY bd.Base_OrderID
					, bd.TransDate
					, bd.TransCodeID
					, bd.StoreID
			
			UNION

			/* Open Order Changes */
			SELECT 
				o.OrderID
				, CAST(COALESCE(MIN(o.DateChanged), MIN(o.DateCreated)) AS DATE) AS TransDate
				, o.TransCodeID
				, o.OrderBookedStoreID AS StoreID
			FROM [$(Source_data)].[Retail_Corporate].[Orders] o
			INNER JOIN [MasterData_Retail_Ent].[DataSetKey] dwi
			ON o.OrderID = dwi.DataSetKeyValue
			WHERE dwi.DataSetName = @DataSetName
			AND dwi.DataSetType = @DataSetType
			AND (
					  o.DateCreated >= @TransDate
					  OR o.DateChanged >= @TransDate
				  )
			GROUP BY o.OrderID
					 , o.TransCodeID
					 , o.OrderBookedStoreID

			UNION

			/* Order / Invoice Changes */
			SELECT 
				i.Base_OrderID AS OrderID
				, CAST(COALESCE(MIN(i.DateChanged), MIN(i.DateCreated)) AS DATE) AS TransDate
				, i.TransCodeID
				, i.OrderBookedStoreID AS StoreID
			FROM [$(Source_data)].[Retail_Corporate].[Invoice] i
			INNER JOIN [MasterData_Retail_Ent].[DataSetKey] dwi
			ON i.Base_OrderID = dwi.DataSetKeyValue
			WHERE dwi.DataSetName = @DataSetName
			AND dwi.DataSetType = @DataSetType
			AND 
			(
				i.DateCreated >= @TransDate
				OR i.DateChanged >= @TransDate
			)
			GROUP BY i.Base_OrderID
					, i.TransCodeID
					, i.OrderBookedStoreID
			
			UNION

			SELECT
				od.OrderID
				, od.TransDate
				, od.TransCodeID
				, od.StoreID
			FROM #ORDate AS od
			GROUP BY od.OrderID
					 , od.TransDate
					 , od.TransCodeID
					 , od.StoreID
		) ord
		GROUP BY CONVERT(VARCHAR(8), TransDate, 112)
				 , ord.OrderID
				 , ord.TransCodeID
				 , ord.StoreID;

		DELETE FROM #DateQ
		WHERE TransCodeID NOT IN
		(
			SELECT tc.TransCodeID 
			FROM #TransCodes AS tc
		);

		DELETE FROM #DateQ
		WHERE OrderID NOT IN
		(
			SELECT toh.SourceOrderID 
			FROM [Retail_Sales_Enh].[SalesOrderHeader] AS toh
		);

		/* Get Last TransDate for orders already proceses*/

		IF OBJECT_ID('tempdb..#His') IS NOT NULL 
		DROP TABLE #His;

		SELECT 
			oh.SourceOrderID AS OrderID
			, MAX(sh.TransDateKey) AS LTransDateKey
		INTO #His
		FROM [Retail_Sales_Enh].[SalesOrderHeader] AS oh
		INNER JOIN [Retail_Sales_Enh].[SalesOrderHist] sh
		ON sh.OrderID = oh.SourceOrderID
		WHERE oh.SourceOrderID IN
		(
			SELECT DISTINCT OrderID 
			FROM #DateQ AS dq
		)
		GROUP BY oh.SourceOrderID;

		--/******* Remove Dates already processed **************/
		DELETE FROM dq
		FROM #DateQ dq
		INNER JOIN #His AS h
		ON h.OrderID = dq.OrderID
		WHERE dq.TransDateKey <= h.LTransDateKey
		AND dq.TransDateKey <> CONVERT(VARCHAR(8), GETDATE(), 112);
		--/***************************************************/

		INSERT INTO [Retail_Sales_Wrk].[SalesOrderHistDateQueue]
		(
			OrderID
			, TransDateKey
		)

		SELECT 
			OrderID
			, TransDateKey
		FROM #DateQ dq
		GROUP BY dq.OrderID
				 , dq.TransDateKey;

		/*
		/************* REMOVED old completed Orders *******************/
		DELETE FROM wsohdq
		FROM [Retail_Sales_Enh].[SalesOrderHeader] AS oh
		INNER JOIN [Retail_Sales_Wrk].[SalesOrderHistDateQueue] AS wsohdq
		ON wsohdq.OrderID = oh.SourceOrderID
		WHERE oh.SFMCFulfillmentStatus = 'Completed'
		AND oh.SFMCLastFulfillmentDate < DATEADD(DAY, -30, GETDATE());
		*/

		INSERT INTO [Retail_Sales_Wrk].[SalesOrderHistQueue]
		(
			OrderID
			, ProcessStatus
		)

		SELECT
			OrderID
			, 0
		FROM [Retail_Sales_Wrk].[SalesOrderHistDateQueue]
		GROUP BY OrderID;

		DROP TABLE #ORDate;
		DROP TABLE #DateQ;
		DROP TABLE #TransCodes;
		DROP TABLE #His;

		EXEC [Retail_Sales_Wrk].[usp_OrderSplit];
		EXEC [Retail_Sales_Wrk].[usp_OrderHist_Payments];
		EXEC [Retail_Sales_Enh].[usp_SalesOrderHistProcessOrders_Bulk];
		
		/* Update OrderKey */
		UPDATE sot
		SET sot.OrderKey = oh.OrderKey
		FROM [Retail_Sales_Enh].[SalesOrderHist] AS sot
		INNER JOIN [Retail_Sales_Enh].[SalesOrderHeader] AS oh 
		ON oh.SourceOrderID = sot.OrderID;

		/* Update Financed Orders */
		UPDATE oh
		SET oh.IsFinanced = 1
		FROM [Retail_Sales_Enh].[SalesOrderHeader] AS oh
		INNER JOIN [Retail_Sales_Enh].[SalesOrderHist] AS sot
		ON oh.SourceOrderID = sot.OrderID
		INNER JOIN [MasterData_Ent].[PaymentType] AS pt 
		ON pt.PaymentTypeID = sot.TransKey
		WHERE sot.SalesDataTypeKey = 5
		AND pt.IsFinanced = 1;
		--AND oh.OrderDate >= DATEADD(DAY, -2, GETDATE())

		UPDATE oh
		SET oh.IsFinanced = 1
		FROM [Retail_Sales_Enh].[SalesOrderHeader] AS oh
		INNER JOIN 
		(
			SELECT SuperOrderID 
			FROM [Retail_Sales_Enh].[SalesOrderHeader] AS oh2 
			WHERE oh2.IsFinanced = 1
		) FI
		ON FI.SuperOrderID = oh.SuperOrderID
		WHERE oh.IsFinanced = 0;
		--AND oh.OrderDate >= DATEADD(DAY, -2, GETDATE());

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
		EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase, @DestinationSchema, @DestinationTable
	
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