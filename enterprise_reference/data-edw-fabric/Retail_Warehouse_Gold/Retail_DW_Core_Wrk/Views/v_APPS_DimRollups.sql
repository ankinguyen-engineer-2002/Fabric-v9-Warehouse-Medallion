-- Auto Generated (Do not modify) 5538D11D8A2BECD7E9D200A82D62DF459297BE68D9EE1547A4BCE147480532B3
/*
2025-08-21 || Satya B:  Created View
*/

CREATE   VIEW [Retail_DW_Core_Wrk].[v_APPS_DimRollups] AS

SELECT R.StoreID AS LocationID
     , R.[RollUp]
     , R.RollUpFilter
     , L.LocationGroupID AS Division
     , R2.[RollUp]       AS Region
FROM [Retail_DW_Core].[DimRollUps] R
    LEFT JOIN [Retail_DW_Core].[DimStoreLocationGroup] L
        ON L.StoreID = R.StoreID
           AND L.LocationGroupID IN ( 'NHOSTR', 'SHOSTR' )
    LEFT JOIN [Retail_DW_Core].[DimRollUps]        R2
        ON R2.StoreID = R.StoreID
           AND R2.RollUpFilter = 'Region'