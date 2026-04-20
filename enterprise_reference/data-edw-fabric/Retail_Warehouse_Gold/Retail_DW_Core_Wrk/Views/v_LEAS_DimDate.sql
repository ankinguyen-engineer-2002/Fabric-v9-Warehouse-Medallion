CREATE     VIEW [Retail_DW_Core_Wrk].[v_LEAS_DimDate] AS
SELECT 
    DateKey AS TransDateKey,
    CalendarDate AS TransDate,
    
    -- WeekDaySort - numeric day of week
    CASE CalendarDayOfWeekName
        WHEN 'Sunday' THEN 1
        WHEN 'Monday' THEN 2
        WHEN 'Tuesday' THEN 3
        WHEN 'Wednesday' THEN 4
        WHEN 'Thursday' THEN 5
        WHEN 'Friday' THEN 6
        WHEN 'Saturday' THEN 7
        ELSE DATEPART(WEEKDAY, CalendarDate)
    END AS WeekDaySort,
    
    -- CalendarWeekDay - INT (same as WeekDaySort for this table)
    CASE CalendarDayOfWeekName
        WHEN 'Sunday' THEN 1
        WHEN 'Monday' THEN 2
        WHEN 'Tuesday' THEN 3
        WHEN 'Wednesday' THEN 4
        WHEN 'Thursday' THEN 5
        WHEN 'Friday' THEN 6
        WHEN 'Saturday' THEN 7
        ELSE DATEPART(WEEKDAY, CalendarDate)
    END AS CalendarWeekDay,
    
    -- Week - VARCHAR
    CAST(CalendarWeek AS VARCHAR(8000)) AS [Week],
    
    CalendarWeekFirstDate AS WeekStartDate,
    
    -- YearWeekSort - INT
    (CAST(CalendarYear AS INT) * 100) + CAST(CalendarWeek AS INT) AS YearWeekSort,
    
    -- Weekday - VARCHAR (3 char abbreviation)
    LEFT(CalendarDayOfWeekName, 3) AS Weekday,
    
    CAST(CalendarDayOfMonth AS INT) AS [Day],
    
    -- Month - VARCHAR
    CAST(CalendarMonth AS VARCHAR(8000)) AS [Month],
    
    -- MonthSort - INT
    (CAST(CalendarYear AS INT) * 100) + CAST(CalendarMonth AS INT) AS MonthSort,
    
    EOMONTH(CalendarDate, -1) AS PrevMonthEnd,
    
    DATEADD(DAY, -7, CalendarWeekLastDate) AS PrevEndOfWeek,
    
    -- YearQuarterSort - INT
    (CAST(CalendarYear AS INT) * 10) + CAST(CalendarQuarter AS INT) AS YearQuarterSort,
    
    -- Quarter - VARCHAR
    CAST(CalendarQuarter AS VARCHAR(8000)) AS [Quarter],
    
    -- YearMonthSort - INT
    (CAST(CalendarYear AS INT) * 100) + CAST(CalendarMonth AS INT) AS YearMonthSort,
    
    -- Year_Month - VARCHAR
    CONCAT(FORMAT(CalendarDate, 'MMM'), '-', CAST(CalendarYear AS VARCHAR(4))) AS [Year_Month],
    
    CAST(CalendarYear AS INT) AS [Year],
    
    -- Today - VARCHAR (was probably "Yes"/"No" or "1"/"0")
    CASE WHEN CalendarDate = CAST(GETDATE() AS DATE) THEN '1' ELSE '0' END AS Today,
    
    CAST(CalendarYear AS INT) AS YearKey,
    
    (CAST(CalendarYear AS INT) * 100) + CAST(CalendarMonth AS INT) AS YearMonthKey,
    
    (CAST(CalendarYear AS INT) * 10) + CAST(CalendarQuarter AS INT) AS YearQuarterKey,
    
    CAST(CONVERT(VARCHAR(8), DATEADD(YEAR, -1, CalendarDate), 112) AS INT) AS LYDateKey,
    
    CAST(CONVERT(VARCHAR(8), DATEADD(YEAR, 1, CalendarDate), 112) AS INT) AS NYDateKey,
    
    CONCAT(LEFT(CalendarMonthName, 3), '-', CAST(CalendarYear AS VARCHAR(4))) AS [Month-Year]
    
FROM [$(MasterData_Warehouse)].[MasterData_DW].[DimDate]
-- WHERE CalendarDate >= DATEFROMPARTS(YEAR(GETDATE()) - 2, 1, 1)
--       AND CalendarDate <= CAST(GETDATE() - 1 AS DATE)
WHERE CalendarDate >= '2023-01-01'
GO

