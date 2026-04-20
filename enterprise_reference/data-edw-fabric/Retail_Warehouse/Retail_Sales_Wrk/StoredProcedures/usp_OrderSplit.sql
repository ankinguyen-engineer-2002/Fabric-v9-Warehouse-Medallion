CREATE PROCEDURE [Retail_Sales_Wrk].[usp_OrderSplit]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Wrk.usp_OrderSplit';
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

		TRUNCATE TABLE [Retail_Sales_Wrk].[OrderSplit];

		INSERT INTO [Retail_Sales_Wrk].[OrderSplit]
		(
			OrderID
			, SalesPersonID
			, TransDateKey
			, DataSource
			, TransCodeID
			, SalesType
			, NetSales
			, NetUnits
		)

		SELECT
			bd.OrderID
			, bd.SalespersonID
			, CONVERT(VARCHAR(8), bd.TransDate, 112) AS TransDateKey
			, 'bta' AS DataSource
			, bd.TransCodeID
			, bd.Source
			, SUM(bd.NetSales) AS NetSales
			, SUM(bd.NetUnits) AS NetUnits
		FROM [$(Source_Data)].[Retail_Corporate].[BtaData] bd
		INNER JOIN [MasterData_Retail_Ent].[DataSetKey] dwi
		ON bd.OrderID = dwi.DataSetKeyValue
		WHERE dwi.DataSetName = @DataSetName
		AND dwi.DataSetType = @DataSetType
		AND bd.Source = 'W'
		AND bd.TransCodeID NOT IN (20, 50)
		GROUP BY bd.OrderID
				, bd.SalespersonID
				, CONVERT(VARCHAR(8), bd.TransDate, 112)
				, bd.TransCodeID
				, bd.Source;

		/*Debit / Credit Memos*/
		INSERT INTO [Retail_Sales_Wrk].[OrderSplit]
		(
			OrderID
			, SalesPersonID
			, TransDateKey
			, DataSource
			, TransCodeID
			, SalesType
			, NetSales
			, NetUnits
		)

		SELECT
			bd.OrderID
			, bd.SalespersonID
			, CONVERT(VARCHAR(8), bd.TransDate, 112) AS TransDateKey
			, 'bta' AS DataSource
			, bd.TransCodeID
			, bd.Source
			, SUM(bd.NetSales) AS NetSales
			, SUM(bd.NetUnits) AS NetUnits
		FROM [$(Source_Data)].[Retail_Corporate].[BtaData] bd
		INNER JOIN [MasterData_Retail_Ent].[DataSetKey] dwi
		ON bd.OrderID = dwi.DataSetKeyValue
		WHERE dwi.DataSetName = @DataSetName
		AND dwi.DataSetType = @DataSetType
		AND bd.Source = 'D'
		AND bd.TransCodeID IN (20, 50)
		GROUP BY bd.OrderID
				, bd.SalespersonID
				, CONVERT(VARCHAR(8), bd.TransDate, 112)
				, bd.TransCodeID
				, bd.Source;

		EXEC [Retail_Sales_Wrk].[usp_OrderSplit_OI];

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