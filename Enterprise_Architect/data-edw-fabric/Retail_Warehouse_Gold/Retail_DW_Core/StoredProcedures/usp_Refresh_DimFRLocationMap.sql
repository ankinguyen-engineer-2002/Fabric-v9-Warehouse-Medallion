CREATE PROCEDURE [Retail_DW_Core].[usp_Refresh_DimFRLocationMap]
AS 
BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Refresh_DimFRLocationMap';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'DimFRLocationMap';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		UPDATE dst
		SET dst.FRLocationID = src.FRLocationID
		FROM [$(Source_Data)].[Retail_External].[FrLocationMap] src
		INNER JOIN [Retail_DW_Core].[DimFRLocationMap] dst 
		ON src.LocationID = dst.StoreID
		AND src.ShipLocationID = dst.ShipLocationID

		INSERT INTO [Retail_DW_Core].[DimFRLocationMap]
		(
			StoreID,
			ShipLocationID,
			FRLocationID
		)

		SELECT 
			src.LocationID AS StoreID,
			src.ShipLocationID,
			src.FRLocationID	
		FROM [$(Source_Data)].[Retail_External].[FrLocationMap] src
		LEFT OUTER JOIN [Retail_DW_Core].[DimFRLocationMap] dst 
		ON src.LocationID = dst.StoreID
		AND src.ShipLocationID = dst.ShipLocationID
		WHERE dst.StoreID IS NULL;

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