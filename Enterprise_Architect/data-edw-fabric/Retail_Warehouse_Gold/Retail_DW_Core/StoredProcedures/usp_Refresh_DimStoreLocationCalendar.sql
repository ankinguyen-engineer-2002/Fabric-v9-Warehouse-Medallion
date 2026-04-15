CREATE PROCEDURE [Retail_DW_Core].[usp_Refresh_DimStoreLocationCalendar]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Refresh_DimStoreLocationCalendar';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'DimStoreLocationCalendar';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		UPDATE lc
		SET lc.OpenTime = CAST(sdoh.OpenTime AS VARCHAR(20))
			, lc.CloseTime = CAST(sdoh.CloseTime AS VARCHAR(20))
			, lc.IsDelivery = ISNULL(sdoh.DlvyDay, 0)
			, lc.ChangedBy = ISNULL(sdoh.ChangedBy, 'CURRENT_USER')
			, lc.DateChanged = GETDATE()
		FROM [Retail_DW_Core].[DimStoreLocationCalendar] lc
		INNER JOIN [Retail_DW_Core].[DimStoreLocation] lm 
		ON lc.StoreID = lm.StoreID
		INNER JOIN [$(Source_Data)].[Retail_External].[StoreDailyOpenHours] sdoh 
		ON lc.TransDateKey = CAST(CONVERT(VARCHAR(12), sdoh.TransDate,112) AS INT)
		AND lm.StoreID = CAST(sdoh.StoreID AS INT)
		WHERE (lc.OpenTime <> CAST(sdoh.OpenTime AS VARCHAR(20))
		OR lc.CloseTime <> CAST(sdoh.CloseTime AS VARCHAR(20))
		OR lc.IsDelivery <> COALESCE(sdoh.DlvyDay, 0));

		INSERT INTO [Retail_DW_Core].[DimStoreLocationCalendar]
		(
			StoreID
			, LocationKey
			, TransDate
			, TransDateKey
			, YearMonthKey
			, YearKey
			, OpenTime
			, CloseTime
			, IsOpen
			, IsDelivery
			, DateChanged
			, ChangedBy
		)

		SELECT 
			lc.StoreID
			, lm.LocationKey
			, dm.DateID AS TransDate
			, lc.TransDateKey
			, lc.YearMonthKey
			, lc.YearKey
			, CAST(lc.OpenTime AS TIME(0)) OpenTime
			, CAST(lc.CloseTime AS TIME(0)) CloseTime
			, lc.IsOpen
			, lc.IsDelivery
			, lc.DateChanged
			, lc.ChangedBy
		FROM [$(Retail_Warehouse)].[MasterData_Retail_Ent].[StoreLocationCalendar] AS lc
		INNER JOIN [Retail_DW_Core].[DimDate] AS dm
		ON dm.DateKey = lc.TransDateKey
		INNER JOIN [Retail_DW_Core].[DimStoreLocation] AS lm
		ON lm.StoreID = lc.StoreID
		WHERE NOT EXISTS 
		(
			SELECT 1 
			FROM [Retail_DW_Core].[DimStoreLocationCalendar] lce
			WHERE lce.StoreID = lc.StoreID
			AND lce.TransDateKey = lc.TransDateKey
		);

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