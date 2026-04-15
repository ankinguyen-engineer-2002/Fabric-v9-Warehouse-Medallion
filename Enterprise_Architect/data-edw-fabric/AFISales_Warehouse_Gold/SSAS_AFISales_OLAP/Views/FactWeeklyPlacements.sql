CREATE VIEW [SSAS_AFISALES_OLAP].[FactWeeklyPlacements]
AS
    SELECT
            -1                                                                                                         AS [Goal Id],
            [AFI Sales Category]                                                                                       AS [Sales Category],
            [AFI Sales Division Code]                                                                                  AS [AFI Sales Division],
            [AFI Sales Region Code]                                                                                    AS [AFI Sales Region],
            [AFI Sales RepID]                                                                                          AS [Marketing Specialist ID],
            RegionCode_RepID_Category,
            [AFI Sales Division Code]                                                                                  AS [Division Code],
            [Customer Account Number],
            [Customer Shipto Number],
            RTRIM([Customer Account Number]) + '-' + RTRIM([Customer Shipto Number]) + '-' + [AFI Sales Division Code] AS [Customer Shipto Division Number],
            MP.[Account And Shipto Number],
            MP.Territory,
            [Store Address ID],
            MP.[Shipto AddressID],
            MP.[Item SKU],
            MP.[Item Status],
            MP.[Week Ended],
            MP.[Net Placement Gain],
            MP.[Weekly Quantity],
            MP.[Placement Gain],
            MP.[Placement Loss],
            MP.[Current Placements],
            MP.[At Risk Placements],
            MP.SalesTerritoryID
    FROM
            AFISales_DW.FactWeeklyPlacements MP
        LEFT JOIN
            AFISales_DW.DimDateFile          D
                ON MP.[Week Ended] = D.[Transaction Date]
    WHERE
            [Fiscal Year] >= YEAR(GETDATE()) - 4;
GO