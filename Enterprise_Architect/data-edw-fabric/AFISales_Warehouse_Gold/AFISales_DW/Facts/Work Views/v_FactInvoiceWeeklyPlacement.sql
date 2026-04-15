CREATE VIEW [AFISales_DW_Wrk].[v_FactInvoiceWeeklyPlacement]
AS
    WITH PlacementWeekDate
    AS (
           SELECT
               CONVERT(
                          INT,
                          CONVERT(CHAR(4), [Fiscal Year])
                          + REPLICATE('0', ABS(LEN(CONVERT(VARCHAR(2), [Fiscal Week])) - 2))
                          + CONVERT(VARCHAR(2), [Fiscal Week])
                      )                AS [YearWeek],
               MAX([Transaction Date]) AS [WeekEndedDate]
           FROM
               AFISales_DW.DimDateFile
           GROUP BY
               CONVERT(
                          INT,
                          CONVERT(CHAR(4), [Fiscal Year])
                          + REPLICATE('0', ABS(LEN(CONVERT(VARCHAR(2), [Fiscal Week])) - 2))
                          + CONVERT(VARCHAR(2), [Fiscal Week])
                      ))
    SELECT
            ROW_NUMBER() OVER (ORDER BY C1.ItemSKU)                   AS RowID,
            CASE
                WHEN C1.ShiptoNumber = ''
                    THEN
                    C1.CustomerNumber
                ELSE
                    RTRIM(C1.CustomerNumber) + '-' + LTRIM(C1.ShiptoNumber)
            END                                                               AS [Account And Shipto Number],
            [SalesTerritoryID],
            C1.ItemSKU                                                     AS [Item SKU],
            'ASHLEY_' + C1.ItemSKU                                         AS [Item Key],
            C1.ItemStatus                                                  AS [Item Status],
            PlacementWeekDate.[WeekEndedDate]                              AS [Week Ended],
            DimCustomers.[Shipto AddressID],
            (C1.Gained - C1.Lost) * MrktSpclstAcctOwnershipSlsCat.Ratio [Net Placement Gain],
            C1.Quantity * MrktSpclstAcctOwnershipSlsCat.Ratio              AS [Weekly Quantity],
            C1.Gained * MrktSpclstAcctOwnershipSlsCat.Ratio                AS [Placement Gain],
            C1.Lost * MrktSpclstAcctOwnershipSlsCat.Ratio                  AS [Placement Loss],
            C1.Placement * MrktSpclstAcctOwnershipSlsCat.Ratio             AS [Current Placements],
            C1.AtRisk * MrktSpclstAcctOwnershipSlsCat.Ratio                AS [At Risk Placements],
            (MrktSpclstAcctOwnershipSlsCat.Ratio
             * (ISNULL(C1.Quantity, 0) + ISNULL(P1.Quantity, 0) + ISNULL(P2.Quantity, 0)
                + ISNULL(P3.Quantity, 0) + ISNULL(P4.Quantity, 0) + ISNULL(P5.Quantity, 0)
                + ISNULL(P6.Quantity, 0) + ISNULL(P7.Quantity, 0) + ISNULL(P8.Quantity, 0)
                + ISNULL(P9.Quantity, 0) + ISNULL(P10.Quantity, 0) + ISNULL(P11.Quantity, 0)
                + ISNULL(P12.Quantity, 0)
               )
            ) / 3                                                             AS [Velocity Rolling Average Quantity], -- divide by 3 to get to average monthly velocity
            MrktSpclstAcctOwnershipSlsCat.Ratio * ISNULL(P12.Placement, 0) AS [Velocity Placement Denominator],
            DimSalesTerritories.[AFI Sales Category],
            DimSalesTerritories.[AFI Sales Division Code],
            DimSalesTerritories.[AFI Sales Region Code],
            DimSalesTerritories.[AFI Sales RepID],
            DimSalesTerritories.RegionCode_RepID_Category,
            CASE
                WHEN CAST(DimCustomers.[Shipto Sales Territory] AS INT) = 0
                    THEN
                    DimCustomers.[Primary Sales Territory]
                ELSE
                    DimCustomers.[Primary Sales Territory] + DimCustomers.[Shipto Sales Territory]
            END                                                               AS Territory,
            DimCustomers.[Store Address ID],
            RTRIM(DimCustomers.[Customer Account Number]) + '-' + RTRIM(DimCustomers.[Customer Shipto Number]) + '-'
            + DimSalesTerritories.[AFI Sales Division Code]                   AS [Customer Shipto Division Number],
            DimCustomers.[Customer Account Number],
            DimCustomers.[Customer Shipto Number]
    FROM
            AFISales_Enh.InvoiceWeeklyPlacements C1
        LEFT JOIN
            AFISales_Enh.InvoiceWeeklyPlacements P1
                ON C1.ItemSKU = P1.ItemSKU
                   AND C1.CustomerNumber = P1.CustomerNumber
                   AND C1.ShiptoNumber = P1.ShiptoNumber
                   AND P1.Year = CASE
                                        WHEN C1.Week = 1
                                            THEN
                                            C1.Year - 1
                                        ELSE
                                            C1.Year
                                    END
                   AND P1.Week = CASE
                                        WHEN C1.Week = 1
                                            THEN
                                            12
                                        ELSE
                                            C1.Week - 1
                                    END
        LEFT JOIN
            AFISales_Enh.InvoiceWeeklyPlacements P2
                ON C1.ItemSKU = P2.ItemSKU
                   AND C1.CustomerNumber = P2.CustomerNumber
                   AND C1.ShiptoNumber = P2.ShiptoNumber
                   AND P2.Year = CASE
                                        WHEN C1.Week <= 2
                                            THEN
                                            C1.Year - 1
                                        ELSE
                                            C1.Year
                                    END
                   AND P2.Week = CASE
                                        WHEN C1.Week <= 2
                                            THEN
                                            52 + C1.Week - 2
                                        ELSE
                                            C1.Week - 2
                                    END
        LEFT JOIN
            AFISales_Enh.InvoiceWeeklyPlacements P3
                ON C1.ItemSKU = P3.ItemSKU
                   AND C1.CustomerNumber = P3.CustomerNumber
                   AND C1.ShiptoNumber = P3.ShiptoNumber
                   AND P3.Year = CASE
                                        WHEN C1.Week <= 3
                                            THEN
                                            C1.Year - 1
                                        ELSE
                                            C1.Year
                                    END
                   AND P3.Week = CASE
                                        WHEN C1.Week <= 3
                                            THEN
                                            52 + C1.Week - 3
                                        ELSE
                                            C1.Week - 3
                                    END
        LEFT JOIN
            AFISales_Enh.InvoiceWeeklyPlacements P4
                ON C1.ItemSKU = P4.ItemSKU
                   AND C1.CustomerNumber = P4.CustomerNumber
                   AND C1.ShiptoNumber = P4.ShiptoNumber
                   AND P4.Year = CASE
                                        WHEN C1.Week <= 4
                                            THEN
                                            C1.Year - 1
                                        ELSE
                                            C1.Year
                                    END
                   AND P4.Week = CASE
                                        WHEN C1.Week <= 4
                                            THEN
                                            52 + C1.Week - 4
                                        ELSE
                                            C1.Week - 4
                                    END
        LEFT JOIN
            AFISales_Enh.InvoiceWeeklyPlacements P5
                ON C1.ItemSKU = P5.ItemSKU
                   AND C1.CustomerNumber = P5.CustomerNumber
                   AND C1.ShiptoNumber = P5.ShiptoNumber
                   AND P5.Year = CASE
                                        WHEN C1.Week <= 5
                                            THEN
                                            C1.Year - 1
                                        ELSE
                                            C1.Year
                                    END
                   AND P5.Week = CASE
                                        WHEN C1.Week <= 5
                                            THEN
                                            52 + C1.Week - 5
                                        ELSE
                                            C1.Week - 5
                                    END
        LEFT JOIN
            AFISales_Enh.InvoiceWeeklyPlacements P6
                ON C1.ItemSKU = P6.ItemSKU
                   AND C1.CustomerNumber = P6.CustomerNumber
                   AND C1.ShiptoNumber = P6.ShiptoNumber
                   AND P6.Year = CASE
                                        WHEN C1.Week <= 6
                                            THEN
                                            C1.Year - 1
                                        ELSE
                                            C1.Year
                                    END
                   AND P6.Week = CASE
                                        WHEN C1.Week <= 6
                                            THEN
                                            52 + C1.Week - 6
                                        ELSE
                                            C1.Week - 6
                                    END
        LEFT JOIN
            AFISales_Enh.InvoiceWeeklyPlacements P7
                ON C1.ItemSKU = P7.ItemSKU
                   AND C1.CustomerNumber = P7.CustomerNumber
                   AND C1.ShiptoNumber = P7.ShiptoNumber
                   AND P7.Year = CASE
                                        WHEN C1.Week <= 7
                                            THEN
                                            C1.Year - 1
                                        ELSE
                                            C1.Year
                                    END
                   AND P7.Week = CASE
                                        WHEN C1.Week <= 7
                                            THEN
                                            52 + C1.Week - 7
                                        ELSE
                                            C1.Week - 7
                                    END
        LEFT JOIN
            AFISales_Enh.InvoiceWeeklyPlacements P8
                ON C1.ItemSKU = P8.ItemSKU
                   AND C1.CustomerNumber = P8.CustomerNumber
                   AND C1.ShiptoNumber = P8.ShiptoNumber
                   AND P8.Year = CASE
                                        WHEN C1.Week <= 8
                                            THEN
                                            C1.Year - 1
                                        ELSE
                                            C1.Year
                                    END
                   AND P8.Week = CASE
                                        WHEN C1.Week <= 8
                                            THEN
                                            52 + C1.Week - 8
                                        ELSE
                                            C1.Week - 8
                                    END
        LEFT JOIN
            AFISales_Enh.InvoiceWeeklyPlacements P9
                ON C1.ItemSKU = P9.ItemSKU
                   AND C1.CustomerNumber = P9.CustomerNumber
                   AND C1.ShiptoNumber = P9.ShiptoNumber
                   AND P9.Year = CASE
                                        WHEN C1.Week <= 9
                                            THEN
                                            C1.Year - 1
                                        ELSE
                                            C1.Year
                                    END
                   AND P9.Week = CASE
                                        WHEN C1.Week <= 9
                                            THEN
                                            52 + C1.Week - 9
                                        ELSE
                                            C1.Week - 9
                                    END
        LEFT JOIN
            AFISales_Enh.InvoiceWeeklyPlacements P10
                ON C1.ItemSKU = P10.ItemSKU
                   AND C1.CustomerNumber = P10.CustomerNumber
                   AND C1.ShiptoNumber = P10.ShiptoNumber
                   AND P10.Year = CASE
                                         WHEN C1.Week <= 10
                                             THEN
                                             C1.Year - 1
                                         ELSE
                                             C1.Year
                                     END
                   AND P10.Week = CASE
                                         WHEN C1.Week <= 10
                                             THEN
                                             52 + C1.Week - 10
                                         ELSE
                                             C1.Week - 10
                                     END
        LEFT JOIN
            AFISales_Enh.InvoiceWeeklyPlacements P11
                ON C1.ItemSKU = P11.ItemSKU
                   AND C1.CustomerNumber = P11.CustomerNumber
                   AND C1.ShiptoNumber = P11.ShiptoNumber
                   AND P11.Year = CASE
                                         WHEN C1.Week <= 11
                                             THEN
                                             C1.Year - 1
                                         ELSE
                                             C1.Year
                                     END
                   AND P11.Week = CASE
                                         WHEN C1.Week <= 11
                                             THEN
                                             52 + C1.Week - 11
                                         ELSE
                                             C1.Week - 11
                                     END
        LEFT JOIN
            AFISales_Enh.InvoiceWeeklyPlacements P12
                ON C1.ItemSKU = P12.ItemSKU
                   AND C1.CustomerNumber = P12.CustomerNumber
                   AND C1.ShiptoNumber = P12.ShiptoNumber
                   AND P12.Year = CASE
                                         WHEN C1.Week <= 12
                                             THEN
                                             C1.Year - 1
                                         ELSE
                                             C1.Year
                                     END
                   AND P12.Week = CASE
                                         WHEN C1.Week <= 12
                                             THEN
                                             52 + C1.Week - 12
                                         ELSE
                                             C1.Week - 12
                                     END
        JOIN
            AFISales_DW.DimItemMaster
                ON DimItemMaster.ItemSKU = C1.ItemSKU
        JOIN
            AFISales_DW.DimCustomers             
                ON DimCustomers.[Customer Account Number] = C1.CustomerNumber
                   AND DimCustomers.[Customer Shipto Number] = C1.ShiptoNumber
        LEFT JOIN
            AFISales_Enh.MrktSpclstAcctOwnershipSlsCat
                ON AFISalesDivisionCode = MrktSpclstAcctOwnershipSlsCat.Division
                   AND C1.CustomerNumber = MrktSpclstAcctOwnershipSlsCat.CustomerNumber
                   AND C1.ShiptoNumber = MrktSpclstAcctOwnershipSlsCat.ShiptoNumber
                   AND AFISalesCategoryCode = MrktSpclstAcctOwnershipSlsCat.SalesCategory
        JOIN
            PlacementWeekDate                   
                ON PlacementWeekDate.[YearWeek] = C1.[YearWeek]
        LEFT JOIN
            AFISales_DW.[DimSalesTerritories]    
                ON DimSalesTerritories.[AFI Sales Region Code] = ISNULL(
                                                                           MrktSpclstAcctOwnershipSlsCat.Region,
                                                                           CAST('Z' AS CHAR(3))
                                                                       )
                   AND DimSalesTerritories.[AFI Sales RepID] = ISNULL(
                                                                         MrktSpclstAcctOwnershipSlsCat.RepID,
                                                                         CAST('ZZZZZ' AS CHAR(5))
                                                                     )
                   AND DimSalesTerritories.[AFI Sales Category] = CASE
                                                                      WHEN ISNULL(DimItemMaster.AFISalesCategoryCode, '') = ''
                                                                           OR ISNULL(
                                                                                        MrktSpclstAcctOwnershipSlsCat.Region,
                                                                                        ''
                                                                                    ) = ''
                                                                          THEN
                                                                          CAST('ZZ' AS CHAR(3))
                                                                      ELSE
                                                                          DimItemMaster.AFISalesCategoryCode
                                                                  END
                   AND DimSalesTerritories.[Active Record] = 1;
