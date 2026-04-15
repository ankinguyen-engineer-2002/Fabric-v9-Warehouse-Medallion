-- Auto Generated (Do not modify) DF51B1E5A6E599756253E3A26A894501576311B3C6E576E3C441D54F7EBB907F
/*
2025-08-26 || Created by Harshit S

*/
CREATE   VIEW [Retail_DW_Core_Wrk].[v_SMQQ_FactTransactions] AS
SELECT C.[LocationKey]
     , dat.DateID AS [TransDate]
     , S.WrittenSales
     , SUM(C.[SuperOrderClose]) AS StoreTransCount
FROM [Retail_DW_Core].[FactCloses]  C
LEFT JOIN [Retail_DW_Core].[DimDate] as dat
ON C.[TransDateKey] = dat.[DateKey]
    LEFT JOIN
    (
        SELECT T.TransDateTime
             , T.LocationKey
             , SUM(T.Sales) AS WrittenSales
        FROM [Retail_DW_Core].[FactSales] T
        WHERE T.TransDateTime >= '2019-12-29'
        GROUP BY T.TransDateTime
               , T.LocationKey
    )                             S
        ON dat.[DateID] = s.TransDateTime
           AND C.LocationKey = S.LocationKey
WHERE dat.[DateID] >= '2019-12-29'
GROUP BY C.LocationKey
       , dat.[DateID]
	   , S.WrittenSales