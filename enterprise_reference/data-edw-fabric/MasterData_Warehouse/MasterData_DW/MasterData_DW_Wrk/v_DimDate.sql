CREATE VIEW MasterData_DW_Wrk.v_DimDate AS


--Calendar Week Look Up
	
WITH 
CalendarWeek (C_Year, C_Week, C_FDoW, C_LDoW) AS
(
	SELECT DATEPART(YEAR, dfiInpsdt) C_Year, 
           DATEPART(WEEK, dfiInpsdt) C_Week, 
           MIN(dfiInpsdt) C_FDoW, 
           MAX(dfiInpsdt) C_LDoW
	FROM [$(Databricks)].[enterprise_ods].[datefile] 
	GROUP BY DATEPART(YEAR, dfiInpsdt), DATEPART(WEEK, dfiInpsdt)

) 

,

--Calendar Month Look Up
CalendarMonth (C_Year, C_Month, C_FDoM, C_LDoM)  AS
(
	SELECT DATEPART(YEAR, dfiInpsdt) C_Year, 
           DATEPART(MONTH, dfiInpsdt) C_Month,  
           MIN(dfiInpsdt) C_FDoM,
           MAX(dfiInpsdt) C_LDoM
	FROM [$(Databricks)].[enterprise_ods].[datefile] 
	GROUP BY DATEPART(YEAR, dfiInpsdt), DATEPART(MONTH, dfiInpsdt)
) 
,

--Fiscal Week Look Up

FiscalWeek ([Indicator], F_Year, F_Week, F_YearWeek, F_FDoW, F_LDoW) AS 
(
	SELECT ROW_NUMBER () OVER (ORDER BY CAST(dfiYear AS CHAR(4)) + CASE WHEN LEN(dfiWeek) = 1 THEN '0' + CAST(dfiWeek AS CHAR(1)) ELSE CAST(dfiWeek AS CHAR(2)) END) - CI.CurrentIndicator as [Indicator], 
           dfiInpsyr as F_Year,
           dfiInpswk as F_Week,
           CAST(dfiYear AS CHAR(4)) + CASE WHEN LEN(dfiWeek) = 1 THEN '0' + CAST(dfiWeek AS CHAR(1)) ELSE CAST(dfiWeek AS CHAR(2)) END AS F_YearWeek,
           MIN(dfiInpsdt) AS F_FDoW,
           MAX(dfiInpsdt) AS F_LDoW
	FROM [$(Databricks)].[enterprise_ods].[datefile] 
	CROSS JOIN (SELECT COUNT(DISTINCT CAST(dfiYear AS CHAR(4)) + CASE WHEN LEN(dfiWeek) = 1 THEN '0' + CAST(dfiWeek AS CHAR(1)) ELSE CAST(dfiWeek AS CHAR(2)) END) AS CurrentIndicator
				FROM [$(Databricks)].[enterprise_ods].[datefile] 
				WHERE dfiInpsdt <= CAST(DATEADD(Day,-1,GETDATE()) AS DATE)) CI
	GROUP BY dfiInpsyr, dfiInpswk, CAST(dfiYear AS CHAR(4)) + CASE WHEN LEN(dfiWeek) = 1 THEN '0' + CAST(dfiWeek AS CHAR(1)) ELSE CAST(dfiWeek AS CHAR(2)) END, CI.CurrentIndicator
)
,


--Fiscal Month Look Up

FiscalMonth ([Indicator], F_Year, F_Month, F_FDoM, F_LDoM) AS 
(
    SELECT ROW_NUMBER () OVER (ORDER BY CAST(dfiYear AS CHAR(4)) + CASE WHEN LEN(dfiMonth) = 1 THEN '0' + CAST(dfiMonth AS CHAR(1)) ELSE CAST(dfiMonth AS CHAR(2)) END) - CI.CurrentIndicator AS [Indicator],
           dfiInpsyr as F_Year,
           dfiMonth as F_Month, 
           MIN(dfiInpsdt) as F_FDoM, 
           MAX(dfiInpsdt) as F_LDoM
	FROM [$(Databricks)].[enterprise_ods].[datefile] 
	CROSS JOIN (SELECT COUNT(DISTINCT CAST(dfiYear AS CHAR(4)) + CASE WHEN LEN(dfiMonth) = 1 THEN '0' + CAST(dfiMonth AS CHAR(1)) ELSE CAST(dfiMonth AS CHAR(2)) END) AS CurrentIndicator
				FROM [$(Databricks)].[enterprise_ods].[datefile] 
				WHERE dfiInpsdt <= CAST(DATEADD(Day,-1,GETDATE()) AS DATE)) CI
	GROUP BY dfiInpsyr, dfiMonth, CAST(dfiYear AS CHAR(4)) + CASE WHEN LEN(dfiMonth) = 1 THEN '0' + CAST(dfiMonth AS CHAR(1)) ELSE CAST(dfiMonth AS CHAR(2)) END, CI.CurrentIndicator
) 
,

--Fiscal Quarter Look up
		
