CREATE     PROCEDURE [Retail_DW_Core].[usp_Refresh_StorePulse]
AS

BEGIN

	DECLARE
	@String VARCHAR(5000),
	@DateValue DATETIME,
	@User VARCHAR(500),
	@DestinationDatabase VARCHAR(150),
	@DestinationSchema VARCHAR(150),
	@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.[usp_Refresh_StorePulse]';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'FactStorePulse';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

BEGIN TRY

	DECLARE @StartDate  DATE 
	SET @StartDate  = (
	SELECT 
	MIN(DateID) 
	FROM Retail_DW_Core.DimDate
	WHERE CalendarYearIndicator = -2
	-- WHERE CalendarYearIndicator = 0  and DateId < cast(getdate() -200 as date)
	)
	
	DECLARE @EndDate DATE 
	SET @EndDate = (
	SELECT 
	MAX(DateID) 
	FROM Retail_DW_Core.DimDate
	WHERE CalendarYearIndicator = 0  and DateId < cast(getdate() as date)
	);

    Truncate TABLE [Retail_DW_Core].[FactStorePulse]

	DROP TABLE IF exists [Retail_DW_Core].[FactStorePulseHolding]
	CREATE TABLE [Retail_DW_Core].[FactStorePulseHolding]
(
	[LocationKey] [int] NULL,
	[OrderChangeDate] [date] NULL,
	[Written_GrossSale] [numeric](38,2) NULL,
	[Written_Sales] [numeric](38,2) NULL,
	[DLVY] [numeric](38,2) NULL,
	[Written_GM] [numeric](38,2) NULL,
	[Delivered_Sales] [numeric](38,2) NULL,
	[Delivered_GM] [numeric](38,2) NULL,
	[Sleep_Assessments] [int] NULL,
	[Bedding_WrittenSales] [numeric](38,2) NULL,
	[Bedding_Written_GM] [numeric](38,2) NULL,
	[Bedding_Qty] [numeric](38,2) NULL,
	[ACCESS_WrittenSales] [numeric](38,2) NULL,
	[ACCESS_Written_GM] [numeric](38,2) NULL,
	[BEDRO_WrittenSales] [numeric](38,2) NULL,
	[BEDRO_Written_GM] [numeric](38,2) NULL,
	[CASEG_WrittenSales] [numeric](38,2) NULL,
	[CASEG_Written_GM] [numeric](38,2) NULL,
	[DININ_WrittenSales] [numeric](38,2) NULL,
	[DININ_Written_GM] [numeric](38,2) NULL,
	[MOTION_WrittenSales] [numeric](38,2) NULL,
	[MOTION_Written_GM] [numeric](38,2) NULL,
	[OUTDR_WrittenSales] [numeric](38,2) NULL,
	[OUTDR_Written_GM] [numeric](38,2) NULL,
	[UPHOL_WrittenSales] [numeric](38,2) NULL,
	[UPHOL_Written_GM] [numeric](38,2) NULL,
	[WARR_WrittenSales] [numeric](38,2) NULL,
	[WARR_Written_GM] [numeric](38,2) NULL,
	[Derived_Ups] [decimal](38,2) NULL,
	[OrderCount] [decimal](38,4) NULL,
	[SOOrderCount] [decimal](38,4) NULL,
	[EmailCount] [int] NULL,
	[EmailCustCount] [int] NULL,
	[Recorded_Guest] [int] NULL,
	[AppFees] [numeric](38,2) NULL,
	[MattUnits] [numeric](38,2) NULL,
	[PBSUnits] [numeric](38,2) NULL,
	[AppCount] [int] NULL,
	[FinancedOrders] [decimal](38,4) NULL,
	[ShortPayments] [int] NULL,
	[LongPayments] [int] NULL,
	[OtherPayments] [int] NULL,
	[DownPayments] [int] NULL,
	[TotalPayments] [int] NULL,
	[FinanceFeeCost] [decimal](38,2) NULL,
	[Written_Sales_GM_FF] [numeric](38,2) NULL,
	[Written_GM_FF] [numeric](38,2) NULL,
	[Furn_Close_sales] [numeric](38,2) NULL,
	[Furn_Opp_sales] [numeric](38,2) NULL,
	[Matt_Close_sales] [numeric](38,2) NULL,
	[Matt_Opp_sales] [numeric](38,2) NULL,
	[Furn_Closen] [decimal](38,4) NULL,
	[Furn_Oppn] [decimal](38,4) NULL,
	[Matt_Closen] [decimal](38,4) NULL,
	[Matt_Oppn] [decimal](38,4) NULL,
	[over_Closen] [decimal](38,4) NULL,
	[over_Oppn] [decimal](38,4) NULL,
	[WrittenSalesBudget] [decimal](38,4) NULL,
	[dlvyBudget] [decimal](38,4) NULL,
	[WrittenCogsBudget] [decimal](38,4) NULL,
	[InvoicedSalesBudget] [decimal](38,4) NULL,
	[InvoicedCOGSBudget] [decimal](38,4) NULL,
	[WrittenSOCountBudget] [int] NULL,
	[AverageOrderValue] [int] NULL,
	[ConversionRateBudget] [int] NULL,
	[WrittenCOFBudget] [int] NULL,
	[BEDDI_Bud_WrittenSales] [decimal](38,4) NULL,
	[BEDDI_Bud_WrittenGM] [decimal](38,4) NULL,
	[ACCESS_Bud_WrittenSales] [decimal](38,4) NULL,
	[ACCESS_Bud_WrittenGM] [decimal](38,4) NULL,
	[BEDRO_Bud_WrittenSales] [decimal](38,4) NULL,
	[BEDRO_Bud_WrittenGM] [decimal](38,4) NULL,
	[CASEG_Bud_WrittenSales] [decimal](38,4) NULL,
	[CASEG_Bud_WrittenGM] [decimal](38,4) NULL,
	[DININ_Bud_WrittenSales] [decimal](38,4) NULL,
	[DININ_Bud_WrittenGM] [decimal](38,4) NULL,
	[MOTION_Bud_WrittenSales] [decimal](38,4) NULL,
	[MOTION_Bud_WrittenGM] [decimal](38,4) NULL,
	[OUTDR_Bud_WrittenSales] [decimal](38,4) NULL,
	[OUTDR_Bud_WrittenGM] [decimal](38,4) NULL,
	[UPHOL_Bud_WrittenSales] [decimal](38,4) NULL,
	[UPHOL_Bud_WrittenGM] [decimal](38,4) NULL,
	[WARR_Bud_WrittenSales] [decimal](38,4) NULL,
	[WARR_Bud_WrittenGM] [decimal](38,4) NULL,
	[DerivedUpsBudget] [decimal](38,4) NULL,
	[CloseGoalBudget] [decimal](38,9) NULL,
	[DateKey] [int] NULL,
	[FiscalDate] [varchar](10) NULL,
	[FiscalWeek] [smallint] NULL,
	[FiscalMonth] [smallint] NULL,
	[FiscalMonthName] [varchar](100) NULL,
	[FiscalYear] [smallint] NULL,
	[FiscalDayOfWeek] [smallint] NULL,
	[FiscalWeekYear] [int] NULL,
	[CalendarYear_M] [smallint] NULL,
	[Alt_CalendarWeek_M] [int] NULL,
	[Alt_CalendarWeekLastDate] [date] NULL,
	[Alt_CalendarWeekIndicator_M] [int] NULL,
	[CalendarMonthLastDate_M] [date] NULL,
	[CalendarMonthFirstDate_M] [date] NULL,
	[CalendarMonthIndicator_M] [int] NULL,
	[Alt_CalendarYearIndicator_M] [int] NULL,
	[Datekey_M] [int] NULL
);


    -- select cast(getdate()-1 as date)

	-- Create Alternative Start/End Date for Weeks (Mon/Sun)

	WITH L0 AS (SELECT 1 AS C UNION ALL SELECT 1),
	L1 AS (SELECT 1 AS C FROM L0 AS A CROSS JOIN L0 AS B),
	L2 AS (SELECT 1 AS C FROM L1 AS A CROSS JOIN L1 AS B),
	L3 AS (SELECT 1 AS C FROM L2 AS A CROSS JOIN L2 AS B),
	L4 AS (SELECT 1 AS C FROM L3 AS A CROSS JOIN L3 AS B),
	Numbers AS (
		SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) - 1 AS Number
		FROM L4
	),
	DateSequence AS (
		SELECT 
			DATEADD(DAY, Number, (SELECT MIN(DateID) FROM Retail_DW_Core.DimDate WHERE CalendarYearIndicator = -2)) AS DateID
		FROM Numbers
		WHERE Number <= DATEDIFF(DAY, (SELECT MIN(DateID) FROM Retail_DW_Core.DimDate WHERE CalendarYearIndicator = -2), (SELECT MAX(DateID) FROM Retail_DW_Core.DimDate WHERE CalendarYearIndicator = 1))
	),
	WeekBoundaries AS (
		SELECT 
			DateID,
			DATENAME(WEEKDAY, DateID) AS Alt_CalendarDayOfWeekName,
			DATEADD(DAY, -(DATEPART(WEEKDAY, DateID) + 5) % 7, DateID) AS WeekStartDate,
			DATEADD(DAY, 
				CASE 
					WHEN DATEPART(WEEKDAY, DateID) = 1 THEN 0
					ELSE 8 - DATEPART(WEEKDAY, DateID)
				END, 
				DateID) AS Alt_CalendarWeekLastDate
		FROM DateSequence
	),
	WeekCalculations AS (
		SELECT DISTINCT
			wb.DateID,
			wb.Alt_CalendarDayOfWeekName,
			wb.Alt_CalendarWeekLastDate,
			CASE
				WHEN MONTH(wb.WeekStartDate) = 12 
					AND DAY(wb.WeekStartDate) >= 29 
					AND DAY(wb.WeekStartDate) <= 31 THEN 1
				ELSE (DATEDIFF(DAY, 
						DATEADD(DAY, 
							-(DATEPART(WEEKDAY, DATEADD(YEAR, DATEDIFF(YEAR, 0, wb.DateID), 0)) + 5) % 7,
							DATEADD(YEAR, DATEDIFF(YEAR, 0, wb.DateID), 0)
						),
						wb.WeekStartDate) / 7) + 1
			END AS Alt_CalendarWeek,
			CASE
				WHEN MONTH(wb.DateID) = 12 AND DAY(wb.DateID) >= 29 
				THEN YEAR(wb.DateID) + 1
				ELSE YEAR(wb.DateID)
            END AS Alt_CalendarYear,
			DATEDIFF(WEEK, 
				DATEADD(DAY, -(DATEPART(WEEKDAY, GETDATE()) + 5) % 7, GETDATE()),
				wb.WeekStartDate) AS Alt_CalendarWeekIndicator,
			CASE WHEN DateID < '2023-12-29' THEN -3
				WHEN DateID < '2024-12-30' THEN -2
				WHEN DateID < '2025-12-29' THEN -1
				WHEN DateID < '2026-12-28' THEN 0
				ELSE 1
			END AS Alt_CalendarYearIndicator
		FROM WeekBoundaries wb
	)
	SELECT 
		CAST(FORMAT(DateID, 'yyyy-MM-dd') AS DATE) AS DateID,
		CAST(Alt_CalendarYear as INT) as Alt_CalendarYear,
		CAST(Alt_CalendarYearIndicator as INT) as Alt_CalendarYearIndicator,
		CAST(Alt_CalendarDayOfWeekName as VARCHAR(10)) as Alt_CalendarDayOfWeekName,
		CAST(Alt_CalendarWeek as INT) AS Alt_CalendarWeek,
		CAST(FORMAT(Alt_CalendarWeekLastDate, 'yyyy-MM-dd') as DATE) AS Alt_CalendarWeekLastDate,
		CAST(Alt_CalendarWeekIndicator As INT) AS Alt_CalendarWeekIndicator
