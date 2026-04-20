CREATE VIEW [PowerBI_Wholesale].[WeeklyPlacements_Aggregated_WeeklyGoals]
AS
    SELECT   (ST.[AFI Alternate Division] + '' + C.[Reporting Business Type])        AS DivisionChannelKey,
             ST.[AFI Alternate Division],
             ST.[AFI Sales Region Type],
             ST.[Sales Regional VP],
             ST.[Marketing Specialist],
             (TRIM(OH.[Account And Shipto Number]) + '' + ST.[Marketing Specialist]) AS Associate,
             OH.[Account And Shipto Number],
             C.[Customer Account Number],
             C.[Reporting Business Type],
             SUM([Current Placements])                                               [Weekly Current Placements]
    FROM
              AFISales_DW.FactWeeklyPlacements                    OH
        INNER JOIN
             (
                 SELECT
                     MAX([Transaction Date]) [Transaction Date]
                 FROM
                     [PowerBI_Wholesale].[DateFile]
                 WHERE
                     [Fiscal Week] = DATEPART("ww", GETDATE())
                     AND [Fiscal Year] = DATEPART("yyyy", GETDATE())
             )                                                       DT
                 ON OH.[Week Ended] = DT.[Transaction Date]
        LEFT JOIN
             AFISales_DW.DimCustomers        C
                 ON OH.[Account And Shipto Number] = C.[Account And Shipto Number]
        LEFT JOIN
             AFISales_DW.DimSalesTerritories ST
                 ON OH.[SalesTerritoryID] = ST.[SalesTerritoryID]
    GROUP BY (ST.[AFI Alternate Division] + '' + C.[Reporting Business Type]),
             ST.[AFI Alternate Division],
             ST.[AFI Sales Region Type],
             ST.[Sales Regional VP],
             ST.[Marketing Specialist],
             (TRIM(OH.[Account And Shipto Number]) + '' + ST.[Marketing Specialist]),
             OH.[Account And Shipto Number],
             C.[Customer Account Number],
             C.[Reporting Business Type];