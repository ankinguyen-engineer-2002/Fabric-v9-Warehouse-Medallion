CREATE PROCEDURE [Retail_OOM_Enh].[usp_Update_OOMSchedulePerformance]
AS
BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_OOM_Enh.usp_Update_OOMSchedulePerformance';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_OOM_Enh';
	SET @DestinationTable = 'OOMSchedulePerformance';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		--TRUNCATE TABLE [Retail_OOM_Enh].[OOMSchedulePerformance];

		DECLARE @TransDate DATE = (GETDATE() - 1),
				@WrittenSales DECIMAL(19, 4),
				@TotalScheduleStore DECIMAL(19, 4),
				@TotalScheduleGRT DECIMAL(19, 4),
				@TotalScheduleDTR DECIMAL(19, 4),
				@TotalScheduleAudit DECIMAL(19, 4),
				@TotalScheduleUnassigned DECIMAL(19, 4),
				@TotalScheduleIVR DECIMAL(19, 4),
				@TotalScheduleSMS DECIMAL(19, 4),
				@AttackTarget DECIMAL(19, 4),
				@FilledCleanDelivery DECIMAL(19, 4),
				@ScheduleAtPOS DECIMAL(19, 4),
				@DaysToSchedule DECIMAL(19, 4),
				@AttackTargetNumPreviousDays INT,
				@FilledCleanTarget DECIMAL(19, 4),
				@FilledCleanDeliveryPreviousDay DECIMAL(19, 4),
				@PreviousDaysAverageWrittenSales DECIMAL(19, 4),
				@PreviousDaysAveragePrntSCDPOS DECIMAL(5, 4),
				@SMSMessagesSentCount INT,
				@AutoScheduleOrderCount INT,
				@TotalScheduleStoreOrderCount INT, 
				@TotalScheduleGRTOrderCount INT, 
				@TotalScheduleDTROrderCount INT, 
				@TotalScheduleAuditOrderCount INT, 
				@TotalScheduleUnassignedOrderCount INT, 
				@TotalScheduleIVROrderCount INT, 
				@ScheduleAtPOSOrderCount INT, 
				@TotalScheduleSMSOrderCount INT, 
				@TotalScheduleChatBotOrderCount INT,
				@TotalScheduleChatBot INT;

		SET @AttackTargetNumPreviousDays = 3;
		SET @FilledCleanTarget = 3000000;

		SELECT 
			@WrittenSales = SUM(oi.QtyOrdered * oi.CaseSellingPrice)
		FROM [$(Source_Data)].[Retail_Corporate].[Orders] AS o
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderItem] AS oi 
		ON oi.OrderID = o.OrderID
		WHERE o.RecStatus <> 'D'
		AND oi.RecStatus <> 'D'
		AND o.OrderDate = @TransDate
		AND oi.TransCodeID IN (0, 1, 7);

		-- ScheduleBy StaffTypeID is Store Ops / Sales
		SELECT	
			@TotalScheduleStore = COALESCE(SUM(otdds.OrderAmount), 0)
			, @TotalScheduleStoreOrderCount = COUNT(DISTINCT otdds.OrderID)
		FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[Staff] AS s 
		ON s.StaffID = otdds.ScheduleBy
		WHERE otdds.TransDate = @TransDate
		AND otdds.ScheduleToday = 1
		AND (otdds.ScheduleChangeType IS NULL OR otdds.ScheduleChangeType IN (1, 2))
		AND s.StaffTypeID IN ('CSR', 'ETMGR', 'ETNGT', 'ETSLS', 'EXCSUP', 'GER', 'LMCM', 'LMSM', 'REGMGR', 'RSA', 
		'S$MSM', 'S$MSS', 'S$SALE', 'S$SMGR', 'SLSENS', 'SLSETM', 'SLSHC', 'SOGRTA', 'STRMGR', 'SVPM', 'VIP');

		-- ScheduleBy StaffTypeID is OOM-GRT
		SELECT 
			@TotalScheduleGRT = COALESCE(SUM(otdds.OrderAmount), 0)
			, @TotalScheduleGRTOrderCount = COUNT(DISTINCT otdds.OrderID)
		FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[Staff] AS s 
		ON s.StaffID = otdds.ScheduleBy
		WHERE otdds.TransDate = @TransDate
		AND otdds.ScheduleToday = 1
		AND (otdds.ScheduleChangeType IS NULL OR otdds.ScheduleChangeType IN (1, 2))
		AND s.StaffTypeID IN ('GRMGR', 'GRSUP', 'GRTA', 'OOM');

		-- ScheduleBy StaffTypeID is DTR
		SELECT 
			@TotalScheduleDTR = COALESCE(SUM(otdds.OrderAmount), 0) 
			, @TotalScheduleDTROrderCount = COUNT(DISTINCT otdds.OrderID)
		FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[Staff] AS s 
		ON s.StaffID = otdds.ScheduleBy
		WHERE otdds.TransDate = @TransDate
		AND otdds.ScheduleToday = 1
		AND (otdds.ScheduleChangeType IS NULL OR otdds.ScheduleChangeType IN (1, 2))
		AND s.StaffTypeID IN ('WHMGR', 'WHSUP');

		-- ScheduleBy StaffTypeID is AUDIT
		SELECT
			@TotalScheduleAudit = COALESCE(SUM(otdds.OrderAmount), 0) 
			, @TotalScheduleAuditOrderCount = COUNT(DISTINCT otdds.OrderID)
		FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[Staff] AS s 
		ON s.StaffID = otdds.ScheduleBy
		WHERE otdds.TransDate = @TransDate
		AND otdds.ScheduleToday = 1
		AND (otdds.ScheduleChangeType IS NULL OR otdds.ScheduleChangeType IN (1, 2))
		AND s.StaffTypeID IN ('AUDIT');

		-- ScheduleBy StaffTypeID is UNASSIGNED
		SELECT 
			@TotalScheduleUnassigned = COALESCE((SUM(otdds.OrderAmount) - @TotalScheduleStore - @TotalScheduleGRT - @TotalScheduleDTR - @TotalScheduleAudit), 0)
			, @TotalScheduleUnassignedOrderCount = COUNT(DISTINCT otdds.OrderID)
		FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds
		WHERE otdds.TransDate = @TransDate
		AND otdds.ScheduleToday = 1
		AND (otdds.ScheduleChangeType IS NULL OR otdds.ScheduleChangeType IN (1, 2));

		-- Schedule Automation - Twilio IVR
		SELECT
			@TotalScheduleIVR = COALESCE(SUM(otdds.OrderAmount), 0) 
			, @TotalScheduleIVROrderCount = COUNT(DISTINCT otdds.OrderID)
		FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds
		WHERE otdds.TransDate = @TransDate
		AND otdds.ScheduleToday = 1
		AND otdds.ScheduleChangeType = 3;

		-- Schedule Automation - Text/SMS
		SELECT 
			@TotalScheduleSMS = COALESCE(SUM(otdds.OrderAmount), 0)
			, @TotalScheduleSMSOrderCount = COUNT(DISTINCT otdds.OrderID)
		FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds
		WHERE otdds.TransDate = @TransDate
		AND otdds.ScheduleToday = 1
		AND otdds.ScheduleChangeType = 4;

		-- QTY Order = QTY Committed on all lines -- all in stock
		SELECT
			oi.OrderID
			, SUM(oi.QtyOrdered * oi.CaseSellingPrice) AS OrderAmount
			, SUM(oi.QtyOrdered) AS QuantityOrdered
			, SUM(oi.QtyCommitted) AS QuantityCommitted
		INTO #OrdTtls
		FROM [$(Source_Data)].[Retail_Corporate].[OrderItem] AS oi 
		WHERE oi.RecStatus <> 'D'
		AND oi.TransCodeID IN (0, 1, 7)
		AND oi.DlvyStatus = 'EST'
		GROUP BY oi.OrderID;

		SELECT
			@FilledCleanDelivery = COALESCE(SUM(ot.OrderAmount), 0)
		FROM #OrdTtls ot
		INNER JOIN 
		(
			SELECT 
				DISTINCT OrderID 
			FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds 
			WHERE otdds.TransDate = @TransDate
		) otdds 
		ON ot.OrderID = otdds.OrderID
		WHERE ot.QuantityOrdered = ot.QuantityCommitted;

		DROP TABLE #OrdTtls;

		-- OrdTransDetail DlvyStatAtPOS = SCD and TransDate = order date
		SELECT	
			@ScheduleAtPOS = COALESCE(SUM(oi.QtyOrdered * oi.CaseSellingPrice), 0)
			, @ScheduleAtPOSOrderCount = COUNT(DISTINCT o.OrderID) 
		FROM [$(Source_Data)].[Retail_Corporate].[Orders] AS o
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderItem] oi
		ON oi.OrderID = o.OrderID
		INNER JOIN [Retail_OOM_Enh].[OrderTransDetail] otd 
		ON oi.OrderID = otd.OrderID
		AND	oi.ItemID = otd.ItemID
		WHERE o.RecStatus <> 'D'
		AND oi.RecStatus <> 'D'
		AND o.OrderDate = @TransDate
		AND otd.DeliveryStatusAtPOS = 'SCD'
		AND oi.TransCodeID IN (0, 1, 7);

		--Calculate Attack Target using formula....	

		-- (1 - AVG. % SCD POS)) * AVG. Written Sales (over previous X number of days)
		SELECT	
			@PreviousDaysAverageWrittenSales = AVG(osp.WrittenSales)
			, @PreviousDaysAveragePrntSCDPOS = AVG(osp.ScheduleAtPOS / osp.WrittenSales)
		FROM [Retail_OOM_Enh].[OOMSchedulePerformance] osp
		WHERE osp.TransDate BETWEEN DATEADD(dd, - (@AttackTargetNumPreviousDays + 1), @TransDate) AND DATEADD(dd, -1, @TransDate);

		SET @AttackTarget = (1.0 - @PreviousDaysAveragePrntSCDPOS) * @PreviousDaysAverageWrittenSales;

		-- PLUS (Prev Day Filled Clean - Filled Clean Target) / 7 (if > 0)
		SELECT	@FilledCleanDeliveryPreviousDay = osp.FilledCleanDelivery
		FROM [Retail_OOM_Enh].[OOMSchedulePerformance] osp
		WHERE osp.TransDate = DATEADD(dd, -1, @TransDate);

		IF (@FilledCleanDeliveryPreviousDay - @FilledCleanTarget) > 0
		SET @AttackTarget = @AttackTarget + ((@FilledCleanDeliveryPreviousDay - @FilledCleanTarget) / 7);

		-- Avg. # days for orders scheduled on TransDate
		SELECT	
			@DaysToSchedule = AVG(DATEDIFF(dd, o.OrderDate, otdds.TransDate))
		FROM [$(Source_Data)].[Retail_Corporate].[Orders] o
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderItem] oi
		ON oi.OrderID = o.OrderID
		INNER JOIN [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds 
		ON oi.OrderID = otdds.OrderID
		AND oi.ItemID = otdds.ItemID
		WHERE o.RecStatus <> 'D'
		AND oi.RecStatus <> 'D'
		AND otdds.TransDate = @TransDate
		AND otdds.FirstSchedule = 1
		AND oi.TransCodeID IN (0, 1, 7);

		-- Count of orders scheduled via SMS or IVR
		SELECT	
			@AutoScheduleOrderCount = COUNT(DISTINCT otdds.OrderID)
		FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds
		WHERE otdds.TransDate = @TransDate
		AND otdds.ScheduleToday = 1
		AND otdds.ScheduleChangeType IN (3, 4);

		-- Count of orders scheduled via ChatBot ---New
		SELECT	
			@TotalScheduleChatBot = COALESCE(SUM(otdds.OrderAmount), 0) 
			, @TotalScheduleChatBotOrderCount = COUNT(DISTINCT otdds.OrderID)
		FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds
		WHERE otdds.TransDate = @TransDate
		AND otdds.ScheduleToday = 1
		AND otdds.ScheduleChangeType = 5;


		--Count of SMS messages sent for scheduling delivery
		/*SELECT	
			@SMSMessagesSentCount = SUM(SMSAttempt)
		FROM [$(Source_Data)].[Retail_Miniapps].[GuestCare_OutboundStats]
		WHERE CAST(DateCreated AS DATE) = @TransDate; */

		INSERT INTO [Retail_OOM_Enh].[OOMSchedulePerformance]
		(
			TransDate
			, WrittenSales
			, TotalScheduleStore
			, TotalScheduleGRT
			, TotalScheduleDTR
			, TotalScheduleAudit
			, TotalScheduleUnassigned
			, TotalScheduleIVR
			, TotalScheduleSMS
			, TotalScheduleChatBot
			, AttackTarget
			, FilledCleanDelivery
			, ScheduleAtPOS
			, DaysToSchedule
			, SMSMessagesSentCount
			, AutoScheduleOrderCount
			, TotalScheduleStoreOrderCount
			, TotalScheduleGRTOrderCount
			, TotalScheduleDTROrderCount
			, TotalScheduleAuditOrderCount
			, TotalScheduleUnassignedOrderCount
			, TotalScheduleIVROrderCount
			, ScheduleAtPOSOrderCount
			, TotalScheduleSMSOrderCount
			, TotalScheduleChatBotOrderCount
		)
	
		SELECT	
			@TransDate
			, @WrittenSales
			, @TotalScheduleStore
			, @TotalScheduleGRT
			, @TotalScheduleDTR
			, @TotalScheduleAudit
			, @TotalScheduleUnassigned
			, @TotalScheduleIVR
			, @TotalScheduleSMS
			, @TotalScheduleChatBot
			, @AttackTarget
			, @FilledCleanDelivery
			, @ScheduleAtPOS
			, @DaysToSchedule
			, cast('0' as int) as SMSMessagesSentCount
			, @AutoScheduleOrderCount
			, @TotalScheduleStoreOrderCount
			, @TotalScheduleGRTOrderCount
			, @TotalScheduleDTROrderCount
			, @TotalScheduleAuditOrderCount
			, @TotalScheduleUnassignedOrderCount
			, @TotalScheduleIVROrderCount
			, @ScheduleAtPOSOrderCount
			, @TotalScheduleSMSOrderCount
			, @TotalScheduleChatBotOrderCount;

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