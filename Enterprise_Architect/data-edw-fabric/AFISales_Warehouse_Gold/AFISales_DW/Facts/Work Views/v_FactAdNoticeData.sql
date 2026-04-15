CREATE VIEW [AFISales_DW_Wrk].[v_FactAdNoticeData]
AS
    SELECT
            AdNoticeDetail.[Key],
            AdNotice.CustomerNumber                                                                                     [Customer Account Number],
            ' '                                                                                                         [Ship Number],
            CAST(AccountMaster.PrimaryTerritory AS CHAR(5)) + '00000'                                                AS [Territory],
            AdNotice.RequestDate                                                                                        [Delivery Date for AD],
            AdNotice.StartDate                                                                                          [Start Date for AD],
            AdNotice.EndDate                                                                                            [End Date for AD],
            AdNoticeDetail.Warehouse                                                                                    [Warehouse],
            AdNotice.DateAdded                                                                                               [AD Date Entered],
            DimSalesTerritories.SalesTerritoryID,
            AdNoticeDetail.ItemSKU                                                                                      [Item Number],
            AdNoticeDetail.Quantity                                                                                     [AD Goal Quantity],
            ISNULL(Quantity.Total, 0)                                                                                AS [Ad Actual Qty],
            DATEDIFF(dd, AdNotice.DateAdded, AdNotice.RequestDate)                                                           [Notice Time Lead],
            DATEDIFF(dd, AdNotice.StartDate, AdNotice.EndDate) + 28                                                     [Promotion Duration],
            DimItemMaster.AFISalesDivisionCode                                                                          [Division Code],
            RTRIM(LTRIM(ISNULL(AdNotice.CustomerNumber, ''))) + ' ' 
            + RTRIM(LTRIM(ISNULL(DimItemMaster.AFISalesDivisionCode, '')))                                              [Customer Shipto Division Number]
    FROM
            [$(Wholesale_Warehouse)].Marketing.AdNotice       
        JOIN
            [$(Wholesale_Warehouse)].Marketing.AdNoticeDetail  
                ON AdNotice.[Key] = AdNoticeDetail.ForeignKey
        JOIN
            [$(Wholesale_Warehouse)].Customers.AccountMaster
                ON AccountMaster.CustomerNumber = AdNotice.CustomerNumber
        LEFT JOIN
            (
                SELECT
                        AdNoticeDetail.[Key],
                        AdNotice.CustomerNumber,
                        AdNoticeDetail.ItemSKU,
                        SUM(OrderHistory.[Quantity]) AS Total
                FROM
                        [$(Wholesale_Warehouse)].Marketing.AdNotice      
                    JOIN
                        [$(Wholesale_Warehouse)].Marketing.AdNoticeDetail 
                            ON AdNotice.[Key] = AdNoticeDetail.ForeignKey
                    JOIN
                        [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                            ON OrderHistory.[CustomerNumber] = AdNotice.CustomerNumber
                               AND AdNoticeDetail.ItemSKU = OrderHistory.[ItemSKU]
                               AND CAST(SUBSTRING(CAST(OrderHistory.[OrderChangeDate] AS CHAR(8)), 5, 2) + '/'
                                        + SUBSTRING(CAST(OrderHistory.[OrderChangeDate] AS CHAR(8)), 7, 2) + '/'
                                        + SUBSTRING(CAST(OrderHistory.[OrderChangeDate] AS CHAR(8)), 1, 4) AS DATETIME)
                               BETWEEN AdNotice.StartDate AND AdNotice.EndDate
                GROUP BY
                        AdNoticeDetail.[Key],
                        AdNotice.CustomerNumber,
                        AdNoticeDetail.ItemSKU
            )                                  Quantity
                ON AdNotice.CustomerNumber = Quantity.CustomerNumber
                   AND AdNoticeDetail.ItemSKU = Quantity.ItemSKU
                   AND AdNoticeDetail.[Key] = Quantity.[Key]
        LEFT JOIN
            (
                SELECT
                        UserProfile.UserLogin,
                        MrktSpclstRegion.RepID,
                        MrktSpclstRegion.Region,
                        DimItemMaster.AFISalesCategoryCode,
                        ROW_NUMBER() OVER (PARTITION BY
                                               UserProfile.UserLogin
                                           ORDER BY
                                               AFISalesCategoryCode
                                          ) AS Rn
                FROM
                        [$(Wholesale_Warehouse)].Marketing.AdNotice
                    JOIN
                        [$(MasterData_Warehouse)].[Security].UserProfile
                            ON AdNotice.UserLogin = UserProfile.UserLogin
                    JOIN
                        [$(MasterData_Warehouse)].[Security].SalesProfile
                            ON UserProfile.MHS = SalesProfile.MHS_Name
                    JOIN
                        [$(Wholesale_Warehouse)].Marketing.MrktSpclstRegion
                            ON SalesProfile.SalesCode = MrktSpclstRegion.MarketingSpecialist
                    JOIN
                        [$(Wholesale_Warehouse)].Marketing.AdNoticeDetail
                            ON AdNotice.[Key] = AdNoticeDetail.ForeignKey
                    JOIN
                        AFISales_DW.DimItemMaster
                            ON AdNoticeDetail.ItemSKU = DimItemMaster.ItemSKU
                GROUP BY
                        UserProfile.UserLogin,
                        MrktSpclstRegion.RepID,
                        MrktSpclstRegion.Region,
                        AFISalesCategoryCode
            )                                  A
                ON AdNotice.UserLogin = A.UserLogin
                   AND A.Rn = 1
     
        LEFT JOIN
            AFISales_DW.DimItemMaster
                ON AdNoticeDetail.ItemSKU = DimItemMaster.ItemSKU
        LEFT JOIN
            AFISales_DW.[DimSalesTerritories]  
                ON DimSalesTerritories.[AFI Sales Region Code] = ISNULL(A.Region, CAST('Z' AS CHAR(3)))
                   AND DimSalesTerritories.[AFI Sales RepID] = ISNULL(A.RepID, CAST('ZZZZZ' AS CHAR(3)))
                   AND DimSalesTerritories.[AFI Sales Category] = ISNULL(A.AFISalesCategoryCode, CAST('ZZ' AS CHAR(3)))
                   AND DimSalesTerritories.[Active Record] = 1;
