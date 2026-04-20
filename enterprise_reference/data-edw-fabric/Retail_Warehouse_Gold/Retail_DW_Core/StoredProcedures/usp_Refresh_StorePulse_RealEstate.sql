CREATE                                    PROCEDURE [Retail_DW_Core].[usp_Refresh_StorePulse_RealEstate]
AS
BEGIN


DECLARE @parallel_date_LY DATE

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
	WHERE CalendarYearIndicator = 0  and DateID < cast(getdate() as date)
	);


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
			CASE WHEN DateID < '2023-12-29' THEN -2
				WHEN DateID < '2024-12-30' THEN -1
				WHEN DateID < '2025-12-29' THEN 0
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
	,dte.FiscalMonth
	,dte.FiscalYear
	,dte.FiscalYearIndicator
	--,dte.Datekey
	,[FiscalDate]
    ,[FiscalMonthName]
    ,CAST(GETDATE() AS DATE) as [Date_Today]--,CAST(DW_Developer.fn_GetCSTDate(GETDATE()) AS DATE) AS [Date_Today]
INTO #Dates
	FROM Retail_DW_Core.DimDate dte
	WHERE dte.CalendarYearIndicator BETWEEN -2 AND 0




----------------------------------------------------------------------------------------------------------------
DECLARE @DateKey VARCHAR(10) = '20221231', @year INT = 2022;

----------------------------------------------------------------------------------------------------------------

 Drop table if exists Retail_DW_Core.FactStorePulseHolding_RealEstate
----------------------------------------------------------------------------------------------------------------
-- Budget COMPLETED
select TransDate
, a.StoreID as LocationKey
, c.LocationName as StoreName
, SUM(WrittenSales*PrimaryCategory) as WrittenSalesBudget
INTO #SalesBudget
FROM Retail_DW_Core.FactSalesBudget a
    LEFT JOIN Retail_DW_Core.DimDate b ON b.FiscalDate = a.TransDate
	LEFT JOIN Retail_DW_Core.DimStoreLocation c ON c.StoreID = a.StoreID
WHERE YEAR(a.TransDate) >= @year
GROUP BY a.TransDate, a.StoreID,c.LocationName
ORDER BY a.TransDate, a.StoreID,c.LocationName

select TransDate
, a.StoreID as LocationKey
, c.LocationName as StoreName
, SUM(TUGoal) AS  TrafficBudget 
INTO #TrafficBudget
FROM Retail_DW_Core.FactTrafficandCloseBudget a 
    LEFT JOIN Retail_DW_Core.DimDate b ON b.FiscalDate = a.TransDate
	LEFT JOIN Retail_DW_Core.DimStoreLocation c ON c.StoreID = a.StoreID
	
where YEAR(TransDate) >= @year
group by TransDate,a.StoreID,c.LocationName
order by TransDate,a.StoreID,c.LocationName


select a.TransDate
, a.LocationKey
,a.StoreName
, a.WrittenSalesBudget
, b.TrafficBudget
INTO #wrk_Budget 
FROM #SalesBudget a JOIN #TrafficBudget  b on a.TransDate = b.TransDate and a.LocationKey = b.LocationKey


---------------------------------------------------------------------------------------------------------------
-- Order Count -- 

SELECT DateID as TransDate, a.LocationKey as LocationKey, c.LocationName as StoreName, SUM(SuperOrderClose) as  OrderCount
INTO #wrk_OrderCount
FROM Retail_DW_Core.FactCloses a 
    LEFT JOIN Retail_DW_Core.DimDate b ON b.DateKey = TransDateKey
    LEFT JOIN Retail_DW_Core.DimStoreLocation c on a.LocationKey = c.LocationKey 
where YEAR(DateID) >=  @year
group by DateID,a.LocationKey, c.LocationName
order by DateID,a.LocationKey, c.LocationName


----------------------------------------------------------------------------------------------------------------
-- Traffic

SELECT 
	tra.StoreID as LocationKey
	,TransDate as  TransactionDate
    , dte.FiscalDate
	, c.LocationName as StoreName
    , 
     DATEADD(
        DAY,
        (7 + DATEPART(WEEKDAY, dte.FiscalDate) 
             - DATEPART(WEEKDAY, DATEADD(YEAR, -1, dte.FiscalDate))) % 7,
        DATEADD(YEAR, -1, dte.FiscalDate)
    ) AS ParallelDateLY
	,SUM(TrafficGuest) as Traffic
	, CONVERT(DECIMAL(16, 2), NULL) AS [Traffic_SP_LY] 
    
INTO #wrk_Traffic
	