INTO #TempDateDimension
	FROM WeekCalculations
--select * from #TempDateDimension

    	SELECT
	 dte.DateID
	,dte.CalendarDayOfWeekName
	,dte.CalendarWeek
	,dte.CalendarWeekLastDate
	,dte.CalendarWeekIndicator
	,dte.CalendarMonth
	,dte.CalendarMonthIndicator
	,dte.CalendarMonthFirstDate
	,dte.CalendarMonthLastDate
	,dte.CalendarYear
	,dte.CalendarYearIndicator
	,tdd.Alt_CalendarWeek
	,tdd.Alt_CalendarWeekLastDate
	,tdd.Alt_CalendarWeekIndicator
	,tdd.Alt_CalendarYear
	,tdd.Alt_CalendarYearIndicator
	,dte.FiscalDayOfWeekName
	,dte.FiscalWeek
	,dte.FiscalWeekLastDate
	,dte.FiscalWeekIndicator
	,dte.FiscalMonth
	,dte.FiscalMonthIndicator
	,dte.FiscalMonthLastDate
	,dte.FiscalYear
	,dte.FiscalYearIndicator
	,dte.DateKey
	
	,[FiscalDate]
,[FiscalMonthName]
,[FiscalDayOfWeek]
,[FiscalWeekYear] 
    ,CAST(GETDATE() AS DATE) as [Date_Today]--,CAST(DW_Developer.fn_GetCSTDate(GETDATE()) AS DATE) AS [Date_Today]
INTO #Dates
	FROM Retail_DW_Core.DimDate dte
	LEFT JOIN #TempDateDimension tdd ON tdd.DateID = dte.DateID
	WHERE dte.CalendarYearIndicator BETWEEN -2 AND 0


----------------------------------------------------------------------------------------------------------------
DECLARE @DateKey VARCHAR(10) = '20221231', @year INT = 2022;
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

