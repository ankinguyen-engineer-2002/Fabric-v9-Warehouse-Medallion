-- Auto Generated (Do not modify) CCB7E31EC7E0D0127F5E566B73E203934E30E2ECACA49D67C43F56040878AE80
/* 
09/09/2025 || Harshit S: Created View
*/
CREATE   VIEW [Retail_DW_Core_Wrk].[v_SMQQ_FactTraffic] AS 
SELECT t.StoreID AS [LocationID]
     , dat.DateID AS [TransDate]
     , t.[TransHour]
     , SUM(t.[TrafficCount]) AS Traffic
     
     -- Hours Key
     , CONCAT(CAST(t.[StoreID] AS VARCHAR(10)), 
              FORMAT(dat.DateID, 'yyyy-MM-dd'), 
              CAST(t.[TransHour] AS VARCHAR(8))) AS Hours_Key
     
     -- Key Field
     , CONCAT(FORMAT(dat.DateID, 'yyyy-MM-dd'), 
              CAST(t.[StoreID] AS VARCHAR(10))) AS Key_Field
     
     -- Trans Day of Week
     , FORMAT(dat.DateID, 'ddd') AS Trans_Day_of_Week
     
     -- Trans Day of Week Number
     , DATEPART(WEEKDAY, dat.DateID) AS Trans_Day_of_Week_Number
     
     -- Trans Year
     , YEAR(dat.DateID) AS Trans_Year
     
     -- Week of Year - Using DATEPART with ISO_WEEK for consistency
     , DATEPART(ISO_WEEK, dat.DateID) AS Week_of_Year
     
     -- WeekNum of Year - Format: YYYYWW
     , CAST(CONCAT(
         CAST(YEAR(dat.DateID) AS VARCHAR(4)),
         RIGHT('0' + CAST(DATEPART(ISO_WEEK, dat.DateID) AS VARCHAR(2)), 2)
       ) AS INT) AS WeekNum_of_Year
     
     -- Placeholder for Start Stop Filter
     , 1 AS Start_Stop_Filter

FROM [Retail_DW_Core].[FactTraffic] t
INNER JOIN [Retail_DW_Core].[DimDate] dat 
    ON t.TransDateKey = dat.DateKey
WHERE t.IsOpen = 1
      AND CAST(dat.DateID AS DATE) >= '2019-12-29'  -- Explicit CAST for safety
      AND t.[TransHour] >= 10
      AND t.[TransHour] <= 20
GROUP BY t.[StoreID]
       , dat.[DateID]
       , t.[TransHour];  -- Added for Hours_Key calculation