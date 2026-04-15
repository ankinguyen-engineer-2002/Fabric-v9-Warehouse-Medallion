CREATE PROCEDURE [Retail_Sales_Enh].[usp_Update_StoreTraffic]
AS

BEGIN
	
	DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
    SET @String = 'Retail_Sales_Enh.usp_Update_StoreTraffic';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'Retail_Sales_Enh'
	SET @DestinationTable = 'StoreTraffic';

	SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    BEGIN TRY

		--TRUNCATE TABLE [Retail_Sales_Enh].[StoreTraffic];

		DECLARE @StartDate DATE = GETDATE()-5
				, @EndDate DATE = GETDATE()-1;

		DROP TABLE IF EXISTS [Retail_Sales_Enh].[StoreTrafficHolding];
		
		CREATE TABLE [Retail_Sales_Enh].[StoreTrafficHolding]
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

		DROP TABLE IF EXISTS [Retail_Sales_Enh].[StoreLocMapping];
        CREATE TABLE [Retail_Sales_Enh].[StoreLocMapping]
		(
			[StoreID] [int] NOT NULL,
            [OperationID] [int]  NULL,
            [ProfitCenter] [int]  NULL,
            [ShopperTrakLocID] [int] NULL,
            [sttLocID] [varchar](20) NULL
        );

		WITH cteStoreMap AS 
		(
			SELECT 213 as StoreID, '0213' as LocID 
			UNION
			SELECT 217, 'Corsicana'
			UNION
			SELECT 228, 'Rossford'
			UNION
			SELECT 235, '0235'
			UNION
			SELECT 236, '0236'
			UNION
			SELECT 237, '0237'
			UNION
			SELECT 504, '0504'
			UNION
			SELECT 544, 'Airtex Outlet'
			UNION
			SELECT 555, 'Perimeter Memphis'
			UNION
			SELECT 566, 'Hixson'
			UNION
			SELECT 628, '0321-0064'
			UNION
			SELECT 721, '0133-721'
			--UNION
			--SELECT 629, '0321-0065'

		)


        INSERT INTO [Retail_Sales_Enh].[StoreLocMapping]
        (
            [StoreID],
            [OperationID],
            [ProfitCenter],
            [ShopperTrakLocID],
            [sttLocID]
        )
        SELECT 
			sl.StoreID
			, OperationID
			, ProfitCenter
			, ShopperTrakLocID
            , COALESCE(stt.sttLocID, b.LocID)
		FROM [MasterData_Retail_Ent].[StoreLocation] sl
        LEFT JOIN [MasterData_Retail_Ent].[MappingLocIDShopperTrakID] stt 
        ON CONCAT(sl.OperationID, '_', sl.ProfitCenter) = stt.LocationKey
        LEFT JOIN cteStoreMap b on sl.StoreID = b.StoreID 
        WHERE sl.StoreID IS NOT NULL

/*
		WITH CTE AS
		(
			SELECT 
				StoreID
				, OperationID
				, ProfitCenter
				, ShopperTrakLocID
			FROM [MasterData_Retail_Ent].[StoreLocation]
		)
*/
		INSERT INTO [Retail_Sales_Enh].[StoreTrafficHolding]
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
			, ma.ShopperTrakLocID AS DeviceSourceID
			, ma.StoreID
			--, CTE.ShopperTrakLocID AS DeviceSourceID
			--, CTE.StoreID
			, st.TransDate
			, DAY(st.TransDate) AS TransDay
			, CAST(DATEPART(HOUR, st.TransTime) AS DECIMAL(18,2)) AS TransHour
			, CAST(DATEPART(HOUR, st.TransTime) + (CAST(DATEPART(MINUTE, st.TransTime) AS DECIMAL(5,2)) / 60) AS DECIMAL(18,2)) AS TransHourMinute
			, CAST(CAST(st.GuestEntry AS DECIMAL(19,4)) / sts.DivideBy  AS DECIMAL(19,4)) AS TransCount
			, 0 AS IsOpen
			, CAST(GETDATE() AS DATETIME2(3)) AS LastUpdated
			, CAST(CAST(st.GuestEntry AS DECIMAL(19,4)) / sts.DivideBy  AS DECIMAL(19,4)) AS TrafficCount
			, 0 AS RSAMinutes
			, 0 AS IsOverride
		FROM [Retail_Sales].[StoreTraffic] st
		LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[ShopperTrakStores] sts ON st.LocationKey = sts.APIStoreID
		JOIN [Retail_Sales_Enh].[StoreLocMapping] ma ON st.LocationKey = ma.sttLocID