-- Budget COMPLETED
select TransDate
, StoreID as LocationKey
, SUM(WrittenSales*PrimaryCategory) as WrittenSalesBudget
, SUM(CASE WHEN CategoryID = 'DLVY' THEN WrittenSales END) AS dlvyBudget
, SUM(WrittenSales*PrimaryCategory)+SUM(CASE WHEN CategoryID = 'DLVY' THEN WrittenSales END) AS WrittenSalesBudget_d
, SUM(WrittenGM) AS WrittenCogsBudget
, SUM(DeliveredSales*PrimaryCategory) AS InvoicedSalesBudget
, SUM(DeliveredGM) AS InvoicedCOGSBudget
, 0 AS WrittenSOCountBudget
, 0 AS AverageOrderValue
, 0 AS ConversionRateBudget
, 0 AS WrittenCOFBudget
, SUM(case when CategoryID = 'BEDDI' then WrittenSales END) AS BEDDI_Bud_WrittenSales
, SUM(case when CategoryID = 'BEDDI' then WrittenGM END) AS BEDDI_Bud_WrittenGM
, SUM(case when CategoryID = 'ACCESS' then WrittenSales END) AS ACCESS_Bud_WrittenSales
, SUM(case when CategoryID = 'ACCESS' then WrittenGM END) AS ACCESS_Bud_WrittenGM
, SUM(case when CategoryID = 'BEDRO' then WrittenSales END) AS BEDRO_Bud_WrittenSales
, SUM(case when CategoryID = 'BEDRO' then WrittenGM END) AS BEDRO_Bud_WrittenGM
, SUM(case when CategoryID = 'CASEG' then WrittenSales END) AS CASEG_Bud_WrittenSales
, SUM(case when CategoryID = 'CASEG' then WrittenGM END) AS CASEG_Bud_WrittenGM
, SUM(case when CategoryID = 'DININ' then WrittenSales END) AS DININ_Bud_WrittenSales
, SUM(case when CategoryID = 'DININ' then WrittenGM END) AS DININ_Bud_WrittenGM
, SUM(case when CategoryID = 'MOTION' then WrittenSales END) AS MOTION_Bud_WrittenSales
, SUM(case when CategoryID = 'MOTION' then WrittenGM END) AS MOTION_Bud_WrittenGM
, SUM(case when CategoryID = 'OUTDR' then WrittenSales END) AS OUTDR_Bud_WrittenSales
, SUM(case when CategoryID = 'OUTDR' then WrittenGM END) AS OUTDR_Bud_WrittenGM
, SUM(case when CategoryID = 'UPHOL' then WrittenSales END) AS UPHOL_Bud_WrittenSales
, SUM(case when CategoryID = 'UPHOL' then WrittenGM END) AS UPHOL_Bud_WrittenGM
, SUM(case when CategoryID like 'WARR%' then WrittenSales END) AS WARR_Bud_WrittenSales
, SUM(case when CategoryID like  'WARR%' then WrittenGM END) AS WARR_Bud_WrittenGM
INTO #SalesBudget
FROM Retail_DW_Core.FactSalesBudget a
    LEFT JOIN Retail_DW_Core.DimDate b ON b.FiscalDate = a.TransDate
where YEAR(TransDate) >= @year
group by TransDate,a.StoreID
order by TransDate,a.StoreID




select TransDate
, a.StoreID as LocationKey
, SUM(TUGoal) AS  DerivedUpsBudget
, SUM(CloseGoal) as CloseGoalBudget
INTO #TrafficBudget
FROM Retail_DW_Core.FactTrafficandCloseBudget a
    LEFT JOIN Retail_DW_Core.DimDate b ON b.FiscalDate = a.TransDate
where YEAR(TransDate) >= @year
group by TransDate,a.StoreID
order by TransDate,a.StoreID


select a.TransDate
, a.LocationKey
, a.WrittenSalesBudget
, a.dlvyBudget
, a.WrittenSalesBudget_d
, a.WrittenCogsBudget
, a.InvoicedSalesBudget
, a.InvoicedCOGSBudget
, a.WrittenSOCountBudget
, a.AverageOrderValue
, a.ConversionRateBudget
, a.WrittenCOFBudget
, a.BEDDI_Bud_WrittenSales
, a.BEDDI_Bud_WrittenGM
, a.ACCESS_Bud_WrittenSales
, a.ACCESS_Bud_WrittenGM
, a.BEDRO_Bud_WrittenSales
, a.BEDRO_Bud_WrittenGM
, a.CASEG_Bud_WrittenSales
, a.CASEG_Bud_WrittenGM
, a.DININ_Bud_WrittenSales
, a.DININ_Bud_WrittenGM
, a.MOTION_Bud_WrittenSales
, a.MOTION_Bud_WrittenGM
, a.OUTDR_Bud_WrittenSales
, a.OUTDR_Bud_WrittenGM
, a.UPHOL_Bud_WrittenSales
, a.UPHOL_Bud_WrittenGM
, a.WARR_Bud_WrittenSales
, a.WARR_Bud_WrittenGM
, b.DerivedUpsBudget
, b.CloseGoalBudget
INTO #wrk_Budget 
FROM #SalesBudget a JOIN #TrafficBudget  b on a.TransDate = b.TransDate and a.LocationKey = b.LocationKey

---------------------------------------------------------------------------------------------------------------

-- Email Capture
select oh.StoreID
,c.CustomerID
,c.EmailAddress ValidEmails
,OrderDate
INTO	#BaseData_Email
from Retail_DW_Core.FactSalesOrderHeader oh
inner join Retail_DW_Core.DimCustomerMaster c on oh.CustomerID = c.CustomerID
inner join [Retail_DW_Core].[DimTransCodeMap] tcm
		    ON oh.TransCodeID = tcm.TransCodeID
		WHERE
        YEAR(OrderDate)>= 2025 -- @year
			AND tcm.TransCodeGroup = 'SRE'
			AND oh.SFMCFulfillmentStatus<>'Cancelled'
			--AND oh.TransCodeID IN (0, 1, 7)
			GROUP BY oh.StoreID,
					 c.CustomerID,
					 c.EmailAddress,
					 oh.OrderDate

SELECT	StoreID LocationKey,
			OrderDate,
			COUNT(DISTINCT CustomerID) AS DataValue1,
			CAST(0 AS INT) DataValue2
		INTO	#wrk_EmailCapture
		FROM	#BaseData_Email
		GROUP BY StoreID,
				 OrderDate;

	UPDATE	ed
		SET DataValue2 = bd.EmailCount
		FROM	#wrk_EmailCapture ed
			INNER JOIN (
				SELECT	StoreID,
						OrderDate,
						COUNT(DISTINCT CustomerID) EmailCount
					FROM	#BaseData_Email
					WHERE	ValidEmails IS NOT NULL
					GROUP BY StoreID,
							 OrderDate
			) bd ON bd.StoreID = ed.LocationKey
					 AND  bd.OrderDate = ed.OrderDate;

----------------------------------------------------------------------------------------------------------------

