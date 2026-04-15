-- Auto Generated (Do not modify) 981A1DDA9E362D7DA8B07853AEBC387DDF776EEF5226052E3CC888C7F9488A23
/* 
Created by Harshit S on 09/09/2025
*/

CREATE     VIEW [Retail_DW_Core_Wrk].[v_SMQQ_FactTrafficBudget] AS 

SELECT tb.[StoreID]
     , tb.[TransDate]
     , tb.[TUGoal]
     
     -- Year = YEAR(TrafficBudget[TransDate])
     , YEAR(tb.[TransDate]) AS Year_Field
     
     -- Week Ending = IF(WEEKDAY(TrafficBudget[TransDate]) > 1, TrafficBudget[TransDate] + 8 - WEEKDAY(TrafficBudget[TransDate]), TrafficBudget[TransDate])
     , CASE 
           WHEN DATEPART(WEEKDAY, tb.[TransDate]) > 1 
           THEN DATEADD(DAY, 8 - DATEPART(WEEKDAY, tb.[TransDate]), tb.[TransDate])
           ELSE tb.[TransDate]
       END AS Week_Ending
     
     -- Week of Year = WEEKNUM(TrafficBudget[Week Ending])
     , DATEPART(WEEK, 
           CASE 
               WHEN DATEPART(WEEKDAY, tb.[TransDate]) > 1 
               THEN DATEADD(DAY, 8 - DATEPART(WEEKDAY, tb.[TransDate]), tb.[TransDate])
               ELSE tb.[TransDate]
           END) AS Week_of_Year
     
     -- WeekNum of Year = YEAR(TrafficBudget[Week Ending]) & IF(TrafficBudget[Week of Year] < 10, "0") & TrafficBudget[Week of Year]
     , CAST(CONCAT(
           CAST(YEAR(CASE 
               WHEN DATEPART(WEEKDAY, tb.[TransDate]) > 1 
               THEN DATEADD(DAY, 8 - DATEPART(WEEKDAY, tb.[TransDate]), tb.[TransDate])
               ELSE tb.[TransDate]
           END) AS VARCHAR(4)),
           RIGHT('0' + CAST(DATEPART(WEEK, 
               CASE 
                   WHEN DATEPART(WEEKDAY, tb.[TransDate]) > 1 
                   THEN DATEADD(DAY, 8 - DATEPART(WEEKDAY, tb.[TransDate]), tb.[TransDate])
                   ELSE tb.[TransDate]
               END) AS VARCHAR(2)), 2)
       ) AS INT) AS WeekNum_of_Year
     
     -- Week Ending Location Key = TrafficBudget[Week Ending] & VALUE(TrafficBudget[LocationID])
     , CONCAT(
           CONVERT(VARCHAR(10), 
               CASE 
                   WHEN DATEPART(WEEKDAY, tb.[TransDate]) > 1 
                   THEN DATEADD(DAY, 8 - DATEPART(WEEKDAY, tb.[TransDate]), tb.[TransDate])
                   ELSE tb.[TransDate]
               END, 120),
           CAST(tb.[StoreID] AS VARCHAR(10))
       ) AS Week_Ending_Location_Key
     
     -- TransDate Filter = IF(TrafficBudget[TransDate] < TODAY(), 1, 0)
     , CASE 
           WHEN tb.[TransDate] < CAST(GETDATE() AS DATE) THEN 1
           ELSE 0
       END AS TransDate_Filter
     
     -- Key = TrafficBudget[TransDate] & VALUE(TrafficBudget[LocationID])
     , CONCAT(CONVERT(VARCHAR(10), tb.[TransDate], 120), 
              CAST(tb.[StoreID] AS VARCHAR(10))) AS Key_Field
     
     -- Start End Filter = IF(AND(TrafficBudget[WeekNum of Year] >= [Start Week], TrafficBudget[WeekNum of Year] <= [End Week]), 1, 0)
     -- Note: Placeholder since parameters are not available in views
     , 1 AS Start_End_Filter
     
     -- Quarter of Year = YEAR(TrafficBudget[TransDate]) & "Q" & TrafficBudget[TransDate].[QuarterNo]
     , CONCAT(CAST(YEAR(tb.[TransDate]) AS VARCHAR(4)), 'Q', 
              CAST(DATEPART(QUARTER, tb.[TransDate]) AS VARCHAR(1))) AS Quarter_of_Year
     
     -- Month of Year = YEAR(TrafficBudget[TransDate]) & IF(MONTH(TrafficBudget[TransDate]) < 10, "0") & MONTH(TrafficBudget[TransDate])
     , CONCAT(CAST(YEAR(tb.[TransDate]) AS VARCHAR(4)),
              RIGHT('0' + CAST(MONTH(tb.[TransDate]) AS VARCHAR(2)), 2)) AS Month_of_Year
     
     -- RSA Hours = LOOKUPVALUE('RSA Hours'[EmployeeHours], 'RSA Hours'[Date_Location_Key], TrafficBudget[Key])
     , ISNULL(rsa.EmployeeHours, 0) AS RSA_Hours
     
     -- # of RSAs = LOOKUPVALUE('RSA Hours'[TotalEmployees], 'RSA Hours'[Date_Location_Key], TrafficBudget[Key])
     , ISNULL(rsa.TotalEmployees, 0) AS Number_of_RSAs
     
     -- Display = IF(AND(TrafficBudget[WeekNum of Year] >= [WeekNum Start], TrafficBudget[WeekNum of Year] <= [WeekNum Display]), 1, 0)
     -- Note: Placeholder since parameters are not available in views
     , 1 AS Display_Field
     
     -- Traffic = CALCULATE(SUM(Traffic[Traffic]), FILTER(Traffic, Traffic[Key] = TrafficBudget[Key]))
     , ISNULL(tf.Traffic_Sum, 0) AS Traffic
     
     -- Hours / RSA = TrafficBudget[RSA Hours] / TrafficBudget[# of RSAs]
     , CASE 
           WHEN ISNULL(rsa.TotalEmployees, 0) > 0 
           THEN ISNULL(rsa.EmployeeHours, 0) / ISNULL(rsa.TotalEmployees, 0)
           ELSE 0
       END AS Hours_per_RSA
     
     -- Current Headcount = CALCULATE(SUM(Stores[Head Count]), FILTER(Stores, Stores[LocationID] = EARLIER(TrafficBudget[LocationID])))
     , ISNULL(stores.Head_Count, 0) AS Current_Headcount

FROM [Retail_DW_Core].[FactTrafficandCloseBudget] tb

    -- LEFT JOIN for RSA Hours lookup
    LEFT JOIN [Retail_DW_Core_Wrk].[v_SMQQ_FactRSAHours] rsa
        ON rsa.Date_Location_Key = CONCAT(CONVERT(VARCHAR(10), tb.[TransDate], 120), 
                                         CAST(tb.[StoreID] AS VARCHAR(10)))

    -- LEFT JOIN for Traffic lookup (aggregated)
    LEFT JOIN (
        SELECT Key_Field,
               SUM(Traffic) AS Traffic_Sum
        FROM [Retail_DW_Core_Wrk].[v_SMQQ_FactTraffic]
        GROUP BY Key_Field
    ) tf ON tf.Key_Field = CONCAT(CONVERT(VARCHAR(10), tb.[TransDate], 120), 
                                  CAST(tb.[StoreID] AS VARCHAR(10)))
    
    -- LEFT JOIN for Stores Summary lookup (Current Headcount)
    LEFT JOIN [Retail_DW_Core].[SMQQ_Stores_Summary] stores
        ON stores.LocationID = tb.[StoreID]

WHERE tb.TransDate >= '2019-12-29'