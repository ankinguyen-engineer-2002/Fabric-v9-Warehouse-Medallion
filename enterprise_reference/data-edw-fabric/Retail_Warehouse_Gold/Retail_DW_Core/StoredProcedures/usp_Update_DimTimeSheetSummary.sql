CREATE   PROCEDURE [Retail_DW_Core].[usp_Update_DimTimeSheetSummary]
AS
BEGIN

	DECLARE
        @String VARCHAR(5000),
        @DateValue DATETIME,
        @User VARCHAR(500),
		@DestinationDatabase VARCHAR(150),
		@DestinationSchema VARCHAR(150),
		@DestinationTable VARCHAR(150);
			      
    SET @String = 'Retail_DW_Core.usp_Update_DimTimeSheetSummary';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'Retail_DW_Core'
	SET @DestinationTable = 'DimTimeSheetSummary';
	
	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

BEGIN TRY

		DECLARE @StartDate DATE = CAST(GETDATE()-30 AS DATE)
				, @EndDate DATE = GETDATE();
		
		DELETE ts
		FROM [Retail_DW_Core].[DimTimeSheetSummary] ts
		WHERE ts.TransDate BETWEEN @StartDate AND @EndDate;
		
		INSERT INTO [Retail_DW_Core].[DimTimeSheetSummary]
		(
			SourceDataID
			, TransDate
			, LocationID
			, LocationKey
			, LocationName
			, LocationType
			, Productive
			, PayCodeID
			, PayCodeName
			, TaskCodeID
			, TaskCodeName
			, TimeCodeID
			, TotalHours
			, RegularHours
			, OverTimeHours
			, ExternalHours
			, InternalHours
			, TotalCost
			, RegularCost
			, OverTimeCost
			, ExternalCost
			, InternalCost
			, Benefit
			, IsExternal
			, ApprovedByManager
			, DataSource
		)

		SELECT
			ts.SourceDataID
			, CONVERT(DATE, CAST(ts.TransDateKey AS VARCHAR(8)), 112) AS TransDate
			, ts.SourceLocationID AS LocationID
			, st.LocationKey
			, st.LocationName
			, st.LocationType
			, CASE WHEN tpc.PayCodeType IN (1, 2, 7) AND tac.TaskCodeType = 1 THEN 1 ELSE 0 END AS Productive
			, ts.PayCodeID
			, tpc.PayCodeName
			, ts.TaskCodeID
			, tac.TaskCodeName
			, ts.TimeCodeID
			, ts.TotalTime AS TotalHours
			, ts.TotalTime * (1 - ts.TimeCodeID) AS RegularHours
			, ts.TotalTime * ts.TimeCodeID AS OverTimeHours
			, ts.TotalTime * ts.IsExternal AS ExternalHours
			, ts.TotalTime * ((ts.IsExternal+1)%2) AS InternalHours
			, ts.TotalCost
			, ts.TotalCost * (1 - ts.TimeCodeID) AS RegularCost
			, ts.TotalCost * ts.TimeCodeID AS OverTimeCost
			, ts.TotalCost * ts.IsExternal AS ExternalCost
			, ts.TotalCost * ((ts.IsExternal+1)%2) AS InternalCost
			, ts.Benefit
			, ts.IsExternal
			, ts.ApprovedByManager
			, ts.DataSource
		FROM [$(Retail_Warehouse)].[MasterData_HR_UKG_Enh].[TimeSheetSummary] ts
		LEFT JOIN [Retail_DW_Core].[DimStoreLocation] st
        ON st.StoreID = ts.SourceLocationID
		LEFT JOIN [$(Source_Data)].[Retail_External].[TATaskCodes] tac
        ON tac.TaskCodeID = ts.TaskCodeID
		LEFT JOIN [$(Source_Data)].[Retail_External].[TAPayCodes] tpc
        ON tpc.PayCodeID = ts.PayCodeID
		WHERE CONVERT(DATE, CAST(ts.TransDateKey AS VARCHAR(8)), 112) BETWEEN @StartDate AND @EndDate;

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