FiscalQuarter  ([Indicator], F_Year, F_Quarter, F_FDoQ, F_LDoQ) AS 
(
	SELECT	ROW_NUMBER () OVER (ORDER BY CAST(dfiInpsyr AS varchar (4)) + CAST(CASE WHEN dfiInpsmn BETWEEN 1 AND 3 THEN 1 WHEN dfiInpsmn BETWEEN 4 AND 6 THEN 2 WHEN dfiInpsmn BETWEEN 7 AND 9 THEN 3 ELSE 4 END AS varchar(1))) - CI.CurrentIndicator AS [Indicator], 
			dfiInpsyr as F_Year,
            CASE WHEN dfiInpsmn BETWEEN 1 AND 3 THEN 1 WHEN dfiInpsmn BETWEEN 4 AND 6 THEN 2 WHEN dfiInpsmn BETWEEN 7 AND 9 THEN 3 ELSE 4 END as F_Quarter, 
            MIN(dfiInpsdt) as F_FDoQ , 
            MAX(dfiInpsdt) as F_LDoQ
	FROM [$(Databricks)].[enterprise_ods].[datefile] 
	CROSS JOIN (SELECT COUNT(DISTINCT CAST(dfiInpsyr AS varchar (4)) + CAST(CASE WHEN dfiInpsmn BETWEEN 1 AND 3 THEN 1 WHEN dfiInpsmn BETWEEN 4 AND 6 THEN 2 WHEN dfiInpsmn BETWEEN 7 AND 9 THEN 3 ELSE 4 END AS varchar(1))) AS CurrentIndicator
				FROM [$(Databricks)].[enterprise_ods].[datefile] 
				WHERE dfiInpsdt <= CAST(DATEADD(Day,-1,GETDATE()) AS DATE)) CI
	GROUP BY dfiInpsyr, CASE WHEN dfiInpsmn BETWEEN 1 AND 3 THEN 1 WHEN dfiInpsmn BETWEEN 4 AND 6 THEN 2 WHEN dfiInpsmn BETWEEN 7 AND 9 THEN 3 ELSE 4 END, CI.CurrentIndicator
)
,

--Fiscal Year Look Up

FiscalYear   ([Indicator], F_Year, F_FDoY, F_LDoY)  as
(
	SELECT ROW_NUMBER () OVER (ORDER BY dfiInpsyr)- CI.CurrentIndicator as [Indicator], 
           dfiInpsyr AS F_Year, 
           MIN(dfiInpsdt) AS F_FDoY, 
           MAX(dfiInpsdt) AS F_LDoY
	FROM [$(Databricks)].[enterprise_ods].[datefile] 
	CROSS JOIN (SELECT COUNT(DISTINCT dfiInpsyr) AS CurrentIndicator
				FROM [$(Databricks)].[enterprise_ods].[datefile] 
				WHERE dfiInpsdt <= CAST(DATEADD(Day,-1,GETDATE()) AS DATE)) CI
	GROUP BY dfiInpsyr, CI.CurrentIndicator
 ) 

--1970 to 1992 excluding Fiscal Attributes (They do not exist in our current Fiscal Calendar)

