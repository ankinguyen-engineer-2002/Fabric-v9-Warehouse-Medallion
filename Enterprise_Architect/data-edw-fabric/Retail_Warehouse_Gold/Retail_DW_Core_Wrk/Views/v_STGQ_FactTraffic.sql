-- Auto Generated (Do not modify) B2EA98BF5A1EA34387ADEE9B7518BC2D01E4F5DE1A79D031776D1242C14D7498
/*
2025-08-27 || Harshit S:  Created View
2025-09-02 || Harshit S:  Updated: Added DAX calculated columns converted to SQL 
*/

CREATE     VIEW [Retail_DW_Core_Wrk].[v_STGQ_FactTraffic] AS
WITH EmployeeHours AS (
    SELECT D.LocationID,
           D.TransDate,
           CAST(D.TransHour AS TIME) AS TransHour,
           SUM(D.MinutesWorked) / 60.0 AS EmployeeHours,
           COUNT(DISTINCT D.EmployeeNumber) AS RSAsWorking
    FROM [Retail_DW_Core].[DMTimeSheetHours] D 
        LEFT JOIN (
            SELECT H.EmployeeNumber
            FROM [$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory] H 
            WHERE H.TransDate = (
                SELECT MAX(HH.TransDate) 
                FROM [$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory] HH 
            )
            AND H.JobID IN (307, 366, 367, 83, 256, 322, 150, 369) 
        ) E ON D.EmployeeNumber = E.EmployeeNumber
    WHERE D.TransDate >= DATEFROMPARTS(YEAR(GETDATE()) - 1, 1, 1)
        AND E.EmployeeNumber IS NOT NULL
        AND CAST(D.TransHour AS TIME) >= '09:00:00'
        AND CAST(D.TransHour AS TIME) <= '20:00:00'
    GROUP BY D.LocationID, D.TransDate, D.TransHour
),
RSAsWorkingCalc AS (
    SELECT 
        LocationID,
        CASE 
            WHEN COUNT(DISTINCT TransDate) > 0 
            THEN CAST(SUM(RSAsWorking) AS FLOAT) / COUNT(DISTINCT TransDate)
            ELSE 0.0 
        END AS RSAs_Working_Avg
    FROM EmployeeHours
    GROUP BY LocationID
)

SELECT 
    T.StoreID AS [LocationID],
    dat.DateID AS [TransDate],
    T.[TransHour],
    SUM(T.[TrafficCount]) AS Traffic,
    ISNULL(EmployeeHours.EmployeeHours, 0) AS EmployeeHours,
    ISNULL(EmployeeHours.RSAsWorking, 0) AS RSAsWorking,
    
    -- 3. Hours Key (Fixed FORMAT function)
    CONCAT(CAST(T.[StoreID] AS VARCHAR(10)), 
           CONVERT(VARCHAR(10), dat.[DateID], 120), 
           CONVERT(VARCHAR(8), T.[TransHour], 108)
           --CONVERT(VARCHAR(8), CAST(T.[TransHour] AS TIME), 108)
           ) AS Hours_Key,
    
    -- 4. Key (Fixed FORMAT function)
    CONCAT(CONVERT(VARCHAR(10), dat.[DateID], 120), '-', CAST(T.StoreID AS VARCHAR(10))) AS Key_Field,
    
    -- 5. Location (Fixed FORMAT function for LocationID padding)
    ISNULL(Loc.LocationName, CONCAT('Location ', RIGHT('000' + CAST(T.StoreID AS VARCHAR(3)), 3))) AS Location,
    
    -- 7. RSAs Working (DIVIDE equivalent)
    ISNULL(RSAsWorkingCalc.RSAs_Working_Avg, 0) AS RSAs_Working,
    
    -- 8. Trans Day of Week (Fixed FORMAT function)
    DATENAME(dw, dat.DateID) AS Trans_Day_of_Week,
    
    -- 9. Trans Day of Week # (WEEKDAY equivalent)
    DATEPART(dw, dat.DateID) AS Trans_Day_of_Week_Num,
    
    -- 10. Trans Year
    YEAR(dat.DateID) AS Trans_Year,
    
    -- 11. Week of Year
    DATEPART(wk, dat.DateID) AS Week_of_Year,
    
    -- 12. WeekNum of Year
    CONCAT(CAST(YEAR(dat.DateID) AS VARCHAR(4)), 
           CASE 
               WHEN DATEPART(wk, dat.DateID) < 10 
               THEN CONCAT('0', CAST(DATEPART(wk, dat.DateID) AS VARCHAR(1)))
               ELSE CAST(DATEPART(wk, dat.DateID) AS VARCHAR(2))
           END) AS WeekNum_of_Year

FROM [Retail_DW_Core].[FactTraffic] T
    INNER JOIN [Retail_DW_Core].[DimDate] dat 
        ON T.TransDateKey = dat.DateKey
    
    -- LEFT JOIN for Location lookup only
    LEFT JOIN [Retail_DW_Core].[STGQ_FactLocation] Loc
        ON Loc.LocationID = RIGHT('000' + CAST(T.StoreID AS VARCHAR(3)), 3)
    
    -- Employee Hours calculation
    LEFT JOIN EmployeeHours
        ON T.StoreID = EmployeeHours.LocationID
           AND dat.DateID = EmployeeHours.TransDate
           AND T.TransHour = DATEPART(hour, EmployeeHours.TransHour)
    
    -- RSAs Working calculation
    LEFT JOIN RSAsWorkingCalc 
        ON RSAsWorkingCalc.LocationID = T.StoreID

WHERE dat.DateID >= DATEFROMPARTS(YEAR(GETDATE()) - 1, 1, 1)
    AND T.TransHour >= 9
    AND T.TransHour <= 20

GROUP BY T.[StoreID],
         dat.[DateID],
         T.TransHour,
         ISNULL(EmployeeHours.EmployeeHours, 0),
         ISNULL(EmployeeHours.RSAsWorking, 0),
         Loc.LocationName,
         RSAsWorkingCalc.RSAs_Working_Avg;