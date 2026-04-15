CREATE   PROCEDURE [Retail_DW_Core].[usp_Update_FactTraffic]
AS
BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Update_FactTraffic';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'FactTraffic';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY
		-- DROP TABLE IF EXISTS [Retail_DW_Core].[StoreOpenHoursHolding]
		-- CREATE TABLE [Retail_DW_Core].[StoreOpenHoursHolding]
		-- (
		-- 	[StoreID] [int] NOT NULL,
		-- 	[TransDate] [date] NOT NULL,
		-- 	[Store_OpenTime] [decimal](18,2) NULL,
		-- 	[Store_CloseTime] [decimal](18,2) NULL
		-- )

		-- INSERT INTO [Retail_DW_Core].[StoreOpenHoursHolding]
		-- (StoreID
		-- ,TransDate
		-- , Store_OpenTime
		-- , Store_CloseTime
		-- )
		-- select StoreID, 
		-- TransDate,
		-- min(TransHour) as Store_OpenTime,
		-- max(TransHour) as Store_CloseTime
		-- from Retail_DW_Core.FactTraffic where TransDate >= '2025-12-25'
		-- AND IsOpen = 1
		-- group by StoreID, TransDate;

		TRUNCATE TABLE [Retail_DW_Core].[FactTraffic];

		-- DECLARE @FromDateKey INT
		--  		, @ToDateKey INT;
	
		-- DECLARE @StartDate DATE = GETDATE()-30
		-- 		, @EndDate DATE = GETDATE()-1;

		DROP TABLE IF EXISTS [Retail_DW_Core].[FactTrafficHolding];

		CREATE TABLE [Retail_DW_Core].[FactTrafficHolding]
		(
			[DataSource] [varchar](5) NULL,
			[DeviceSourceID] [varchar](20) NULL,
			[StoreID] [int] NOT NULL,
			[TransDate] [date] NOT NULL,
			[TransDay] [int] NOT NULL,
			[TransHour] [decimal](18, 2) NOT NULL,
			[TransHourMinute] [decimal](18, 2) NOT NULL,
			[TransCount] [decimal](18, 2) NULL,
			[IsOpen] [int] NULL,
			[LastUpdated] [datetime2](3) NULL,
			[TrafficCount] [decimal](18, 2) NULL,
			[RSAMinutes] [int] NULL,
			[IsOverride] [int] NULL
		);

		INSERT INTO [Retail_DW_Core].[FactTrafficHolding]
		(
			DataSource
			, DeviceSourceID
			, StoreID
			, TransDate
			, TransDay
			, TransHour
			, TransHourMinute
			, TransCount
			, IsOpen
			, LastUpdated
			, TrafficCount
			, RSAMinutes
			, IsOverride
		)

		SELECT
			st.DataSource
			, st.DeviceSourceID
			, st.StoreID
			, st.TransDate
			, st.TransDay
			, CAST(st.TransHour AS DECIMAL(18,2)) AS TransHour
			, CAST(st.TransHour AS DECIMAL(18,2)) AS TransHourMinute
			, st.TransCount
			, st.IsOpen
			, st.LastUpdated
			, st.TrafficCount
			, st.RSAMinutes
			, st.IsOverride
		FROM [$(Retail_Warehouse)].[Retail_Traffic].[StoreTraffic] st
        WHERE st.StoreID IS NOT NULL
        
		-- WHERE TransDate BETWEEN @StartDate AND @EndDate;

		-- UPDATE a set 
		--  a.IsOpen = case when a.TransHourMinute >= 9 and TransHourMinute < 21 then 1 else 0 end
		--  from [Retail_DW_Core].[FactTrafficHolding] a
		--  where a.TransDate >= '2025-12-31' and a.TransDate <= '2026-01-01' 
		
		--  UPDATE a set 
		--  a.IsOpen = case when TransHourMinute between b.Store_OpenTime and b.Store_CloseTime then 1 else 0 end
		--  from [Retail_DW_Core].[FactTrafficHolding] a 
		--  JOIN [Retail_DW_Core].[StoreOpenHoursHolding] b ON a.StoreID = b.StoreID and a.TransDate = DATEADD(day, 7,  b.TransDate)
		--  WHERE a.TransDate >= '2026-01-02' 
		
		-- End here 

		-- SELECT 
		-- 	@FromDateKey = CAST(CONVERT(VARCHAR(12), MIN(TransDate), 112) AS INT)
		-- 	, @ToDateKey = CAST(CONVERT(VARCHAR(12), MAX(TransDate), 112) AS INT)
		-- FROM [Retail_DW_Core].[FactTrafficHolding];

		-- DELETE FROM [Retail_DW_Core].[FactTraffic]
		-- WHERE TransDateKey BETWEEN @FromDateKey AND @ToDateKey;

		INSERT INTO [Retail_DW_Core].[FactTraffic]
		(
			DataSource
			, DeviceSourceID
			, StoreID
			, TransDate
			, TransDateKey
			, TransDay
			, TransHour
			, TransHourMinute
			, TransCount
			, IsOpen
			, LastUpdated
			, TrafficCount
			, TrafficGuest
			, RSAMinutes
			, IsOverride
		)

		SELECT
			src.DataSource
			, src.DeviceSourceID
			, src.StoreID
			, src.TransDate
			, CONVERT(VARCHAR(8), src.TransDate, 112) AS TransDateKey
			, src.TransDay
			, src.TransHour
			, src.TransHourMinute
			, src.TransCount
			, src.IsOpen
			, src.LastUpdated
			, src.TrafficCount
			, src.IsOpen * src.TransCount AS TrafficGuest
			, src.RSAMinutes
			, src.IsOverride
		FROM [Retail_DW_Core].[FactTrafficHolding] src;

--		DROP TABLE [Retail_DW_Core].[FactTrafficHolding];

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