-- Application Count
SELECT CAST(a.QueuedDateTime as Date) as TransDate, StoreID as LocationKey, SUM(AppCount) as  AppCount
INTO #wrt_App
FROM Retail_DW_Core.FactCreditReview a
    LEFT JOIN Retail_DW_Core.DimDate b ON b.FiscalDate = CAST(a.QueuedDateTime as Date)
where YEAR(CAST(a.QueuedDateTime as Date)) >= @year
group by CAST(a.QueuedDateTime as Date),a.StoreID
order by CAST(a.QueuedDateTime as Date),a.StoreID
----------------------------------------------------------------------------------------------------------------

-- Order Count --
SELECT DateID as TransDate, c.StoreID as LocationKey, SUM(SuperOrderClose) as  OrderCount,SUM(SOClose) as  SOOrderCount
-- INTO #wrk_OrderCount
INTO #wrk_Orders
FROM Retail_DW_Core.FactCloses a
-- LEFT JOIN Retail_DW_Core.FactOrderHeader h on a.SuperOrderID = h.SuperOrderID
    LEFT JOIN Retail_DW_Core.DimDate b ON b.DateKey = TransDateKey
    LEFT JOIN Retail_DW_Core.DimStoreLocation c on a.LocationKey = c.LocationKey
where YEAR(DateID) >=  @year
group by DateID,c.StoreID
order by DateID,c.StoreID



-- Financed Order Count --
SELECT DateID as TransDate, c.StoreID as LocationKey,SUM(case when h.IsFinanced = 1 then SOClose else 0 end) as FinancedOrders
INTO #wrk_FinanceOrders
FROM Retail_DW_Core.FactCloses a
LEFT JOIN Retail_DW_Core.FactOrderHeader h on a.SourceOrderID = h.SourceOrderID
    LEFT JOIN Retail_DW_Core.DimDate b ON b.DateKey = TransDateKey
    LEFT JOIN Retail_DW_Core.DimStoreLocation c on a.LocationKey = c.LocationKey
where YEAR(DateID) >=  @year
group by DateID,c.StoreID
order by DateID,c.StoreID

SELECT a.TransDate, a.LocationKey, a.OrderCount, a.SOOrderCount, b.FinancedOrders
INTO #wrk_OrderCount
FROM #wrk_Orders a join #wrk_FinanceOrders b on a.TransDate = b.TransDate and a.LocationKey = b.LocationKey


----------------------------------------------------------------------------------------------------------------

-- Traffic
SELECT 
	StoreID as LocationKey
	,TransDate as  TransactionDate
	,SUM(TrafficGuest) as Derived_Ups
INTO #wrk_Traffic
	
FROM Retail_DW_Core.FactTraffic tra
	LEFT JOIN Retail_DW_Core.DimDate dte ON dte.DateID = tra.TransDate
WHERE dte.DateID  BETWEEN @StartDate  AND @EndDate
	
GROUP BY
	StoreID
	,TransDate
----------------------------------------------------------------------------------------------------------------

-- Recorded Ups
SELECT 
	StoreID as LocationKey
	,TransDate as  Scoreboard_Date
	,SUM(RecordedUps) as Recorded_Guest
INTO #wrk_RecordedGuests
	
FROM Retail_DW_Core.FactRSADailyStats rsa
	LEFT JOIN Retail_DW_Core.DimDate dte ON dte.DateID = rsa.TransDate
	WHERE dte.DateID  BETWEEN @StartDate  AND @EndDate
GROUP BY
	StoreID
	,TransDate
----------------------------------------------------------------------------------------------------------------
-- Finance Metrics

select StoreID as LocationKey, TransDate, 
SUM(case WHEN b.PaymentTypeGroupID = 'ST' THEN ISNULL(Payments,0) END) AS ShortPayments
, SUM(case WHEN b.PaymentTypeGroupID = 'LT' THEN ISNULL(Payments,0) END) AS LongPayments
, SUM(case WHEN b.PaymentTypeGroupID = 'OF' THEN ISNULL(Payments,0) END) AS OtherPayments
, SUM(case WHEN b.PaymentTypeGroupID = 'DP' and OrderIsFinanced = 1 THEN ISNULL(Payments,0) END) AS DownPayments
-- , SUM(case WHEN b.PaymentTypeGroupID = 'DP' THEN ISNULL(Payments,0) END) AS DownPayments
-- , SUM(Payments) as TotalPayments
, SUM(case WHEN OrderIsFinanced = 1 THEN ISNULL(Payments,0) END) AS TotalPayments
, SUM(case when  b.PaymentTypeGroupID in ('LT', 'ST', 'EP', 'OF') then Payments * a.IsFinanced * FinanceUseEe 
 else 0 end) as FinanceFeeCost
-- , SUM(FinanceFees) as FinanceFeeCost -- FinanceFee_GM_FF
into #wrk_Finance
 from Retail_DW_Core.FactPayments a LEFT JOIN Retail_DW_Core.DimPaymentType b on a.PaymentTypeID = b.PaymentTypeID
 wHERE TransDate  Between @StartDate  AND @EndDate

 GROUP BY StoreID, TransDate
/*
select StoreID as LocationKey, TransDate, 
SUM(case WHEN b.PaymentTypeGroupID = 'ST' THEN ISNULL(Payments,0) END) AS ShortPayments
, SUM(case WHEN b.PaymentTypeGroupID = 'LT' THEN ISNULL(Payments,0) END) AS LongPayments
, SUM(case WHEN b.PaymentTypeGroupID = 'OF' THEN ISNULL(Payments,0) END) AS OtherPayments
, SUM(case WHEN b.PaymentTypeGroupID = 'DP' and OrderIsFinanced = 1 THEN ISNULL(Payments,0) END) AS DownPayments
, SUM(case when  b.PaymentTypeGroupID in ('LT', 'ST', 'EP', 'OF') then Payments else 0 end) as TotalPayments
, SUM(case when  b.PaymentTypeGroupID in ('LT', 'ST', 'EP', 'OF') then Payments * a.IsFinanced * FinanceUseEe 
 else 0 end) as FinanceFeeCost,
 SUM(FinanceFees) as FinanceFee_GM_FF
into #wrk_Finance
 from Retail_DW_Core.FactPayments a LEFT JOIN Retail_DW_Core.DimPaymentType b on a.PaymentTypeID = b.PaymentTypeID
 wHERE TransDate  Between @StartDate  AND @EndDate

 GROUP BY StoreID, TransDate
 */
----------------------------------------------------------------------------------------------------------------