SELECT	CAST(DATEPART(year, D1.dfiInpsdt) AS Varchar(4)) + 
		CASE LEN(CAST(DATEPART(MONTH, D1.dfiInpsdt) AS varchar(2))) WHEN 1 THEN '0' + CAST(DATEPART(MONTH, D1.dfiInpsdt) AS varchar(2)) ELSE CAST(DATEPART(MONTH, D1.dfiInpsdt) AS varchar(2)) END + 
		CASE LEN(CAST(DATEPART(DAY,   D1.dfiInpsdt) AS varchar(2))) WHEN 1 THEN '0' + CAST(DATEPART(DAY,   D1.dfiInpsdt) AS varchar(2)) ELSE CAST(DATEPART(DAY,   D1.dfiInpsdt) AS varchar(2)) END AS [DateKey],
		NULL AS [MapicsDate],
		CAST(D1.dfiInpsdt AS DATE) AS [DateID],
		CAST(D1.dfiInpsdt AS DATETIME) AS [DateTimeID],
		D1.dfiInpsdt AS [CalendarDate],
		CASE DATEPART(dw,D1.dfiInpsdt) WHEN 1 THEN 'Sun' WHEN 2 THEN 'Mon' WHEN 3 THEN 'Tue' WHEN 4 THEN 'Wed' WHEN 5 THEN 'Thu' WHEN 6 THEN 'Fri' WHEN 7 THEN 'Sat' END + ', ' + CAST (D1.dfiInpsdt AS VARCHAR(12)) AS [CalendarDateName], 
		DATEDIFF(DAY,CAST(DATEADD(Day,-1,GETDATE()) AS DATE), D1.dfiInpsdt) AS [CalendarDateIndicator],		
	--Calendar Week 
		DATEPART(WEEK, D1.dfiInpsdt) AS [CalendarWeek],
		DATEDIFF(WEEK, CAST(DATEADD(Day,-1,GETDATE()) AS DATE), D1.dfiInpsdt) AS [CalendarWeekIndicator],
		CAST(DATEPART(year, D1.dfiInpsdt) AS Varchar(4)) + CASE LEN(CAST(DATEPART(WEEK, D1.dfiInpsdt) AS varchar(2))) WHEN 1 THEN '0' + CAST(DATEPART(WEEK, D1.dfiInpsdt) AS varchar(2)) ELSE CAST(DATEPART(WEEK, D1.dfiInpsdt) AS varchar(2)) END AS [CalendarWeekYear],
		CASE DatePart(dw,D1.dfiInpsdt)	WHEN 1 THEN 'Week Ended,  ' + convert(varchar(13), DATEADD(DAY, 6, D1.dfiInpsdt), 107)	
										WHEN 2 THEN 'Week Ended,  ' + convert(varchar(13), DATEADD(DAY, 5, D1.dfiInpsdt), 107) 
										WHEN 3 THEN 'Week Ended,  ' + convert(varchar(13), DATEADD(DAY, 4, D1.dfiInpsdt), 107) 
										WHEN 4 THEN 'Week Ended,  ' + convert(varchar(13), DATEADD(DAY, 3, D1.dfiInpsdt), 107) 
										WHEN 5 THEN 'Week Ended,  ' + convert(varchar(13), DATEADD(DAY, 2, D1.dfiInpsdt), 107) 
										WHEN 6 THEN 'Week Ended,  ' + convert(varchar(13), DATEADD(DAY, 1, D1.dfiInpsdt), 107) 
										WHEN 7 THEN 'Week Ended,  ' + convert(varchar(13), D1.dfiInpsdt, 107) END	AS [CalendarWeekYearName],
		DATEPART(WEEKDAY, D1.dfiInpsdt) AS [CalendarDayOfWeek],
		DATENAME(WEEKDAY, D1.dfiInpsdt) AS [CalendarDayOfWeekName],
		C_FDoW AS [CalendarWeekFirstDate],
		C_LDoW AS [CalendarWeekLastDate],
	--Calendar Month Attributes
		DATEPART(MONTH, D1.dfiInpsdt) AS [CalendarMonth],
		DATEDIFF(MONTH, CAST(DATEADD(Day,-1,GETDATE()) AS DATE), D1.dfiInpsdt) AS [CalendarMonthIndicator],
		CAST(DATEPART(year, D1.dfiInpsdt) AS Varchar(4)) + CASE LEN(CAST(DATEPART(MONTH, D1.dfiInpsdt) AS varchar(2))) WHEN 1 THEN '0' + CAST(DATEPART(MONTH, D1.dfiInpsdt) AS varchar(2)) ELSE CAST(DATEPART(MONTH, D1.dfiInpsdt) AS varchar(2)) END AS [CalendarMonthYear],
		DATENAME(MONTH, D1.dfiInpsdt) AS [CalendarMonthName],
		DATENAME(MONTH, D1.dfiInpsdt) + ', '+ CAST(DATEPART(YEAR,D1.dfiInpsdt) as char(4))AS [CalendarMonthYearName],
		DATENAME(DAY, D1.dfiInpsdt) AS [CalendarDayOfMonth],
		DATEPART(WEEK, D1.dfiInpsdt) - DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM,0,D1.dfiInpsdt), 0))+ 1 AS [CalendarWeekOfMonth],
		C_FDoM AS [CalendarMonthFirstDate],
		C_LDoM AS [CalendarMonthLastDate],
	--Calendar Quarter Attributes
		DATEPART(QUARTER, D1.dfiInpsdt) AS [CalendarQuarter],
		'Qtr. ' + CAST(DATEPART(QUARTER, D1.dfiInpsdt) AS CHAR(1)) AS [CalendarQuarterName],
		DATEDIFF(QUARTER, CAST(DATEADD(Day,-1,GETDATE()) AS DATE), D1.dfiInpsdt) AS [CalendarQuarterIndicator],
		CAST(DATEPART(year, D1.dfiInpsdt) AS Varchar(4)) + CAST(DATEPART(QUARTER, D1.dfiInpsdt) AS VARCHAR(1)) AS [CalendarQuarterYear],
		'Quarter '+ CAST(DATEPART(qq,D1.dfiInpsdt) AS CHAR(1)) + ', ' + CAST(DATEPART(YEAR,D1.dfiInpsdt) AS CHAR(4)) AS [CalendarQuarterYearName],
	--Calendar Semester Attributes
		CASE DATEPART(QUARTER, D1.dfiInpsdt) WHEN 1 THEN 1	WHEN 2 THEN 1 WHEN 3 THEN 2	WHEN 4 THEN 2 END AS [CalendarSememster],
		CAST(DATEPART(year, D1.dfiInpsdt) AS Varchar(4)) + CAST(CASE DATEPART(QUARTER, D1.dfiInpsdt) WHEN 1 THEN 1	WHEN 2 THEN 1 WHEN 3 THEN 2	WHEN 4 THEN 2 END AS varchar(1)) AS [CalendarSemesterYear],
	--Calendar Year Attributes
		DATEPART(YEAR, D1.dfiInpsdt) AS [CalendarYear],
		'Calendar '+ CAST(DATEPART(yy,D1.dfiInpsdt) AS CHAR(4)) AS [CalendarYearName],
		DATEDIFF(YEAR, CAST(DATEADD(Day,-1,GETDATE()) AS DATE), D1.dfiInpsdt) AS [CalendarYearIndicator],
		DATEPART(DAYOfYEAR, D1.dfiInpsdt) AS [CalendarDayOfYear],
	--Fiscal Date Attributes
		NULL AS [FiscalDate],
		NULL AS [FiscalDateName],
		NULL AS [FiscalDateIndicator],
	--Fiscal Week Attributes
		NULL AS [FiscalWeek],
		NULL AS [FiscalWeekIndicator],
		NULL AS [FiscalDayOfWeek],
		NULL AS [FiscalDayOfWeekName],
		NULL AS [FiscalWeekYear],
		NULL AS [FiscalWeekYearName],
		NULL AS [FiscalWeekFirstDate],
		NULL AS [FiscalWeekLastDate],
	--Fiscal Month Attributes
		NULL AS [FiscalMonth],
		NULL AS [FiscalMonthIndicator],
		NULL AS [FiscalMonthYear],
		NULL AS [FiscalMonthName],
		NULL AS [FiscalMonthYearName],			
		NULL AS [FiscalDayOfMonth],
		NULL AS [FiscalWeekOfMonth],
		NULL AS [FiscalMonthFirstDate],
		NULL AS [FiscalMonthLastDate],
	--Fiscal Quarter Attributes
		NULL AS [FiscalQuarter],
		NULL AS [FiscalQuarterName],
		NULL AS [FiscalQuarterIndicator],
		NULL AS [FiscalQuarterYear],
		NULL AS [FiscalQuarterYearName],
	--Fiscal Semester Attributes
		NULL AS [FiscalSemester],
		NULL AS [FiscalSemesterYear],
	--Fiscal Year Attributes
		NULL AS [FiscalYear],
		NULL AS [FiscalYearName],
		NULL AS [FiscalYearIndicator],
		NULL AS [FiscalDayOfYear],
		NULL AS [FiscalYearFirstDate],
		NULL AS [FiscalYearLastDate],
	--Misc
		NULL AS [HolidayIndicator],
		NULL AS [Holiday_Name],
		NULL AS [WorkingDayIndicator],
		NULL AS [WeekdayWeekend]

