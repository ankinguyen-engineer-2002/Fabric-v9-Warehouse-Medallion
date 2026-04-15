CREATE   PROCEDURE [Retail_OOM_Enh].[usp_Update_OOMSchedulePerformanceDetails]
AS
BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_OOM_Enh.usp_Update_OOMSchedulePerformanceDetails';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_OOM_Enh';
	SET @DestinationTable = 'OOMSchedulePerformanceDetails';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY
	
		--Variables
		DECLARE @TransDate DATE = DATEADD(DAY, -1, CAST(GETDATE() AS DATE)),
				@AttackTargetNumPreviousDays SMALLINT = 3,
				@FilledCleanTarget DECIMAL(13, 2) = 3000000;
		
		-----------------------------------------------------------------------------------------------------
		--WrittenSales
		-----------------------------------------------------------------------------------------------------
		IF OBJECT_ID('tempdb..#WrittenSales') IS NOT NULL 
		DROP TABLE #WrittenSales;

		SELECT  
			store_b.STORE_ID AS BookedStoreID
			, store_dc.STORE_ID AS DCStoreID
			, COALESCE(SUM(oi.QtyOrdered * oi.CaseSellingPrice),0) as WrittenSales
			,oi.OrderID
		INTO #WrittenSales
		FROM [$(Source_Data)].[Retail_Corporate].[Orders] AS o
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderItem] AS oi 
		ON oi.OrderID = o.OrderID
		OUTER APPLY 
		(
			SELECT TOP 1 STORE_ID
			FROM 
			(
				SELECT oi2.BookedStoreID AS STORE_ID
				FROM [$(Source_Data)].[Retail_Corporate].[OrderItem] oi2 
				WHERE oi2.OrderID = oi.OrderID
				and oi2.RecStatus <> 'D'
				
				UNION
				
				SELECT ii2.BookedStoreID AS STORE_ID
				FROM [$(Source_Data)].[Retail_Corporate].[InvoiceItem] ii2 
				WHERE ii2.OrderID = oi.OrderID
			) R
		) AS store_b 
		OUTER APPLY 
		(
			SELECT TOP 1 STORE_ID
			FROM 
			(
				SELECT oi3.StoreID AS STORE_ID
				FROM [$(Source_Data)].[Retail_Corporate].[OrderItem] oi3 
				WHERE oi3.OrderID = oi.OrderID
				and oi3.RecStatus <> 'D'
				
				UNION
			
				SELECT ii3.StoreID AS STORE_ID
				FROM [$(Source_Data)].[Retail_Corporate].[InvoiceItem] ii3 
				WHERE ii3.OrderID = oi.OrderID
			) R
		) AS  store_dc
		WHERE o.RecStatus <> 'D'
		AND oi.RecStatus <> 'D'
		AND o.OrderDate = @TransDate
		AND oi.TransCodeID IN (0, 1, 7)
		GROUP BY
			store_b.STORE_ID
			, store_dc.STORE_ID,oi.OrderID;

		-----------------------------------------------------------------------------------------------------
		--ScheduleBy StaffTypeID is Store Ops / Sales
		-----------------------------------------------------------------------------------------------------
		IF OBJECT_ID('tempdb..#TotalScheduleStore') IS NOT NULL 
		DROP TABLE #TotalScheduleStore;

		SELECT
			otdds.BookedStoreID
			, otdds.DCStoreID
			, COALESCE(SUM(otdds.OrderAmount), 0) AS TotalScheduleStore
			, COUNT(DISTINCT otdds.OrderID) AS TotalScheduleStoreOrderCount
		INTO #TotalScheduleStore
		FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[Staff] AS s 
		ON s.StaffID = otdds.ScheduleBy
		WHERE otdds.TransDate = @TransDate
		AND otdds.ScheduleToday = 1
		AND (otdds.ScheduleChangeType IS NULL OR otdds.ScheduleChangeType IN (1, 2))
		AND s.StaffTypeID IN('ETHOU', 'ETMGR', 'ETNGT', 'ETSLS', 'LMCM', 'LMSM', 'REGMGR', 'RSA', 'RSAESG', 'SLSENS', 
		'SLSETM', 'SLSHC', 'SLSTRN', 'SOGRTA', 'SOPS', 'STRMGR', 'VIP', 'VMERCH', 'VRSA', 'VSOPS', 'VSTRMG', 'WMERCH')
		GROUP BY
			otdds.BookedStoreID
			, otdds.DCStoreID;
	
		-----------------------------------------------------------------------------------------------------
		--ScheduleBy StaffTypeID is OOM-GRT
		-----------------------------------------------------------------------------------------------------
		IF OBJECT_ID('tempdb..#OOMGRT') IS NOT NULL 
		DROP TABLE #OOMGRT;

		SELECT	
			otdds.BookedStoreID
			, otdds.DCStoreID
			, COALESCE(SUM(otdds.OrderAmount), 0) AS TotalScheduleGRT
			, COUNT(DISTINCT otdds.OrderID) AS TotalScheduleGRTOrderCount
		INTO #OOMGRT
		FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[Staff] AS s
		ON s.StaffID = otdds.ScheduleBy
		WHERE otdds.TransDate = @TransDate
		AND otdds.ScheduleToday = 1
		AND (otdds.ScheduleChangeType IS NULL OR otdds.ScheduleChangeType IN (1, 2))
		AND s.StaffTypeID IN ('GRMGR','GRSUP','GRTA','OOM','OOMS')
		GROUP BY 
			otdds.BookedStoreID
			, otdds.DCStoreID;

		-----------------------------------------------------------------------------------------------------
		--ScheduleBy StaffTypeID is DTR
		-----------------------------------------------------------------------------------------------------
		IF OBJECT_ID('tempdb..#DTR') IS NOT NULL 
		DROP TABLE #DTR;

		SELECT	
			otdds.BookedStoreID
			, otdds.DCStoreID
			, COALESCE(SUM(otdds.OrderAmount), 0) AS TotalScheduleDTR 
			, COUNT(DISTINCT otdds.OrderID) AS TotalScheduleDTROrderCount
		INTO #DTR
		FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[Staff] AS s
		ON s.StaffID = otdds.ScheduleBy
		WHERE otdds.TransDate = @TransDate
		AND otdds.ScheduleToday = 1
		AND (otdds.ScheduleChangeType IS NULL OR otdds.ScheduleChangeType IN (1, 2))
		AND s.StaffTypeID IN ('BINLBL','DITR','DTREX','INVMGR','WHMGR','WHSE','WHSENH','WHSUP','WINSTM')
		GROUP BY 
			otdds.BookedStoreID
			, otdds.DCStoreID;

		-----------------------------------------------------------------------------------------------------
		--ScheduleBy StaffTypeID is AUDIT
		-----------------------------------------------------------------------------------------------------
		IF OBJECT_ID('tempdb..#AUDIT') IS NOT NULL 
		DROP TABLE #AUDIT;

		SELECT	
			otdds.BookedStoreID
			, otdds.DCStoreID
			, COALESCE(SUM(otdds.OrderAmount), 0) AS TotalScheduleAudit 
			, COUNT(DISTINCT otdds.OrderID) AS TotalScheduleAuditOrderCount
		INTO #AUDIT
		FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[Staff] AS s
		ON s.StaffID = otdds.ScheduleBy
		WHERE otdds.TransDate = @TransDate
		AND otdds.ScheduleToday = 1
		AND (otdds.ScheduleChangeType IS NULL OR otdds.ScheduleChangeType IN (1, 2))
		AND s.StaffTypeID IN('ACCFIN','ACCHC','ACCMGR','ACCPAY','ACCREC','APSUP','AUDIT','CONTLR','PAYROL')
		GROUP BY 
			otdds.BookedStoreID
			, otdds.DCStoreID;

		-----------------------------------------------------------------------------------------------------
		--ScheduleBy StaffTypeID is UNASSIGNED
		-----------------------------------------------------------------------------------------------------
		IF OBJECT_ID('tempdb..#Unassigned') IS NOT NULL 
		DROP TABLE #Unassigned;

		SELECT	
			otdds.BookedStoreID
			, otdds.DCStoreID
			, COALESCE(SUM(otdds.OrderAmount), 0) AS TotalScheduleUnassigned
			, COUNT(DISTINCT otdds.OrderID) AS TotalScheduleUnassignedOrderCount
		INTO #Unassigned
		FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds
		LEFT JOIN [$(Source_Data)].[Retail_Corporate].[Staff] AS s
		ON s.StaffID = otdds.ScheduleBy
		WHERE otdds.TransDate = @TransDate
		AND otdds.ScheduleToday = 1
		AND (otdds.ScheduleChangeType IS NULL OR otdds.ScheduleChangeType IN (1, 2))
		AND (s.StaffTypeID IS NULL OR s.StaffTypeID   IN ('EXCSUP', 'EXEC','FLMADM','GER','HCHFIN','IT','MERCH','POWR','PWRUSR','RAPID','REPPLN','SUPCHN','SVPM','TERM')  )
		GROUP BY 
			otdds.BookedStoreID
			, otdds.DCStoreID;

		-----------------------------------------------------------------------------------------------------
		--Schedule Automation - Twilio IVR
		-----------------------------------------------------------------------------------------------------
		IF OBJECT_ID('tempdb..#IVR') IS NOT NULL 
		DROP TABLE #IVR;

		SELECT	
			otdds.BookedStoreID
			, otdds.DCStoreID
			, COALESCE(SUM(otdds.OrderAmount), 0) AS TotalScheduleIVR
			, COUNT(DISTINCT otdds.OrderID) AS TotalScheduleIVROrderCount
		INTO #IVR
		FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds
		WHERE otdds.TransDate = @TransDate
		AND otdds.ScheduleToday = 1
		AND otdds.ScheduleChangeType = 3
		GROUP BY 
			otdds.BookedStoreID
			, otdds.DCStoreID;

		-----------------------------------------------------------------------------------------------------
		--Schedule Automation - Text/SMS
		-----------------------------------------------------------------------------------------------------
		IF OBJECT_ID('tempdb..#SMS') IS NOT NULL 
		DROP TABLE #SMS;

		SELECT	
			otdds.BookedStoreID
			, otdds.DCStoreID
			, COALESCE(SUM(otdds.OrderAmount), 0) AS TotalScheduleSMS
			, COUNT(DISTINCT otdds.OrderID) AS TotalScheduleSMSOrderCount
		INTO #SMS
		FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds
		WHERE otdds.TransDate = @TransDate
		AND otdds.ScheduleToday = 1
		AND otdds.ScheduleChangeType = 4
		GROUP BY 
			otdds.BookedStoreID
			, otdds.DCStoreID;

		-----------------------------------------------------------------------------------------------------
		--QTY Order = QTY Committed on all lines -- all in stock
		-----------------------------------------------------------------------------------------------------
		IF OBJECT_ID('tempdb..#FilledCleanDelivery') IS NOT NULL 
		DROP TABLE #FilledCleanDelivery;

		SELECT 
			r.BookedStoreID
			, r.DCStoreID
			, COALESCE(SUM(r.OrderAmount), 0) AS FilledCleanDelivery
		INTO #FilledCleanDelivery
		FROM 
		(
			SELECT
				store_b.STORE_ID AS BookedStoreID
				, store_dc.STORE_ID AS DCStoreID
				, oi.OrderID
				, SUM(oi.QtyOrdered * oi.CaseSellingPrice) AS OrderAmount
				, SUM(oi.QtyOrdered) AS QtyOrdered
				, SUM(oi.QtyCommitted) AS QtyCommitted
			FROM [$(Source_Data)].[Retail_Corporate].[OrderItem] oi
			OUTER APPLY 
		(
			SELECT TOP 1 STORE_ID
			FROM 
			(
				SELECT oi2.BookedStoreID AS STORE_ID
				FROM [$(Source_Data)].[Retail_Corporate].[OrderItem] oi2 
				WHERE oi2.OrderID = oi.OrderID
				and oi2.RecStatus <> 'D'
				
				UNION
				
				SELECT ii2.BookedStoreID AS STORE_ID
				FROM [$(Source_Data)].[Retail_Corporate].[InvoiceItem] ii2 
				WHERE ii2.OrderID = oi.OrderID
			) R
		) AS store_b
			OUTER APPLY 
		(
			SELECT TOP 1 STORE_ID
			FROM 
			(
				SELECT oi3.StoreID AS STORE_ID
				FROM [$(Source_Data)].[Retail_Corporate].[OrderItem] oi3 
				WHERE oi3.OrderID = oi.OrderID
				and oi3.RecStatus <> 'D'
				
				UNION
			
				SELECT ii3.StoreID AS STORE_ID
				FROM [$(Source_Data)].[Retail_Corporate].[InvoiceItem] ii3 
				WHERE ii3.OrderID = oi.OrderID
			) R
		) AS store_dc 
			WHERE oi.RecStatus <> 'D'
			AND oi.TransCodeID IN (0, 1, 7)
			AND oi.DlvyStatus = 'EST'
			GROUP BY
				store_b.STORE_ID
				, store_dc.STORE_ID
				, oi.OrderID
		) r
		INNER JOIN 
		(
			SELECT 
				DISTINCT OrderID 
			FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds 
			WHERE otdds.TransDate = @TransDate
		) otdds 
		ON r.OrderID = otdds.OrderID
		WHERE r.QtyOrdered = r.QtyCommitted
		GROUP BY
			r.BookedStoreID
			, r.DCStoreID;

		-----------------------------------------------------------------------------------------------------
		--OrdTransDetail DlvyStatAtPOS = SCD and TransDate = order date
		-----------------------------------------------------------------------------------------------------
		IF OBJECT_ID('tempdb..#ScheduleAtPOS') IS NOT NULL 
		DROP TABLE #ScheduleAtPOS;

		SELECT 
			otdds.BookedStoreID
			, otdds.DCStoreID
			, COALESCE(SUM(ScheduleAtPOS),0) AS ScheduleAtPOS
			, COUNT(DISTINCT r.OrderID) AS ScheduleAtPOSOrderCount 
		INTO #ScheduleAtPOS
		FROM 
		(
			SELECT
				o.OrderID
				, COALESCE(oi.QtyOrdered * oi.CaseSellingPrice,0) AS ScheduleAtPOS
			FROM [$(Source_Data)].[Retail_Corporate].[Orders] AS o
			INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderItem] AS oi 
			ON oi.OrderID = o.OrderID
			INNER JOIN [Retail_OOM_Enh].[OrderTransDetail] otd 
			ON oi.OrderID = otd.OrderID 
			AND	oi.ItemID = otd.ItemID
			WHERE o.RecStatus <> 'D'
			AND oi.RecStatus <> 'D'
			AND o.OrderDate = @TransDate
			AND otd.DeliveryStatusAtPOS = 'SCD'
			AND oi.TransCodeID IN (0, 1, 7)
		) r 
		INNER JOIN 
		(
			SELECT DISTINCT 
				BookedStoreID
				,DCStoreID
				, OrderID 
			FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds 
			WHERE otdds.TransDate = @TransDate
		) otdds 
		ON r.OrderID = otdds.OrderID
		GROUP BY 
			otdds.BookedStoreID
			, otdds.DCStoreID;

		-----------------------------------------------------------------------------------------------------
		--Avg. # days for orders scheduled on TransDate
		-----------------------------------------------------------------------------------------------------
		IF OBJECT_ID('tempdb..#DaysToSchedule') IS NOT NULL 
		DROP TABLE #DaysToSchedule;

		SELECT
			oi.BookedStoreID
			, oi.StoreID AS DCStoreID
			, AVG(DATEDIFF(dd, o.OrderDate, otdds.TransDate)) AS DaysToSchedule
		INTO #DaysToSchedule
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
		AND oi.TransCodeID IN (0, 1, 7)
		GROUP BY 
			oi.BookedStoreID
			, oi.StoreID 
		HAVING AVG(DATEDIFF(dd, o.OrderDate, otdds.TransDate)) > 0;

		-----------------------------------------------------------------------------------------------------
		--Count of orders scheduled via SMS or IVR
		-----------------------------------------------------------------------------------------------------
		IF OBJECT_ID('tempdb..#AutoScheduleOrderCount') IS NOT NULL 
		DROP TABLE #AutoScheduleOrderCount;

		SELECT
			otdds.BookedStoreID
			, otdds.DCStoreID
			, COUNT(DISTINCT otdds.OrderID) AS AutoScheduleOrderCount
		INTO #AutoScheduleOrderCount
		FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds
		WHERE otdds.TransDate = @TransDate
		AND otdds.ScheduleToday = 1
		AND otdds.ScheduleChangeType IN (3, 4)
		GROUP BY 
			otdds.BookedStoreID
			, otdds.DCStoreID;

		-----------------------------------------------------------------------------------------------------
		--Count of orders scheduled via ChatBot ---New
		-----------------------------------------------------------------------------------------------------
		IF OBJECT_ID('tempdb..#TotalScheduleChatBot') IS NOT NULL 
		DROP TABLE #TotalScheduleChatBot;

		SELECT
			otdds.BookedStoreID
			, otdds.DCStoreID
			, COALESCE(SUM(otdds.OrderAmount), 0) AS TotalScheduleChatBot 
			, COUNT(DISTINCT otdds.OrderID) AS TotalScheduleChatBotOrderCount
		INTO #TotalScheduleChatBot
		FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds
		WHERE otdds.TransDate = @TransDate
		AND otdds.ScheduleToday = 1
		AND otdds.ScheduleChangeType = 5
		GROUP BY 
			otdds.BookedStoreID
			, otdds.DCStoreID;

		-----------------------------------------------------------------------------------------------------
		--Count of SMS messages sent for scheduling delivery
		-----------------------------------------------------------------------------------------------------
		-- IF OBJECT_ID('tempdb..#SMSMessagesSentCount') IS NOT NULL 
		-- DROP TABLE #SMSMessagesSentCount;

		-- SELECT
		-- 	store_b.STORE_ID AS BookedStoreID
		-- 	, store_dc.STORE_ID AS DCStoreID
		-- 	, SUM(gs.SMSAttempt) AS SMSMessagesSentCount
		-- 	,gs.orderid
		-- INTO #SMSMessagesSentCount
		-- FROM [$(Source_Data)].[Retail_Miniapps].[GuestCare_OutboundStats] gs
		-- OUTER APPLY 
		-- (
		-- 	SELECT TOP 1 STORE_ID
		-- 	FROM 
		-- 	(
		-- 		SELECT oi2.BookedStoreID AS STORE_ID
		-- 		FROM [$(Source_Data)].[Retail_Corporate].[OrderItem] oi2 
		-- 		WHERE oi2.OrderID = gs.OrderID
		-- 		and oi2.RecStatus <> 'D'
				
		-- 		UNION
				
		-- 		SELECT ii2.BookedStoreID AS STORE_ID
		-- 		FROM [$(Source_Data)].[Retail_Corporate].[InvoiceItem] ii2 
		-- 		WHERE ii2.OrderID = gs.OrderID
		-- 	) R
		-- ) AS store_b 
		-- OUTER APPLY 
		-- (
		-- 	SELECT TOP 1 STORE_ID
		-- 	FROM 
		-- 	(
		-- 		SELECT oi3.StoreID AS STORE_ID
		-- 		FROM [$(Source_Data)].[Retail_Corporate].[OrderItem] oi3 
		-- 		WHERE oi3.OrderID = gs.OrderID
		-- 		and oi3.RecStatus <> 'D'
				
		-- 		UNION
			
		-- 		SELECT ii3.StoreID AS STORE_ID
		-- 		FROM [$(Source_Data)].[Retail_Corporate].[InvoiceItem] ii3 
		-- 		WHERE ii3.OrderID = gs.OrderID
		-- 	) R
		-- ) AS  store_dc
		-- WHERE CAST(gs.DateCreated AS DATE) = @TransDate
		-- GROUP BY
		-- 	store_b.STORE_ID
		-- 	, store_dc.STORE_ID,gs.orderid;

		-----------------------------------------------------------------------------------------------------
		--Union of all tables and Save the OOMSchedulePerformance information
		-----------------------------------------------------------------------------------------------------
		INSERT INTO [Retail_OOM_Enh].[OOMSchedulePerformanceDetails]
		(
			TransDate
			, BookedStoreID
			, DCStoreID
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
			, STORES_DC.BookedStoreID
			, STORES_DC.DCStoreID
			, ISNULL(WS.WrittenSales,0) AS WrittenSales
			, ISNULL(TSS.TotalScheduleStore,0) AS TotalScheduleStore
			, ISNULL(GRT.TotalScheduleGRT,0) AS TotalScheduleGRT
			, ISNULL(DTR.TotalScheduleDTR,0) AS TotalScheduleDTR
			, ISNULL([AUDIT].TotalScheduleAudit,0) AS TotalScheduleAudit
			, (ISNULL(UASSIGN.TotalScheduleUnassigned,0) - ISNULL(TSS.TotalScheduleStore,0) - ISNULL(GRT.TotalScheduleGRT,0) - ISNULL(DTR.TotalScheduleDTR,0) - ISNULL([AUDIT].TotalScheduleAudit,0))  AS TotalScheduleUnassigned
			, ISNULL(IVR.TotalScheduleIVR,0) AS TotalScheduleIVR
			, ISNULL(SMS.TotalScheduleSMS,0) TotalScheduleSMS
			, ISNULL(TSCH.TotalScheduleChatBot,0) AS TotalScheduleChatBot
			, NULL as AttackTarget
			, ISNULL(FCD.FilledCleanDelivery,0) AS FilledCleanDelivery
			, ISNULL(SAP.ScheduleAtPOS,0) AS ScheduleAtPOS
			, ISNULL(DTS.DaysToSchedule,0) AS DaysToSchedule
			, NULL AS SMSMessagesSentCount
			--, ISNULL(SMS_MSC.SMSMessagesSentCount,0) AS SMSMessagesSentCount
			, ISNULL(ASOC.AutoScheduleOrderCount,0) AS AutoScheduleOrderCount
			, ISNULL(TSS.TotalScheduleStoreOrderCount,0) AS TotalScheduleStoreOrderCount
			, ISNULL(GRT.TotalScheduleGRTOrderCount,0) AS TotalScheduleGRTOrderCount
			, ISNULL(DTR.TotalScheduleDTROrderCount,0) AS TotalScheduleDTROrderCount
			, ISNULL([AUDIT].TotalScheduleAuditOrderCount,0) AS TotalScheduleAuditOrderCount
			, ISNULL(UASSIGN.TotalScheduleUnassignedOrderCount,0) AS TotalScheduleUnassignedOrderCount
			, ISNULL(IVR.TotalScheduleIVROrderCount,0) AS TotalScheduleIVROrderCount
			, ISNULL(SAP.ScheduleAtPOSOrderCount,0) AS ScheduleAtPOSOrderCount
			, ISNULL(SMS.TotalScheduleSMSOrderCount,0) AS TotalScheduleSMSOrderCount
			, ISNULL(TSCH.TotalScheduleChatBotOrderCount,0) As TotalScheduleChatBotOrderCount
		FROM 
		(
			SELECT 
				BookedStoreID
				, DCStoreID
			FROM [Retail_OOM_Wrk].[OrderTransDetailDailyStat]
			GROUP BY 
				BookedStoreID
				, DCStoreID

			UNION 

			SELECT 
				BookedStoreID
				, DCStoreID
			FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat]
			WHERE TransDate = @TransDate
			GROUP BY 
				BookedStoreID
				, DCStoreID
		) STORES_DC
		LEFT JOIN #WrittenSales WS 
		ON STORES_DC.BookedStoreID = WS.BookedStoreID 
		AND STORES_DC.DCStoreID = WS.DCStoreID
		LEFT JOIN #TotalScheduleStore TSS 
		ON STORES_DC.BookedStoreID = TSS.BookedStoreID 
		AND STORES_DC.DCStoreID = TSS.DCStoreID
		LEFT JOIN #OOMGRT GRT
		ON STORES_DC.BookedStoreID = GRT.BookedStoreID 
		AND STORES_DC.DCStoreID = GRT.DCStoreID
		LEFT JOIN #DTR DTR
		ON STORES_DC.BookedStoreID = DTR.BookedStoreID 
		AND STORES_DC.DCStoreID = DTR.DCStoreID
		LEFT JOIN #AUDIT [AUDIT]
		ON STORES_DC.BookedStoreID = [AUDIT].BookedStoreID 
		AND STORES_DC.DCStoreID = [AUDIT].DCStoreID
		LEFT JOIN #Unassigned UASSIGN
		ON STORES_DC.BookedStoreID = UASSIGN.BookedStoreID 
		AND STORES_DC.DCStoreID = UASSIGN.DCStoreID
		LEFT JOIN #IVR IVR
		ON STORES_DC.BookedStoreID = IVR.BookedStoreID 
		AND STORES_DC.DCStoreID = IVR.DCStoreID
		LEFT JOIN #SMS SMS
		ON STORES_DC.BookedStoreID = SMS.BookedStoreID 
		AND STORES_DC.DCStoreID = SMS.DCStoreID
		LEFT JOIN #FilledCleanDelivery FCD
		ON STORES_DC.BookedStoreID = FCD.BookedStoreID 
		AND STORES_DC.DCStoreID = FCD.DCStoreID
		LEFT JOIN #ScheduleAtPOS SAP
		ON STORES_DC.BookedStoreID = SAP.BookedStoreID 
		AND STORES_DC.DCStoreID = SAP.DCStoreID
		-- ATTACK_TARGET - PENDING
		LEFT JOIN #DaysToSchedule DTS
		ON STORES_DC.BookedStoreID = DTS.BookedStoreID 
		AND STORES_DC.DCStoreID = DTS.DCStoreID
		LEFT JOIN #AutoScheduleOrderCount ASOC
		ON STORES_DC.BookedStoreID = ASOC.BookedStoreID 
		AND STORES_DC.DCStoreID = ASOC.DCStoreID
		LEFT JOIN #TotalScheduleChatBot TSCH
		ON STORES_DC.BookedStoreID = TSCH.BookedStoreID 
		AND STORES_DC.DCStoreID = TSCH.DCStoreID
		--LEFT JOIN #SMSMessagesSentCount SMS_MSC
		--ON STORES_DC.BookedStoreID = SMS_MSC.BookedStoreID 
		--AND STORES_DC.DCStoreID = SMS_MSC.DCStoreID
		WHERE 
		(
			WS.WrittenSales IS NOT NULL
			OR TSS.TotalScheduleStore IS NOT NULL
			OR TSS.TotalScheduleStoreOrderCount IS NOT NULL
			OR GRT.TotalScheduleGRT IS NOT NULL
			OR GRT.TotalScheduleGRTOrderCount IS NOT NULL
			OR DTR.TotalScheduleDTR IS NOT NULL
			OR DTR.TotalScheduleDTROrderCount IS NOT NULL
			OR [AUDIT].TotalScheduleAudit IS NOT NULL
			OR [AUDIT].TotalScheduleAuditOrderCount IS NOT NULL
			OR IVR.TotalScheduleIVR IS NOT NULL
			OR IVR.TotalScheduleIVROrderCount IS NOT NULL
			OR SMS.TotalScheduleSMS IS NOT NULL
			OR SMS.TotalScheduleSMSOrderCount IS NOT NULL
			OR FCD.FilledCleanDelivery IS NOT NULL
			OR SAP.ScheduleAtPOS IS NOT NULL
			OR SAP.ScheduleAtPOSOrderCount IS NOT NULL
			OR DTS.DaysToSchedule IS NOT NULL
			OR ASOC.AutoScheduleOrderCount IS NOT NULL
			OR TSCH.TotalScheduleChatBot IS NOT NULL
			OR TSCH.TotalScheduleChatBotOrderCount IS NOT NULL
			--OR SMS_MSC.SMSMessagesSentCount IS NOT NULL
		);

		-----------------------------------------------------------------------------------------------------
		--Calculate Attack Target using formula....	
		-----------------------------------------------------------------------------------------------------
		IF OBJECT_ID('tempdb..#AttackTarget') IS NOT NULL 
		DROP TABLE #AttackTarget;

		SELECT 
			Formula.BookedStoreID, 
			Formula.DCStoreID,
			Formula.TransDate,
			PreviousDaysAveragePrntSCDPOS,
			PreviousDaysAverageWrittenSales,
			((1.0 - ISNULL(PreviousDaysAveragePrntSCDPOS,0)) * ISNULL(PreviousDaysAverageWrittenSales,0)) 
			 + IIF(ISNULL(fcdpd.FilledCleanDeliveryPreviousDay,0) - @FilledCleanTarget > 0,
			((ISNULL(fcdpd.FilledCleanDeliveryPreviousDay,0) - @FilledCleanTarget) / 7), 0) AS AttackTarget
		INTO #AttackTarget
		FROM (
				SELECT
					osp.BookedStoreID
					, osp.DCStoreID
					, osp.TransDate
					, AVG(osp.WrittenSales) AS PreviousDaysAverageWrittenSales
					, AVG(osp.ScheduleAtPOS / NULLIF(osp.WrittenSales,0)) AS PreviousDaysAveragePrntSCDPOS
				FROM [Retail_OOM_Enh].[OOMSchedulePerformanceDetails] osp
				WHERE osp.TransDate BETWEEN DATEADD(dd, - (@AttackTargetNumPreviousDays + 1), @TransDate) AND DATEADD(dd, -1, @TransDate)
				GROUP BY 
					osp.BookedStoreID
					, osp.DCStoreID
					, osp.TransDate
		) Formula
		LEFT JOIN 
		( 
			SELECT	
				osp.BookedStoreID
				, osp.DCStoreID
				, osp.TransDate
				, osp.FilledCleanDelivery AS FilledCleanDeliveryPreviousDay
			FROM [Retail_OOM_Enh].[OOMSchedulePerformanceDetails] osp
			WHERE osp.TransDate = DATEADD(dd, -1, @TransDate)
		) fcdpd 
		ON Formula.BookedStoreID = fcdpd.BookedStoreID 
		AND Formula.DCStoreID = fcdpd.DCStoreID 
		AND Formula.TransDate = fcdpd.TransDate;
	
		-----------------------------------------------------------------------------------------------------
		--Update the tbl_OOMSchedulePerformanceDetails with the AttackTarget metric
		-----------------------------------------------------------------------------------------------------
		UPDATE OOMSSPDTL 
		SET OOMSSPDTL.AttackTarget = ATG.AttackTarget
		FROM [Retail_OOM_Enh].[OOMSchedulePerformanceDetails] OOMSSPDTL
		LEFT JOIN #AttackTarget ATG 
		ON OOMSSPDTL.BookedStoreID = ATG.BookedStoreID 
		AND OOMSSPDTL.DCStoreID = ATG.DCStoreID;

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