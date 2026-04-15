CREATE   PROCEDURE [Retail_DW_Core].[usp_Update_DimPeopleTimeSheet]
AS
BEGIN

	DECLARE
        @String VARCHAR(5000),
        @DateValue DATETIME,
        @User VARCHAR(500),
		@DestinationDatabase VARCHAR(150),
		@DestinationSchema VARCHAR(150),
		@DestinationTable VARCHAR(150);
			      
    SET @String = 'Retail_DW_Core.usp_Update_DimPeopleTimeSheet';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'Retail_DW_Core'
	SET @DestinationTable = 'DimPeopleTimeSheet';
	
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
		
		DELETE pts
		FROM [Retail_DW_Core].[DimPeopleTimeSheet] pts
		WHERE pts.TransDate BETWEEN @StartDate AND @EndDate;

		INSERT INTO [Retail_DW_Core].[DimPeopleTimeSheet]
		(
			TimeSheetID
			, SourceDataID
			, SourceSystemID
			, PeopleID
			, EmployeeNumber
			, PayPeriod
			, TransDate
			, LocationID
			, LocationKey
			, LocationName
			, LocationType
			, Productive
			, TimeIn
			, [TimeOut]
			, [Time]
			, SourcePayCodeID
			, PayCodeID
			, PayCodeName
			, SourceTaskCodeID
			, TaskCodeID
			, TaskCodeName
			, DateCreated
			, Rate
			, ExtCost
			, ApprovedByManager
			, DataSource
		)
		
		SELECT
			pts.TimeSheetID
			, pts.SourceDataID
			, pts.SourceSystemID
			, pts.PeopleID
			, pts.EmployeeNumber
			, pts.PayPeriod
			, CONVERT(DATE, CAST(pts.TransDateKey AS VARCHAR(8)), 112) AS TransDate
			, pts.SourceLocationID AS LocationID
			, st.LocationKey
			, st.LocationName
			, st.LocationType
			, CASE WHEN tpc.PayCodeType = 1 AND tac.TaskCodeType = 1 THEN 1 ELSE 0 END AS Productive
			, pts.TimeIn
			, pts.[TimeOut]
			, pts.[Time]
			, pts.SourcePayCodeID
			, pts.PayCodeID
			, tpc.PayCodeName
			, pts.SourceTaskCodeID
			, pts.TaskCodeID
			, tac.TaskCodeName
			, pts.DateCreated
			, pts.Rate
			, pts.ExtCost
			, pts.ApprovedByManager
			, pts.DataSource
		FROM [$(Retail_Warehouse)].[MasterData_HR_UKG_Enh].[PeopleTimeSheet] pts
		LEFT JOIN [Retail_DW_Core].[DimStoreLocation] st
		ON pts.SourceLocationID = st.StoreID
		LEFT JOIN [$(Source_Data)].[Retail_External].[TATaskCodes] tac
		ON tac.TaskCodeID = pts.TaskCodeID
		LEFT JOIN [$(Source_Data)].[Retail_External].[TAPayCodes] tpc
		ON tpc.PayCodeID = pts.PayCodeID
		WHERE CONVERT(DATE, CAST(pts.TransDateKey AS VARCHAR(8)), 112) BETWEEN @StartDate AND @EndDate;

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