FROM (	SELECT dateadd(d, NUM, '1969-12-31') AS dfiInpsdt
		FROM (
			 select row_number() over (order by (select NULL)) as NUM
			  from [$(Databricks)].[enterprise_ods].[datefile]  ) NUM
		WHERE NUM <= datediff(d, '1970-01-01', '1999-12-26') ) D1

LEFT JOIN CalendarWeek CW ON CW.C_Year = DATEPART(YEAR, dfiInpsdt) AND C_Week = DATEPART(WEEK, dfiInpsdt)
LEFT JOIN CalendarMonth CM ON CM.C_Year = DATEPART(YEAR, dfiInpsdt) AND C_Month = DATEPART(MONTH, dfiInpsdt)


UNION

--Fiscal 1993 to present including Fiscal Attributes

SELECT	CAST(DATEPART(year, D1.dfiInpsdt) AS Varchar(4)) + 
		CASE LEN(CAST(DATEPART(MONTH, D1.dfiInpsdt) AS varchar(2))) WHEN 1 THEN '0' + CAST(DATEPART(MONTH, D1.dfiInpsdt) AS varchar(2)) ELSE CAST(DATEPART(MONTH, D1.dfiInpsdt) AS varchar(2)) END + 
		CASE LEN(CAST(DATEPART(DAY,   D1.dfiInpsdt) AS varchar(2))) WHEN 1 THEN '0' + CAST(DATEPART(DAY,   D1.dfiInpsdt) AS varchar(2)) ELSE CAST(DATEPART(DAY,   D1.dfiInpsdt) AS varchar(2)) END AS [DateKey],
		D1.dfiMapicsDate AS [MapicsDate],
		CAST(D1.dfiInpsdt AS DATE) AS [DateID],
		CAST(D1.dfiInpsdt AS DATETIME) AS [DateTimeID],
		D1.dfiInpsdt AS [CalendarDate],
		CASE DATEPART(dw,D1.dfiInpsdt) WHEN 1 THEN 'Sun' WHEN 2 THEN 'Mon' WHEN 3 THEN 'Tue' WHEN 4 THEN 'Wed' WHEN 5 THEN 'Thu' WHEN 6 THEN 'Fri' WHEN 7 THEN 'Sat' END + ', ' + CAST (D1.dfiInpsdt AS VARCHAR(12)) AS [CalendarDateName], 
		DATEDIFF(DAY, CAST(DATEADD(Day,-1,GETDATE()) AS DATE), D1.dfiInpsdt) AS [CalendarDateIndicator],		
	--Calendar Week 
		DATEPART(WEEK, D1.dfiInpsdt) AS [CalendarWeek],
		DATEDIFF(WEEK,  CAST(DATEADD(Day,-1,GETDATE()) AS DATE), D1.dfiInpsdt)  AS [CalendarWeekIndicator],
		CAST(DATEPART(year, D1.dfiInpsdt) AS Varchar(4)) + CASE LEN(CAST(DATEPART(WEEK, D1.dfiInpsdt) AS varchar(2))) WHEN 1 THEN '0' + CAST(DATEPART(WEEK, D1.dfiInpsdt) AS varchar(2)) ELSE CAST(DATEPART(WEEK, D1.dfiInpsdt) AS varchar(2)) END AS [CalendarWeekYear],
		CASE DatePart(dw,D1.dfiInpsdt)	WHEN 1 THEN 'Week Ended,  ' + convert(varchar(13), DATEADD(DAY,6,D1.dfiInpsdt) ,107)	
										WHEN 2 THEN 'Week Ended,  ' + convert(varchar(13), DATEADD(DAY,5,D1.dfiInpsdt), 107) 
										WHEN 3 THEN 'Week Ended,  ' + convert(varchar(13), DATEADD(DAY,4,D1.dfiInpsdt), 107) 
										WHEN 4 THEN 'Week Ended,  ' + convert(varchar(13), DATEADD(DAY,3,D1.dfiInpsdt), 107) 
										WHEN 5 THEN 'Week Ended,  ' + convert(varchar(13), DATEADD(DAY,2,D1.dfiInpsdt), 107) 
										WHEN 6 THEN 'Week Ended,  ' + convert(varchar(13), DATEADD(DAY,1,D1.dfiInpsdt), 107) 
										WHEN 7 THEN 'Week Ended,  ' + convert(varchar(13), D1.dfiInpsdt, 107) END	AS [CalendarWeekYearName],
		DATEPART(WEEKDAY, D1.dfiInpsdt) AS [CalendarDayOfWeek],
		DATENAME(WEEKDAY, D1.dfiInpsdt) AS [CalendarDayOfWeekName],
		C_FDoW AS [CalendarWeekFirstDate],
		C_LDoW AS [CalendarWeekLastDate],
	--Calendar Month Attributes
		DATEPART(MONTH, D1.dfiInpsdt) AS [CalendarMonth],
		DATEDIFF(MONTH,  CAST(DATEADD(Day,-1,GETDATE()) AS DATE), D1.dfiInpsdt) AS [CalendarMonthIndicator],
		CAST(DATEPART(year, D1.dfiInpsdt) AS Varchar(4)) + CASE LEN(CAST(DATEPART(MONTH, D1.dfiInpsdt) AS varchar(2))) WHEN 1 THEN '0' + CAST(DATEPART(MONTH, D1.dfiInpsdt) AS varchar(2)) ELSE CAST(DATEPART(MONTH, D1.dfiInpsdt) AS varchar(2)) END AS [CalendarMonthYear],
		DATENAME(MONTH, D1.dfiInpsdt) AS [CalendarMonthName],
		DATENAME(MONTH, D1.dfiInpsdt) + ', '+ CAST(DATEPART(YEAR,D1.dfiInpsdt) as char(4))AS [CalendarMonthYearName],
		DATENAME(DAY, D1.dfiInpsdt) AS [CalendarDayOfMonth],
		DATEPART(WEEK, D1.dfiInpsdt) - DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM,0,D1.dfiInpsdt), 0))+ 1 AS [CalendarWeekOfMonth],
		C_FDoM AS [CalendarMonthFirstDate],
		C_LDoM AS [CalendarMonthLastDate],
	--Calendar Quarter Attributes
		DATEPART(QUARTER, D1.dfiInpsdt) AS [CalendarQuarter],
		'Qtr. ' + CAST(DATEPART(QUARTER, D1.dfiInpsdt) AS CHAR(1)) AS [CalendarQuarterName],
		DATEDIFF(QUARTER,  CAST(DATEADD(Day,-1,GETDATE()) AS DATE), D1.dfiInpsdt)  AS [CalendarQuarterIndicator],
		CAST(DATEPART(year, D1.dfiInpsdt) AS Varchar(4)) + CAST(DATEPART(QUARTER, D1.dfiInpsdt) AS VARCHAR(1)) AS [CalendarQuarterYear],
		'Quarter '+ CAST(DATEPART(qq,D1.dfiInpsdt) AS CHAR(1)) + ', ' + CAST(DATEPART(YEAR,D1.dfiInpsdt) AS CHAR(4)) AS [CalendarQuarterYearName],
	--Calendar Semester Attributes
		CASE DATEPART(QUARTER, D1.dfiInpsdt) WHEN 1 THEN 1	WHEN 2 THEN 1 WHEN 3 THEN 2	WHEN 4 THEN 2 END AS [CalendarSememster],
		CAST(DATEPART(year, D1.dfiInpsdt) AS Varchar(4)) + CAST(CASE DATEPART(QUARTER, D1.dfiInpsdt) WHEN 1 THEN 1	WHEN 2 THEN 1 WHEN 3 THEN 2	WHEN 4 THEN 2 END AS varchar(1)) AS [CalendarSemesterYear],
	--Calendar Year Attributes
		DATEPART(YEAR, D1.dfiInpsdt) AS [CalendarYear],
		'Calendar '+ CAST(DATEPART(yy,D1.dfiInpsdt) AS CHAR(4)) AS [CalendarYearName],
		DATEDIFF(YEAR, CAST(DATEADD(Day,-1,GETDATE()) AS DATE), D1.dfiInpsdt)  AS [CalendarYearIndicator],
		DATEPART(DAYOfYEAR, D1.dfiInpsdt) AS [CalendarDayOfYear],
	--Fiscal Date Attributes
		D1.dfiInpsdt AS [FiscalDate],
		CASE DATEPART(dw,D1.dfiInpsdt) WHEN 1 THEN 'Sun' WHEN 2 THEN 'Mon' WHEN 3 THEN 'Tue' WHEN 4 THEN 'Wed' WHEN 5 THEN 'Thu' WHEN 6 THEN 'Fri' WHEN 7 THEN 'Sat' END + ', ' + CAST (D1.dfiInpsdt AS VARCHAR(12)) AS [FiscalDateName],
		DATEDIFF(DAY,  CAST(DATEADD(Day,-1,GETDATE()) AS DATE), D1.dfiInpsdt)  AS [FiscalDateIndicator],
	--Fiscal Week Attributes
		D1.dfiInpswk AS [FiscalWeek],
		FW.Indicator AS [FiscalWeekIndicator],
		DATEPART(WEEKDAY, D1.dfiInpsdt) AS [FiscalDayOfWeek],
		DATENAME(WEEKDAY, D1.dfiInpsdt) AS [FiscalDayOfWeekName],
		CAST(D1.dfiInpsyr AS varchar(4)) + CASE LEN(LTRIM(D1.dfiInpswk)) WHEN 1 THEN '0' + LTRIM(CAST(D1.dfiInpswk AS varchar(2))) ELSE CAST(D1.dfiInpswk AS varchar(2)) END AS [FiscalWeekYear],
		CASE DatePart(dw,D1.dfiInpsdt)	WHEN 1 THEN 'Week Ended,  ' + convert(varchar(13), DATEADD(DAY,6,D1.dfiInpsdt) ,107)	
										WHEN 2 THEN 'Week Ended,  ' + convert(varchar(13), DATEADD(DAY,5,D1.dfiInpsdt), 107) 
										WHEN 3 THEN 'Week Ended,  ' + convert(varchar(13), DATEADD(DAY,4,D1.dfiInpsdt), 107) 
										WHEN 4 THEN 'Week Ended,  ' + convert(varchar(13), DATEADD(DAY,3,D1.dfiInpsdt), 107) 
										WHEN 5 THEN 'Week Ended,  ' + convert(varchar(13), DATEADD(DAY,2,D1.dfiInpsdt), 107) 
										WHEN 6 THEN 'Week Ended,  ' + convert(varchar(13), DATEADD(DAY,1,D1.dfiInpsdt), 107) 
										WHEN 7 THEN 'Week Ended,  ' + convert(varchar(13), D1.dfiInpsdt, 107) END AS [FiscalWeekYearName],
		FW.F_FDoW AS [FiscalWeekFirstDate],
		FW.F_LDoW AS [FiscalWeekLastDate],
	--Fiscal Month Attributes
		D1.dfiInpsmn AS [FiscalMonth],
		FM.Indicator AS [FiscalMonthIndicator],
		CAST(D1.dfiInpsyr AS varchar(4)) + CASE LEN(LTRIM(D1.dfiInpsmn)) WHEN 1 THEN '0' + LTRIM(CAST(D1.dfiInpsmn AS varchar(2))) ELSE CAST(D1.dfiInpsmn AS varchar(2)) END AS [FiscalMonthYear],
		CASE D1.dfiInpsmn	WHEN 1  THEN 'January'	 WHEN 2  THEN 'February' WHEN 3  THEN 'March'	 WHEN 4  THEN 'April'
							WHEN 5  THEN 'May'		 WHEN 6  THEN 'June'	 WHEN 7  THEN 'July'	 WHEN 8  THEN 'August' 
							WHEN 9  THEN 'September' WHEN 10 THEN 'October'  WHEN 11 THEN 'November' WHEN 12 THEN 'December' END AS [FiscalMonthName],	
		CASE D1.dfiInpsmn	WHEN 1  THEN 'January'	 WHEN 2  THEN 'February' WHEN 3  THEN 'March'	 WHEN 4  THEN 'April'
							WHEN 5  THEN 'May'		 WHEN 6  THEN 'June'	 WHEN 7  THEN 'July'	 WHEN 8  THEN 'August' 
							WHEN 9  THEN 'September' WHEN 10 THEN 'October'  WHEN 11 THEN 'November' WHEN 12 THEN 'December' END + ', ' + D1.dfiInpsyr AS[FiscalMonthYearName],		
		ROW_NUMBER() OVER(PARTITION BY D1.dfiInpsyr, D1.dfiInpsmn  ORDER BY D1.dfiInpsdt) AS [FiscalDayOfMonth],
		CASE	WHEN ROW_NUMBER() OVER(PARTITION BY D1.dfiInpsyr, D1.dfiInpsmn  ORDER BY D1.dfiInpsdt) BETWEEN 1  AND 7  THEN 1
				WHEN ROW_NUMBER() OVER(PARTITION BY D1.dfiInpsyr, D1.dfiInpsmn  ORDER BY D1.dfiInpsdt) BETWEEN 8  AND 14 THEN 2
				WHEN ROW_NUMBER() OVER(PARTITION BY D1.dfiInpsyr, D1.dfiInpsmn  ORDER BY D1.dfiInpsdt) BETWEEN 15 AND 21 THEN 3
				WHEN ROW_NUMBER() OVER(PARTITION BY D1.dfiInpsyr, D1.dfiInpsmn  ORDER BY D1.dfiInpsdt) BETWEEN 22 AND 28 THEN 4
				WHEN ROW_NUMBER() OVER(PARTITION BY D1.dfiInpsyr, D1.dfiInpsmn  ORDER BY D1.dfiInpsdt) BETWEEN 29 AND 35 THEN 5
				WHEN ROW_NUMBER() OVER(PARTITION BY D1.dfiInpsyr, D1.dfiInpsmn  ORDER BY D1.dfiInpsdt) BETWEEN 36 AND 42 THEN 6 END AS [FiscalWeekOfMonth],
		F_FDoM AS [FiscalMonthFirstDate],
		F_LDoM AS [FiscalMonthLastDate],
	--Fiscal Quarter Attributes
		F_Quarter AS [FiscalQuarter],
		'Qtr. ' + CAST(F_Quarter AS CHAR(1)) AS [FiscalQuarterName],
		FQ.Indicator AS [FiscalQuarterIndicator],
		CAST(D1.dfiInpsyr AS varchar (4)) + CAST(F_Quarter AS varchar(1)) AS [FiscalQuarterYear],
		'Quarter ' +  CAST(F_Quarter AS varchar(1)) + ', ' + CAST(D1.dfiInpsyr AS varchar (4)) AS [FiscalQuarterYearName],
	--Fiscal Semester Attributes
		CASE WHEN D1.dfiInpsmn BETWEEN 1 AND 6 THEN 1 WHEN D1.dfiInpsmn BETWEEN 7 AND 12 THEN 2 END AS [FiscalSemester],
		CAST(D1.dfiInpsyr AS varchar (4)) + CAST(CASE WHEN D1.dfiInpsmn BETWEEN 1 AND 6 THEN 1 WHEN D1.dfiInpsmn BETWEEN 7 AND 12 THEN 2 END AS Varchar(1)) AS [FiscalSemesterYear],
	--Fiscal Year Attributes
		D1.dfiInpsyr AS [FiscalYear],
		'Fiscal ' + CAST(D1.dfiInpsyr AS varchar (4)) AS [FiscalYearName],
		FY.Indicator AS [FiscalYearIndicator],
		ROW_NUMBER() OVER(PARTITION BY D1.dfiInpsyr ORDER BY D1.dfiInpsdt) AS [FiscalDayOfYear],
		F_FDoY AS [FiscalYearFirstDate],
		F_LDoY AS [FiscalYearLastDate],
	--Misc
		CASE WHEN D1.dfiHoliday IS NULL THEN 'Non-Holiday' ELSE 'Holiday' END AS [HolidayIndicator],
		D1.dfiHoliday AS [Holiday_Name],
		CASE WHEN DATEPART(WEEKDAY, D1.dfiInpsdt) IN ('1','7') THEN 'Non-Working Day'	ELSE 'Working Day' END AS [WorkingDayIndicator],
		CASE WHEN DATEPART(WEEKDAY, D1.dfiInpsdt) IN ('1','7') THEN 'Weekend'			ELSE 'Weekday'	   END AS [WeekdayWeekend]