-- Protection Purchase Plan
SELECT	ppp.LocationKey,
			ppp.TransDate,
			SUM(case when PPPGroupID = 'XFI' then isnull(ppp.Opp,0) end) Furn_Oppn,
			SUM(case when PPPGroupID = 'XFI' then isnull(ppp.Closes,0)  end) Furn_Closen,
			SUM(case when PPPGroupID in ('XMT', 'XMI') then isnull(ppp.Opp,0) end) Matt_Oppn,
			SUM(case when PPPGroupID in ('XMT', 'XMI') then isnull(ppp.Closes,0)  end) Matt_Closen,
			SUM(case when PPPGroupID = 'XFI' then isnull(ppp.OppSales,0) end) Furn_Opp_sales,
			SUM(case when PPPGroupID = 'XFI' then isnull(ppp.CloseSales,0)  end) Furn_Close_sales,
			SUM(case when PPPGroupID in ('XMT', 'XMI') then isnull(ppp.OppSales,0) end) Matt_Opp_sales,
			SUM(case when PPPGroupID in ('XMT', 'XMI') then isnull(ppp.CloseSales,0)  end) Matt_Close_sales,
			SUM(isnull(ppp.Opp,0)) over_Oppn,
			SUM(isnull(ppp.Closes,0)) over_Closen
into #wrk_ppp_plan		
		FROM	(
			SELECT	StoreID as LocationKey,
					cast(TransDateTime as Date) as TransDate,
					OrderID,
					PPPGroupID,
					SIGN(SUM(PPPOpp)) AS Opp,
					SIGN(SUM(PPPClose)) AS Closes,
					SUM(CASE WHEN PPPGroupID <> c.GroupID THEN Sales ELSE 0 END) OppSales,
					SUM(CASE WHEN PPPGroupID = c.GroupID THEN Sales ELSE 0 END) CloseSales
				FROM	Retail_DW_Core.FactSales a left join Retail_DW_Core.DimStoreLocation b on a.LocationKey = b.LocationKey
                LEFT JOIN [Retail_DW_Core].[DimProduct] c ON a.ProductKey = c.ProductKey
				WHERE
				 cast(TransDateTime as Date)  BETWEEN @StartDate  AND @EndDate
					AND SalesType = 'W'
					AND PPPGroupID IS NOT NULL
				GROUP BY StoreID,
						 cast(TransDateTime as Date),
						 OrderID,
						 PPPGroupID
		) ppp
		GROUP BY ppp.LocationKey,
				 ppp.TransDate
----------------------------------------------------------------------------------------------------------------

-- Written,  Invoiced & Category

SELECT
 b.StoreID as LocationKey
, DateID as OrderChangeDate--,WRT.OrderChangeDate
, SUM(CASE WHEN SalesType = 'W' THEN ISNULL(WRT.Sales,0)*ISNULL(GrossMultiplier,0) ELSE 0 END) AS [Written_GrossSale]
, SUM(CASE WHEN SalesType = 'W' THEN ISNULL(WRT.Sales,0)*ISNULL(p.PrimaryCategory,0) ELSE 0 END) AS [Written_Sales]
, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID <> 'DLVY' THEN ISNULL(WRT.Sales,0)*ISNULL(p.PrimaryCategory,0) ELSE 0 END) AS [Written_Sales_GM_FF]
, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID = 'DLVY' THEN ISNULL(WRT.Sales,0) ELSE 0 END) AS [DLVY]
, SUM(CASE WHEN SalesType = 'W' THEN (ISNULL(WRT.Sales,0) - ISNULL(WRT.Cost,0))*ISNULL(p.PrimaryCategory,0) ELSE 0 END) AS [Written_GM]
, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID <> 'DLVY' 
	THEN (ISNULL(WRT.Sales,0) - ISNULL(WRT.Cost,0))*ISNULL(p.PrimaryCategory,0) ELSE 0 END) AS [Written_GM_FF]
, SUM(CASE WHEN SalesType = 'D' THEN ISNULL(WRT.Sales,0)*ISNULL(p.PrimaryCategory,0) ELSE 0 END) AS [Delivered_Sales]
, SUM(CASE WHEN SalesType = 'D' THEN (ISNULL(WRT.Sales,0) - ISNULL(WRT.Cost,0))*ISNULL(p.PrimaryCategory,0) ELSE 0 END) AS [Delivered_GM]
, NULL as  Sleep_Assessments
, SUM(CASE WHEN SalesType = 'W' AND p.GroupID = 'MFA' THEN ISNULL(WRT.Sales,0) ELSE 0 END) AS AppFees
, SUM(CASE WHEN SalesType = 'W' AND p.GroupID = 'MBS' THEN ISNULL(WRT.Units,0)*ISNULL(p.PrimaryCategory,0) ELSE 0 END) AS MattUnits
, SUM(CASE WHEN SalesType = 'W' AND p.GroupID = 'PBS' THEN ISNULL(WRT.Units,0)*ISNULL(p.PrimaryCategory,0) ELSE 0 END) AS PBSUnits

, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID = 'BEDDI' THEN ISNULL(WRT.Sales,0)*ISNULL(p.PrimaryCategory,0) ELSE 0 END) AS [Bedding_WrittenSales]
, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID = 'BEDDI' THEN (ISNULL(WRT.Sales,0) - ISNULL(WRT.Cost,0))*ISNULL(p.PrimaryCategory,0) 
		ELSE 0 END) AS [Bedding_Written_GM]
, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID = 'BEDDI' THEN ISNULL(WRT.Units,0) ELSE 0 END) AS [Bedding_Qty]

, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID = 'ACCESS' THEN ISNULL(WRT.Sales,0)*ISNULL(p.PrimaryCategory,0) ELSE 0 END) AS [ACCESS_WrittenSales]
, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID = 'ACCESS' THEN (ISNULL(WRT.Sales,0) - ISNULL(WRT.Cost,0))*ISNULL(p.PrimaryCategory,0) 
		ELSE 0 END) AS [ACCESS_Written_GM]
-- , SUM(CASE WHEN SalesType = 'W' AND p.CategoryID = 'ACCESS' THEN ISNULL(WRT.Units,0) ELSE 0 END) AS [ACCESS_Qty]

, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID = 'BEDRO' THEN ISNULL(WRT.Sales,0)*ISNULL(p.PrimaryCategory,0) ELSE 0 END) AS [BEDRO_WrittenSales]
, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID = 'BEDRO' THEN (ISNULL(WRT.Sales,0) - ISNULL(WRT.Cost,0))*ISNULL(p.PrimaryCategory,0) 
		ELSE 0 END) AS [BEDRO_Written_GM]
		
, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID = 'CASEG' THEN ISNULL(WRT.Sales,0)*ISNULL(p.PrimaryCategory,0) ELSE 0 END) AS [CASEG_WrittenSales]
, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID = 'CASEG' THEN (ISNULL(WRT.Sales,0) - ISNULL(WRT.Cost,0))*ISNULL(p.PrimaryCategory,0) 
		ELSE 0 END) AS [CASEG_Written_GM]
		
, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID = 'DININ' THEN ISNULL(WRT.Sales,0)*ISNULL(p.PrimaryCategory,0) ELSE 0 END) AS [DININ_WrittenSales]
, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID = 'DININ' THEN (ISNULL(WRT.Sales,0) - ISNULL(WRT.Cost,0))*ISNULL(p.PrimaryCategory,0) 
		ELSE 0 END) AS [DININ_Written_GM]
		
, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID = 'MOTION' THEN ISNULL(WRT.Sales,0)*ISNULL(p.PrimaryCategory,0) ELSE 0 END) AS [MOTION_WrittenSales]
, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID = 'MOTION' THEN (ISNULL(WRT.Sales,0) - ISNULL(WRT.Cost,0))*ISNULL(p.PrimaryCategory,0) 
		ELSE 0 END) AS [MOTION_Written_GM]
		
, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID = 'OUTDR' THEN ISNULL(WRT.Sales,0)*ISNULL(p.PrimaryCategory,0) ELSE 0 END) AS [OUTDR_WrittenSales]
, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID = 'OUTDR' THEN (ISNULL(WRT.Sales,0) - ISNULL(WRT.Cost,0))*ISNULL(p.PrimaryCategory,0) 
		ELSE 0 END) AS [OUTDR_Written_GM]
		
, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID = 'UPHOL' THEN ISNULL(WRT.Sales,0)*ISNULL(p.PrimaryCategory,0) ELSE 0 END) AS [UPHOL_WrittenSales]
, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID = 'UPHOL' THEN (ISNULL(WRT.Sales,0) - ISNULL(WRT.Cost,0))*ISNULL(p.PrimaryCategory,0) 
		ELSE 0 END) AS [UPHOL_Written_GM]
		
, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID LIKE 'WARR%' THEN ISNULL(WRT.Sales,0)*ISNULL(p.PrimaryCategory,0) ELSE 0 END) AS [WARR_WrittenSales]
, SUM(CASE WHEN SalesType = 'W' AND p.CategoryID LIKE 'WARR%' THEN (ISNULL(WRT.Sales,0) - ISNULL(WRT.Cost,0))*ISNULL(p.PrimaryCategory,0) 
		ELSE 0 END) AS [WARR_Written_GM]
INTO #wrk_Sales_Actual
from Retail_DW_Core.FactSales WRT
left join Retail_DW_Core.DimStoreLocation b on WRT.LocationKey = b.LocationKey
LEFT JOIN Retail_DW_Core.DimDate dte ON dte.DateKey = WRT.TransDateKey
left join Retail_DW_Core.DimProduct p on WRT.ProductKey = p.ProductKey
WHERE  dte.DateID  BETWEEN @StartDate  AND @EndDate-- and b.StoreID = 2 -- 422

GROUP BY
b.StoreID
, DateID


SELECT
    A.StoreID as LocationKey,
    B.DateID
into #wrk_Store_Date
FROM
    (select distinct StoreID from Retail_DW_Core.DimStoreLocation WHERE LocationType = 'ST') A
CROSS JOIN
    (select DateID from Retail_DW_Core.DimDate where DateID  BETWEEN @StartDate  AND @EndDate) B
ORDER BY
    A.StoreID, B.DateID;

-- Final table
--select top 2 * from [Retail_DW_Core].[FactStorePulseHolding]

INSERT INTO [Retail_DW_Core].[FactStorePulseHolding]
(
LocationKey
,OrderChangeDate
,Written_GrossSale
,Written_Sales
,DLVY
,Written_GM
,Delivered_Sales
,Delivered_GM
,Sleep_Assessments
,Bedding_WrittenSales
,Bedding_Written_GM
,Bedding_Qty
,ACCESS_WrittenSales
,ACCESS_Written_GM
,BEDRO_WrittenSales
,BEDRO_Written_GM
,CASEG_WrittenSales
,CASEG_Written_GM
,DININ_WrittenSales
,DININ_Written_GM
,MOTION_WrittenSales
,MOTION_Written_GM
,OUTDR_WrittenSales
,OUTDR_Written_GM
,UPHOL_WrittenSales
,UPHOL_Written_GM
,WARR_WrittenSales
,WARR_Written_GM
,Derived_Ups
,OrderCount
,SOOrderCount
,EmailCount
,EmailCustCount
,Recorded_Guest
,AppFees
,MattUnits
,PBSUnits
,AppCount
,FinancedOrders
,ShortPayments
,LongPayments
,OtherPayments
,DownPayments
,TotalPayments
,FinanceFeeCost
,Written_Sales_GM_FF
,Written_GM_FF
,Furn_Close_sales
,Furn_Opp_sales
,Matt_Close_sales
,Matt_Opp_sales
,Furn_Closen
,Furn_Oppn
,Matt_Closen
,Matt_Oppn
,over_Closen
,over_Oppn
,WrittenSalesBudget
,dlvyBudget
,WrittenCogsBudget
,InvoicedSalesBudget
,InvoicedCOGSBudget
,WrittenSOCountBudget
,AverageOrderValue
,ConversionRateBudget
,WrittenCOFBudget
,BEDDI_Bud_WrittenSales
,BEDDI_Bud_WrittenGM
,ACCESS_Bud_WrittenSales
,ACCESS_Bud_WrittenGM
,BEDRO_Bud_WrittenSales
,BEDRO_Bud_WrittenGM
,CASEG_Bud_WrittenSales
,CASEG_Bud_WrittenGM
,DININ_Bud_WrittenSales
,DININ_Bud_WrittenGM
,MOTION_Bud_WrittenSales
,MOTION_Bud_WrittenGM
,OUTDR_Bud_WrittenSales
,OUTDR_Bud_WrittenGM
,UPHOL_Bud_WrittenSales
,UPHOL_Bud_WrittenGM
,WARR_Bud_WrittenSales
,WARR_Bud_WrittenGM
,DerivedUpsBudget
,CloseGoalBudget
,DateKey
,FiscalDate
,FiscalWeek
,FiscalMonth
,FiscalMonthName
,FiscalYear
,FiscalDayOfWeek
,FiscalWeekYear
,CalendarYear_M
,Alt_CalendarWeek_M
,Alt_CalendarWeekLastDate
,Alt_CalendarWeekIndicator_M
,CalendarMonthLastDate_M
,CalendarMonthFirstDate_M
,CalendarMonthIndicator_M
,Alt_CalendarYearIndicator_M
,Datekey_M
)

SELECT
  sd.LocationKey
