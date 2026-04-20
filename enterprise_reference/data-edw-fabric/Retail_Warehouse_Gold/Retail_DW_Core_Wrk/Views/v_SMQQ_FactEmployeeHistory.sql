-- Auto Generated (Do not modify) 8C18D895156489EC0401204542B8712128DD0EB01DFA05F2CF477B8B9A8FD357
/* 
09/09/2025 || Harshit S: Created View
*/
CREATE     VIEW [Retail_DW_Core_Wrk].[v_SMQQ_FactEmployeeHistory] AS
WITH LatestRun AS (
    SELECT MAX(TransDate) AS Latest_Run_Date
    FROM [$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory]
)
SELECT [EmployeeID]
     , RIGHT([EmployeeNumber], 6) AS EmployeeNumber
     , RIGHT([SupID], 6) AS SupID
     , UPPER([FirstName]) AS FirstName
     , UPPER([LastName])  AS LastName
     , [EmpStatus]
     , [Email]
     , [EmpHourlySalary]
     , [EmpFTPT]
     , [EmpAddressCity]
     , [EmpAddressState]
     , [EmpAddressZip]
     , [HireDate]
     , [LocationID]
     , [JobID]
     , [DivisionID]
     , [DepartmentID]
     , [RegionID]
     , [EmployeeTypeID]
     , [SepCode]
     , [SepType]
     , [SepReason]
     , [SepDate]
     , [TransDate]
     , CASE
           WHEN YEAR(BirthDate) <= 1945 THEN 'Silent'
           WHEN YEAR(BirthDate) <= 1964 THEN 'Baby Boomer'
           WHEN YEAR(BirthDate) <= 1980 THEN 'Generation X'
           WHEN YEAR(BirthDate) <= 1996 THEN 'Millennial'
           ELSE 'Generation Z'
       END AS Generation
     
     -- Week Ending = 'Employee History'[TransDate] + 7 - WEEKDAY('Employee History'[TransDate])
     , DATEADD(DAY, 7 - DATEPART(WEEKDAY, [TransDate]), [TransDate]) AS Week_Ending
     
     -- Tenure Days = IF('Employee History'[EmpStatus] = "T", 'Employee History'[SepDate] - 'Employee History'[HireDate], 'Employee History'[TransDate] - 'Employee History'[HireDate])
     , CASE 
           WHEN [EmpStatus] = 'T' THEN DATEDIFF(DAY, [HireDate], [SepDate])
           ELSE DATEDIFF(DAY, [HireDate], [TransDate])
       END AS Tenure_Days
     
     -- Tenure Months based on Tenure Days
     , CASE 
           WHEN (CASE WHEN [EmpStatus] = 'T' THEN DATEDIFF(DAY, [HireDate], [SepDate]) ELSE DATEDIFF(DAY, [HireDate], [TransDate]) END) <= 30 THEN '000 - 030 Days'
           WHEN (CASE WHEN [EmpStatus] = 'T' THEN DATEDIFF(DAY, [HireDate], [SepDate]) ELSE DATEDIFF(DAY, [HireDate], [TransDate]) END) <= 90 THEN '031 - 090 Days'
           WHEN (CASE WHEN [EmpStatus] = 'T' THEN DATEDIFF(DAY, [HireDate], [SepDate]) ELSE DATEDIFF(DAY, [HireDate], [TransDate]) END) <= 180 THEN '091 - 180 Days'
           WHEN (CASE WHEN [EmpStatus] = 'T' THEN DATEDIFF(DAY, [HireDate], [SepDate]) ELSE DATEDIFF(DAY, [HireDate], [TransDate]) END) <= 365 THEN '181 - 365 Days'
           ELSE '366+ Days'
       END AS Tenure_Months
     
     -- Separation Week = 'Employee History'[SepDate] + 7 - WEEKDAY('Employee History'[SepDate])
     , CASE 
           WHEN [SepDate] IS NOT NULL THEN DATEADD(DAY, 7 - DATEPART(WEEKDAY, [SepDate]), [SepDate])
           ELSE NULL
       END AS Separation_Week
     
     -- MonthNo = 'Employee History'[HireDate].[MonthNo]
     , MONTH([HireDate]) AS MonthNo
     
     -- Is RSA = IF('Employee History'[JobID] IN {108, 128, 129, 130, 160, 179, 294, 295, 296, 297, 308, 309, 310, 311, 338, 339, 340, 312}, 1, 0)
     , CASE 
           WHEN [JobID] IN (108, 128, 129, 130, 160, 179, 294, 295, 296, 297, 308, 309, 310, 311, 338, 339, 340, 312) THEN 1
           ELSE 0
       END AS Is_RSA
     
     -- Is Latest Run = IF('Employee History'[TransDate] = [Latest Run], 1, 0)
     , CASE 
           WHEN [TransDate] = lr.Latest_Run_Date THEN 1
           ELSE 0
       END AS Is_Latest_Run
     
     -- Hire Week = 'Employee History'[HireDate] + 7 - WEEKDAY('Employee History'[HireDate])
     , DATEADD(DAY, 7 - DATEPART(WEEKDAY, [HireDate]), [HireDate]) AS Hire_Week
     
     -- Head Count = IF('Employee History'[EmpStatus] <> "T", 1, 0)
     , CASE 
           WHEN [EmpStatus] <> 'T' THEN 1
           ELSE 0
       END AS Head_Count
     
     -- GRT Key = 'Employee History'[LocationID] & 'Employee History'[JobID]
     , CONCAT(CAST([LocationID] AS VARCHAR(10)), CAST([JobID] AS VARCHAR(10))) AS GRT_Key
     
     -- FT Equivalent = IF('Employee History'[EmpStatus] <> "T", IF('Employee History'[EmpFTPT] = "F", 1, 0.5), 0)
     , CASE 
           WHEN [EmpStatus] <> 'T' THEN 
               CASE WHEN [EmpFTPT] = 'F' THEN 1.0 ELSE 0.5 END
           ELSE 0.0
       END AS FT_Equivalent
     
     -- CY Separations = IF(YEAR('Employee History'[SepDate]) = YEAR('Employee History'[TransDate]), 1, 0)
     , CASE 
           WHEN YEAR([SepDate]) = YEAR([TransDate]) THEN 1
           ELSE 0
       END AS CY_Separations
     
     -- CY Hires = IF(YEAR('Employee History'[HireDate]) = YEAR('Employee History'[TransDate]), 1, 0)
     , CASE 
           WHEN YEAR([HireDate]) = YEAR([TransDate]) THEN 1
           ELSE 0
       END AS CY_Hires
     
     -- CW Separations = IF(AND('Employee History'[Is Latest Run] = 1, 'Employee History'[Separation Week] = 'Employee History'[Week Ending]), 1, 0)
     , CASE 
           WHEN [TransDate] = lr.Latest_Run_Date 
                AND [SepDate] IS NOT NULL 
                AND DATEADD(DAY, 7 - DATEPART(WEEKDAY, [SepDate]), [SepDate]) = DATEADD(DAY, 7 - DATEPART(WEEKDAY, [TransDate]), [TransDate])
           THEN 1
           ELSE 0
       END AS CW_Separations
     
     -- CW Hires = IF(AND('Employee History'[Is Latest Run] = 1, 'Employee History'[Hire Week] = 'Employee History'[Week Ending]), 1, 0)
     , CASE 
           WHEN [TransDate] = lr.Latest_Run_Date 
                AND DATEADD(DAY, 7 - DATEPART(WEEKDAY, [HireDate]), [HireDate]) = DATEADD(DAY, 7 - DATEPART(WEEKDAY, [TransDate]), [TransDate])
           THEN 1
           ELSE 0
       END AS CW_Hires

FROM [$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory] eh
CROSS JOIN LatestRun lr
WHERE eh.TransDate = lr.Latest_Run_Date