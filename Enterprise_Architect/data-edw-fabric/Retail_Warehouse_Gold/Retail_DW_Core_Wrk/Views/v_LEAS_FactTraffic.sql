-- Auto Generated (Do not modify) 47381EB2AFD935056ED1E5486BE9F0EA931CD0977A7F230BE24BF7A118853E8E

/*
2025-08-26 || Harshit S: Created View
*/

CREATE    VIEW [Retail_DW_Core_Wrk].[v_LEAS_FactTraffic] AS
SELECT tr.StoreID AS [LocationID]
      ,d.DateID AS [TransDate]
      ,SUM(tr.[TrafficCount]) as TrafficGuest
  FROM [Retail_DW_Core].[FactTraffic] as tr
  left join [Retail_DW_Core].[DimDate] as d 
  on tr.[TransDateKey] = d.[DateKey]
  WHERE tr.[TrafficCount] > 0 AND
        d.DateID >= DATEFROMPARTS(YEAR(GETDATE())-2, 01, 01)
  GROUP BY  tr.[StoreID]
      ,d.[DateID]
      ,tr.TransHourMinute