, sd.DateID as OrderChangeDate
, w.[Written_GrossSale]
, w.[Written_Sales]
, w.DLVY
, w.[Written_GM]
, w.[Delivered_Sales]
, w.[Delivered_GM]
, w.[Sleep_Assessments]
, w.[Bedding_WrittenSales]
, w.[Bedding_Written_GM]
, w.[Bedding_Qty]
, w.[ACCESS_WrittenSales]
, w.[ACCESS_Written_GM]
, w.[BEDRO_WrittenSales]
, w.[BEDRO_Written_GM]
, w.[CASEG_WrittenSales]
, w.[CASEG_Written_GM]
, w.[DININ_WrittenSales]
, w.[DININ_Written_GM]
, w.[MOTION_WrittenSales]
, w.[MOTION_Written_GM]
, w.[OUTDR_WrittenSales]
, w.[OUTDR_Written_GM]
, w.[UPHOL_WrittenSales]
, w.[UPHOL_Written_GM]
, w.[WARR_WrittenSales]
, w.[WARR_Written_GM]
, t.[Derived_Ups]
, o.[OrderCount]
, o.[SOOrderCount]
, e.DataValue2 as [EmailCount]
, e.DataValue1 as [EmailCustCount]
, rg.[Recorded_Guest]
, w.AppFees
, w.MattUnits
, w.PBSUnits
, app.AppCount
, o.FinancedOrders
, fi.ShortPayments
, fi.LongPayments
, fi.OtherPayments
, fi.DownPayments
, fi.TotalPayments
, fi.FinanceFeeCost
, w.Written_Sales_GM_FF
, w.Written_GM_FF
-- , fi.FinanceFee_GM_FF
, ppp.Furn_Close_sales
, ppp.Furn_Opp_sales
, ppp.Matt_Close_sales
, ppp.Matt_Opp_sales
, ppp.Furn_Closen
, ppp.Furn_Oppn
, ppp.Matt_Closen
, ppp.Matt_Oppn
, ppp.over_Closen
, ppp.over_Oppn
, bud.WrittenSalesBudget
, bud.dlvyBudget
, bud.WrittenCogsBudget
, bud.InvoicedSalesBudget
, bud.InvoicedCOGSBudget
, bud.WrittenSOCountBudget
, bud.AverageOrderValue
, bud.ConversionRateBudget
, bud.WrittenCOFBudget
, bud.BEDDI_Bud_WrittenSales
, bud.BEDDI_Bud_WrittenGM
, bud.ACCESS_Bud_WrittenSales
, bud.ACCESS_Bud_WrittenGM
, bud.BEDRO_Bud_WrittenSales
, bud.BEDRO_Bud_WrittenGM
, bud.CASEG_Bud_WrittenSales
, bud.CASEG_Bud_WrittenGM
, bud.DININ_Bud_WrittenSales
, bud.DININ_Bud_WrittenGM
, bud.MOTION_Bud_WrittenSales
, bud.MOTION_Bud_WrittenGM
, bud.OUTDR_Bud_WrittenSales
, bud.OUTDR_Bud_WrittenGM
, bud.UPHOL_Bud_WrittenSales
, bud.UPHOL_Bud_WrittenGM
, bud.WARR_Bud_WrittenSales
, bud.WARR_Bud_WrittenGM
, bud.DerivedUpsBudget
, bud.CloseGoalBudget
, [DateKey]
, convert(varchar(10), FiscalDate, 101) AS  [FiscalDate]
, [FiscalWeek]
, [FiscalMonth]
, [FiscalMonthName]
,[FiscalYear]
,[FiscalDayOfWeek]
,[FiscalWeekYear] 
,CalendarYear as [CalendarYear_M]
,Alt_CalendarWeek as [Alt_CalendarWeek_M]
,[Alt_CalendarWeekLastDate]
,Alt_CalendarWeekIndicator as [Alt_CalendarWeekIndicator_M]
,CalendarMonthLastDate as [CalendarMonthLastDate_M]
,CalendarMonthFirstDate as [CalendarMonthFirstDate_M]
,CalendarMonthIndicator as [CalendarMonthIndicator_M]
,Alt_CalendarYearIndicator as [Alt_CalendarYearIndicator_M]
,DateKey as [Datekey_M]
-- into Retail_DW_Core.FactStorePulseHolding
FROM #wrk_Store_Date sd
LEFT JOIN #wrk_Sales_Actual as w ON sd.LocationKey = w.LocationKey AND sd.DateID = w.OrderChangeDate
LEFT JOIN #wrk_Traffic t ON t.LocationKey = sd.LocationKey AND t.TransactionDate = sd.DateID
LEFT JOIN #wrk_OrderCount o ON o.LocationKey = sd.LocationKey AND o.TransDate = sd.DateID
LEFT JOIN #wrk_EmailCapture e ON e.LocationKey = sd.LocationKey AND e.OrderDate = sd.DateID
LEFT JOIN #wrk_RecordedGuests rg ON rg.LocationKey = sd.LocationKey AND rg.Scoreboard_Date = sd.DateID
LEFT JOIN #wrt_App app ON app.LocationKey = sd.LocationKey AND app.TransDate = sd.DateID
LEFT JOIN #wrk_Finance fi ON fi.LocationKey = sd.LocationKey AND fi.TransDate = sd.DateID
LEFT JOIN #wrk_ppp_plan ppp ON ppp.LocationKey = sd.LocationKey AND ppp.TransDate = sd.DateID
LEFT JOIN #wrk_Budget bud ON bud.LocationKey = sd.LocationKey AND bud.TransDate = sd.DateID
LEFT JOIN #Dates on #Dates.DateID = sd.DateID
-- where w.LocationKey in (1,2) -- 422
-- where w.LocationKey in (1,2) -- 422

DELETE FROM Retail_DW_Core.FactStorePulseHolding WHERE LocationKey in (111, 613, 627);-- , 332);

-- Drop table if exists Retail_DW_Core.FactStorePulse
INSERT INTO [Retail_DW_Core].[FactStorePulse]
(
Division
,Region
,DateKey
,FiscalDate
,FiscalWeek
,FiscalMonth
,FiscalMonthName
,FiscalYear
,FiscalDayOfWeek
,FiscalWeekYear
,CalendarYear_M
,Alt_CalendarWeek_M
,Alt_CalendarWeekLastDate
,Alt_CalendarWeekIndicator_M
,CalendarMonthLastDate_M
,CalendarMonthFirstDate_M
,CalendarMonthIndicator_M
,Alt_CalendarYearIndicator_M
,Datekey_M
,CorporateFinanceGrouping
,CompLocation
,StoreLocation
,StoreID
,VPName
,Newmarket
,NewRegion
,RegionalDirector
,OrderChangeDate_M
,CompLocation_M
,StoreLocation_M
,Updated_Region_M
,LocationKey
,OrderChangeDate
,Written_GrossSale
,Written_Sales
,DLVY
,Written_GM
,Delivered_Sales
,Delivered_GM
,Sleep_Assessments
,Bedding_WrittenSales
,Bedding_Written_GM
,Bedding_Qty
,ACCESS_WrittenSales
,ACCESS_Written_GM
,BEDRO_WrittenSales
,BEDRO_Written_GM
,CASEG_WrittenSales
,CASEG_Written_GM
,DININ_WrittenSales
,DININ_Written_GM
,MOTION_WrittenSales
,MOTION_Written_GM
,OUTDR_WrittenSales
,OUTDR_Written_GM
,UPHOL_WrittenSales
,UPHOL_Written_GM
,WARR_WrittenSales
,WARR_Written_GM
,Derived_Ups
,OrderCount
,SOOrderCount
,EmailCount
,EmailCustCount
,Recorded_Guest
,AppFees
,MattUnits
,PBSUnits
,AppCount
,FinancedOrders
,ShortPayments
,LongPayments
,OtherPayments
,DownPayments
,TotalPayments
,FinanceFeeCost
,Written_Sales_GM_FF
,Written_GM_FF
,Furn_Close_sales
,Furn_Opp_sales
,Matt_Close_sales
,Matt_Opp_sales
,Furn_Closen
,Furn_Oppn
,Matt_Closen
,Matt_Oppn
,over_Closen
,over_Oppn
,WrittenSalesBudget
,dlvyBudget
,WrittenCogsBudget
,InvoicedSalesBudget
,InvoicedCOGSBudget
,WrittenSOCountBudget
,AverageOrderValue
,ConversionRateBudget
,WrittenCOFBudget
,BEDDI_Bud_WrittenSales
,BEDDI_Bud_WrittenGM
,ACCESS_Bud_WrittenSales
,ACCESS_Bud_WrittenGM
,BEDRO_Bud_WrittenSales
,BEDRO_Bud_WrittenGM
,CASEG_Bud_WrittenSales
,CASEG_Bud_WrittenGM
,DININ_Bud_WrittenSales
,DININ_Bud_WrittenGM
,MOTION_Bud_WrittenSales
,MOTION_Bud_WrittenGM
,OUTDR_Bud_WrittenSales
,OUTDR_Bud_WrittenGM
,UPHOL_Bud_WrittenSales
,UPHOL_Bud_WrittenGM
,WARR_Bud_WrittenSales
,WARR_Bud_WrittenGM
,DerivedUpsBudget
,CloseGoalBudget

)

