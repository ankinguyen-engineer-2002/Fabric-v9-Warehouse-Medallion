CREATE         PROCEDURE [Retail_Sales_Enh].[usp_SalesOrderCloses]
AS
/*
This procedure in TDSG Database [etl].[proc_Btadata_ProcessSUOrders]
*/
BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Enh.usp_SalesOrderCloses';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_Sales_Enh';
	SET @DestinationTable = 'SalesOrderCloses';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		DECLARE @SUOrderID VARCHAR(50),
				@OrderDate DATE = GETDATE()-1,
				-- @TransDateKey INT;
				@TransDateKey INT = CONVERT(VARCHAR(8), GETDATE()-1, 112)

		TRUNCATE TABLE [Retail_Sales_Wrk].[SUOrderDateQueue];
		TRUNCATE TABLE [Retail_Sales_Wrk].[SUOrderLoadQueue];

		--SUOID, PID, PS

		/* Get Super Order to Process*/
		INSERT INTO [Retail_Sales_Wrk].[SUOrderDateQueue]
		(
			SUOrderID,
			TransDateKey
		)

		SELECT
			SuperOrderID AS SUOrderID,
			CONVERT(VARCHAR(8), TransDate, 112) AS TransDateKey
		FROM [Retail_Sales_Enh].[SalesOrderLineHistory] AS soc
		INNER JOIN [$(Source_Data)].[Retail_External].[TransCodeMap] As tm
		ON tm.TransCodeID = soc.TransCodeID
		WHERE soc.Source = 'W'
		AND tm.TransCodeGroup = 'SREAT'
		AND soc.SourceOrderID NOT IN
		(
			SELECT SourceOrderID
			FROM [Retail_Sales_Enh].[SalesOrderHeader] AS oh
			WHERE oh.SFMCFulfillmentStatus = 'Completed'
			AND oh.SFMCLastFulfillmentDate < DATEADD(DAY, -7, GETDATE())
		) 
		-- AND OrderDate >= @OrderDate
		AND TransDateKey >= @TransDateKey
		GROUP BY soc.SuperOrderID,
				 CONVERT(VARCHAR(8), soc.TransDate, 112)
		ORDER BY soc.SuperOrderID,
				 CONVERT(VARCHAR(8), soc.TransDate, 112);

		/* Clear Date that was processed already*/
		DELETE FROM sd
		FROM Retail_Sales_Wrk.[SUOrderDateQueue] sd
		INNER JOIN
		(
			SELECT 
				tsoc.SuperOrderID,
				MAX(tsoc.TransDateKey) AS CTransDateKey
			FROM [Retail_Sales_Enh].[SalesOrderCloses] AS tsoc
			INNER JOIN Retail_Sales_Wrk.[SUOrderDateQueue] AS sd
			ON sd.SUOrderID = tsoc.SuperOrderID
			GROUP BY tsoc.SuperOrderID
		) cls
		ON cls.SuperOrderID = sd.SUOrderID
		WHERE sd.TransDateKey < cls.CTransDateKey;


		INSERT INTO  Retail_Sales_Wrk.[SUOrderLoadQueue]
		(
			SUOrderID,
			ProcessStatus
		)

		SELECT DISTINCT 
			SUOrderID,
			0
		FROM Retail_Sales_Wrk.[SUOrderDateQueue];

		EXEC [Retail_Sales_Enh].[usp_SalesOrderCloses_ProcessSUOrder_Bulk];


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
		Exec [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase,@DestinationSchema,@DestinationTable
	
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