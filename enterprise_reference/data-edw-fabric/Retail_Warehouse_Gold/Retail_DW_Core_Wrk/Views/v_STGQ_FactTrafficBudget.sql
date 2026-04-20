-- Auto Generated (Do not modify) EB68E210F52672C7D4EAE3C0BF6102444A4BD934E4B99EE363F0B65977836EDC

/*
2025-08-27 || Harshit S:  Created View
2025-09-08 || Harshit S:  Updated: Added DAX calculated columns converted to SQL 
*/

CREATE     VIEW [Retail_DW_Core_Wrk].[v_STGQ_FactTrafficBudget] AS
WITH SatWeekEnding AS (
    SELECT TB.*,
           CASE 
               WHEN DATEPART(dw, TB.[TransDate]) > 1 
               THEN DATEADD(DAY, 8 - DATEPART(dw, TB.[TransDate]), TB.[TransDate])
               ELSE TB.[TransDate]
           END AS Sat_Week_Ending_Calc,
           DATEADD(DAY, 7 - DATEPART(dw, TB.[TransDate]), TB.[TransDate]) AS Week_Ending_Calc,
           -- Added Week of Year calculation
           DATEPART(week, TB.[TransDate]) AS Week_of_Year_Calc
    FROM [Retail_DW_Core].[FactTrafficandCloseBudget] TB
)

SELECT TB.StoreID AS [LocationID],
       TB.[TransDate],
       TB.[TUGoal],
       T.TrafficGuest,
       CASE 
           WHEN EmployeesWorking.NumDays > 0 
           THEN EmployeesWorking.RSAsWorking * 1.0 / EmployeesWorking.NumDays 
           ELSE 0 
       END AS NumOfRSAs,
       
       -- Key = TrafficBudget[TransDate] & "-" & VALUE(TrafficBudget[LocationID])
       CONCAT(CONVERT(VARCHAR(10), TB.[TransDate], 120), '-', CAST(TB.StoreID AS VARCHAR(10))) AS Key_Field,
       
       -- Location Name
       ISNULL(Loc.LocationName, CONCAT('Location ', TB.StoreID)) AS Location_Name,
       
       -- EmployeeHours
       ISNULL(EmpHours.EmployeeHours, 0) AS EmployeeHours,
       
       -- Display (placeholder)
       1 AS Display,
       
       -- Month of Year
       CONCAT(CAST(YEAR(TB.[TransDate]) AS VARCHAR(4)), 
              RIGHT('0' + CAST(MONTH(TB.[TransDate]) AS VARCHAR(2)), 2)) AS Month_of_Year,
       
       -- Quarter of Year = YEAR(TrafficBudget[TransDate]) & "Q" & TrafficBudget[TransDate].[QuarterNo]
       CONCAT(CAST(YEAR(TB.[TransDate]) AS VARCHAR(4)), 'Q', CAST(DATEPART(quarter, TB.[TransDate]) AS VARCHAR(1))) AS Quarter_of_Year,
       
       -- Sat Week Ending
       TB.Sat_Week_Ending_Calc AS Sat_Week_Ending,
       
       -- Sat Week Ending Year
       YEAR(TB.Sat_Week_Ending_Calc) AS Sat_Week_Ending_Year,
       
       -- Sat Week of Year
       DATEPART(wk, TB.Sat_Week_Ending_Calc) AS Sat_Week_of_Year,
       
       -- Sat WeekNum of Year
       CONCAT(CAST(YEAR(TB.Sat_Week_Ending_Calc) AS VARCHAR(4)),
              RIGHT('0' + CAST(DATEPART(wk, TB.Sat_Week_Ending_Calc) AS VARCHAR(2)), 2)) AS Sat_WeekNum_of_Year,
       
       -- TransDate Filter
       CASE WHEN TB.[TransDate] < CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END AS TransDate_Filter,
       
       -- Week Ending
       TB.Week_Ending_Calc AS Week_Ending,
       
       -- Week Ending Location Key
       CONCAT(CONVERT(VARCHAR(10), TB.Week_Ending_Calc, 120), CAST(TB.StoreID AS VARCHAR(10))) AS Week_Ending_Location_Key,
       
       -- Week of Year (Added from DAX)
       TB.Week_of_Year_Calc AS Week_of_Year,
       
       -- WeekNum of Year (Added from DAX) as INTEGER
       CAST(CONCAT(CAST(YEAR(TB.[TransDate]) AS VARCHAR(4)),
                   RIGHT('0' + CAST(TB.Week_of_Year_Calc AS VARCHAR(2)), 2)) AS INT) AS WeekNum_of_Year,
       
       -- Week of Year (original calculation - keeping for backward compatibility)
       DATEPART(wk, TB.[TransDate]) AS Week_of_Year_Original,
       
       -- Year
       YEAR(TB.[TransDate]) AS Year_Field

FROM SatWeekEnding TB
    LEFT JOIN (
        SELECT T.StoreID AS LocationID,
               dat.DateID AS TransDate,
               SUM(T.TrafficCount) AS TrafficGuest
        FROM [Retail_DW_Core].[FactTraffic] T 
        INNER JOIN [Retail_DW_Core].[DimDate] dat
            ON T.TransDateKey = dat.DateKey
        WHERE dat.DateID >= DATEFROMPARTS(YEAR(GETDATE()) - 1, 1, 1)
        GROUP BY T.StoreID, dat.DateID
    ) T
        ON TB.StoreID = T.LocationID
           AND TB.TransDate = T.TransDate
    LEFT JOIN (
        SELECT D.LocationID,
               DATEADD(DAY, 7 - DATEPART(WEEKDAY, D.TransDate), D.TransDate) AS WeekEnding,
               COUNT(DISTINCT D.TransDate) AS NumDays,
               COUNT(DISTINCT E.EmployeeNumber) AS RSAsWorking
        FROM [Retail_DW_Core].[DMTimeSheetHours] D 
            LEFT JOIN [$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory] E 
                ON D.EmployeeNumber = E.EmployeeNumber
                   AND D.TransDate = E.TransDate
        WHERE D.TransDate >= DATEFROMPARTS(YEAR(GETDATE()) - 1, 1, 1)
              AND D.IsOpen = 1
              AND E.EmployeeNumber IS NOT NULL
              AND CAST(D.TransHour AS TIME) >= '10:00:00'
              AND CAST(D.TransHour AS TIME) <= '20:00:00'
              AND E.JobID IN (6, 15, 83, 150, 203, 256, 307, 322, 366, 367, 368, 369, 421)
        GROUP BY D.LocationID, DATEADD(DAY, 7 - DATEPART(WEEKDAY, D.TransDate), D.TransDate)
    ) EmployeesWorking 
        ON T.LocationID = EmployeesWorking.LocationID
           AND TB.Week_Ending_Calc = EmployeesWorking.WeekEnding
    
    -- Location lookup
    LEFT JOIN [Retail_DW_Core].[STGQ_FactLocation] Loc
        ON CAST(Loc.LocationID AS VARCHAR(10)) = CAST(TB.StoreID AS VARCHAR(10))

    -- EmployeeHours lookup
    LEFT JOIN [Retail_DW_Core].[STGQ_FactEmployeeHours] EmpHours
        ON CAST(EmpHours.LocationID AS VARCHAR(10)) = CAST(TB.StoreID AS VARCHAR(10))
       AND EmpHours.TransDate = TB.TransDate

WHERE TB.TransDate >= DATEFROMPARTS(YEAR(GETDATE()) - 1, 1, 1);