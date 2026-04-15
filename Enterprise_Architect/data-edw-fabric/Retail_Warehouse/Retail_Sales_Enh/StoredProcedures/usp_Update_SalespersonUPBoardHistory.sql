CREATE   PROCEDURE [Retail_Sales_Enh].[usp_Update_SalespersonUPBoardHistory]
AS
BEGIN

	DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);

    SET @String = 'Retail_Sales_Enh.usp_Update_SalespersonUPBoardHistory';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'Retail_Sales_Enh'
	SET @DestinationTable = 'SalesPersonUPBoardHistory';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

	BEGIN TRY

		--TRUNCATE TABLE [Retail_Sales_Enh].[SalesPersonUPBoardHistory];
		
		DECLARE @StartTransDate DATE
				, @EndTransDate DATE;

		SELECT @EndTransDate = MAX(SalespersonUPBoardHistoryStatusStart)
		FROM [$(Source_Data)].[MasterData_Retail].[SalespersonUPBoardHistoryAGR];

		SET @StartTransDate = DATEADD(DAY, -1, @EndTransDate);

		DECLARE	@Date3AM DATETIME2(3)
				, @NextDate3AM DATETIME2(3);
		SELECT	@Date3AM = CONVERT(DATETIME2(3), FORMAT(DATEADD(hh, 3, DATEADD(dd, DATEDIFF(dd, 0, @StartTransDate), 0)), 'yyyyMMdd H:00:00'))
				, @NextDate3AM = CONVERT(DATETIME2(3), FORMAT(DATEADD(hh, 27, DATEADD(dd, DATEDIFF(dd, 0, @EndTransDate), 0)), 'yyyyMMdd H:00:00'));
		
		IF OBJECT_ID('tempdb..#Store') IS NOT NULL
		DROP TABLE #Store;

		SELECT 
			ss.StoreID AS ScoreboardStoreID
			, CASE WHEN ss.StoreNumber = 16090 THEN 421
				WHEN ss.StoreNumber = 16198 THEN 622
				WHEN ss.StoreNumber = 16736 THEN 720
				WHEN ss.StoreNumber = 16680 THEN 719
				WHEN ss.StoreNumber = 7521 THEN 342
				WHEN ss.StoreNumber = 7551 THEN 332
				WHEN ss.StoreNumber = 99999 THEN 999
				ELSE st.RetailSystemNumber END AS StoreID
			, ss.StoreName
		INTO #Store
		FROM [$(Source_Data)].[MasterData_Retail].[ScoreboardStore] ss
		LEFT JOIN [$(Source_Data)].[MasterData_Retail].[SiteMasterLocations] st
		ON (LEN(ss.StoreNumber) = 3 AND LTRIM(ss.StoreNumber, '0') = st.RetailSystemNumber)
		OR (LEN(ss.StoreNumber) <> 3 AND ss.StoreNumber = st.financialUnitNumber);

		IF OBJECT_ID('tempdb..#SalesPerson') IS NOT NULL
		DROP TABLE #SalesPerson;

		;WITH RankedSalesPerson AS 
		(
			SELECT	
				-- s.EmployeeNbr AS EmployeeNumber
				COALESCE(s.EmployeeNbr, ei.EmployeeNumber) AS EmployeeNumber
				, IIF(ISNULL(sm.people_id, 0) > 0, sm.people_id, NULL) AS PeopleID
				, sm.active_status AS ActiveStatus
				, s.SalespersonID AS SalesPersonID
				, spx.Name AS SalesPersonName
				, ROW_NUMBER() OVER(PARTITION BY COALESCE(s.EmployeeNbr, ei.EmployeeNumber) ORDER BY IIF(s.RecStatus = 'D', 1, 0), s.SalespersonID) AS RowNum
				-- , ROW_NUMBER() OVER(PARTITION BY s.EmployeeNbr ORDER BY IIF(s.RecStatus = 'D', 1, 0), s.SalespersonID) AS RowNum
			FROM [$(Source_Data)].[Retail_Corporate].[Salesperson] spx
			-- INNER JOIN [Source_Data].[Retail_Corporate].[Staff] s
			LEFT JOIN [$(Source_Data)].[Retail_Corporate].[Staff] s
			ON s.SalespersonID = spx.SalespersonID
			LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[EmployeeInfo] ei  ON ei.SalespersonID = spx.SalespersonID -- Newly Added
			LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[Salesman] sm
			ON sm.ID = s.SalespersonID
			-- WHERE s.EmployeeNbr IS NOT NULL
			-- OR s.SalespersonID = 'FSP'
			WHERE
			 (COALESCE(s.EmployeeNbr, ei.EmployeeNumber) IS NOT NULL
			OR s.SalespersonID = 'FSP') 
		),
		FilteredSalesPerson AS 
		(
			SELECT 
				rsp.EmployeeNumber 
				, rsp.PeopleID
				, rsp.ActiveStatus
				, sp.SalespersonID
				, sp.Name AS SalesPersonName
			FROM [$(Source_Data)].[Retail_Corporate].[Salesperson] sp
			INNER JOIN RankedSalesPerson rsp 
			ON rsp.SalesPersonID = sp.SalespersonID
			WHERE rsp.RowNum = 1
		),
		RankedMasterData AS 
		(
			SELECT 
				ss.SalesPersonID AS ScoreboardSalesPersonID
				, ss.StoreID AS ScoreboardStoreID
				, ss.SalesPersonName
				, ss.SalesPersonEmailAddress
				, ss.SalesPersonMobilePhoneNumber
				, ss.SalesPersonUserName
				, ss.SalesPersonPassword
				, ss.SalesPersonRole
				, ss.DeletedIND
				, ss.EmployeeID
				, a.PeopleID
				, a.ActiveStatus
				, a.SalesPersonID
				, ROW_NUMBER() OVER(PARTITION BY ss.SalesPersonID ORDER BY ss.EmployeeID DESC) AS RN
			FROM [$(Source_Data)].[MasterData_Retail].[Salesperson] ss
			LEFT JOIN FilteredSalesPerson a
			ON (LTRIM(ss.EmployeeID, 'DSG') = LTRIM(a.EmployeeNumber, '0') 
			OR LTRIM(ss.EmployeeID, '0') = LTRIM(a.EmployeeNumber, '0'))
			LEFT JOIN [$(Source_Data)].[Retail_Corporate].[Staff] staff
			ON (LTRIM(ss.EmployeeID, 'DSG') = LTRIM(staff.EmployeeNbr, '0') 
			OR LTRIM(ss.EmployeeID, '0') = LTRIM(staff.EmployeeNbr, '0'))
			AND staff.StaffTypeID NOT IN ('S$RF')
		)

		SELECT 
			ScoreboardStoreID
			, ScoreboardSalesPersonID
			, SalesPersonID
			, SalesPersonName
			, SalesPersonEmailAddress
			, SalesPersonMobilePhoneNumber
			, SalesPersonUserName
			, SalesPersonPassword
			, SalesPersonRole
			, DeletedIND
			, EmployeeID
			, PeopleID
			, ActiveStatus
		INTO #SalesPerson
		FROM RankedMasterData
		WHERE RN = 1;

		IF OBJECT_ID('tempdb..#wrk_SalespersonUPBoardHistory') IS NOT NULL
		DROP TABLE #wrk_SalespersonUPBoardHistory;

		SELECT
			agr.SalespersonUPBoardHistoryID AS HistoryID
			, st.StoreID
			, agr.StoreID AS ScoreboardStoreID
			, agr.SalespersonID
			, agr.SalespersonUPBoardStatusID AS StatusID
			, agr.SalespersonUPBoardHistorySequence AS HistorySequence
			, agr.SalespersonUPBoardHistoryStatusStart AS HistoryStatusStart
			, agr.SalespersonUPBoardHistoryStatusEnd AS HistoryStatusEnd
			, agr.SalespersonRotationTypeID
			, agr.SalespersonUPBoardHistoryGuestName AS HistoryGuestName
			, agr.SalespersonUPBoardHistoryGuestDescription AS HistoryGuestDescription
			, agr.SalespersonUPBoardHistoryGuestCount AS HistoryGuestCount
			, agr.SalespersonUPBoardHistoryIsCloseSale AS HistoryIsCloseSale
			, agr.SalespersonUPBoardHistoryIsProspect AS HistoryIsProspect
			, agr.SalespersonUPBoardHistoryLocalTimeStatusStart AS HistoryLocalTimeStatusStart
			, agr.SalespersonUPBoardHistoryLocalTimeStatusEnd AS HistoryLocalTimeStatusEnd
			, agr.SalespersonUPBoardHistoryGuestPhoneNumber AS HistoryGuestPhoneNumber
			, agr.SalespersonUPBoardHistoryGuestProspecting AS HistoryGuestProspecting
			, agr.SalespersonUPBoardHistoryIsSaleOverThreshold AS HistoryIsSaleOverThreshold
			, agr.SalespersonUPBoardHistoryOverflowCount AS HistoryOverflowCount
			, agr.SalespersonUPBoardHistoryIsSleepAssessment AS HistoryIsSleepAssessment
			, agr.SalespersonUPBoardID AS ID
			, agr.SalespersonUPBoardHistoryStrikeOuts AS HistoryStrikeOuts
			, agr.IsUp AS HistoryCount
			, agr.SalespersonUPBoardHistoryCompleted AS HistoryCompleted
			, agr.IsShot
			, agr.WasFinanceApplicationCreated
			, agr.SalespersonUPBoardReasonManagerAddWith AS ReasonManagerAddWith
			, agr.SalespersonUPBoardReasonManagerAddSP AS ReasonManagerAddSP
			, agr.SalespersonUPBoardReasonManagerAddUps AS ReasonManagerAddUps
			, agr.SalespersonUPBoardReasonManagerRemoveSP AS ReasonManagerRemoveSP
			, agr.SalespersonUPBoardManagerCoachingNotes AS ManagerCoachingNotes
			, agr.CoachingNotesCreationDate AS ManagerCoachingNotesTime
			, agr.IsStrike
			, agr.IsStrikeOut
			, agr.ConsecutiveStrikes
			, agr.ConsecutiveStrikeOuts
			, sp.EmployeeID
		INTO #wrk_SalespersonUPBoardHistory
		FROM [$(Source_Data)].[MasterData_Retail].[SalespersonUPBoardHistoryAGR] agr
		LEFT JOIN #Store st
		ON agr.StoreID = st.ScoreboardStoreID
		LEFT JOIN [$(Source_Data)].[MasterData_Retail].[Salesperson] sp
		ON agr.SalespersonID = sp.SalesPersonID
		WHERE SalespersonUPBoardHistoryLocalTimeStatusStart > @Date3AM
		AND SalespersonUPBoardHistoryLocalTimeStatusEnd <= @NextDate3AM
		AND SalespersonUPBoardStatusID IN (2, 3, 9, 10, 11, 98, 99);

		IF OBJECT_ID('tempdb..#wrk_StoreDailyOpenHours') IS NOT NULL 
		DROP TABLE #wrk_StoreDailyOpenHours;

		SELECT  
			LTRIM(StoreID, '0') AS StoreID
			, CAST(TransDate AS DATE) AS TransDate
			, FLOOR(OpenTime) AS OpenTime
			, CEILING(CloseTime) AS CloseTime
		INTO #wrk_StoreDailyOpenHours
		FROM [$(Source_Data)].[Retail_External].[StoreDailyOpenHours]
		WHERE CONVERT(DATE, TransDate) BETWEEN @StartTransDate AND @EndTransDate
		AND IsOpen = 1;

		DROP TABLE IF EXISTS [Retail_Sales_Enh].[SalesPersonUPBoardHistoryAGRHolding];
	
		CREATE TABLE [Retail_Sales_Enh].[SalesPersonUPBoardHistoryAGRHolding]
		(
			[Source] [varchar](5) NOT NULL,
			[StoreID] [int] NOT NULL,
			[ScoreboardStoreID] [int] NOT NULL,
			[SalesPersonID] [varchar](30) NULL,
			[ScoreboardSalesPersonID] [int] NULL,
			[SalesPersonName] [varchar](100) NULL,
			[SalesPersonUserName] [varchar](30) NULL,
			[StatusStartTime] [datetime2](3) NOT NULL,
			[StatusEndTime] [datetime2](3) NULL,
			[StatusStartDate] [date] NOT NULL,
			[StatusStartHour] [int] NULL,
			[RecordedUpDate] [date] NULL,
			[RecordedUpHour] [int] NULL,
			[SPUBStatusID] [int] NULL,
			[GuestName] [varchar](100) NULL,
			[isCountedAsUP] [int] NULL,
			[isSale] [int] NULL,
			[StrikeCount] [int] NULL,
			[Shot] [int] NULL,
			[FinApp] [int] NULL,
			[ReasonManagerAddWith] [varchar](500) NULL,
			[ReasonManagerAddSP] [varchar](500) NULL,
			[ReasonManagerAddUps] [varchar](500) NULL,
			[ReasonManagerRemoveSP] [varchar](500) NULL,
			[ManagerCoachingNotes] [varchar](500) NULL,
			[ManagerCoachingNotesTime] [datetime2](3) NULL,
			[IsStrike] [bit] NULL,
			[IsStrikeOut] [bit] NULL,
			[ConsecutiveStrikes] [int] NULL,
			[ConsecutiveStrikeOuts] [int] NULL
		);
	
		INSERT INTO [Retail_Sales_Enh].[SalesPersonUPBoardHistoryAGRHolding]
		(
			Source
			, StoreID
			, ScoreboardStoreID
			, SalesPersonID
			, ScoreboardSalesPersonID
			, SalesPersonName
			, SalesPersonUserName
			, StatusStartTime
			, StatusEndTime
			, StatusStartDate
			, StatusStartHour
			, SPUBStatusID
			, GuestName
			, isCountedAsUP
			, isSale
			, StrikeCount
			, Shot
			, FinApp
			, ReasonManagerAddWith
			, ReasonManagerAddSP
			, ReasonManagerAddUps
			, ReasonManagerRemoveSP
			, ManagerCoachingNotes
			, ManagerCoachingNotesTime
			, IsStrike
			, IsStrikeOut
			, ConsecutiveStrikes
			, ConsecutiveStrikeOuts
		)

		SELECT DISTINCT
			'AGR' AS Source
			, sh.StoreID
			, sh.ScoreboardStoreID
			, COALESCE(sp.SalesPersonID, 'FSP') AS SalesPersonID
			, sp.ScoreboardSalesPersonID
			, COALESCE(sp.SalesPersonName,'FORMER SALES PERSON') AS SalesPersonName
			, sp.SalesPersonUserName AS SalesPersonUserName
			, sh.HistoryLocalTimeStatusStart AS StatusStartTime
			, sh.HistoryLocalTimeStatusEnd AS StatusEndTime
			, CAST(sh.HistoryLocalTimeStatusStart AS DATE) AS StatusStartDate
			, DATEPART(HOUR, sh.HistoryLocalTimeStatusStart) AS StatusStartHour
			, sh.StatusID AS SPUBStatusID
			, sh.HistoryGuestName AS GuestName
			, sh.HistoryCount AS isCountedAsUP
			, sh.HistoryIsCloseSale AS isSale
			, sh.HistoryStrikeOuts AS StrikeCount
			, sh.IsShot AS Shot
			, sh.WasFinanceApplicationCreated AS FinApp
			, sh.ReasonManagerAddWith AS ReasonManagerAddWith
			, sh.ReasonManagerAddSP AS ReasonManagerAddSP
			, sh.ReasonManagerAddUps AS ReasonManagerAddUps
			, sh.ReasonManagerRemoveSP AS ReasonManagerRemoveSP
			, sh.ManagerCoachingNotes AS ManagerCoachingNotes
			, sh.ManagerCoachingNotesTime AS ManagerCoachingNotesTime
			, sh.IsStrike AS IsStrike
			, sh.IsStrikeOut AS IsStrikeOut
			, sh.ConsecutiveStrikes AS ConsecutiveStrikes
			, sh.ConsecutiveStrikeOuts AS ConsecutiveStrikeOuts
		FROM #wrk_SalespersonUPBoardHistory sh
		LEFT JOIN #SalesPerson sp
		ON sh.SalespersonID = sp.ScoreboardSalesPersonID;
		
		/*
		UPDATE [Retail_Sales_Enh].[SalesPersonUPBoardHistoryAGRHolding]
		SET StatusStartDate = CAST(StatusStartTime AS DATE)
			, StatusStartHour = DATEPART(HOUR, StatusStartTime);
		*/

		UPDATE d
		SET	RecordedUpDate = CASE WHEN StatusStartHour BETWEEN 0 AND 3	THEN DATEADD(DAY, -1, StatusStartDate)
							 ELSE StatusStartDate END
			, RecordedUpHour = CASE WHEN StatusStartHour BETWEEN 3 AND OpenTime THEN OpenTime 
							   WHEN StatusStartHour >= CloseTime OR StatusStartHour BETWEEN 0 AND 3 THEN CloseTime - 1
							   ELSE StatusStartHour END
		FROM [Retail_Sales_Enh].[SalesPersonUPBoardHistoryAGRHolding] d
		INNER JOIN #wrk_StoreDailyOpenHours sdoh 
		ON d.StoreID = sdoh.StoreID
		AND d.StatusStartDate = sdoh.TransDate;

		--Fix Status ID = 99
 
		UPDATE [Retail_Sales_Enh].[SalesPersonUPBoardHistoryAGRHolding]
		SET SPUBStatusID = 99
		WHERE SPUBStatusID = 2
		AND NULLIF(ReasonManagerAddSP,'') IS NOT NULL;

		--Save Data For Activity Report

		INSERT INTO [Retail_Sales_Enh].[SalesPersonUPBoardHistory]
		(
			Source
			, StoreID
			, ScoreboardStoreID
			, SalesPersonID
			, ScoreboardSalesPersonID
			, SalesPersonName
			, SalesPersonUserName
			, StatusStartTime
			, StatusEndTime
			, StatusStartDate
			, StatusStartHour
			, RecordedUpDate
			, RecordedUpHour
			, SPUBStatusID
			, GuestName
			, isCountedAsUP
			, isSale
			, StrikeCount
			, Shot
			, FinApp
			, ReasonManagerAddWith
			, ReasonManagerAddSP
			, ReasonManagerAddUps
			, ReasonManagerRemoveSP
			, ManagerCoachingNotes
			, ManagerCoachingNotesTime
			, IsStrike
			, IsStrikeOut
			, ConsecutiveStrikes
			, ConsecutiveStrikeOuts
		)

		SELECT
			src.Source
			, src.StoreID
			, src.ScoreboardStoreID
			, src.SalesPersonID
			, src.ScoreboardSalesPersonID
			, src.SalesPersonName
			, src.SalesPersonUserName
			, ISNULL(src.StatusStartTime, CAST('' AS DATETIME2(3))) AS StatusStartTime
			, ISNULL(src.StatusEndTime, CAST('' AS DATETIME2(3))) AS StatusEndTime
			, ISNULL(src.StatusStartDate, CAST('' AS DATE)) AS StatusStartDate
			, ISNULL(src.StatusStartHour, 0) AS StatusStartHour
			, src.RecordedUpDate
			, src.RecordedUpHour
			, src.SPUBStatusID
			, src.GuestName
			, src.isCountedAsUP
			, src.isSale
			, src.StrikeCount
			, src.Shot
			, src.FinApp
			, src.ReasonManagerAddWith
			, src.ReasonManagerAddSP
			, src.ReasonManagerAddUps
			, src.ReasonManagerRemoveSP
			, src.ManagerCoachingNotes
			, src.ManagerCoachingNotesTime
			, src.IsStrike
			, src.IsStrikeOut
			, src.ConsecutiveStrikes
			, src.ConsecutiveStrikeOuts
		FROM [Retail_Sales_Enh].[SalesPersonUPBoardHistoryAGRHolding] src
		WHERE src.ScoreboardSalesPersonID IS NOT NULL
		AND NOT EXISTS
		(
			SELECT 1
			FROM [Retail_Sales_Enh].[SalesPersonUPBoardHistory] dst
			WHERE dst.StoreID = src.StoreID
			AND dst.SalesPersonID = src.SalesPersonID
			AND dst.StatusStartTime = src.StatusStartTime
			AND dst.StatusEndTime = src.StatusEndTime
		);

		UPDATE dst
		SET dst.SalesPersonName = src.SalesPersonName
			, dst.SalesPersonID = src.SalesPersonID
			, dst.StatusStartHour = src.StatusStartHour
			, dst.RecordedUpDate = src.RecordedUpDate
			, dst.RecordedUpHour = src.RecordedUpHour
			, dst.SPUBStatusID = src.SPUBStatusID
			, dst.GuestName = src.GuestName
			, dst.isCountedAsUP = src.isCountedAsUP
			, dst.isSale = src.isSale
			, dst.StrikeCount = src.StrikeCount
			, dst.Shot = src.Shot
			, dst.FinApp = src.FinApp
			, dst.ReasonManagerAddWith = src.ReasonManagerAddWith
			, dst.ReasonManagerAddSP = src.ReasonManagerAddSP
			, dst.ReasonManagerAddUps = src.ReasonManagerAddUps
			, dst.ReasonManagerRemoveSP = src.ReasonManagerRemoveSP
			, dst.ManagerCoachingNotes = src.ManagerCoachingNotes
			, dst.ManagerCoachingNotesTime = src.ManagerCoachingNotesTime
			, dst.IsStrike = src.IsStrike
			, dst.IsStrikeOut = src.IsStrikeOut
			, dst.ConsecutiveStrikes = src.ConsecutiveStrikes
			, dst.ConsecutiveStrikeOuts = src.ConsecutiveStrikeOuts
		FROM [Retail_Sales_Enh].[SalesPersonUPBoardHistory] AS dst
		INNER JOIN [Retail_Sales_Enh].[SalesPersonUPBoardHistoryAGRHolding] AS src
		ON dst.StoreID = src.StoreID
		AND dst.SalesPersonID = src.SalesPersonID
		AND dst.StatusStartTime = src.StatusStartTime
		AND dst.StatusEndTime = src.StatusEndTime
		WHERE src.ScoreboardSalesPersonID IS NOT NULL;

		DROP TABLE [Retail_Sales_Enh].[SalesPersonUPBoardHistoryAGRHolding];

		/*
		/*History Load*/

		INSERT INTO [Retail_Sales_Enh].[SalesPersonUPBoardHistory] 
		(
			Source
			, StoreID
			, ScoreboardStoreID
			, SalesPersonID
			, ScoreboardSalesPersonID
			, SalesPersonName
			, SalesPersonUserName
			, StatusStartTime
			, StatusEndTime
			, StatusStartDate
			, StatusStartHour
			, RecordedUpDate
			, RecordedUpHour
			, SPUBStatusID
			, GuestName
			, isCountedAsUP
			, isSale
			, StrikeCount
			, Shot
			, FinApp
			, ReasonManagerAddWith
			, ReasonManagerAddSP
			, ReasonManagerAddUps
			, ReasonManagerRemoveSP
			, ManagerCoachingNotes
			, ManagerCoachingNotesTime
			, IsStrike
			, IsStrikeOut
			, ConsecutiveStrikes
			, ConsecutiveStrikeOuts
		)

		SELECT
			'DSG' AS Source
			, LTRIM(rg.StoreID, '0') AS StoreID
			, ISNULL(st.ScoreboardStoreID, 0) AS ScoreboardStoreID
			, rg.SalespersonUsername AS SalesPersonID
			, ISNULL(sp.ScoreboardSalesPersonID, 0) AS ScoreboardSalesPersonID
			, rg.SalespersonName AS SalesPersonName
			, sp.SalesPersonUserName
			, ISNULL(rg.StatusStartTime, CAST('' AS DATETIME2(3))) AS StatusStartTime
			, ISNULL(rg.StatusEndTime, CAST('' AS DATETIME2(3))) AS StatusEndTime
			, ISNULL(rg.StatusStartDate, CAST('' AS DATE)) AS StatusStartDate
			, ISNULL(rg.StatusStartHour, 0) AS StatusStartHour
			, rg.RecordedUpDate
			, rg.RecordedUpHour
			, rg.SPUB_StatusID AS SPUBStatusID
			, rg.GuestName
			, rg.isCountedAsUP
			, rg.isSale
			, rg.StrikeCount
			, rg.Shot
			, rg.FinApp
			, rg.ReasonManagerAddWith
			, rg.ReasonManagerAddSP
			, rg.ReasonManagerAddUps
			, rg.ReasonManagerRemoveSP
			, rg.ManagerCoachingNotes
			, rg.ManagerCoachingNotesTime
			, rg.IsStrike
			, rg.IsStrikeOut
			, rg.ConsecutiveStrikes
			, rg.ConsecutiveStrikeOuts
		FROM [$(Source_Data)].[MasterData_Retail].[SalespersonUPBoardHistoryDSG] rg
		LEFT JOIN #Store st
		ON rg.StoreID = st.StoreID
		LEFT JOIN #SalesPerson sp
		ON rg.SalespersonUsername = sp.SalesPersonID
		LEFT JOIN [Retail_Sales_Enh].[SalesPersonUPBoardHistory] agr 
		ON rg.StoreID = agr.StoreID
		AND rg.StatusStartDate = agr.StatusStartDate
		AND rg.SalespersonUsername = agr.SalesPersonID
		WHERE agr.StoreID IS NULL;
		
		*/

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
		Exec [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase, @DestinationSchema, @DestinationTable
		
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