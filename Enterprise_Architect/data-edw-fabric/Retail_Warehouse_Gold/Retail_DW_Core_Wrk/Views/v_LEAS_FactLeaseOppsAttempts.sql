-- Auto Generated (Do not modify) 43208FDF833F11A029F818142878C68360893C23E2EF8982BFB2CCFCF4BBAE2E
CREATE   VIEW [Retail_DW_Core_Wrk].[v_LEAS_FactLeaseOppsAttempts] AS 

SELECT
    lm.LocationKey,
    sp.SalesPersonKey,
    dm.DateID,
    cr.FinanceProviderID,
    SUM(cr.AppCount) AppCount,
    SUM(cr.LeaseAttempt) AS LeaseAttempt,
    SUM(cr.LeaseOpp) AS LeaseOpp
FROM [Retail_DW_Core].[FactCreditReview] cr
    INNER JOIN [Retail_DW_Core].[DimDate] dm
        ON cr.TransDateKey = dm.DateKey
    INNER JOIN [Retail_DW_Core].[DimStoreLocation] AS lm
        ON cr.StoreID = lm.StoreID
    INNER JOIN [Retail_DW_Core].[DimSalesPerson] AS sp
        ON sp.SalesPersonID = cr.SalesPersonID
WHERE dm.DateID >= DATEFROMPARTS(YEAR(GETDATE()) - 2, 01, 01)
      AND cr.CreditRequestStatusCodeID <> 9
GROUP BY lm.LocationKey,
         sp.SalesPersonKey,
         dm.DateID,
         cr.FinanceProviderID;