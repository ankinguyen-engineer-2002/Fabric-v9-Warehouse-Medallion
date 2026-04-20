CREATE PROCEDURE [MasterData_Retail_Ent].[usp_Refresh_DataSetKey]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'MasterData_Retail_Ent.usp_Refresh_DataSetKey';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'MasterData_Retail_Ent';
	SET @DestinationTable = 'usp_Refresh_DataSetKey';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		DECLARE @FromDate DATE = GETDATE()-1;
		DECLARE @ToDate DATE = GETDATE();
 
		TRUNCATE TABLE [MasterData_Retail_Ent].[DataSetKey];

		INSERT INTO [MasterData_Retail_Ent].[DataSetKey]
		(
			DataSetName
			, DataSetKeyValue
			, DataSetType
		)
 
		SELECT 
			'Orders' AS DataSetName
			 , OrderID AS DataSetKeyValue
			 , 'PROD' AS DataSetType
		FROM
		(
			SELECT Base_OrderID AS OrderID
			FROM [$(Source_Data)].[Retail_Corporate].[BtaData]
			WHERE 
			(
				TransDate BETWEEN @FromDate AND @ToDate
			)
			GROUP BY Base_OrderID

			UNION

			SELECT OrderID
			FROM [$(Source_Data)].[Retail_Corporate].[Orders] 
			WHERE 
			(
				CAST(DateCreated AS DATE) BETWEEN @FromDate AND @ToDate
				OR CAST(DateChanged AS DATE) BETWEEN @FromDate AND @ToDate
			)
			GROUP BY OrderID

			UNION

			SELECT Base_OrderID AS OrderID
			FROM [$(Source_Data)].[Retail_Corporate].[Invoice]
			WHERE 
			(
				CAST(DateCreated AS DATE) BETWEEN @FromDate AND @ToDate
				OR CAST(DateChanged AS DATE)  BETWEEN @FromDate AND @ToDate
			)
			AND RecStatus <> 'D'
			GROUP BY Base_OrderID
		) ord
		GROUP BY ord.OrderID;

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
		EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase, @DestinationSchema, @DestinationTable;
	
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
GO

