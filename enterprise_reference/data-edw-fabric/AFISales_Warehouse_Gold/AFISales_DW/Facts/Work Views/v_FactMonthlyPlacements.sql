CREATE VIEW [AFISales_DW_Wrk].[v_FactMonthlyPlacement]
AS

    SELECT
            ROW_NUMBER() OVER (ORDER BY
                                  C1.ItemSKU
                             )                   AS RowID,
            DimCustomers.[Account And Shipto Number],
            [SalesTerritoryID],
            C1.ItemSKU                                                                                        AS [Item SKU],
            'ASHLEY_' + C1.ItemSKU                                                                            AS [Item Key],
            C1.ItemStatus                                                                                     AS [Item Status],
            MonthEndDates.MonthEndDate                                                                          AS [Month Ended],
            DimCustomers.[Shipto AddressID],
            (C1.Gained - C1.lost) * MrktSpclstAcctOwnershipSlsCat.Ratio                                       AS [Net Placement Gain],
            C1.Quantity * MrktSpclstAcctOwnershipSlsCat.Ratio                                                 AS [Monthly Quantity],
            C1.Gained * MrktSpclstAcctOwnershipSlsCat.Ratio                                                   AS [Placement Gain],
            C1.lost * MrktSpclstAcctOwnershipSlsCat.Ratio                                                     AS [Placement Loss],
            C1.Placement * MrktSpclstAcctOwnershipSlsCat.Ratio                                                AS [Current Placements],
            C1.AtRisk * MrktSpclstAcctOwnershipSlsCat.Ratio                                                   AS [At Risk Placements],
            CASE
                WHEN MonthEndDates.[Fiscal Year Indicator] = 0
                     AND C1.Gained <> 0
                    THEN
                    C1.Quantity * MrktSpclstAcctOwnershipSlsCat.Ratio
                ELSE
                    0
            END                                                                                                AS [MTD Quantity],
            CASE
                WHEN MonthEndDates.[Fiscal Year Indicator] = 0
                    THEN
                    C1.Gained * MrktSpclstAcctOwnershipSlsCat.Ratio
                ELSE
                    0
            END                                                                                                  AS [MTD Placements],
            (MrktSpclstAcctOwnershipSlsCat.Ratio * (ISNULL(C1.Quantity, 0) + ISNULL(P1.Quantity, 0) + ISNULL(P2.Quantity, 0))) / 3 AS [Velocity Rolling Average Quantity],
            MrktSpclstAcctOwnershipSlsCat.Ratio * ISNULL(P2.Placement, 0)                                                                AS [Velocity Placement Denominator],
            DimSalesTerritories.RegionCode_RepID_Category,
            RTRIM(DimCustomers.[Customer Account Number]) + '-' + RTRIM(DimCustomers.[Customer Shipto Number]) + '-'
            + DimSalesTerritories.[AFI Sales Division Code]                                                                        AS [Customer Shipto Division Number],
            CASE
                WHEN CAST(DimCustomers.[Shipto Sales Territory] AS INT) = 0
                    THEN
                    DimCustomers.[Primary Sales Territory]
                ELSE
                    DimCustomers.[Primary Sales Territory] + DimCustomers.[Shipto Sales Territory]
            END                                                                                                  AS Territory,
            DimSalesTerritories.[AFI Sales Category],
            DimSalesTerritories.[AFI Sales Division Code],
            DimSalesTerritories.[AFI Sales Region Code],
            DimSalesTerritories.[AFI Sales RepID],
            DimCustomers.[Customer Account Number],
            DimCustomers.[Customer Shipto Number],
            DimCustomers.[Store Address ID]
    FROM
            AFISales_Enh.CustItemMonthlyPlacements C1
        LEFT JOIN
            AFISales_Enh.CustItemMonthlyPlacements P1
                ON C1.ItemSKU = P1.ItemSKU
                   AND C1.CustomerNumber = P1.CustomerNumber
                   AND C1.ShiptoNumber = P1.ShiptoNumber
                   AND P1.Year = CASE
                                        WHEN C1.Month = 1
                                            THEN
                                            C1.Year - 1
                                        ELSE
                                            C1.Year
                                    END
                   AND P1.Month = CASE
                                         WHEN C1.Month = 1
                                             THEN
                                             12
                                         ELSE
                                             C1.Month - 1
                                     END
        LEFT JOIN
            AFISales_Enh.CustItemMonthlyPlacements P2
                ON C1.ItemSKU = P2.ItemSKU
                   AND C1.CustomerNumber = P2.CustomerNumber
                   AND C1.ShiptoNumber = P2.ShiptoNumber
                   AND P2.Year = CASE
                                        WHEN C1.Month <= 2
                                            THEN
                                            C1.Year - 1
                                        ELSE
                                            C1.Year
                                    END
                   AND P2.Month = CASE
                                         WHEN C1.Month = 1
                                             THEN
                                             11
                                         WHEN C1.Month = 2
                                             THEN
                                             12
                                         ELSE
                                             C1.Month - 2
                                     END
        JOIN
            AFISales_DW.DimItemMaster
                ON DimItemMaster.ItemSKU = C1.ItemSKU
        JOIN
            AFISales_DW.DimCustomers               
                ON [Customer Account Number] = C1.CustomerNumber
                   AND [Customer Shipto Number] = C1.ShiptoNumber
        LEFT JOIN
            AFISales_Enh.MrktSpclstAcctOwnershipSlsCat
                ON AFISalesDivisionCode = MrktSpclstAcctOwnershipSlsCat.Division
                   AND C1.CustomerNumber = MrktSpclstAcctOwnershipSlsCat.CustomerNumber
                   AND C1.ShiptoNumber = MrktSpclstAcctOwnershipSlsCat.ShiptoNumber
                   AND AFISalesCategoryCode = MrktSpclstAcctOwnershipSlsCat.SalesCategory
        JOIN
            (
                SELECT
                    [FiscalYearPeriod] ,
                    [Fiscal Year Indicator],
                    MAX([Transaction Date]  ) AS [MonthEndDate]  
                FROM
                    AFISales_DW.DimDateFile
                GROUP BY
                    FiscalYearPeriod,
                    [Fiscal Year Indicator]
            )                                      MonthEndDates
                ON MonthEndDates.FiscalYearPeriod = C1.YearMonth
        LEFT JOIN
            AFISales_DW.[DimSalesTerritories]      
                ON DimSalesTerritories.[AFI Sales Region Code] = ISNULL(MrktSpclstAcctOwnershipSlsCat.Region, CAST('Z' AS CHAR(3)))
                   AND DimSalesTerritories.[AFI Sales RepID] = ISNULL(MrktSpclstAcctOwnershipSlsCat.RepID, CAST('ZZZZZ' AS CHAR(5)))
                   AND DimSalesTerritories.[AFI Sales Category] = CASE
                                                    WHEN ISNULL(AFISalesCategoryCode, '') = ''
                                                         OR ISNULL(MrktSpclstAcctOwnershipSlsCat.Region, '') = ''
                                                        THEN
                                                        CAST('ZZ' AS CHAR(3))
                                                    ELSE
                                                        AFISalesCategoryCode
                                                END
                   AND DimSalesTerritories.[Active Record] = 1;