FROM [$(Databricks)].[enterprise_ods].[datefile]  D1
LEFT JOIN [$(Databricks)].[enterprise_ods].[datefile]  D2 ON DATEADD(DAY, -364, D1.dfiInpsdt) = D2.dfiInpsdt
LEFT JOIN [$(Databricks)].[enterprise_ods].[datefile]  D3 ON DATEADD(DAY, -728, D1.dfiInpsdt) = D3.dfiInpsdt
LEFT JOIN CalendarWeek CW ON CW.C_Year = DATEPART(YEAR, D1.dfiInpsdt) AND C_Week = DATEPART(WEEK, D1.dfiInpsdt)
LEFT JOIN CalendarMonth CM ON CM.C_Year = DATEPART(YEAR, D1.dfiInpsdt) AND C_Month = DATEPART(MONTH, D1.dfiInpsdt)
LEFT JOIN FiscalWeek FW ON FW.F_Year = D1.dfiInpsyr AND FW.F_Week = D1.dfiInpswk
LEFT JOIN FiscalMonth FM ON FM.F_Year = D1.dfiInpsyr AND FM.F_Month = D1.dfiInpsmn
LEFT JOIN FiscalQuarter FQ ON FQ.F_Year = D1.dfiInpsyr AND FQ.F_Quarter = CASE WHEN D1.dfiInpsmn BETWEEN 1 AND 3 THEN 1 WHEN D1.dfiInpsmn BETWEEN 4 AND 6 THEN 2 WHEN D1.dfiInpsmn BETWEEN 7 AND 9 THEN 3 ELSE 4 END
LEFT JOIN FiscalYear FY ON FY.F_Year = D1.dfiInpsyr
WHERE D1.dfiInpsyr >= DATEPART(YEAR, DATEADD(DAY,-3650, GETDATE()))