SELECT
case when RollUpFilter = 'Division' then COALESCE([RollUp], 'ALSTR') end as Division,
case when RollUpFilter = 'Region' then COALESCE([RollUp], 'ALSTR') end as Region,
[DateKey]
, convert(varchar(10), FiscalDate, 101) AS  [FiscalDate]
, [FiscalWeek]
, [FiscalMonth]
, [FiscalMonthName]
,[FiscalYear]
,[FiscalDayOfWeek]
,[FiscalWeekYear]
, [CalendarYear_M]
, [Alt_CalendarWeek_M]
, [Alt_CalendarWeekLastDate]
, [Alt_CalendarWeekIndicator_M]
, [CalendarMonthLastDate_M]
, [CalendarMonthFirstDate_M]
, [CalendarMonthIndicator_M]
, [Alt_CalendarYearIndicator_M]
, [Datekey_M]
, CorporateFinanceGrouping
, CASE WHEN CompLocation = 1 THEN 'Yes' ELSE 'No' END AS CompLocation
, LocationName as [StoreLocation]
, RIGHT(REPLICATE('0', 3) + CAST(a.LocationKey  AS VARCHAR(3)), 3) as StoreID
, VPName
, CorporateMarket as [Newmarket]
, RegionName as [NewRegion]
, RegionalDirector
, OrderChangeDate as [OrderChangeDate_M]
, CASE WHEN CompLocation = 1 THEN 'Yes' ELSE 'No' END as [CompLocation_M]
, LocationName as [StoreLocation_M]
, RegionName as [Updated_Region_M]
, a.LocationKey
, a.OrderChangeDate
, a.[Written_GrossSale]
, a.[Written_Sales]
, a.DLVY
, a.[Written_GM]
, a.[Delivered_Sales]
, a.[Delivered_GM]
, a.[Sleep_Assessments]
, a.[Bedding_WrittenSales]
, a.[Bedding_Written_GM]
, a.[Bedding_Qty]
, a.[ACCESS_WrittenSales]
, a.[ACCESS_Written_GM]
, a.[BEDRO_WrittenSales]
, a.[BEDRO_Written_GM]
, a.[CASEG_WrittenSales]
, a.[CASEG_Written_GM]
, a.[DININ_WrittenSales]
, a.[DININ_Written_GM]
, a.[MOTION_WrittenSales]
, a.[MOTION_Written_GM]
, a.[OUTDR_WrittenSales]
, a.[OUTDR_Written_GM]
, a.[UPHOL_WrittenSales]
, a.[UPHOL_Written_GM]
, a.[WARR_WrittenSales]
, a.[WARR_Written_GM]
, a.[Derived_Ups]
, a.[OrderCount]
, a.[SOOrderCount]
, a.[EmailCount]
, a.[EmailCustCount]
, a.[Recorded_Guest]
, a.AppFees
, a.MattUnits
, a.PBSUnits
, a.AppCount
, a.FinancedOrders
, a.ShortPayments
, a.LongPayments
, a.OtherPayments
, a.DownPayments
, a.TotalPayments
, a.FinanceFeeCost
, Written_Sales_GM_FF
, Written_GM_FF
-- , FinanceFee_GM_FF
, a.Furn_Close_sales
, a.Furn_Opp_sales
, a.Matt_Close_sales
, a.Matt_Opp_sales
, a.Furn_Closen
, a.Furn_Oppn
, a.Matt_Closen
, a.Matt_Oppn
, a.over_Closen
, a.over_Oppn
, a.WrittenSalesBudget
, a.dlvyBudget
, a.WrittenCogsBudget
, a.InvoicedSalesBudget
, a.InvoicedCOGSBudget
, a.WrittenSOCountBudget
, a.AverageOrderValue
, a.ConversionRateBudget
, a.WrittenCOFBudget
, a.BEDDI_Bud_WrittenSales
, a.BEDDI_Bud_WrittenGM
, a.ACCESS_Bud_WrittenSales
, a.ACCESS_Bud_WrittenGM
, a.BEDRO_Bud_WrittenSales
, a.BEDRO_Bud_WrittenGM
, a.CASEG_Bud_WrittenSales
, a.CASEG_Bud_WrittenGM
, a.DININ_Bud_WrittenSales
, a.DININ_Bud_WrittenGM
, a.MOTION_Bud_WrittenSales
, a.MOTION_Bud_WrittenGM
, a.OUTDR_Bud_WrittenSales
, a.OUTDR_Bud_WrittenGM
, a.UPHOL_Bud_WrittenSales
, a.UPHOL_Bud_WrittenGM
, a.WARR_Bud_WrittenSales
, a.WARR_Bud_WrittenGM
, a.DerivedUpsBudget
, a.CloseGoalBudget
-- into Retail_DW_Core.FactStorePulse
 FROM
Retail_DW_Core.FactStorePulseHolding a
left join Retail_DW_Core.DimStoreLocation b on a.LocationKey = b.StoreID
left join Retail_DW_Core.DimRollUps c on b.StoreID = c.StoreID
where ([RollUpFilter] in ('Division')  and [RollUp] not in ('WDIV','EDIV')) or (c.StoreID = 642 and c.[RollUp] = 'ALSTR')


update a set a.Region = b.[RollUp]
from Retail_DW_Core.FactStorePulse a
join Retail_DW_Core.DimRollUps b on a.LocationKey = b.StoreID
where b.RollUpFilter = 'Region'

DROP TABLE [Retail_DW_Core].[FactStorePulseHolding];

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
		EXEC [Retail_DW_Core].[usp_Refresh_StorePulse_CEMT]

	END CATCH

END