/*		INNER JOIN [MasterData_Retail_Ent].[MappingLocIDShopperTrakID] stt 
		ON stt.sttLocID = st.LocationKey
		INNER JOIN CTE 
		ON CONCAT(CTE.OperationID, '_', CTE.ProfitCenter) = stt.LocationKey
*/
		WHERE TransDate BETWEEN @StartDate AND @EndDate;

		--IsOpen

		UPDATE st
		SET st.IsOpen = 1
		FROM [Retail_Sales_Enh].[StoreTrafficHolding] st
		INNER JOIN [$(Source_Data)].[Retail_External].[StoreDailyOpenHours] sdoh
		ON st.StoreID = sdoh.StoreID
		AND CAST(st.TransDate AS DATE) = CAST(sdoh.TransDate AS DATE)
		AND st.TransHourMinute >= sdoh.OpenTime
		AND st.TransHourMinute < sdoh.CloseTime
		AND st.TransDate BETWEEN @StartDate AND @EndDate;

		DELETE st
		FROM [Retail_Sales_Enh].[StoreTrafficHolding] st
		INNER JOIN [$(Source_Data)].[Retail_Miniapps].[TrafficRequests] tr
		ON st.StoreID = tr.LocationID
		AND st.TransDate = CAST(tr.TransDate AS DATE)
		AND cast(st.TransHour AS INT) = CAST(tr.TransHour AS INT);

		INSERT INTO [Retail_Sales_Enh].[StoreTrafficHolding]
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

		--Traffic Override

		SELECT
			st.DataSource
			, st.DeviceSourceID
			, tr.LocationID AS StoreID
			, CAST(tr.TransDate AS DATE) AS TransDate
			, DAY(tr.TransDate) AS TransDay
			, tr.TransHour AS TransHour
			, 0 AS TransHourMinute
			, tr.ChangeCount AS TransCount
			, 1 AS IsOpen
			, GETDATE() AS LastUpdated
			, tr.ChangeCount AS TrafficCount
			, 0 AS RSAMinutes
			, 1 AS IsOverride
		FROM [$(Source_Data)].[Retail_Miniapps].[TrafficRequests] tr
		LEFT JOIN
		(
			SELECT DISTINCT 
				StoreID
				, DataSource
				, DeviceSourceID
			FROM [Retail_Sales_Enh].[StoreTrafficHolding] 
			WHERE NULLIF(DataSource, '') IS NOT NULL
		) st 
		ON tr.LocationID = st.StoreID
		WHERE -- NULLIF(st.DataSource, '') IS NOT NULL AND
		CAST(tr.TransDate AS DATE) >= @StartDate ;

		DELETE FROM [Retail_Sales_Enh].[StoreTraffic]
		WHERE TransDate BETWEEN @StartDate AND @EndDate;

		INSERT INTO [Retail_Sales_Enh].[StoreTraffic]
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
		FROM [Retail_Sales_Enh].[StoreTrafficHolding];

		DROP TABLE [Retail_Sales_Enh].[StoreTrafficHolding];

		--DeviceSourceID

		UPDATE st
		SET st.DeviceSourceID = map.sttShopperTrakOrgID
		FROM [Retail_Sales_Enh].[StoreTraffic] st
		JOIN
		(
			SELECT 
				LTRIM(b.StoreID, '0') AS StoreID
				, a.sttLocID
				, a.sttShopperTrakOrgID
			FROM [MasterData_Retail_Ent].[MappingLocIDShopperTrakID] a
			INNER JOIN [$(Source_Data)].[Retail_Miniapps].[ShopperTrakStores] b
			on a.sttLocID = b.APIStoreID
		) map
		ON st.StoreID = map.StoreID
		WHERE st.DeviceSourceID IS NULL;

		--DataSource

		UPDATE st
		SET st.DataSource = sl.CompanyCode
		FROM [Retail_Sales_Enh].[StoreTraffic] st
		INNER JOIN [MasterData_Retail_Ent].[StoreLocation] sl
		ON st.StoreID = sl.StoreID
		WHERE st.DataSource IS NULL;

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