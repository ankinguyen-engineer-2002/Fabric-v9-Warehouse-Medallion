-- Auto Generated (Do not modify) C6D4DDC7AEFEEA515C6EA46F4EA800426AA2EC52F4D6223F12F107DB7CDD608D
/*
2025-08-21 || Satya B:  Created View
*/

CREATE   VIEW [Retail_DW_Core_Wrk].[v_APPS_FactTraffic] AS

SELECT 
	StoreID AS LocationID,
	TransDateKey,
	SUM(TrafficCount) AS Traffic
FROM [Retail_DW_Core].[FactTraffic]
WHERE
	IsOpen = 1
	AND TransDateKey >= '20200101'
GROUP BY
	StoreID,
	TransDateKey