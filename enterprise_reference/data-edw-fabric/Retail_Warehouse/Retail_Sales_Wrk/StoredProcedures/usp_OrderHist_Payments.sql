CREATE PROCEDURE [Retail_Sales_Wrk].[usp_OrderHist_Payments]
AS
BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Wrk.usp_OrderHist_Payments';
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
		
		DECLARE @DataSetName VARCHAR(50) = 'ORDERS'
				, @DataSetType VARCHAR(5) = 'PROD';

		IF OBJECT_ID('tempdb..#Orders') IS NOT NULL 
		DROP TABLE #Orders;

		SELECT 
			o.OrderID
			, o.OrderDate
			, o.OrderBookedStoreID
			, o.FinancePaymentTypeID
			, o.FinanceAmt
			, o.TransCodeID
			, o.DateCreated
			, o.DateChanged
			, o.RecStatus
		INTO #Orders
		FROM [$(Source_Data)].[Retail_Corporate].[Orders] o
		INNER JOIN [MasterData_Retail_Ent].[DataSetKey] dwi
		ON o.OrderID = dwi.DataSetKeyValue
		WHERE dwi.DataSetName = @DataSetName
		AND dwi.DataSetType = @DataSetType;

		IF OBJECT_ID('tempdb..#Invoice') IS NOT NULL 
		DROP TABLE #Invoice;
			   
		SELECT 
			i.Base_OrderID
			, i.OrderID
			, i.OrderDate
			, i.OrderBookedStoreID
			, i.FinancePaymentTypeID
			, i.FinanceAmt
			, i.TransCodeID
			, i.DateCreated
			, i.DateChanged
			, i.RecStatus
		INTO #Invoice
		FROM [$(Source_Data)].[Retail_Corporate].[Invoice] i
		INNER JOIN [MasterData_Retail_Ent].[DataSetKey] dwi
		ON i.Base_OrderID = dwi.DataSetKeyValue
		WHERE dwi.DataSetName = @DataSetName
		AND dwi.DataSetType = @DataSetType;

		IF OBJECT_ID('tempdb..#InvoicePaymentInfo') IS NOT NULL 
		DROP TABLE #InvoicePaymentInfo;

		SELECT
			ipi.OrderID
			, ipi.TransDate
			, ipi.PaymentAmt
		    , ipi.PaymentNbr
		    , ipi.PaymentTypeID
		    , ipi.PostDate
		    , ipi.DateChanged
		    , ipi.DateCreated
		    , ipi.RecStatus
		    , ipi.SourceID
		INTO #InvoicePaymentInfo
		FROM [$(Source_Data)].[Retail_Corporate].[Invoice] i
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[invoice_paymentinfo] ipi
		ON ipi.OrderID = i.OrderID
		INNER JOIN [MasterData_Retail_Ent].[DataSetKey] dwi
		ON i.Base_OrderID = dwi.DataSetKeyValue
		WHERE dwi.DataSetName = @DataSetName
		AND dwi.DataSetType = @DataSetType;

		IF OBJECT_ID('tempdb..#Deposits') IS NOT NULL 
		DROP TABLE #Deposits;

		SELECT 
			d.OrderID
			, d.PaymentTypeID
			, d.PaymentAmt
			, d.DepositDate
			, d.IsFinanced
			, d.Sequence
			, d.SourceID
			, d.DateCreated
			, d.DateChanged
			, d.RecStatus
		INTO #Deposits
		FROM [$(Source_Data)].[Retail_Corporate].[Deposits] AS d
		INNER JOIN [MasterData_Retail_Ent].[DataSetKey] dwi
		ON d.OrderID = dwi.DataSetKeyValue
		WHERE dwi.DataSetName = @DataSetName
		AND dwi.DataSetType = @DataSetType;

		TRUNCATE TABLE [Retail_Sales_Wrk].[OrderHistPayments];

		INSERT INTO [Retail_Sales_Wrk].[OrderHistPayments]
		(
			OrderID
			, FinancePaymentTypeID
			, TotalAmt
		)
		
		SELECT 
			fin.OrderID
            , fin.FinancePaymentTypeID
            , SUM(FinanceAmt) AS TotalAmt
		FROM
		(
			SELECT 
				o.OrderID
				, o.FinancePaymentTypeID
				, o.FinanceAmt * tc.TransCodeMultiplier AS FinanceAmt
			FROM #Orders AS o
			INNER JOIN [$(Source_Data)].[Retail_External].[TransCodes] AS tc
			ON tc.TransCodeID = o.TransCodeID
			WHERE o.RecStatus <> 'D'

			UNION ALL
			
			SELECT 
				d.OrderID
				, d.PaymentTypeID AS FinancePaymentTypeID
				, SUM(d.PaymentAmt * tc.TransCodeMultiplier) AS FinanceAmt
			FROM #Deposits AS d
			INNER JOIN #Orders AS o
			ON d.OrderID = o.OrderID
			INNER JOIN [$(Source_Data)].[Retail_External].[TransCodes] AS tc
			ON tc.TransCodeID = o.TransCodeID
			WHERE d.RecStatus <> 'D'
			GROUP BY d.OrderID
					 , d.PaymentTypeID

			UNION ALL

			SELECT 
				o.Base_OrderID AS OrderID
				, o.FinancePaymentTypeID
				, SUM(o.FinanceAmt * tc.TransCodeMultiplier) AS FinanceAmt
			FROM #Invoice AS o
			INNER JOIN [$(Source_Data)].[Retail_External].[TransCodes] AS tc
			ON tc.TransCodeID = o.TransCodeID
			GROUP BY o.Base_OrderID
					 , o.FinancePaymentTypeID

			UNION ALL

			SELECT 
				i.Base_OrderID AS OrderID
				, ipo.PaymentTypeID AS FinancePaymentTypeID
				, SUM(ipo.PaymentAmt * tc.TransCodeMultiplier) AS FinanceAmt
			FROM #InvoicePaymentInfo ipo
			INNER JOIN #Invoice i
			ON i.OrderID = ipo.OrderID
			INNER JOIN [$(Source_Data)].[Retail_External].[TransCodes] AS tc
			ON tc.TransCodeID = i.TransCodeID
			GROUP BY i.Base_OrderID
					 , ipo.PaymentTypeID
		) fin
		WHERE fin.FinancePaymentTypeID IS NOT NULL
		GROUP BY fin.OrderID
				 , fin.FinancePaymentTypeID
		ORDER BY fin.OrderID;

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