UNION ALL

SELECT	'19000101'	 AS 	DateKey,
		NULL    	 AS 	MapicsDate,
		'1/1/1900'	 AS 	DateID,
		'1900-01-01 00:00:00.000'	AS 	DateTimeID,
		'1900-01-01 00:00:00.000'	 AS 	CalendarDate,
		NULL	 AS		CalendarDateName,
		NULL	 AS 	CalendarDateIndicator,
		NULL	 AS 	CalendarWeek,
		NULL	 AS 	CalendarWeekIndicator,
		NULL	 AS 	CalendarWeekYear,
		NULL	 AS		CalendarWeekYearName,
		NULL	 AS 	CalendarDayOfWeek,
		NULL	 AS 	CalendarDayOfWeekName,
		NULL	 AS 	CalendarWeekFirstDate,
		NULL	 AS 	CalendarWeekLastDate,
		NULL	 AS 	CalendarMonth,
		NULL	 AS 	CalendarMonthIndicator,
		NULL	 AS 	CalendarMonthYear,
		NULL	 AS 	CalendarMonthName,
		NULL	 AS		CalendarMonthYearName,
		NULL	 AS 	CalendarDayOfMonth,
		NULL	 AS 	CalendarWeekOfMonth,
		NULL	 AS 	CalendarMonthFirstDate,
		NULL	 AS 	CalendarMonthLastDate,
		NULL	 AS 	CalendarQuarter,
		NULL	 AS 	CalendarQuarterName,
		NULL	 AS 	CalendarQuarterIndicator,
		NULL	 AS 	CalendarQuarterYear,
		NULL	 AS 	CalendarQuarterYearName,
		NULL	 AS 	CalendarSememster,
		NULL	 AS 	CalendarSemesterYear,
		NULL	 AS 	CalendarYear,
		NULL	 AS		CalendarYearName,
		NULL	 AS 	CalendarYearIndicator,
		NULL	 AS 	CalendarDayOfYear,
		NULL	 AS 	FiscalDate,
		NULL     AS     FiscalDateName,
		NULL	 AS 	FiscalDateIndicator,
		NULL	 AS 	FiscalWeek,
		NULL	 AS 	FiscalWeekIndicator,
		NULL	 AS 	FiscalDayOfWeek,
		NULL	 AS 	FiscalDayOfWeekName,
		NULL	 AS 	FiscalWeekYear,
		NULL	 AS		FiscalWeekYearName,
		NULL	 AS 	FiscalWeekFirstDate,
		NULL	 AS 	FiscalWeekLastDate,
		NULL	 AS 	FiscalMonth,
		NULL	 AS 	FiscalMonthIndicator,
		NULL	 AS 	FiscalMonthYear,
		NULL	 AS 	FiscalMonthName,
		NULL	 AS		FiscalMonthYearName,
		NULL	 AS 	FiscalDayOfMonth,
		NULL	 AS 	FiscalWeekOfMonth,
		NULL	 AS 	FiscalMonthFirstDate,
		NULL	 AS 	FiscalMonthLastDat,
		NULL	 AS 	FiscalQuarter,
		NULL	 AS 	FiscalQuarterName,
		NULL	 AS 	FiscalQuarterIndicator,
		NULL	 AS 	FiscalQuarterYear,
		NULL	 AS 	FiscalQuarterYearName,
		NULL	 AS 	FiscalSemester,
		NULL	 AS 	FiscalSemesterYear,
		NULL	 AS 	FiscalYear,
		NULL	 AS     FiscalYearName,
		NULL	 AS 	FiscalYearIndicator,
		NULL	 AS 	FiscalDayOfYear,
		NULL	 AS 	FiscalYearFirstDate,
		NULL	 AS 	FiscalYearLastDate,
		NULL	 AS 	HolidayIndicator,
		NULL	 AS 	Holiday_Name,
		NULL	 AS 	WorkingDayIndicator,
		NULL	 AS 	WeekdayWeekend	