FROM Retail_DW_Core.FactTraffic tra
	LEFT JOIN Retail_DW_Core.DimDate dte ON dte.DateID = tra.TransDate
	LEFT JOIN Retail_DW_Core.DimStoreLocation c on tra.StoreID = c.LocationKey 
WHERE dte.DateID  BETWEEN @StartDate  AND @EndDate
	
GROUP BY
	tra.StoreID
	,TransDate
    ,FiscalDate
	,c.LocationName


----------------------------------------------------------------------------------------------------------------
-- Written,  Invoiced & Category

SELECT 
 WRT.LocationKey as LocationKey
, dte.FiscalDate as OrderChangeDate
, dte.FiscalDate
,b.LocationName as StoreName
, 
     DATEADD(
        DAY,
        (7 + DATEPART(WEEKDAY, dte.FiscalDate) 
             - DATEPART(WEEKDAY, DATEADD(YEAR, -1, dte.FiscalDate))) % 7,
        DATEADD(YEAR, -1, dte.FiscalDate)
    ) AS ParallelDateLY
, SUM(CASE WHEN SalesType = 'W' THEN ISNULL(WRT.Sales,0)*ISNULL(GrossMultiplier,0) ELSE 0 END) AS [Written_GrossSale]
, SUM(CASE WHEN SalesType = 'W' THEN ISNULL(WRT.Sales,0)*ISNULL(p.PrimaryCategory,0) ELSE 0 END) AS [Written_Sales]
, CONVERT(DECIMAL(16, 2), NULL) AS [Written_Sales_LY]
, SUM(CASE WHEN SalesType = 'W' THEN ISNULL(WRT.Sales,0)*ISNULL(p.PrimaryCategory,0) ELSE 0 END) + SUM(CASE WHEN SalesType = 'W' AND p.CategoryID = 'DLVY' THEN ISNULL(WRT.Sales,0) ELSE 0 END) as [Written_Sales_D]
, SUM(CASE WHEN SalesType = 'W' THEN (ISNULL(WRT.Sales,0) - ISNULL(WRT.Cost,0))*ISNULL(p.PrimaryCategory,0) ELSE 0 END) AS [Written_GM]
, SUM(CASE WHEN SalesType = 'D' THEN ISNULL(WRT.Sales,0)*ISNULL(p.PrimaryCategory,0) ELSE 0 END) AS [Delivered_Sales]
, SUM(CASE WHEN SalesType = 'D' THEN (ISNULL(WRT.Sales,0) - ISNULL(WRT.Cost,0))*ISNULL(p.PrimaryCategory,0) ELSE 0 END) AS [Delivered_GM]
, (SUM(CASE WHEN SalesType = 'D' THEN (ISNULL(WRT.Sales,0) - ISNULL(WRT.Cost,0))*ISNULL(p.PrimaryCategory,0) ELSE 0 END)
/ nullif(SUM(CASE WHEN SalesType = 'W' THEN ISNULL(WRT.Sales,0)*ISNULL(p.PrimaryCategory,0) ELSE 0 END),0)) *100 AS [Delivered_GM_%]

INTO #wrk_Sales_Actual
from Retail_DW_Core.FactSales WRT 
left join Retail_DW_Core.DimStoreLocation b on WRT.LocationKey = b.LocationKey
LEFT JOIN Retail_DW_Core.DimDate dte ON dte.DateKey = WRT.TransDateKey
left join Retail_DW_Core.DimProduct p on WRT.ProductKey = p.ProductKey
WHERE  dte.DateID  BETWEEN @StartDate  AND @EndDate

GROUP BY  
WRT.LocationKey
, DateID
,FiscalDate
,b.LocationName


----------------------------------------------------------------------------------------------------------------
--All Metrics
SELECT
l.StoreID as LocationKey
, l.LocationName as StoreName
, bud.[TrafficBudget]
, bud.[WrittenSalesBudget]
, d.[FiscalDate]
, 
     DATEADD(
        DAY,
        (7 + DATEPART(WEEKDAY, d.FiscalDate) 
             - DATEPART(WEEKDAY, DATEADD(YEAR, -1, d.FiscalDate))) % 7,
        DATEADD(YEAR, -1, d.FiscalDate)
    ) AS ParallelDateLY
