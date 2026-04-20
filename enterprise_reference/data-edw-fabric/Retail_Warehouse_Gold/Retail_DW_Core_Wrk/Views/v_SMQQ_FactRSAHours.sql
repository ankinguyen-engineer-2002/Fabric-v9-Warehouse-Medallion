-- Auto Generated (Do not modify) CDA877F47D6C7E9CC05F832D649A6685062F3B7D277006C505891DB2510A6117
/* 
Created by Harshit S on 09/09/2025
*/

CREATE     VIEW [Retail_DW_Core_Wrk].[v_SMQQ_FactRSAHours] AS 

SELECT D.LocationID
     , D.TransDate
     , SUM(D.MinutesWorked) / 60.0 AS EmployeeHours
     , COUNT(DISTINCT D.EmployeeNumber) AS TotalEmployees
     
     -- Date Location Key = 'RSA Hours'[TransDate] & VALUE('RSA Hours'[LocationID])
     , CONCAT(CONVERT(VARCHAR(10), D.TransDate, 120), CAST(D.LocationID AS VARCHAR(10))) AS Date_Location_Key
     
     -- Week Ending = 'RSA Hours'[TransDate] + 7 - WEEKDAY('RSA Hours'[TransDate])
     , DATEADD(DAY, 7 - DATEPART(WEEKDAY, D.TransDate), D.TransDate) AS Week_Ending
     
     -- Week Ending Location Key = 'RSA Hours'[Week Ending] & 'RSA Hours'[LocationID]
     , CONCAT(CONVERT(VARCHAR(10), DATEADD(DAY, 7 - DATEPART(WEEKDAY, D.TransDate), D.TransDate), 120), 
              CAST(D.LocationID AS VARCHAR(10))) AS Week_Ending_Location_Key
     
     -- Week of Year = WEEKNUM('RSA Hours'[TransDate])
     , DATEPART(WEEK, D.TransDate) AS Week_of_Year
     
     -- WeekNum of Year = YEAR('RSA Hours'[TransDate]) & IF('RSA Hours'[Week of Year] < 10, "0") & 'RSA Hours'[Week of Year]
     , CAST(CONCAT(CAST(YEAR(D.TransDate) AS VARCHAR(4)),
                   RIGHT('0' + CAST(DATEPART(WEEK, D.TransDate) AS VARCHAR(2)), 2)) AS INT) AS WeekNum_of_Year

FROM [Retail_DW_Core].[DMTimeSheetHours] D
    LEFT JOIN [$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory] E
        ON D.EmployeeNumber = E.EmployeeNumber
           AND D.TransDate = E.TransDate
    LEFT JOIN [Retail_DW_Core].[DimHRJobs] J
        ON E.JobID = J.JobID
WHERE D.TransDate >= '2019-12-29'
      AND D.IsOpen = 1
      AND E.EmployeeNumber IS NOT NULL
      AND CAST(D.TransHour AS TIME) >= '10:00:00'
      AND CAST(D.TransHour AS TIME) <= '20:00:00'
      AND E.JobID IN ( '108', '128', '129', '130', '160', '179', '294', '295', '296', '297',
                       '308', '309', '310', '311', '338', '339', '340' )
GROUP BY D.LocationID
       , D.TransDate