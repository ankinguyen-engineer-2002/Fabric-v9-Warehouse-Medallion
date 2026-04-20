-- Auto Generated (Do not modify) E8044095A4BA6BA470F19610BDCCE4D7408EA31DB4B9E322E671D589B15474B1

/*
2025-08-27 || Harshit S:  Created View
*/

CREATE   VIEW [Retail_DW_Core_Wrk].[v_STGQ_FactTrafficBudgetLocations] AS
SELECT distinct([LocationID])
FROM 
(SELECT TB.StoreID AS [LocationID]
     , TB.[TransDate]
     , TB.[TUGoal]
     , T.TrafficGuest
     , EmployeesWorking.RSAsWorking * 1.0 / EmployeesWorking.NumDays AS NumOfRSAs
FROM [Retail_DW_Core].[FactTrafficandCloseBudget] TB 
    LEFT JOIN
    (
        SELECT T.StoreID AS LocationID
             , dat.DateID AS TransDate
             , SUM(T.TrafficCount) AS TrafficGuest
        FROM [Retail_DW_Core].[FactTraffic] T 
        INNER JOIN [Retail_DW_Core].[DimDate] as dat
            on T.TransDateKey= dat.DateKey
        WHERE dat.DateID >= DATEFROMPARTS(YEAR(GETDATE()) - 1, 1, 1)
        GROUP BY T.StoreID, dat.DateID
    )                                       T
        ON TB.StoreID = T.LocationID
           AND TB.TransDate = T.TransDate
    LEFT JOIN
    (
        SELECT D.LocationID
             , DATEADD(DAY, 7 - DATEPART(WEEKDAY, D.TransDate), D.TransDate) AS WeekEnding
             , COUNT(DISTINCT D.TransDate)                                   AS NumDays
             , COUNT(DISTINCT (E.EmployeeNumber))                            AS RSAsWorking
        FROM [Retail_DW_Core].[DMTimeSheetHours]          D 
            LEFT JOIN [$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory] E 
                ON D.EmployeeNumber = E.EmployeeNumber
                   AND D.TransDate = E.TransDate
            LEFT JOIN [$(Databricks)].[masterdata_hr_ukg_dsg].[hrjobs]            J 
                ON E.JobID = J.JobID
        WHERE D.TransDate >= DATEFROMPARTS(YEAR(GETDATE()) - 1, 1, 1)
              AND D.IsOpen = 1
              AND E.EmployeeNumber IS NOT NULL
              AND CAST(D.TransHour AS TIME) >= '10:00:00'
              AND CAST(D.TransHour AS TIME) <= '20:00:00'
              AND E.JobID IN ( '6', '15', '83', '150', '203', '256', '307', '322', '366', '367', '368'
                                     , '369', '421'
                                     )
			  --( '108', '128', '129', '130', '160', '179', '294', '295', '296', '297', '308', '309'
     --                        , '310', '311', '312', '338', '339', '340'
     --                        )
        GROUP BY D.LocationID, DATEADD(DAY, 7 - DATEPART(WEEKDAY, D.TransDate), D.TransDate)
    ) EmployeesWorking 
        ON T.LocationID = EmployeesWorking.LocationID
           AND DATEADD(DAY, 7 - DATEPART(WEEKDAY, T.TransDate), T.TransDate) = EmployeesWorking.WeekEnding
WHERE TB.TransDate >= DATEFROMPARTS(YEAR(GETDATE()) - 1, 1, 1)) temp
