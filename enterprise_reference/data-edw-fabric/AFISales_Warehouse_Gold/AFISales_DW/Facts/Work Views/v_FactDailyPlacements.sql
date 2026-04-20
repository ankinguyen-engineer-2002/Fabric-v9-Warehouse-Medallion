CREATE VIEW [AFISales_DW_Wrk].[v_FactDailyPlacements]
AS
    SELECT
            ROW_NUMBER() OVER (ORDER BY DailyPlacements.ItemSKU)                                                    AS RowID,
            'ASHLEY_' + DailyPlacements.ItemSKU                                                                     AS [Item Key],
            DailyPlacements.ItemSKU,
            DimSalesTerritories.[SalesTerritoryID],
            ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1)                                                          AS [Daily Placement],
            CASE
                WHEN CurrentWeek.[Fiscal Year] IS NOT NULL
                    THEN
                    ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1)
                ELSE
                    0
            END                                                                                                     AS [Daily Placement for Risk Calc],
            DailyPlacements.DateOfPlacement                                                                         AS [Placement Date],
            DimCustomers.[Store Address ID],
            DimCustomers.[Shipto AddressID],
            DimCustomers.[Account And Shipto Number],
            DimCustomers.[Customer Account Number],
            DimCustomers.[Customer Shipto Number],
            RTRIM(DimCustomers.[Customer Account Number]) + '-' + RTRIM(DimCustomers.[Customer Shipto Number]) + '-' + DimItemMaster.AFISalesDivisionCode AS [Customer Shipto Division Number],
            CASE
                WHEN CAST(DimCustomers.[Shipto Sales Territory] AS INT) = 0
                    THEN
                    DimCustomers.[Primary Sales Territory]
                ELSE
                    DimCustomers.[Primary Sales Territory] + DimCustomers.[Shipto Sales Territory]
            END                                                                                                     AS Territory,
            DimSalesTerritories.[AFI Sales Region Code],
            DimSalesTerritories.[AFI Sales RepID],
            DimSalesTerritories.[AFI Sales Category],
            DimSalesTerritories.RegionCode_RepID_Category,
            DimSalesTerritories.[AFI Sales Division Code]
    FROM
            AFISales_Enh.DailyPlacements
        LEFT JOIN
            AFISales_DW.DimCustomers
                ON DimCustomers.[Customer Account Number] = DailyPlacements.CustomerNumber
                   AND DimCustomers.[Customer Shipto Number] = DailyPlacements.ShiptoNumber
        LEFT JOIN
            AFISales_DW.DimItemMaster       
                ON DailyPlacements.ItemSKU = DailyPlacements.ItemSKU
        LEFT JOIN
            AFISales_Enh.MrktSpclstAcctOwnershipSlsCat
                ON AFISalesDivisionCode = MrktSpclstAcctOwnershipSlsCat.Division
                   AND DailyPlacements.CustomerNumber = MrktSpclstAcctOwnershipSlsCat.CustomerNumber
                   AND DailyPlacements.ShiptoNumber = MrktSpclstAcctOwnershipSlsCat.ShiptoNumber
                   AND DimItemMaster.AFISalesCategoryCode = MrktSpclstAcctOwnershipSlsCat.SalesCategory
        LEFT JOIN
            AFISales_DW.DimDateFile     AllWeeks
                ON DailyPlacements.DateOfPlacement = AllWeeks.[Transaction Date]
        LEFT JOIN
            (
                SELECT
                        DimDateFile.[Fiscal Year],
                        DimDateFile.[Fiscal Week]
                FROM
                        AFISales_DW.DimDateFile
                WHERE
                        DimDateFile.[Transaction Date]
                BETWEEN GETDATE() - 1 AND GETDATE()
            )                                 CurrentWeek
                ON AllWeeks.[Fiscal Year] = CurrentWeek.[Fiscal Year]
                   AND AllWeeks.[Fiscal Week] = CurrentWeek.[Fiscal Week]
        LEFT JOIN
            AFISales_DW.[DimSalesTerritories] 
                ON DimSalesTerritories.[AFI Sales Region Code] = ISNULL(MrktSpclstAcctOwnershipSlsCat.Region, CAST('Z' AS CHAR(3)))
                   AND DimSalesTerritories.[AFI Sales RepID] = ISNULL(MrktSpclstAcctOwnershipSlsCat.RepID, CAST('ZZZZZ' AS CHAR(5)))
                   AND DimSalesTerritories.[AFI Sales Category] = CASE
                                                    WHEN ISNULL(MrktSpclstAcctOwnershipSlsCat.SalesCategory, '') = ''
                                                         OR ISNULL(MrktSpclstAcctOwnershipSlsCat.Region, '') = ''
                                                        THEN
                                                        CAST('ZZ' AS CHAR(3))
                                                    ELSE
                                                        MrktSpclstAcctOwnershipSlsCat.SalesCategory
                                                END
                   AND DimSalesTerritories.[Active Record] = 1;
