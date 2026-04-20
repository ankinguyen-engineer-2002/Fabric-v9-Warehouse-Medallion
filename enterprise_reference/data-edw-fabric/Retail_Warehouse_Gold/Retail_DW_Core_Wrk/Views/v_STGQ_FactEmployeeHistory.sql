-- Auto Generated (Do not modify) 84EA0669A95B8719857B4974A54D75CBEB9E929B880D2C0EFE8BE3221027ABAF
/*
2025-08-27 || Harshit S:  Created View
2025-09-02 || Harshit S:  Updated: Added DAX calculated columns converted to SQL 
*/

CREATE VIEW [Retail_DW_Core_Wrk].[v_STGQ_FactEmployeeHistory] AS

SELECT  H.[EmployeeID]
     , RIGHT(H.[EmployeeNumber], 6) AS EmployeeNumber
     , RIGHT(H.[SupID], 6)          AS SupID
     , UPPER(H.[FirstName])         AS FirstName
     , UPPER(H.[LastName])          AS LastName
     , H.[EmpStatus]
     , H.[Email]
     , H.[EmpHourlySalary]
     , H.[EmpFTPT]
     , H.[EmpAddressCity]
     , H.[EmpAddressState]
     , H.[EmpAddressZip]
     , H.[HireDate]
     , H.[LocationID]
     , H.[JobID]
     , H.[DivisionID]
     , H.[DepartmentID]
     , H.[RegionID]
     , H.[EmployeeTypeID]
     , H.[SepCode]
     , H.[SepType]
     , H.[SepReason]
     , H.[SepDate]
     , H.[TransDate]
     , CASE
           WHEN YEAR(H.BirthDate) <= 1945 THEN 'Silent'
           WHEN YEAR(H.BirthDate) <= 1964 THEN 'Baby Boomer'
           WHEN YEAR(H.BirthDate) <= 1980 THEN 'Generation X'
           WHEN YEAR(H.BirthDate) <= 1996 THEN 'Millennial'
           ELSE 'Generation Z'
       END AS Generation
     , MAX(H.TransDate) OVER () AS Latest_Run
     , CASE 
           WHEN H.TransDate = MAX(H.TransDate) OVER () THEN 1 
           ELSE 0 
       END AS Is_Latest_Run
     
     -- 1. Head Count LOA
     , CASE 
           WHEN H.[EmpStatus] = 'L' THEN 1 
           ELSE 0 
       END AS Head_Count_LOA
     
     -- 2. Week Ending
     , DATEADD(DAY, 7 - DATEPART(dw, H.[TransDate]), H.[TransDate]) AS Week_Ending
     
     -- 3. Tenure Days
     , CASE 
           WHEN H.[EmpStatus] = 'T' THEN DATEDIFF(DAY, H.[HireDate], H.[SepDate])
           ELSE DATEDIFF(DAY, H.[HireDate], H.[TransDate])
       END AS Tenure_Days
     
     -- 4. Tenure Months (based on Tenure Days)
     , CASE 
           WHEN (CASE 
                   WHEN H.[EmpStatus] = 'T' THEN DATEDIFF(DAY, H.[HireDate], H.[SepDate])
                   ELSE DATEDIFF(DAY, H.[HireDate], H.[TransDate])
                 END) <= 30 THEN '000 - 030 Days'
           WHEN (CASE 
                   WHEN H.[EmpStatus] = 'T' THEN DATEDIFF(DAY, H.[HireDate], H.[SepDate])
                   ELSE DATEDIFF(DAY, H.[HireDate], H.[TransDate])
                 END) <= 90 THEN '031 - 090 Days'
           WHEN (CASE 
                   WHEN H.[EmpStatus] = 'T' THEN DATEDIFF(DAY, H.[HireDate], H.[SepDate])
                   ELSE DATEDIFF(DAY, H.[HireDate], H.[TransDate])
                 END) <= 180 THEN '091 - 180 Days'
           WHEN (CASE 
                   WHEN H.[EmpStatus] = 'T' THEN DATEDIFF(DAY, H.[HireDate], H.[SepDate])
                   ELSE DATEDIFF(DAY, H.[HireDate], H.[TransDate])
                 END) <= 365 THEN '181 - 365 Days'
           ELSE '366+ Days'
       END AS Tenure_Months
     
     -- 5. MonthNo
     , MONTH(H.[HireDate]) AS MonthNo
     
     -- 6. Is RSA (using integer JobID values)
     , CASE 
           WHEN H.[JobID] IN (307, 366, 367, 83, 256, 322, 150, 369) THEN 1 
           ELSE 0 
       END AS Is_RSA
     
     -- 7. Hire Week
     , DATEADD(DAY, 7 - DATEPART(dw, H.[HireDate]), H.[HireDate]) AS Hire_Week
     
     -- 9. Head Count
     , CASE 
           WHEN H.[EmpStatus] = 'A' THEN 1 
           ELSE 0 
       END AS Head_Count
     
     -- 10. FT Equivalent LOA
     , CASE 
           WHEN H.[EmpStatus] = 'L' THEN 
               CASE WHEN H.[EmpFTPT] = 'F' THEN 1.0 ELSE 0.5 END
           ELSE 0 
       END AS FT_Equivalent_LOA
     
     -- 11. FT Equivalent
     , CASE 
           WHEN H.[EmpStatus] = 'A' THEN 
               CASE WHEN H.[EmpFTPT] = 'F' THEN 1.0 ELSE 0.5 END
           ELSE 0 
       END AS FT_Equivalent
     
     -- 12. Date Location Key
     , CONCAT(H.[TransDate], '-', H.[LocationID]) AS Date_Location_Key
     
     -- 13. CY Separations
     , CASE 
           WHEN YEAR(H.[SepDate]) = YEAR(H.[TransDate]) THEN 1 
           ELSE 0 
       END AS CY_Separations
     
     -- 14. CY Hires
     , CASE 
           WHEN YEAR(H.[HireDate]) = YEAR(H.[TransDate]) THEN 1 
           ELSE 0 
       END AS CY_Hires
     
     -- Separation Week (using the provided DAX logic)
     , DATEADD(DAY, 7 - DATEPART(dw, H.[SepDate]), H.[SepDate]) AS Separation_Week
     
     -- 15. CW Separations
     , CASE 
           WHEN H.TransDate = MAX(H.TransDate) OVER ()
                AND DATEADD(DAY, 7 - DATEPART(dw, H.[SepDate]), H.[SepDate]) = DATEADD(DAY, 7 - DATEPART(dw, H.[TransDate]), H.[TransDate])
           THEN 1 
           ELSE 0 
       END AS CW_Separations
     
     -- 16. CW Hires
     , CASE 
           WHEN H.TransDate = MAX(H.TransDate) OVER ()
                AND DATEADD(DAY, 7 - DATEPART(dw, H.[HireDate]), H.[HireDate]) = DATEADD(DAY, 7 - DATEPART(dw, H.[TransDate]), H.[TransDate])
           THEN 1 
           ELSE 0 
       END AS CW_Hires

FROM [$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory] H 
INNER JOIN [$(Source_Data)].[Retail_Miniapps].[PeopleRecords] P 
    ON P.EmployeeNumber = H.EmployeeNumber
WHERE H.TransDate IN (
          SELECT DISTINCT TransDate
          FROM [$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory]
          WHERE DATEPART(dw, TransDate) = 7
                OR CONVERT(CHAR(10), TransDate, 101) = CONVERT(CHAR(10), GETDATE() - 1, 101)
      )
      AND H.TransDate >= DATEFROMPARTS(YEAR(GETDATE()) - 1, 1, 1)
      AND (
          H.SepDate >= DATEFROMPARTS(YEAR(GETDATE()) - 1, 1, 1)
          OR H.SepDate IS NULL
      )
      --AND P.InHRSystem = 1;