, d.[FiscalMonth]
, d.[FiscalMonthName]
, d.[FiscalYear]
, t.[Traffic]
, t.[Traffic_SP_LY]
, w.[Written_Sales]
, w.[Written_Sales_LY]
, w.[Written_Sales_D]
, w.[Written_GM]
, w.[Written_GrossSale]
, w.[Delivered_Sales]
, w.[Delivered_GM]
, w.[Delivered_GM_%]
, w.[Written_Sales]/nullif(t.[Traffic],0) as SPG
, w.[Written_Sales_D]/nullif(t.[Traffic],0) as [SPG.D]
, CONVERT(DECIMAL(16, 6), NULL) AS SPG_SP_LY
, bud.[WrittenSalesBudget]/nullif(bud.[TrafficBudget],0) as SPG_Budget
, w.[Written_Sales]/nullif(o.[OrderCount],0) as Average_Ticket
, CONVERT(DECIMAL(16, 4), NULL) AS [AverageTicket_%_Var_SP_LY]
, o.[OrderCount] as Total_OrderCount
, CONVERT(DECIMAL(16, 4), NULL) AS Total_OrderCount_LY
, o.[OrderCount]/nullif(t.[Traffic],0) as [Close_%]
, CONVERT(DECIMAL(16, 6), NULL) AS [Close_%_LY]
, w.[Written_GrossSale]-w.[Written_Sales] as [REAC $]
, (w.[Written_GrossSale]-w.[Written_Sales])/nullif(w.[Written_GrossSale],0) as [REAC %]
INTO #All_Metrics_Table

FROM Retail_DW_Core.DimStoreLocation as l
CROSS JOIN #Dates d
LEFT JOIN #wrk_Budget bud ON bud.LocationKey = l.StoreID AND bud.TransDate = d.DateID
LEFT JOIN #wrk_Traffic t ON t.LocationKey = l.StoreID AND t.TransactionDate = d.DateID
LEFT JOIN #wrk_OrderCount o ON o.LocationKey = l.LocationKey AND o.TransDate = d.DateID
LEFT JOIN #wrk_Sales_Actual w ON w.LocationKey = l.LocationKey AND w.OrderChangeDate = d.DateID



-- UPDATING LY METRICS--
UPDATE A
SET A.SPG_SP_LY = B.SPG
FROM #All_Metrics_Table AS A
JOIN #All_Metrics_Table AS B
    ON B.FiscalDate = A.ParallelDateLY
	AND B.LocationKey=A.LocationKey
	AND B.StoreName=A.StoreName

UPDATE A
SET 
    A.Total_OrderCount_LY = B.Total_OrderCount
FROM #All_Metrics_Table AS A
JOIN #All_Metrics_Table AS B
    ON B.FiscalDate = A.ParallelDateLY
	AND B.LocationKey=A.LocationKey
	AND B.StoreName=A.StoreName

UPDATE A
SET 
    A.[Close_%_LY] = B.[Close_%]
FROM #All_Metrics_Table AS A
JOIN #All_Metrics_Table AS B
    ON B.FiscalDate = A.ParallelDateLY
	AND B.LocationKey=A.LocationKey
	AND B.StoreName=A.StoreName

UPDATE A
SET A.[AverageTicket_%_Var_SP_LY] = (A.[Average_Ticket] - B.[Average_Ticket])
             / NULLIF(A.[Average_Ticket], 0)
FROM #All_Metrics_Table AS A
JOIN #All_Metrics_Table AS B
    ON B.FiscalDate = A.ParallelDateLY
	AND B.LocationKey=A.LocationKey
	AND B.StoreName=A.StoreName

UPDATE A
SET A.Written_Sales_LY = B.Written_Sales
FROM #All_Metrics_Table AS A
JOIN #All_Metrics_Table AS B
    ON B.FiscalDate = A.ParallelDateLY
	AND B.LocationKey=A.LocationKey
	AND B.StoreName=A.StoreName

UPDATE A
SET A.Traffic_SP_LY = B.Traffic
FROM #All_Metrics_Table AS A
JOIN #All_Metrics_Table AS B
    ON B.FiscalDate = A.ParallelDateLY
	AND B.LocationKey=A.LocationKey
	AND B.StoreName=A.StoreName

----------------------------------------------------------------------------------------------------------------
-- Final table

SELECT 
 LocationKey as StoreID
, StoreName
, FiscalDate
, ParallelDateLY
, [TrafficBudget]
, [WrittenSalesBudget]
, [FiscalMonth]
, [FiscalMonthName]
, [FiscalYear]
, [Traffic]
, [Traffic_SP_LY]
, [Written_Sales]
, [Written_Sales_LY]
, [Written_Sales_D]
, [Written_GM]
, [Written_GrossSale]
, [Delivered_Sales]
, [Delivered_GM]
, [Delivered_GM_%]
, SPG
, [SPG.D]
, SPG_SP_LY
, SPG_Budget
, Average_Ticket
, [AverageTicket_%_Var_SP_LY]
, Total_OrderCount
, Total_OrderCount_LY
, [Close_%]
, [Close_%_LY]
, [REAC $]
, [REAC %]
into Retail_DW_Core.FactStorePulseHolding_RealEstate
FROM #All_Metrics_Table


 END