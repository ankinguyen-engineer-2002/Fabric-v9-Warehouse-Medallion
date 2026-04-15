CREATE PROC [AFISales_DW].[usp_Refresh_DimItemMaster]
AS

    /* Change Control -----------------------------------------------------------------------------------------------------------
* Procedure: [AFISales_DW].[usp_Refresh_DimItemMaster]
* Description: 
* Dhinesh (6/20/2022): Curated a new DimItemMaster for the AFISales_DW model 
* Indumathi Krishnan (13-sep-2022): Based on debra's mail,altered the SP to fetch consumerchoiceflag from [$(Databricks)].[masterdata_pim].[product] table
* Karthick Surendran (1/25/2023): Added RTA Flag from PIM. Field name: ItemIsRTA
* Bob Horton  convert to Fabric 11/6/2023
---------------------------------------------------------------------------------------------------------------------------*/

    BEGIN


        DECLARE
            @String    VARCHAR(5000),
            @DateValue DATETIME,
            @User      VARCHAR(500);

        SET @String = 'AFISales_DW.AFISales_DW.usp_Refresh_DimItemMaster';
        SET @User = SYSTEM_USER;
        SET @DateValue = GETDATE();
        SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)

        INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
        VALUES
            (
                @String, @DateValue, @User, 'Process Start'
            );

        BEGIN TRY



            SELECT
                    ItemMaster.ItemSKU AS ItemSKU,
                    CASE
                        WHEN Pc0.ItemSKU IS NULL
                            THEN
                            CAST(0 AS INT)
                        ELSE
                            CAST(1 AS INT)
                    END                AS [CommodityItem],
                    CASE
                        WHEN COALESCE(Pc1.ItemSKU, Spc1.SeriesCode, '') = ''
                            THEN
                            CAST(0 AS INT)
                        ELSE
                            CAST(1 AS INT)
                    END                AS [F123ProductFlag],
                    CASE
                        WHEN COALESCE(Pc2.ItemSKU, Spc2.SeriesCode, '') = ''
                            THEN
                            CAST(0 AS INT)
                        ELSE
                            CAST(1 AS INT)
                    END                AS [HSCoreProductFlag],
                    CASE
                        WHEN COALESCE(Pc3.ItemSKU, Spc3.SeriesCode, '') = ''
                            THEN
                            CAST(0 AS INT)
                        ELSE
                            CAST(1 AS INT)
                    END                AS [HSProprietaryProductFlag],
                    CASE
                        WHEN COALESCE(Pc5.ItemSKU, Spc5.SeriesCode, '') = ''
                            THEN
                            CAST(0 AS INT)
                        ELSE
                            CAST(1 AS INT)
                    END                AS [HSExclusiveFlag],
                    CASE
                        WHEN COALESCE(Pc4.PublishCodeID, Spc4.PublishCodeID, '') IN (
                                                                                        'itmBerkline', 'serBerkline'
                                                                                    )
                            THEN
                            CAST(1 AS INT)
                        ELSE
                            CAST(0 AS INT)
                    END                AS [BerklineProductFlag],
                    CASE
                        WHEN COALESCE(Pc4.PublishCodeID, Spc4.PublishCodeID, '') IN (
                                                                                        'itmBenchcraft', 'serBenchcraft'
                                                                                    )
                            THEN
                            CAST(1 AS INT)
                        ELSE
                            CAST(0 AS INT)
                    END                AS [BenchcraftProductFlag],
                    CASE
                        WHEN COALESCE(Pc4.PublishCodeID, Spc4.PublishCodeID, '') IN (
                                                                                        'itmNM', 'serNM'
                                                                                    )
                            THEN
                            CAST(1 AS INT)
                        ELSE
                            CAST(0 AS INT)
                    END                AS [NewMillenniumProductFlag],
                    CASE
                        WHEN COALESCE(Pc4.PublishCodeID, Spc4.PublishCodeID, '') IN (
                                                                                        'itmBardini', 'serBardini'
                                                                                    )
                            THEN
                            CAST(1 AS INT)
                        ELSE
                            CAST(0 AS INT)
                    END                AS [BardiniProductFlag],
                    CASE
                        WHEN COALESCE(Pc4.PublishCodeID, Spc4.PublishCodeID, '') IN (
                                                                                        'itmShanghai', 'serShanghai'
                                                                                    )
                            THEN
                            CAST(1 AS INT)
                        ELSE
                            CAST(0 AS INT)
                    END                AS [ShanghaiStore]
            INTO
                    #ItemFlags
            FROM
                    [$(Wholesale_Warehouse)].Marketing.ItemMaster
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemMaster         itm
                        ON ItemMaster.ItemSKU = itm.ItemSKU
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemSeries         
                        ON itm.SeriesCode = ItemSeries.SeriesCode
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemPublishCodes   Pc0
                        ON Pc0.ItemSKU = ItemMaster.ItemSKU
                           AND Pc0.PublishCodeID = 'ItmCom'
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemPublishCodes   Pc1
                        ON Pc1.ItemSKU = ItemMaster.ItemSKU
                           AND Pc1.PublishCodeID = 'itm123P'
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemPublishCodes   Pc2
                        ON Pc2.ItemSKU = ItemMaster.ItemSKU
                           AND Pc2.PublishCodeID = 'itmHSCore'
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemPublishCodes   Pc3
                        ON Pc3.ItemSKU = ItemMaster.ItemSKU
                           AND Pc3.PublishCodeID = 'itmHSProp'
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemPublishCodes   Pc5
                        ON Pc5.ItemSKU = ItemMaster.ItemSKU
                           AND Pc5.PublishCodeID = 'itmHSExclusive'
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].SeriesPublishCodes Spc1
                        ON Spc1.SeriesCode = ItemSeries.SeriesCode
                           AND Spc1.PublishCodeID = 'ser123P'
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].SeriesPublishCodes Spc2
                        ON Spc2.SeriesCode = ItemSeries.SeriesCode
                           AND Spc2.PublishCodeID = 'serHSCore'
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].SeriesPublishCodes Spc3
                        ON Spc3.SeriesCode = ItemSeries.SeriesCode
                           AND Spc3.PublishCodeID = 'serHSProp'
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].SeriesPublishCodes Spc5
                        ON Spc5.SeriesCode = ItemSeries.SeriesCode
                           AND Spc5.PublishCodeID = 'serHSExclusive'
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemPublishCodes   Pc4
                        ON Pc4.ItemSKU = ItemMaster.ItemSKU
                           AND Pc4.PublishCodeID IN (
                                                        'itmBerkline', 'itmBenchcraft', 'itmNM', 'itmBardini',
                                                        'itmShanghai'
                                                    )
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].SeriesPublishCodes Spc4
                        ON Spc4.SeriesCode = ItemSeries.SeriesCode
                           AND Spc4.PublishCodeID IN (
                                                         'serBerkline', 'serBenchcraft', 'serNM', 'serBardini',
                                                         'serShanghai'
                                                     );




            SELECT
                STSF.SeriesCode,
                CAST('True' AS CHAR(5)) flag
            INTO
                #SofaTable
            FROM
                (
                    SELECT
                            A.SeriesCode
                    FROM
                            (
                                SELECT
                                        ItemMaster.BlockingCode SeriesCode
                                FROM
                                        [$(Wholesale_Warehouse)].Marketing.ItemMaster
                                    LEFT JOIN
                                        [$(MasterData_Warehouse)].[ProductKnowledge].ItemMaster     itm
                                            ON ItemMaster.ItemSKU = itm.ItemSKU
                                    LEFT JOIN
                                        [$(MasterData_Warehouse)].[ProductKnowledge].ItemCodeMaster
                                            ON ItemCodeMaster.ItemCodeID = itm.ItemCodeID
                                    LEFT JOIN
                                        [$(MasterData_Warehouse)].[ProductKnowledge].ItemStatusCode 
                                            ON ItemStatusCode.Code = ItemMaster.Status
                                    LEFT JOIN
                                        [$(Wholesale_Warehouse)].Marketing.SalesCategory
                                            ON SalesCategory.SalesCategory = ItemMaster.SalesCategory
                                    LEFT JOIN
                                        [$(Wholesale_Warehouse)].Marketing.ProductLineMaster
                                            ON ProductLineMaster.ProductLineCode = SalesCategory.ProductLine
                                WHERE
                                        (ItemCodeMaster.Description LIKE '%Sofa Table%')
                                        AND
                                            (
                                                ItemStatusCode.Description = 'Current'
                                                OR ItemStatusCode.Description = 'New'
                                                OR ItemStatusCode.Description = 'Introduction'
                                            )
                                        AND (ProductLineMaster.Description = 'Occasional')
                            ) A
                        INNER JOIN
                            (
                                SELECT
                                        ItemMaster.BlockingCode SeriesCode
                                FROM
                                        [$(Wholesale_Warehouse)].Marketing.ItemMaster
                                    LEFT JOIN
                                        [$(MasterData_Warehouse)].[ProductKnowledge].ItemMaster     itm
                                            ON ItemMaster.ItemSKU = itm.ItemSKU
                                    LEFT JOIN
                                        [$(MasterData_Warehouse)].[ProductKnowledge].ItemCodeMaster
                                            ON ItemCodeMaster.ItemCodeID = itm.ItemCodeID
                                    LEFT JOIN
                                        [$(MasterData_Warehouse)].[ProductKnowledge].ItemStatusCode 
                                            ON ItemStatusCode.Code = ItemMaster.Status
                                    LEFT JOIN
                                        [$(Wholesale_Warehouse)].Marketing.SalesCategory
                                            ON SalesCategory.SalesCategory = ItemMaster.SalesCategory
                                    LEFT JOIN
                                        [$(Wholesale_Warehouse)].Marketing.ProductLineMaster
                                            ON ProductLineMaster.ProductLineCode = SalesCategory.ProductLine
                                WHERE
                                        (
                                            ItemCodeMaster.Description LIKE '%cocktail%'
                                            OR ItemCodeMaster.Description LIKE '%3 Pack%'
                                        )
                                        AND
                                            (
                                                ItemStatusCode.Description = 'Current'
                                                OR ItemStatusCode.Description = 'New'
                                                OR ItemStatusCode.Description = 'Introduction'
                                            )
                                        AND (ProductLineMaster.Description = 'Occasional')
                            ) B
                                ON A.SeriesCode = B.SeriesCode
                    GROUP BY
                            A.SeriesCode
                ) AS STSF;



            SELECT
                    ItemMaster.BlockingCode    SeriesCode,
                    CAST('True' AS CHAR(5)) flag
            INTO
                    #Recliner
            FROM
                    [$(Wholesale_Warehouse)].Marketing.ItemMaster
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemMaster     itm
                        ON ItemMaster.ItemSKU = itm.ItemSKU
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemCodeMaster
                        ON ItemCodeMaster.ItemCodeID = itm.ItemCodeID
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemStatusCode 
                        ON ItemStatusCode.Code = ItemMaster.Status
                LEFT JOIN
                    [$(Wholesale_Warehouse)].Marketing.SalesCategory
                        ON SalesCategory.SalesCategory = ItemMaster.SalesCategory
                LEFT JOIN
                    [$(Wholesale_Warehouse)].Marketing.ProductLineMaster
                        ON ProductLineMaster.ProductLineCode = SalesCategory.ProductLine
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemGrouping
                        ON ItemGrouping.ItemSKU = ItemMaster.ItemSKU
                           AND ItemGrouping.DefaultGroup = 1
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].SeriesGroupingLookup
                        ON SeriesGroupingLookup.LookupID = ItemGrouping.GroupID
            WHERE
                    (
                        (ItemCodeMaster.Description LIKE '%Recliner%')
                        AND
                            (
                                ItemStatusCode.Description = 'Current'
                                OR ItemStatusCode.Description = 'New'
                                OR ItemStatusCode.Description = 'Introduction'
                            )
                    )
                    AND
                        (
                            (
                                SeriesGroupingLookup.LookupCode = 'Stationary Upholstery'
                                OR SeriesGroupingLookup.LookupCode = 'Stationary Leather'
                                OR SeriesGroupingLookup.LookupCode = 'Motion Upholstery'
                                OR SeriesGroupingLookup.LookupCode = 'Motion Leather'
                                OR SeriesGroupingLookup.LookupCode = 'Sectionals'
                            )
                            AND
                                (
                                    ItemStatusCode.Description = 'Current'
                                    OR ItemStatusCode.Description = 'New'
                                    OR ItemStatusCode.Description = 'Introduction'
                                )
                        )
            GROUP BY
                    ItemMaster.BlockingCode;

            SELECT
                PMSF.SeriesCode,
                CAST('True' AS CHAR(5)) flag
            INTO
                #PowerMotion
            FROM
                (
                    SELECT
                            A.SeriesCode
                    FROM
                            (
                                SELECT
                                        ItemMaster.BlockingCode SeriesCode
                                FROM
                                        [$(Wholesale_Warehouse)].Marketing.ItemMaster
                                    LEFT JOIN
                                        [$(MasterData_Warehouse)].[ProductKnowledge].ItemMaster     itm
                                            ON ItemMaster.ItemSKU = itm.ItemSKU
                                    LEFT JOIN
                                        [$(MasterData_Warehouse)].[ProductKnowledge].ItemCodeMaster
                                            ON ItemCodeMaster.ItemCodeID = itm.ItemCodeID
                                    LEFT JOIN
                                        [$(MasterData_Warehouse)].[ProductKnowledge].ItemStatusCode 
                                            ON ItemStatusCode.Code = ItemMaster.Status
                                    LEFT JOIN
                                        [$(Wholesale_Warehouse)].Marketing.SalesCategory
                                            ON SalesCategory.SalesCategory = ItemMaster.SalesCategory
                                    LEFT JOIN
                                        [$(Wholesale_Warehouse)].Marketing.ProductLineMaster
                                            ON ProductLineMaster.ProductLineCode = SalesCategory.ProductLine
                                WHERE
                                        (ItemMaster.Description LIKE '%Power%')
                                        AND
                                            (
                                                ItemStatusCode.Description = 'Current'
                                                OR ItemStatusCode.Description = 'New'
                                                OR ItemStatusCode.Description = 'Introduction'
                                            )
                                        AND (itm.KeyItem = 1)
                                        AND (ProductLineMaster.Description = 'Motion')
                            ) A
                        INNER JOIN
                            (
                                SELECT
                                        ItemMaster.BlockingCode SeriesCode
                                FROM
                                        [$(Wholesale_Warehouse)].Marketing.ItemMaster
                                    LEFT JOIN
                                        [$(MasterData_Warehouse)].[ProductKnowledge].ItemMaster     itm
                                            ON ItemMaster.ItemSKU = itm.ItemSKU
                                    LEFT JOIN
                                        [$(MasterData_Warehouse)].[ProductKnowledge].ItemCodeMaster
                                            ON ItemCodeMaster.ItemCodeID = itm.ItemCodeID
                                    LEFT JOIN
                                        [$(MasterData_Warehouse)].[ProductKnowledge].ItemStatusCode 
                                            ON ItemStatusCode.Code = ItemMaster.Status
                                    LEFT JOIN
                                        [$(Wholesale_Warehouse)].Marketing.SalesCategory
                                            ON SalesCategory.SalesCategory = ItemMaster.SalesCategory
                                    LEFT JOIN
                                        [$(Wholesale_Warehouse)].Marketing.ProductLineMaster
                                            ON ProductLineMaster.ProductLineCode = SalesCategory.ProductLine
                                WHERE
                                        (ItemMaster.Description NOT LIKE '%Power%')
                                        AND
                                            (
                                                ItemStatusCode.Description = 'Current'
                                                OR ItemStatusCode.Description = 'New'
                                                OR ItemStatusCode.Description = 'Introduction'
                                            )
                                        AND (itm.KeyItem = 1)
                                        AND (ProductLineMaster.Description = 'Motion')
                            ) B
                                ON A.SeriesCode = B.SeriesCode
                    GROUP BY
                            A.SeriesCode
                ) AS PMSF;



            SELECT
                    ItemMaster.BlockingCode    SeriesCode,
                    CAST('True' AS CHAR(5)) flag
            INTO
                    #WedgeOption
            FROM
                    [$(Wholesale_Warehouse)].Marketing.ItemMaster
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemMaster     itm
                        ON ItemMaster.ItemSKU = itm.ItemSKU
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemCodeMaster
                        ON ItemCodeMaster.ItemCodeID = itm.ItemCodeID
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemStatusCode 
                        ON ItemStatusCode.Code = ItemMaster.Status
                LEFT JOIN
                    [$(Wholesale_Warehouse)].Marketing.SalesCategory
                        ON SalesCategory.SalesCategory = ItemMaster.SalesCategory
                LEFT JOIN
                    [$(Wholesale_Warehouse)].Marketing.ProductLineMaster
                        ON ProductLineMaster.ProductLineCode = SalesCategory.ProductLine
            WHERE
                    (
                        (ItemMaster.Description LIKE '%Wedge%')
                        AND
                            (
                                ItemStatusCode.Description = 'Current'
                                OR ItemStatusCode.Description = 'New'
                                OR ItemStatusCode.Description = 'Introduction'
                            )
                    )
                    AND (itm.KeyItem = 0)
                    AND (ProductLineMaster.Description = 'Motion')
            GROUP BY
                    ItemMaster.BlockingCode;


            SELECT
                    ItemMaster.BlockingCode    SeriesCode,
                    CAST('True' AS CHAR(5)) flag
            INTO
                    #DiningBench
            FROM
                    [$(Wholesale_Warehouse)].Marketing.ItemMaster
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemMaster     itm
                        ON ItemMaster.ItemSKU = itm.ItemSKU
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemCodeMaster
                        ON ItemCodeMaster.ItemCodeID = itm.ItemCodeID
                LEFT JOIN
                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemStatusCode 
                        ON ItemStatusCode.Code = ItemMaster.Status
                LEFT JOIN
                    [$(Wholesale_Warehouse)].Marketing.SalesCategory
                        ON SalesCategory.SalesCategory = ItemMaster.SalesCategory
                LEFT JOIN
                    [$(Wholesale_Warehouse)].Marketing.ProductLineMaster
                        ON ProductLineMaster.ProductLineCode = SalesCategory.ProductLine
            WHERE
                    (
                        (ItemCodeMaster.Description LIKE '%Bench%')
                        AND
                            (
                                ItemStatusCode.Description = 'Current'
                                OR ItemStatusCode.Description = 'New'
                                OR ItemStatusCode.Description = 'Introduction'
                            )
                    )
                    AND (ProductLineMaster.Description = 'Dining')
            GROUP BY
                    ItemMaster.BlockingCode;




            SELECT
                Division               AS AltDivision,
                ProductLine,
                ItemGrouping,
                ItemSKU,
                CAST('YES' AS CHAR(5)) flag
            INTO
                #Accessories
            FROM
                (
                    SELECT
                            [AFI Alternate Division]                                                                              Division,
                            ProductLineMaster.Description                                                                         AS ProductLine,
                            ISNULL(SeriesGroupingLookup.LookupCode, 'N/A')                                                        ItemGrouping,
                            ItemMaster.ItemSKU,
                            SUM(CAST((Quantity * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)) AS DECIMAL(13, 3))) QuantityOrdered,
                            ROW_NUMBER() OVER (PARTITION BY
                                                   SeriesGroupingLookup.LookupCode
                                               ORDER BY
                                                   SUM(CAST((Quantity
                                                             * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                                                            ) AS DECIMAL(13, 3))
                                                      ) DESC
                                              )                                                                                   rn
                    FROM
                            [$(Wholesale_Warehouse)].Marketing.ItemMaster
                        LEFT JOIN
                            [$(MasterData_Warehouse)].[ProductKnowledge].ItemGrouping
                                ON ItemGrouping.ItemSKU = ItemMaster.ItemSKU
                                   AND ItemGrouping.DefaultGroup = 1
                        LEFT JOIN
                            [$(MasterData_Warehouse)].[ProductKnowledge].SeriesGroupingLookup
                                ON SeriesGroupingLookup.LookupID = ItemGrouping.GroupID
                        LEFT JOIN
                            [$(MasterData_Warehouse)].[ProductKnowledge].ItemMaster     itm
                                ON ItemMaster.ItemSKU = itm.ItemSKU
                        LEFT JOIN
                            [$(Wholesale_Warehouse)].Marketing.MarketLookup
                                ON MarketLookup.MarketID = itm.Market
                        LEFT JOIN
                            [$(Wholesale_Warehouse)].Marketing.SalesCategory
                                ON SalesCategory.SalesCategory = ItemMaster.SalesCategory
                        LEFT JOIN
                            [$(Wholesale_Warehouse)].Marketing.ProductLineMaster
                                ON ProductLineMaster.ProductLineCode = SalesCategory.ProductLine
                        LEFT JOIN
                            [$(MasterData_Warehouse)].[ProductKnowledge].ItemStatusCode SC2
                                ON SC2.Code = ItemMaster.Status
                        JOIN
                            [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                ON OrderHistory.ItemSKU = ItemMaster.ItemSKU
                        JOIN
                            AFISales_DW.DimCustomers                            C
                                ON [C].[Customer Account Number] = CustomerNumber
                                   AND [C].[Customer Shipto Number] = ShiptoNumber
                        LEFT JOIN
                            AFISales_Enh.TerritoryAllocationStatic
                                ON CASE
                                       WHEN CAST(C.[Shipto Sales Territory] AS INT) <> 0
                                           THEN
                                           [C].[Shipto Sales Territory]
                                       ELSE
                                           [C].[Primary Sales Territory]
                                   END = TerritoryAllocationStatic.TerritoryCode
                                   AND ItemMaster.SalesCategory = TerritoryAllocationStatic.SalesCategory
                        LEFT JOIN
                            AFISales_DW.[DimSalesTerritories]                   TR
                                ON TR.[AFI Sales Region Code] = ISNULL(TerritoryAllocationStatic.RegionCode, CAST('Z' AS CHAR(3)))
                                   AND TR.[AFI Sales RepID] = ISNULL(TerritoryAllocationStatic.RepID, CAST('ZZZZZ' AS CHAR(5)))
                                   AND TR.[AFI Sales Category] = ISNULL(ItemMaster.SalesCategory, CAST('ZZ' AS CHAR(3)))
                                   AND TR.[Active Record] = 1

                    --Excluding exclusives, Supplier Direct Ship, AND Rent-A-Center
                    WHERE
                            [AFI Alternate Division] = 'Signature Accessory'
                            AND itm.ExclusiveComment = '' 
                            AND MarketLookup.Code <> 'Supplier Direct Ship'
                            AND CAST(OrderChangeDate AS DATE) >= DATEADD(DAY, -90, GETDATE())
                            AND [Customer Account Number] <> 1256500
                            AND ItemMaster.ActiveRecord <> 'D'
                            AND ItemMaster.Status NOT IN (
                                                             'D', 'R'
                                                         )
                    GROUP BY
                            [AFI Alternate Division],
                            ProductLineMaster.Description,
                            SeriesGroupingLookup.LookupCode,
                            ItemMaster.ItemSKU
                ) A
            WHERE
                A.rn <= 12;

            -- All other product line is calculated based on last 90 days of quantity ordered at the frame number level for each item grouping

            SELECT
                B.Division             AS AltDivision,
                B.ProductLine,
                B.ItemGrouping,
                B.FrameNumber,
                CAST('YES' AS CHAR(5)) flag
            INTO
                #NotAccessories
            FROM
                (
                    SELECT
                        Division,
                        ProductLine,
                        ItemGrouping,
                        FrameNumber,
                        SUM(QuantityOrdered) QuantityOrdered,
                        ROW_NUMBER() OVER (PARTITION BY
                                               Division,
                                               ProductLine,
                                               ItemGrouping
                                           ORDER BY
                                               SUM(CAST(QuantityOrdered AS DECIMAL(13, 3))) DESC
                                          )  rn
                    FROM
                        (
                            SELECT
                                    [AFI Alternate Division]                                                                             Division,
                                    ProductLineMaster.Description                                                                        ProductLine,
                                    ISNULL(SeriesGroupingLookup.LookupCode, 'N/A')                                                       ItemGrouping,
                                    CASE
                                        WHEN ISNULL(SeriesGroupingLookup.LookupCode, 'N/A') IN (
                                                                                                   'Chairs',
                                                                                                   'Motion Leather',
                                                                                                   'Motion Upholstery',
                                                                                                   'Recliners',
                                                                                                   'Sectionals',
                                                                                                   'Stationary Leather',
                                                                                                   'Stationary Upholstery'
                                                                                               )
                                            THEN
                                            CASE
                                                WHEN LEFT(ItemMaster.ItemSKU, 1) = 'U'
                                                    THEN
                                                    LEFT(ItemMaster.ItemSKU, 4)
                                                ELSE
                                                    LEFT(ItemMaster.ItemSKU, 3)
                                            END
                                        ELSE
                                            ISNULL(itm.SeriesCode, 'N/A')
                                    END                                                                                                  AS FrameNumber,
                                    SUM(CAST((Quantity * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)) AS DECIMAL(13, 3))) QuantityOrdered
                            FROM
                                    [$(Wholesale_Warehouse)].Marketing.ItemMaster
                                LEFT JOIN
                                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemGrouping
                                        ON ItemGrouping.ItemSKU = ItemMaster.ItemSKU
                                           AND ItemGrouping.DefaultGroup = 1
                                LEFT JOIN
                                    [$(MasterData_Warehouse)].[ProductKnowledge].SeriesGroupingLookup
                                        ON SeriesGroupingLookup.LookupID = ItemGrouping.GroupID
                                LEFT JOIN
                                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemMaster itm
                                        ON ItemMaster.ItemSKU = itm.ItemSKU
                                LEFT JOIN
                                    [$(Wholesale_Warehouse)].Marketing.MarketLookup
                                        ON MarketLookup.MarketID = itm.Market
                                LEFT JOIN
                                    [$(Wholesale_Warehouse)].Marketing.SalesCategory
                                        ON SalesCategory.SalesCategory = ItemMaster.SalesCategory
                                LEFT JOIN
                                    [$(Wholesale_Warehouse)].Marketing.ProductLineMaster
                                        ON ProductLineMaster.ProductLineCode = SalesCategory.ProductLine
                                JOIN
                                    [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                        ON OrderHistory.ItemSKU = ItemMaster.ItemSKU
                                JOIN
                                    AFISales_DW.DimCustomers                        C
                                        ON [C].[Customer Account Number] = CustomerNumber
                                           AND [C].[Customer Shipto Number] = ShiptoNumber
                                LEFT JOIN
                                    AFISales_Enh.TerritoryAllocationStatic
                                        ON CASE
                                               WHEN CAST(C.[Shipto Sales Territory] AS INT) <> 0
                                                   THEN
                                                   [C].[Shipto Sales Territory]
                                               ELSE
                                                   [C].[Primary Sales Territory]
                                           END = TerritoryAllocationStatic.TerritoryCode
                                           AND ItemMaster.SalesCategory = TerritoryAllocationStatic.SalesCategory
                                LEFT JOIN
                                    AFISales_DW.[DimSalesTerritories]               TR
                                        ON TR.[AFI Sales Region Code] = ISNULL(
                                                                                  TerritoryAllocationStatic.RegionCode,
                                                                                  CAST('Z' AS CHAR(3))
                                                                              )
                                           AND TR.[AFI Sales RepID] = ISNULL(
                                                                                TerritoryAllocationStatic.RepID,
                                                                                CAST('ZZZZZ' AS CHAR(5))
                                                                            )
                                           AND TR.[AFI Sales Category] = ISNULL(
                                                                                   ItemMaster.SalesCategory,
                                                                                   CAST('ZZ' AS CHAR(3))
                                                                               )
                                           AND TR.[Active Record] = 1
                            --Excluding exclusives, Supplier Direct Ship, AND Rent-A-Center
                            WHERE
                                    [AFI Alternate Division] IN (
                                                                    'Bedding', 'Motion', 'Stationary', 'Signature Outdoor'
                                                                )
                                    AND itm.ExclusiveComment = ''
                                    AND MarketLookup.Code <> 'Supplier Direct Ship'
                                    AND CAST(OrderChangeDate AS DATE) >= DATEADD(DAY, -90, GETDATE())
                                    AND [Customer Account Number] <> 1256500
                                    AND ItemMaster.ActiveRecord <> 'D'
                                    AND ItemMaster.Status NOT IN (
                                                                     'D', 'R'
                                                                 )
                            GROUP BY
                                    [AFI Alternate Division],
                                    ProductLineMaster.Description,
                                    ISNULL(SeriesGroupingLookup.LookupCode, 'N/A'),
                                    CASE
                                        WHEN ISNULL(SeriesGroupingLookup.LookupCode, 'N/A') IN (
                                                                                                   'Chairs',
                                                                                                   'Motion Leather',
                                                                                                   'Motion Upholstery',
                                                                                                   'Recliners',
                                                                                                   'Sectionals',
                                                                                                   'Stationary Leather',
                                                                                                   'Stationary Upholstery'
                                                                                               )
                                            THEN
                                            CASE
                                                WHEN LEFT(ItemMaster.ItemSKU, 1) = 'U'
                                                    THEN
                                                    LEFT(ItemMaster.ItemSKU, 4)
                                                ELSE
                                                    LEFT(ItemMaster.ItemSKU, 3)
                                            END
                                        ELSE
                                            ISNULL(itm.SeriesCode, 'N/A')
                                    END
                        ) A
                    GROUP BY
                        Division,
                        ProductLine,
                        ItemGrouping,
                        FrameNumber
                ) B
            --Outdoor AND Bedding show the top 6 frames.  All other categories show top 12
            WHERE
                B.Division IN (
                                  'Bedding', 'Signature Outdoor'
                              )
                AND B.rn <= 6
                OR B.Division NOT IN (
                                         'Bedding', 'Signature Outdoor'
                                     )
                   AND B.rn <= 12;

            -- Casegoods is calculated based on last 90 days of quantity ordered at the frame number level AND import domestic level for Master AND Youth Bedroom

            SELECT
                B.Division             AS AltDivision,
                B.ProductLine,
                B.ItemGrouping,
                B.ImportDomesticCode,
                B.FrameNumber,
                CAST('YES' AS CHAR(5)) Flag
            INTO
                #Casegoods_Bedroom
            FROM
                (
                    SELECT
                        A.Division,
                        A.ProductLine,
                        A.ItemGrouping,
                        A.ImportDomesticCode,
                        A.FrameNumber,
                        SUM(A.QuantityOrdered) AS QuantityOrdered,
                        ROW_NUMBER() OVER (PARTITION BY
                                               A.Division,
                                               A.ProductLine,
                                               A.ItemGrouping,
                                               A.ImportDomesticCode
                                           ORDER BY
                                               SUM(CAST(A.QuantityOrdered AS DECIMAL(13, 3))) DESC
                                          )  rn
                    FROM
                        (
                            SELECT
                                    [AFI Alternate Division]                                                                              Division,
                                    ProductLineMaster.Description                                                                         ProductLine,
                                    ISNULL(SeriesGroupingLookup.LookupCode, 'N/A')                                                        ItemGrouping,
                                    ItemMaster.ImportDomesticCode,
                                    CASE
                                        WHEN ISNULL(SeriesGroupingLookup.LookupCode, 'N/A') IN (
                                                                                                   'Chairs',
                                                                                                   'Motion Leather',
                                                                                                   'Motion Upholstery',
                                                                                                   'Recliners',
                                                                                                   'Sectionals',
                                                                                                   'Stationary Leather',
                                                                                                   'Stationary Upholstery'
                                                                                               )
                                            THEN
                                            CASE
                                                WHEN LEFT(ItemMaster.ItemSKU, 1) = 'U'
                                                    THEN
                                                    LEFT(ItemMaster.ItemSKU, 4)
                                                ELSE
                                                    LEFT(ItemMaster.ItemSKU, 3)
                                            END
                                        ELSE
                                            ISNULL(itm.SeriesCode, 'N/A')
                                    END                                                                                                   FrameNumber,
                                    SUM(CAST((Quantity * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)) AS DECIMAL(13, 3))) QuantityOrdered
                            FROM
                                    [$(Wholesale_Warehouse)].Marketing.ItemMaster
                                LEFT JOIN
                                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemGrouping
                                        ON ItemGrouping.ItemSKU = ItemMaster.ItemSKU
                                           AND ItemGrouping.DefaultGroup = 1
                                LEFT JOIN
                                    [$(MasterData_Warehouse)].[ProductKnowledge].SeriesGroupingLookup
                                        ON SeriesGroupingLookup.LookupID = ItemGrouping.GroupID
                                LEFT JOIN
                                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemMaster itm
                                        ON ItemMaster.ItemSKU = itm.ItemSKU
                                LEFT JOIN
                                    [$(Wholesale_Warehouse)].Marketing.MarketLookup
                                        ON MarketLookup.MarketID = itm.Market
                                LEFT JOIN
                                    [$(Wholesale_Warehouse)].Marketing.SalesCategory
                                        ON SalesCategory.SalesCategory = ItemMaster.SalesCategory
                                LEFT JOIN
                                    [$(Wholesale_Warehouse)].Marketing.ProductLineMaster
                                        ON ProductLineMaster.ProductLineCode = SalesCategory.ProductLine
                                JOIN
                                    [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                        ON OrderHistory.ItemSKU = ItemMaster.ItemSKU
                                JOIN
                                    AFISales_DW.DimCustomers                        C
                                        ON [C].[Customer Account Number] = CustomerNumber
                                           AND [C].[Customer Shipto Number] = ShiptoNumber
                                LEFT JOIN
                                    AFISales_Enh.TerritoryAllocationStatic
                                        ON CASE
                                               WHEN CAST(C.[Shipto Sales Territory] AS INT) <> 0
                                                   THEN
                                                   [C].[Shipto Sales Territory]
                                               ELSE
                                                   [C].[Primary Sales Territory]
                                           END = TerritoryAllocationStatic.TerritoryCode
                                           AND ItemMaster.SalesCategory = TerritoryAllocationStatic.SalesCategory
                                LEFT JOIN
                                    AFISales_DW.[DimSalesTerritories]               TR
                                        ON TR.[AFI Sales Region Code] = ISNULL(
                                                                                  TerritoryAllocationStatic.RegionCode,
                                                                                  CAST('Z' AS CHAR(3))
                                                                              )
                                           AND TR.[AFI Sales RepID] = ISNULL(
                                                                                TerritoryAllocationStatic.RepID,
                                                                                CAST('ZZZZZ' AS CHAR(5))
                                                                            )
                                           AND TR.[AFI Sales Category] = ISNULL(
                                                                                   ItemMaster.SalesCategory,
                                                                                   CAST('ZZ' AS CHAR(3))
                                                                               )
                                           AND TR.[Active Record] = 1
                            --Excluding exclusives, Supplier Direct Ship, AND Rent-A-Center
                            WHERE
                                    [AFI Alternate Division] = 'Casegoods'
                                    AND itm.ExclusiveComment = ''
                                    AND MarketLookup.MarketID <> 'Supplier Direct Ship' 
                                    AND CAST(OrderChangeDate AS DATE) >= DATEADD(DAY, -90, GETDATE())
                                    AND [Customer Account Number] <> '1256500'
                                    AND ItemMaster.ActiveRecord <> 'D'
                                    AND ItemMaster.Status NOT IN (
                                                                     'D', 'R'
                                                                 )
                                    AND SeriesGroupingLookup.LookupCode IN (
                                                                               'Master Bedroom', 'Youth Bedroom'
                                                                           )
                            GROUP BY
                                    [AFI Alternate Division],
                                    ProductLineMaster.Description,
                                    ISNULL(SeriesGroupingLookup.LookupCode, 'N/A'),
                                    ItemMaster.ImportDomesticCode,
                                    CASE
                                        WHEN ISNULL(SeriesGroupingLookup.LookupCode, 'N/A') IN (
                                                                                                   'Chairs',
                                                                                                   'Motion Leather',
                                                                                                   'Motion Upholstery',
                                                                                                   'Recliners',
                                                                                                   'Sectionals',
                                                                                                   'Stationary Leather',
                                                                                                   'Stationary Upholstery'
                                                                                               )
                                            THEN
                                            CASE
                                                WHEN LEFT(ItemMaster.ItemSKU, 1) = 'U'
                                                    THEN
                                                    LEFT(ItemMaster.ItemSKU, 4)
                                                ELSE
                                                    LEFT(ItemMaster.ItemSKU, 3)
                                            END
                                        ELSE
                                            ISNULL(itm.SeriesCode, 'N/A')
                                    END
                        ) A
                    GROUP BY
                        A.Division,
                        A.ProductLine,
                        A.ItemGrouping,
                        A.ImportDomesticCode,
                        A.FrameNumber
                ) B
            WHERE
                B.rn <= 12;

            -- Casegoods is calculated based on last 90 days of quantity ordered at the frame number level for Dining

            SELECT
                B.Division             AS AltDivision,
                B.ProductLine,
                B.ItemGrouping,
                B.FrameNumber,
                CAST('YES' AS CHAR(5)) Flag
            INTO
                #Casegoods_NotBedroom
            FROM
                (
                    SELECT
                        A.Division,
                        A.ProductLine,
                        A.ItemGrouping,
                        A.FrameNumber,
                        SUM(A.QuantityOrdered) AS QuantityOrdered,
                        ROW_NUMBER() OVER (PARTITION BY
                                               A.Division,
                                               A.ProductLine,
                                               A.ItemGrouping
                                           ORDER BY
                                               SUM(CAST(A.QuantityOrdered AS DECIMAL(13, 3))) DESC
                                          )  rn
                    FROM
                        (
                            SELECT
                                    [AFI Alternate Division]                                                                              Division,
                                    ProductLineMaster.Description                                                                         ProductLine,
                                    ISNULL(SeriesGroupingLookup.LookupCode, 'N/A')                                                        ItemGrouping,
                                    CASE
                                        WHEN ISNULL(SeriesGroupingLookup.LookupCode, 'N/A') IN (
                                                                                                   'Chairs',
                                                                                                   'Motion Leather',
                                                                                                   'Motion Upholstery',
                                                                                                   'Recliners',
                                                                                                   'Sectionals',
                                                                                                   'Stationary Leather',
                                                                                                   'Stationary Upholstery'
                                                                                               )
                                            THEN
                                            CASE
                                                WHEN LEFT(ItemMaster.ItemSKU, 1) = 'U'
                                                    THEN
                                                    LEFT(ItemMaster.ItemSKU, 4)
                                                ELSE
                                                    LEFT(ItemMaster.ItemSKU, 3)
                                            END
                                        ELSE
                                            ISNULL(itm.SeriesCode, 'N/A')
                                    END                                                                                                   FrameNumber,
                                    SUM(CAST((Quantity * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)) AS DECIMAL(13, 3))) QuantityOrdered
                            FROM
                                    [$(Wholesale_Warehouse)].Marketing.ItemMaster
                                LEFT JOIN
                                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemGrouping
                                        ON ItemGrouping.ItemSKU = ItemMaster.ItemSKU
                                           AND ItemGrouping.DefaultGroup = 1
                                LEFT JOIN
                                    [$(MasterData_Warehouse)].[ProductKnowledge].SeriesGroupingLookup
                                        ON SeriesGroupingLookup.LookupID = ItemGrouping.GroupID
                                LEFT JOIN
                                    [$(MasterData_Warehouse)].[ProductKnowledge].ItemMaster itm
                                        ON ItemMaster.ItemSKU = itm.ItemSKU
                                LEFT JOIN
                                    [$(Wholesale_Warehouse)].Marketing.MarketLookup
                                        ON MarketLookup.MarketID = itm.Market
                                LEFT JOIN
                                    [$(Wholesale_Warehouse)].Marketing.SalesCategory
                                        ON SalesCategory.SalesCategory = ItemMaster.SalesCategory
                                LEFT JOIN
                                    [$(Wholesale_Warehouse)].Marketing.ProductLineMaster
                                        ON ProductLineMaster.ProductLineCode = SalesCategory.ProductLine
                                JOIN
                                    [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                        ON OrderHistory.ItemSKU = ItemMaster.ItemSKU
                                JOIN
                                    AFISales_DW.DimCustomers                        C
                                        ON [C].[Customer Account Number] = CustomerNumber
                                           AND [C].[Customer Shipto Number] = ShiptoNumber
                                LEFT JOIN
                                    AFISales_Enh.TerritoryAllocationStatic
                                        ON CASE
                                               WHEN CAST(C.[Shipto Sales Territory] AS INT) <> 0
                                                   THEN
                                                   [C].[Shipto Sales Territory]
                                               ELSE
                                                   [C].[Primary Sales Territory]
                                           END = TerritoryAllocationStatic.TerritoryCode
                                           AND ItemMaster.SalesCategory = TerritoryAllocationStatic.SalesCategory
                                LEFT JOIN
                                    AFISales_DW.[DimSalesTerritories]               TR
                                        ON TR.[AFI Sales Region Code] = ISNULL(
                                                                                  TerritoryAllocationStatic.RegionCode,
                                                                                  CAST('Z' AS CHAR(3))
                                                                              )
                                           AND TR.[AFI Sales RepID] = ISNULL(
                                                                                TerritoryAllocationStatic.RepID,
                                                                                CAST('ZZZZZ' AS CHAR(5))
                                                                            )
                                           AND TR.[AFI Sales Category] = ISNULL(
                                                                                   ItemMaster.SalesCategory,
                                                                                   CAST('ZZ' AS CHAR(3))
                                                                               )
                                           AND TR.[Active Record] = 1
                            --Excluding exclusives, Supplier Direct Ship, AND Rent-A-Center
                            WHERE
                                    [AFI Alternate Division] = 'Casegoods'
                                    AND itm.ExclusiveComment = ''
                                    AND MarketLookup.Code <> 'Supplier Direct Ship'
                                    AND CAST(OrderChangeDate AS DATE) >= DATEADD(DAY, -90, GETDATE())
                                    AND [Customer Account Number] <> 1256500
                                    AND ItemMaster.ActiveRecord <> 'D'
                                    AND ItemMaster.Status NOT IN (
                                                                     'D', 'R'
                                                                 )
                                    AND SeriesGroupingLookup.LookupCode NOT IN (
                                                                                   'Master Bedroom', 'Youth Bedroom'
                                                                               )
                            GROUP BY
                                    [AFI Alternate Division],
                                    ProductLineMaster.Description,
                                    ISNULL(SeriesGroupingLookup.LookupCode, 'N/A'),
                                    CASE
                                        WHEN ISNULL(SeriesGroupingLookup.LookupCode, 'N/A') IN (
                                                                                                   'Chairs',
                                                                                                   'Motion Leather',
                                                                                                   'Motion Upholstery',
                                                                                                   'Recliners',
                                                                                                   'Sectionals',
                                                                                                   'Stationary Leather',
                                                                                                   'Stationary Upholstery'
                                                                                               )
                                            THEN
                                            CASE
                                                WHEN LEFT(ItemMaster.ItemSKU, 1) = 'U'
                                                    THEN
                                                    LEFT(ItemMaster.ItemSKU, 4)
                                                ELSE
                                                    LEFT(ItemMaster.ItemSKU, 3)
                                            END
                                        ELSE
                                            ISNULL(itm.SeriesCode, 'N/A')
                                    END
                        ) A
                    GROUP BY
                        A.Division,
                        A.ProductLine,
                        A.ItemGrouping,
                        A.FrameNumber
                ) B
            WHERE
                B.rn <= 12;



            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                'AFISales_DW.DimItemMaster_LOAD';


            CREATE TABLE AFISales_DW.DimItemMaster_Load
                (
                    [RowID]                          BIGINT        NOT NULL, -- IDENTITY (1, 1) 
                    [ItemSKU]                        VARCHAR(15)   NOT NULL,
                    [ItemKey]                        VARCHAR(22)   NOT NULL,
                    [Item]                           VARCHAR(15)   NULL,
                    [ItemCode]                       VARCHAR(25)   NULL,
                    [SeriesCode]                     VARCHAR(5)    NULL,
                    [ExtSeriesCode]                  VARCHAR(16)   NULL,
                    [FrameNumber]                    VARCHAR(16)   NULL,
                    [QtyInBox]                       DECIMAL(4)    NULL,
                    [UOM]                            CHAR(2)       NULL,
                    [Cubes]                          DECIMAL(5, 2) NULL,
                    [Seats]                          DECIMAL(5, 2) NULL,
                    [ItemDescription]                VARCHAR(30)   NULL,
                    [SeriesName]                     VARCHAR(100)  NULL,
                    [SeriesColor]                    VARCHAR(60)   NULL,
                    [Colors]                         VARCHAR(25)   NULL,
                    [ItemDescriptionSeries]          VARCHAR(131)  NULL,
                    [SHItemDescriptionSeries]        VARCHAR(147)  NULL,
                    [SHSeriesDescription]            VARCHAR(106)  NULL,
                    [ItemDescriptionSeriesItemColor] VARCHAR(173)  NULL,
                    [ChildStyleDescription]          VARCHAR(65)   NULL,
                    [ParentStyleDescription]         VARCHAR(65)   NULL,
                    [SeriesDescription]              VARCHAR(117)  NULL,
                    [ItemConsumerDescription]        VARCHAR(100)  NULL,
                    [RetailTypeDescription]          VARCHAR(50)   NULL,
                    [MainPieceItem]                  VARCHAR(5)    NULL,
                    [ItemClass]                      VARCHAR(32)   NULL,
                    [ItemClassCode]                  CHAR(4)       NULL,
                    [ItemClassName]                  VARCHAR(25)   NULL,
                    [ProductLine]                    VARCHAR(25)   NULL,
                    [RetailCategoryCode]             CHAR(3)       NULL,
                    [RetailCategoryDescription]      VARCHAR(30)   NULL,
                    [RetailCategoryName]             VARCHAR(50)   NULL,
                    [RetailDepartmentName]           VARCHAR(50)   NULL,
                    [RetailCategoryGroup]            VARCHAR(50)   NULL,
                    [AFIFinanceDivision]             VARCHAR(30)   NULL,
                    [AFISalesCategoryCode]           CHAR(3)       NULL,
                    [AFISalesCategory]               VARCHAR(25)   NULL,
                    [ItemStyleCode]                  CHAR(3)       NULL,
                    [ItemStyleGroup]                 VARCHAR(20)   NULL,
                    [ItemStyle]                      VARCHAR(65)   NULL,
                    [Division]                       VARCHAR(25)   NULL,
                    [AFISalesDivisionCode]           CHAR(1)       NULL,
                    [AFISalesDivision]               VARCHAR(25)   NULL,
                    [KeyItem]                        INT           NULL,
                    [SalesClassCode]                 CHAR(2)       NULL,
                    [SalesClassDescription]          VARCHAR(25)   NULL,
                    [SalesClass]                     VARCHAR(30)   NULL,
                    [DiscountClassCode]              CHAR(2)       NULL,
                    [DiscountClassDescription]       VARCHAR(25)   NULL,
                    [DiscountClass]                  VARCHAR(30)   NULL,
                    [CommissionClassCode]            CHAR(2)       NULL,
                    [CommissionClassDescription]     VARCHAR(25)   NULL,
                    [CommissionClass]                VARCHAR(30)   NULL,
                    [FreightClassCode]               CHAR(2)       NULL,
                    [FreightClassDescription]        VARCHAR(25)   NULL,
                    [FreightClass]                   VARCHAR(30)   NULL,
                    [AFIItemStatus]                  CHAR(1)       NULL,
                    [SellableItemFlag]               CHAR(1)       NULL,
                    [ManufacturingStatus]            VARCHAR(25)   NULL,
                    [ResponsibleOffice]              VARCHAR(10)   NULL,
                    [ImportDomesticCode]             CHAR(1)       NULL,
                    [CountryofOrigin]                VARCHAR(30)   NULL,
                    [PrimaryVendor]                  CHAR(8)       NULL,
                    [ManufacturingStatusChangeDate]  DATE          NULL,
                    [ItemForecastPlannerID]          VARCHAR(8)    NULL,
                    [NewItemFlag]                    INT           NULL,
                    [DiscontinuedFlag]               INT           NULL,
                    [DiscontinuedYearPeriod]         VARCHAR(7)    NULL,
                    [CommonCarrierFlag]              CHAR(1)       NULL,
                    [ExpressShipFlag]                CHAR(1)       NULL,
                    [DiscontinuedDate]               DATE          NULL,
                    [CEXCode]                        CHAR(3)       NULL,
                    [MarketIntroducedAt]             VARCHAR(30)   NULL,
                    [MerchandisingCategory]          SMALLINT      NULL,
                    [PricePoint]                     INT           NULL,
                    [ItemGrouping]                   VARCHAR(35)   NULL,
                    [AssociationCode]                VARCHAR(35)   NULL,
                    [MarketingItemStatus]            CHAR(1)       NULL,
                    [MarketingStatusDescription]     VARCHAR(25)   NULL,
                    [Lifestyle]                      VARCHAR(65)   NULL,
                    [CommodityItem]                  INT           NULL,
                    [F123ProductFlag]                INT           NULL,
                    [HSCoreProductFlag]              INT           NULL,
                    [HSProprietaryProductFlag]       INT           NULL,
                    [HSExclusiveFlag]                INT           NULL,
                    [BerklineProductFlag]            INT           NULL,
                    [BenchcraftProductFlag]          INT           NULL,
                    [NewMillenniumProductFlag]       INT           NULL,
                    [BardiniProductFlag]             INT           NULL,
                    [ShanghaiStore]                  INT           NULL,
                    [DefaultGroup]                   INT           NULL,
                    [GoodBetterBestForPricePoint]    VARCHAR(6)    NULL,
                    [GBBSortID]                      INT           NULL,
                    [InitialInvoicePeriod]           VARCHAR(7)    NULL,
                    [InitialInvoiceQty]              DECIMAL(38)   NULL,
                    [MarketBeginDate]                DATE          NULL,
                    [MarketEndDate]                  DATE          NULL,
                    [Showroom]                       VARCHAR(25)   NULL,
                    [ItemImage]                      VARCHAR(50)   NULL,
                    [FOBArcPrice]                    DECIMAL(8, 2) NULL,
                    [TrendArrow]                     VARCHAR(20)   NULL,
                    [ItemMerchGridOverridePhoto]     VARCHAR(8000) NULL,
                    [ExclusiveComment]               VARCHAR(60)   NULL,
                    [SeriesImage]                    VARCHAR(50)   NULL,
                    [SofaTableSeriesFlag]            VARCHAR(5)    NULL,
                    [ReclinerSeriesFlag]             VARCHAR(5)    NULL,
                    [PowerMotionSeriesFlag]          VARCHAR(5)    NULL,
                    [WedgeSeriesFlag]                VARCHAR(5)    NULL,
                    [DiningSeriesFlag]               VARCHAR(5)    NULL,
                    [ItemThirdPartyItem]             VARCHAR(100)  NULL,
                    [ItemSupplierDirectShipOnly]     VARCHAR(100)  NULL,
                    [ConsumerChoiceFlag]             VARCHAR(5)    NULL,
                    [SeriesMainImage]                VARCHAR(100)  NULL,
                    [CollectiveClass]                VARCHAR(100)  NULL,
                    [CollectiveClassCode]            CHAR(4)       NULL,
                    [DelayedProductFlag]             VARCHAR(1)    NULL,
                    [ItemFluffAFI]                   VARCHAR(5000) NULL,
                    [ItemMaterial]                   VARCHAR(300)  NULL,
                    [ItemKnockout]                   VARCHAR(100)  NULL,
                    [ItemStandAloneFlag]             VARCHAR(100)  NULL,
                    [ItemScene7ImageSet]             VARCHAR(100)  NULL,
                    [ItemUPC]                        VARCHAR(100)  NULL,
                    [SeriesFeatures]                 VARCHAR(2500) NULL,
                    [PrimariesLifestyle]             VARCHAR(100)  NULL,
                    [ItemIsRTA]                      VARCHAR(6)    NULL,
                    [PreviousStatusCode]             CHAR (1)      NULL
                );
            INSERT INTO AFISales_DW.DimItemMaster_Load
                (
                    ItemSKU,
                    ItemKey,
                    Item,
                    ItemCode,
                    SeriesCode,
                    ExtSeriesCode,
                    FrameNumber,
                    QtyInBox,
                    UOM,
                    Cubes,
                    Seats,
                    ItemDescription,
                    SeriesName,
                    SeriesColor,
                    Colors,
                    ItemDescriptionSeries,
                    SHItemDescriptionSeries,
                    SHSeriesDescription,
                    ItemDescriptionSeriesItemColor,
                    ChildStyleDescription,
                    ParentStyleDescription,
                    SeriesDescription,
                    ItemConsumerDescription,
                    RetailTypeDescription,
                    MainPieceItem,
                    ItemClass,
                    ItemClassCode,
                    ItemClassName,
                    ProductLine,
                    RetailCategoryCode,
                    RetailCategoryDescription,
                    RetailCategoryName,
                    RetailDepartmentName,
                    RetailCategoryGroup,
                    AFIFinanceDivision,
                    -- AFIFinanceDivisionCode,
                    AFISalesCategoryCode,
                    AFISalesCategory,
                    ItemStyleCode,
                    ItemStyleGroup,
                    ItemStyle,
                    Division,
                    AFISalesDivisionCode,
                    AFISalesDivision,
                    KeyItem,
                    SalesClassCode,
                    SalesClassDescription,
                    SalesClass,
                    DiscountClassCode,
                    DiscountClassDescription,
                    DiscountClass,
                    CommissionClassCode,
                    CommissionClassDescription,
                    CommissionClass,
                    FreightClassCode,
                    FreightClassDescription,
                    FreightClass,
                    AFIItemStatus,
                    SellableItemFlag,
                    ManufacturingStatus,
                    ResponsibleOffice,
                    ImportDomesticCode,
                    CountryofOrigin,
                    PrimaryVendor,
                    ManufacturingStatusChangeDate,
                    ItemForecastPlannerID,
                    NewItemFlag,
                    DiscontinuedFlag,
                    DiscontinuedYearPeriod,
                    CommonCarrierFlag,
                    ExpressShipFlag,
                    DiscontinuedDate,
                    CEXCode,
                    MarketIntroducedAt,
                    MerchandisingCategory,
                    PricePoint,
                    ItemGrouping,
                    AssociationCode,
                    MarketingItemStatus,
                    MarketingStatusDescription,
                    Lifestyle,
                    CommodityItem,
                    F123ProductFlag,
                    HSCoreProductFlag,
                    HSProprietaryProductFlag,
                    HSExclusiveFlag,
                    BerklineProductFlag,
                    BenchcraftProductFlag,
                    NewMillenniumProductFlag,
                    BardiniProductFlag,
                    ShanghaiStore,
                    DefaultGroup,
                    GoodBetterBestForPricePoint,
                    GBBSortID,
                    InitialInvoicePeriod,
                    InitialInvoiceQty,
                    MarketBeginDate,
                    MarketEndDate,
                    Showroom,
                    ItemImage,
                    FOBArcPrice,
                    TrendArrow,
                    ItemMerchGridOverridePhoto,
                    ExclusiveComment,
                    SeriesImage,
                    SofaTableSeriesFlag,
                    ReclinerSeriesFlag,
                    PowerMotionSeriesFlag,
                    WedgeSeriesFlag,
                    DiningSeriesFlag,
                    ItemThirdPartyItem,
                    ItemSupplierDirectShipOnly,
                    ConsumerChoiceFlag,
                    [SeriesMainImage],
                    [CollectiveClass],
                    [CollectiveClassCode],
                    [DelayedProductFlag],
                    [ItemFluffAFI],
                    [ItemMaterial],
                    [ItemKnockout],
                    [ItemStandAloneFlag],
                    [ItemScene7ImageSet],
                    [ItemUPC],
                    [SeriesFeatures],
                    [PrimariesLifestyle],
                    [ItemIsRTA],
                    [PreviousStatusCode]  
                )
                        SELECT
                            'N/A'           AS ItemSKU,
                            'ASHLEY_N/A'    AS ItemKey,
                            ''              AS Item,
                            'N/A'           AS ItemCode,
                            ''              AS SeriesCode,
                            'N/A'           AS ExtSeriesCode,
                            'N/A'           AS FrameNumber,
                            NULL            AS QtyInBox,
                            NULL            AS UOM,
                            NULL            AS Cubes,
                            NULL            AS Seats,
                            'Other'         AS ItemDescription,
                            'Other Charges' AS SeriesName,
                            'N/A'           AS SeriesColor,
                            'N/A'           AS Colors,
                            'N/A'           AS ItemDescriptionSeries,
                            'N/A'           AS SHItemDescriptionSeries,
                            'N/A'           AS SHSeriesDescription,
                            'N/A'           AS ItemDescriptionSeriesItemColor,
                            'N/A'           AS ChildStyleDescription,
                            'N/A'           AS ParentStyleDescription,
                            'N/A'           AS SeriesDescription,
                            ''              AS ItemConsumerDescription,
                            ''              AS RetailTypeDescription,
                            'False'         AS MainPieceItem,
                            'Other'         AS ItemClass,
                            ''              AS ItemClassCode,
                            'N/A'           AS ItemClassName,
                            'N/A'           AS ProductLine,
                            'N/A'           AS RetailCategoryCode,
                            'N/A'           AS RetailCategoryDescription,
                            'N/A'           AS RetailCategoryName,
                            'N/A'           AS RetailDepartmentName,
                            'N/A'           AS RetailCategoryGroup,
                            'N/A'           AS AFIFinanceDivision,
                            ''              AS AFISalesCategoryCode,
                            'N/A'           AS AFISalesCategory,
                            ''              AS ItemStyleCode,
                            'N/A'           AS ItemStyleGroup,
                            'N/A'           AS ItemStyle,
                            'N/A'           AS Division,
                            'Z'             AS AFISalesDivisionCode,
                            'Z'             AS AFISalesDivision,
                            CAST(0 AS INT)  AS KeyItem,
                            ''              AS SalesClassCode,
                            'N/A'           AS SalesClassDescription,
                            ''              AS SalesClass,
                            ''              AS DiscountClassCode,
                            'N/A'           AS DiscountClassDescription,
                            ''              AS DiscountClass,
                            ''              AS CommissionClassCode,
                            'N/A'           AS CommissionClassDescription,
                            ''              AS CommissionClass,
                            ''              AS FreightClassCode,
                            'N/A'           AS FreightClassDescription,
                            ''              AS FreightClass,
                            ''              AS AFIItemStatus,
                            ''              AS SellableItemFlag,
                            'N/A'           AS ManufacturingStatus,
                            ''              AS ResponsibleOffice,
                            ''              AS ImportDomesticCode,
                            'N/A'           AS CountryofOrigin,
                            NULL            AS PrimaryVendor,
                            NULL            AS ManufacturingStatusChangeDate,
                            NULL            AS ItemForecastPlannerID,
                            CAST(0 AS INT)  AS NewItemFlag,
                            CAST(0 AS INT)  AS DiscontinuedFlag,
                            NULL            AS DiscontinuedYearPeriod,
                            NULL            AS CommonCarrierFlag,
                            NULL            AS ExpressShipFlag,
                            ''              AS DiscontinuedDate,
                            ''              AS CEXCode,
                            'N/A'           AS MarketIntroducedAt,
                            NULL            AS MerchandisingCategory,
                            NULL            AS PricePoint,
                            'N/A'           AS ItemGrouping,
                            'N/A'           AS AssociationCode,
                            ''              AS MarketingItemStatus,
                            'N/A'           AS MarketingStatusDescription,
                            NULL            AS Lifestyle,
                            CAST(0 AS INT)  AS CommodityItem,
                            CAST(0 AS INT)  AS F123ProductFlag,
                            CAST(0 AS INT)  AS HSCoreProductFlag,
                            CAST(0 AS INT)  AS HSProprietaryProductFlag,
                            CAST(0 AS INT)  AS HSExclusiveFlag,
                            CAST(0 AS INT)  AS BerklineProductFlag,
                            CAST(0 AS INT)  AS BenchcraftProductFlag,
                            CAST(0 AS INT)  AS NewMillenniumProductFlag,
                            CAST(0 AS INT)  AS BardiniProductFlag,
                            CAST(0 AS INT)  AS ShanghaiStore,
                            CAST(0 AS INT)  AS DefaultGroup,
                            NULL            AS GoodBetterBestForPricePoint,
                            NULL            AS GBBSortId,
                            'N/A'           AS InitialInvoicePeriod,
                            0               AS InitialInvoiceQty,
                            NULL            AS MarketBeginDate,
                            NULL            AS MarketEndDate,
                            NULL            AS Showroom,
                            NULL            AS ItemImage,
                            NULL            AS FOBArcPrice,
                            NULL            AS TrendArrow,
                            NULL            AS ItemMerchGridOverridePhoto,
                            NULL            AS ExclusiveComment,
                            NULL            AS SeriesImage,
                            NULL            AS SofaTableSeriesFlag,
                            NULL            AS ReclinerSeriesFlag,
                            NULL            AS PowerMotionSeriesFlag,
                            NULL            AS WedgeSeriesFlag,
                            NULL            AS DiningSeriesFlag,
                            NULL            AS ItemThirdPartyItem,
                            NULL            AS ItemSupplierDirectShipOnly,
                            NULL            AS ConsumerChoiceFlag,
                            NULL            AS [SeriesMainImage],
                            NULL            AS [CollectiveClass],
                            NULL            AS [CollectiveClassCode],
                            NULL            AS [DelayedProductFlag],
                            NULL            AS [ItemFluffAFI],
                            NULL            AS [ItemMaterial],
                            NULL            AS [ItemKnockout],
                            NULL            AS [ItemStandAloneFlag],
                            NULL            AS [ItemScene7ImageSet],
                            NULL            AS [ItemUPC],
                            NULL            AS [SeriesFeatures],
                            NULL            AS [PrimariesLifestyle],
                            NULL            AS [ItemIsRTA],
                            NULL            AS [PreviousStatusCode]  
                        UNION ALL
                        SELECT  DISTINCT
                            -- Item Keys
                                TRIM(ItemMaster.ItemSKU)                                                        AS [ItemSKU],
                                TRIM('ASHLEY_' + ItemMaster.ItemSKU)                                            AS [ItemKey],
                                TRIM(ItemMaster.ItemSKU)                                                        AS [Item],
                                ISNULL(ItemCodeMaster.Description, 'N/A')                                       AS ItemCode,
                                ItemMaster.BlockingCode                                                            AS SeriesCode,
                                ISNULL(itm.SeriesCode, 'N/A')                                                   AS ExtSeriesCode,
                                CASE
                                    WHEN ISNULL(SeriesGroupingLookup.LookupCode, 'N/A') IN (
                                                                                               'Chairs', 'Motion Leather',
                                                                                               'Motion Upholstery',
                                                                                               'Recliners', 'Sectionals',
                                                                                               'Stationary Leather',
                                                                                               'Stationary Upholstery'
                                                                                           )
                                        THEN
                                        CASE
                                            WHEN LEFT(ItemMaster.ItemSKU, 1) = 'U'
                                                THEN
                                                LEFT(ItemMaster.ItemSKU, 4)
                                            ELSE
                                                LEFT(ItemMaster.ItemSKU, 3)
                                        END
                                    ELSE
                                        ISNULL(itm.SeriesCode, 'N/A')
                                END                                                                             AS FrameNumber,

                                -- Item Dimension
                                ItemMaster.QtyInBox                                                             AS QtyInBox,
                                ItemDimensions.UnitOfMeasure                                                    AS UOM,
                                ItemMaster.Cubes                                                                AS Cubes,
                                ItemMaster.Nbseat                                                               AS Seats,
                                ItemMaster.Description                                                          AS ItemDescription,
                                ItemSeries.SeriesName                                                           AS SeriesName,
                                ItemSeries.SeriesColor                                                          AS SeriesColor,
                                itm.Colors,
                                RTRIM(ISNULL(ItemMaster.Description, 'N/A')) + '-'
                                + LTRIM(ISNULL(ItemSeries.SeriesName, 'N/A'))                                   AS [ItemDescriptionSeries],
                                RTRIM(ItemMaster.ItemSKU) + '-' + RTRIM(ISNULL(ItemMaster.Description, 'N/A')) + '-'
                                + LTRIM(ISNULL(ItemSeries.SeriesName, 'N/A'))                                   AS [SHItemDescriptionSeries],
                                RTRIM(ItemMaster.BlockingCode) + '-' + RTRIM(ISNULL(ItemSeries.SeriesName, 'N/A')) AS [SHSeriesDescription],
                                RTRIM(ItemMaster.ItemSKU) + '-' + RTRIM(LTRIM(ISNULL(ItemMaster.Descripription, 'N/A')))
                                + '-' + LTRIM(ISNULL(ItemSeries.SeriesName, 'N/A')) + '-'
                                + LTRIM(ISNULL(itm.Colors, 'N/A'))                                              AS [ItemDescriptionSeriesItemColor],
                                ISNULL(ChildStyleLookup.Description, 'N/A')                                     AS ChildStyleDescription,
                                ISNULL(ParentStyleLookup.Description, 'N/A')                                    AS ParentStyleDescription,
                                ISNULL(itm.SeriesCode + ' ' + [Series_Name], 'N/A')                             AS SeriesDescription,
                                itm.ConsumerDescription                                                         AS ItemConsumerDescription,
                                rttRetailTypeDescription                                                        AS RetailTypeDescription,
                                CASE
                                    WHEN itm.KeyItem = 0
                                        THEN
                                        'False'
                                    ELSE
                                        'True'
                                END                                                                             AS MainPieceItem,
                                ISNULL(RTRIM(ItemMaster.Class) + ' - ' + ItemClass.ItemClassName, 'N/A')        AS [ItemClass],
                                ItemMaster.Class                                                                AS [ItemClassCode],
                                ISNULL(ItemClass.ItemClassName, 'N/A')                                          AS [ItemClassName],
                                ISNULL(ProductLineMaster.Description, 'N/A')                                    AS [ProductLine],
                                ISNULL(ItemClass.RetailCategory, 'N/A')                                         AS [RetailCategoryCode],
                                ISNULL(M1.Description, 'N/A')                                                   AS [RetailCategoryDescription],
                                ISNULL(M1.CategoryName, 'N/A')                                                  AS RetailCategoryName,
                                ISNULL(M1.DepartmentStoreName, 'N/A')                                           AS RetailDepartmentName,
                                M1.[StoreGroup]                                                                 AS RetailCategoryGroup,
                                ISNULL(FinancialDivision.Description, 'N/A')                                    AS [AFIFinanceDivision],
                                ItemMaster.SalesCategory                                                        AS AFISalesCategoryCode,
                                ISNULL(SalesCategory.Desription, 'N/A')                                         AS AFISalesCategory,
                                ItemMaster.Style                                                                AS ItemStyleCode,
                                ISNULL(ItemStyle.StyleGroup, 'N/A')                                             AS ItemStyleGroup,
                                ISNULL(ItemStyle.Description, 'N/A')                                            AS ItemStyle,
                                Divisions.Description                                                           AS Division,
                                ItemMaster.DivisionCode                                                         AS AFISalesDivisionCode,
                                ISNULL(Divisions.DivisionCode, 'N/A')                                           AS AFISalesDivision,
                                itm.KeyItem                                                                     AS KeyItem,
                                ItemMaster.SalesClass                                                           AS SalesClassCode,
                                SalesClass.Description                                                          AS SalesClassDescription,
                                RTRIM(ItemMaster.SalesClass) + ' - ' + SalesClass.Description                   AS SalesClass,
                                ItemMaster.DiscountClass                                                        AS DiscountClassCode,
                                DiscountClass.Description                                                       AS DiscountClassDescription,
                                RTRIM(ItemMaster.DiscountClass) + ' - ' + DiscountClass.Description             AS DiscountClass,
                                ItemMaster.CommissionClass                                                      AS CommissionClassCode,
                                CommissionClass.Description                                                     AS CommissionClassDescription,
                                RTRIM(ItemMaster.CommissionClass) + ' - ' + CommissionClass.Description         AS CommissionClass,
                                ItemMaster.FreightClass                                                         AS FreightClassCode,
                                FreightClass.Description                                                        AS FreightClassDescription,
                                RTRIM(ItemMaster.FreightClass) + ' - ' + FreightClass.Description               AS FreightClass,
                                ItemMaster.Status                                                               AS AFIItemStatus,
                                CASE
                                    WHEN ItemClass.ProductLine = 'Z'
                                        THEN
                                        'N'
                                    ELSE
                                        'Y'
                                END                                                                             AS SellableItemFlag,
                                CASE
                                    WHEN ItemMaster.ActiveRecord = 'D'
                                         OR ItemMaster.Status IN (
                                                                     'D', 'R'
                                                                 )
                                        THEN
                                        'Discontinued'
                                    ELSE
                                        ISNULL(SC2.Description, 'N/A')
                                END                                                                             AS ManufacturingStatus,
                                ISNULL(VendorMaster.NameAbbreviation, 'N/A')                                    AS [ResponsibleOffice],
                                ItemMaster.ImportDomestic                                                       AS ImportDomesticCode,
                                ISNULL(CountryMaster.Description, 'N/A')                                        AS CountryofOrigin,
                                ISNULL(VendorMaster.VendorNumber, 'N/A')                                        AS PrimaryVendor,
                                ItemMaster.StatusLastChanged                                                    AS ManufacturingStatusChangeDate,
                                [Forecast Planner ID]                                                           AS ItemForecastPlannerID,
                                CAST(COALESCE(itm.itmIsNewItem, 0) AS BIT)                                      AS NewItemFlag,
                                CAST(COALESCE(ITM2.DiscontinuedStatus, 0) AS BIT)                               AS DiscontinuedFlag,
                                CASE
                                    WHEN ItemMaster.Status IN (
                                                                  'D', 'R'
                                                              )
                                        THEN
                                        RIGHT(CONVERT(VARCHAR(10), ITM2.DiscontinuedDate, 103), 7)
                                    ELSE
                                        ''
                                END                                                                             AS DiscontinuedYearPeriod,
                                ISNULL(iteCommonCarrier_ITMUC1B, '')                                            AS CommonCarrierFlag,
                                COALESCE(   CASE
                                                WHEN [ExpressShipFlag] = 'True'
                                                    THEN
                                                    'Y'
                                                WHEN [ExpressShipFlag] = 'False'
                                                    THEN
                                                    'N'
                                                ELSE
                                                    ''
                                            END, iteExpressService_ITMUC1A, ''
                                        )                                                                       AS ExpressShipFlag,
                                ITM2.DiscontinuedDate                                                           AS DiscontinuedDate,
                                ItemMaster.CEX                                                                  AS CEXCode,
                                ISNULL(MarketLookup.Code, 'N/A')                                                AS MarketIntroducedAt,
                                CASE
                                    WHEN itm.KeyItem = 1
                                        THEN
                                        ISNULL(ItemGrouping.GroupID, 0)
                                    ELSE
                                        0
                                END                                                                             AS MerchandisingCategory,
                                0                                                                               AS PricePoint,
                                ISNULL(SeriesGroupingLookup.LookupCode, 'N/A')                                  AS ItemGrouping,
                                ISNULL(grpAssociationCode, 'N/A')                                               AS AssociationCode,
                                CASE
                                    WHEN ItemMaster.PreviousStatus = 'N'
                                         AND DATEDIFF(m, ItemMaster.StatusLastChanged, GETDATE())
                                         BETWEEN 0 AND 5
                                        THEN
                                        'I'
                                    WHEN ItemMaster.PreviousStatus = 'N'
                                         AND DATEDIFF(m, ItemMaster.StatusLastChanged, GETDATE()) < 0
                                        THEN
                                        'N'
                                    WHEN ItemMaster.PreviousStatus = ''
                                         AND DATEDIFF(m, ItemMaster.StatusLastChanged, GETDATE()) < 0
                                        THEN
                                        ''
                                    ELSE
                                        ItemMaster.Status
                                END                                                                             AS MarketingItemStatus,
                                ISNULL(SC.Description, 'N/A')                                                   AS MarketingStatusDescription,
                                COALESCE(PLC.ProductLifestyle, lfaDescription)                                  AS Lifestyle,
                                CommodityItem,
                                F123ProductFlag,
                                HSCoreProductFlag,
                                HSProprietaryProductFlag,
                                HSExclusiveFlag,
                                BerklineProductFlag,
                                BenchcraftProductFlag,
                                NewMillenniumProductFlag,
                                BardiniProductFlag,
                                ShanghaiStore,
                                ItemGrouping.DefaultGroup                                                       AS DefaultGroup,
                                ItemMaster.GoodBetterBest                                                       AS GoodBetterBestForPricePoint,
                                CASE
                                    WHEN ItemMaster.GoodBetterBest = 'Good'
                                        THEN
                                        1
                                    WHEN ItemMaster.GoodBetterBest = 'Better'
                                        THEN
                                        2
                                    WHEN ItemMaster.GoodBetterBest = 'Best'
                                        THEN
                                        3
                                    WHEN ItemMaster.GoodBetterBest = 'N/A'
                                        THEN
                                        4
                                    ELSE
                                        0
                                END                                                                             AS GBBSortId,
                                InitialInvoicePeriod,
                                InitialInvoiceQty,
                                MarketLookup.StartDate                                                          AS MarketBeginDate,
                                MarketLookup.EndDate                                                            AS MarketEndDate,
                                Showroom                                                                        AS Showroom,
                                Photo                                                                           AS ItemImage,
                                ITM2.FobarcPrice                                                                AS FOBArcPrice,
                                CASE
                                    WHEN frtTrend_Comp * 100 > 0
                                        THEN
                                        'small_arrow_up.gif'
                                    WHEN frtTrend_Comp * 100 <= 0
                                        THEN
                                        'small_arrow_down.gif'
                                    ELSE
                                        'small_arrow_down.gif'
                                END                                                                             AS TrendArrow,
                                CASE
                                    WHEN itmMerchGridOverridePhoto <> ''
                                        THEN
                                        REPLACE(itmMerchGridOverridePhoto, 'BIG', 'MED')
                                    ELSE
                                        'NA_MED.gif'
                                END                                                                             AS ItemMerchGridOverridePhoto,
                                ISNULL(itm.ExclusiveComment, 'N/A')                                          AS [ExclusiveComment],
                                cim.ImageName                                                                   AS [SeriesImage],
                                ISNULL(SS.flag, 'False')                                                        SofaTableSeriesFlag,
                                ISNULL(RS.flag, 'False')                                                        ReclinerSeriesFlag,
                                ISNULL(PS.flag, 'False')                                                        PowerMotionSeriesFlag,
                                ISNULL(WS.flag, 'False')                                                        WedgeSeriesFlag,
                                ISNULL(DS.flag, 'False')                                                        DiningSeriesFlag,
                                Product.ItemThirdPartyItem,
                                Product.ItemSupplierDirectShipOnly,
                                CASE
                                    WHEN Product.[ItemConsumerChoice] = 'True'
                                        THEN
                                        'Yes'
                                    WHEN Product.[ItemConsumerChoice] = 'False'
                                        THEN
                                        'No'
                                    ELSE
                                        Product.[ItemConsumerChoice]
                                END                                                                             AS ConsumerChoiceFlag,
                                Product1.[SeriesMainImage]                                                      AS [SeriesMainImage],
                                [Collective Class]                                                              AS [CollectiveClass],
                                [Collective Class Code]                                                         AS [CollectiveClassCode],
                                controlallocationitems.ControlledProduct                                        AS [DelayedProductFlag],
                                [ItemFluffAFI]                                                                  AS [ItemFluffAFI],
                                [ItemMaterial]                                                                  AS [ItemMaterial],
                                [ItemKnockout]                                                                  AS [ItemKnockout],
                                [ItemStandAloneFlag]                                                            AS [ItemStandAloneFlag],
                                [ItemScene7ImageSet]                                                            AS [ItemScene7ImageSet],
                                [ItemUPC]                                                                       AS [ItemUPC],
                                Product1.[SeriesFeatures]                                                       AS [SeriesFeatures],
                                Product1.[SeriesPrimary]                                                        AS [PrimariesLifestyle],
                                Product.[ItemIsRTA]                                                             AS [ItemIsRTA],
                                ItemMaster.PreviousStatus						                                AS PreviousStatusCode
                        FROM
                                [$(Wholesale_Warehouse)].Marketing.ItemMaster
                            LEFT JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].ItemMattressTypes 
                                    ON ItemMaster.ItemSKU = ItemMattressTypes.ItemSKU
                            LEFT JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].ItemMaster        itm
                                    ON ItemMaster.ItemSKU = itm.ItemSKU
                            LEFT JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].ItemSeries       
                                    ON itm.SeriesCode = ItemSeries.SeriesCode
                            LEFT JOIN
                                [$(Databricks)].wholesale_demandplanning_afi.salesforecast   SalesForecast 
                                    ON ItemMaster.ItemSKU = SalesForecast.frtItnbr 
                            LEFT JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].ItemClass
                                    ON ItemMaster.Class = ItemClass.ItemClass
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Marketing.FinancialDivision
                                    ON FinancialDivision.FinancialDivision = ItemClass.FinancialDivision 
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Marketing.Divisions
                                    ON Divisions.DivisionCode = ItemMaster.DivisionCode 
                            LEFT JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].RetailSalesCategory
                                    ON RetailSalesCategory.RetailCategory = ItemClass.RetailCategory
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Marketing.SalesCategory
                                    ON SalesCategory.SalesCategory = ItemMaster.SalesCategory
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Marketing.ProductLineMaster
                                    ON ProductLineMaster.ProductLineCode = SalesCategory.ProductLine
                            LEFT JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].ItemStyle
                                    ON ItemStyle.Style = ItemMaster.Style
                            LEFT JOIN
                                [$(MasterData_Warehouse)].[GeographicData].CountryMaster
                                    ON CountryMaster.Country = ItemMaster.CountryOfOrigin
                            LEFT JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].ItemStatusCode    SC2
                                    ON SC2.Code = ItemMaster.Status
                            LEFT JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].ItemDimensions
                                    ON ItemMaster.ItemSKU = ItemDimensions.ItemSKU
                            LEFT JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].ItemCodeMaster
                                    ON ItemCodeMaster.ItemCodeID = itm.ItemCodeID
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Marketing.MarketLookup
                                    ON MarketLookup.MarketID = itm.Market
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Pricing_AFI.CommissionClass
                                    ON ItemMaster.CommissionClass = CommissionClass.CommissionClass
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Pricing_AFI.DiscountClass
                                    ON ItemMaster.DiscountClass = DiscountClass.DiscountClass
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Pricing_AFI.FreightClass
                                    ON ItemMaster.FreightClass = FreightClass.FreightClass 
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Pricing_AFI.SalesClass
                                    ON ItemMaster.SalesClass = SalesClass.SalesClass
                            LEFT JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].ItemGrouping
                                    ON ItemGrouping.ItemSKU = ItemMaster.ItemSKU
                                       AND ItemGrouping.DefaultGroup = 1
                            LEFT JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].SeriesGroupingLookup
                                    ON SeriesGroupingLookup.LookupID = ItemGrouping.GroupID
                            LEFT JOIN
                                [$(Source_Data)].[MasterData_ItemMaster_AFI].ITMRVA  ITMRVA              
                                    ON ItemMaster.CEX = ITMRVA.STID
                                       AND ItemMaster.ItemSKU = ITMRVA.ITNBR
                                       AND '1' = ITMRVA.UUCA
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Purchasing_AFI.VendorMaster               
                                    ON ITMRVA.VNDNR = VendorMaster.VendorNumber 
                            LEFT JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].ParentStyleLookup
                                    ON ParentStyleLookup.ParentStyleCode = ItemMaster.Style
                            LEFT JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].ChildStyleLookup
                                    ON ChildStyleLookup.ChildStyleCode = ItemSeries.ChildStyleCode 
                            LEFT JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].ItemStatusCode    SC 
                                    ON SC.Code = CASE
                                                                    WHEN ItemMaster.PreviousStatus = 'N'
                                                                         AND DATEDIFF(
                                                                                         m,
                                                                                         ItemMaster.StatusLastChanged,
                                                                                         GETDATE()
                                                                                     )
                                                                         BETWEEN 0 AND 5
                                                                        THEN
                                                                        'I'
                                                                    WHEN ItemMaster.PreviousStatus = 'N'
                                                                         AND DATEDIFF(
                                                                                         m,
                                                                                         ItemMaster.StatusLastChanged,
                                                                                         GETDATE()
                                                                                     ) < 0
                                                                        THEN
                                                                        'N'
                                                                    WHEN ItemMaster.PreviousStatus = ''
                                                                         AND DATEDIFF(
                                                                                         m,
                                                                                         ItemMaster.StatusLastChanged,
                                                                                         GETDATE()
                                                                                     ) < 0
                                                                        THEN
                                                                        ''
                                                                    ELSE
                                                                        ItemMaster.Status
                                                                END
                            LEFT JOIN
                                #ItemFlags
                                    ON ItemMaster.ItemSKU = #ItemFlags.ItemSKU
                            LEFT JOIN
                                (
                                    SELECT  DISTINCT
                                            MULT.ItemSKU                                 AS [AFI Item Number],
                                            ISNULL(MULT.ForecastPlannerID, Fcst_Plnr_Id) AS [Forecast Planner ID]
                                    FROM
                                            [$(Databricks)].wholesale_demandplanning_afi.scp_fcst_root SCP_FCST_ROOT 
                                        JOIN
                                            [$(Databricks)].wholesale_demandplanning_afi.logresultantforecast LogResultantForecast
                                                ON LogResultantForecast.rfcScpSeqNbr = SCP_FCST_ROOT.Scp_Seq_Nbr
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        LogResultantForecast.rfcItemNum as ItemSKU ,
                                                        'MULTIPLE' AS ForecastPlannerID
                                                FROM
                                                        [$(Databricks)].wholesale_demandplanning_afi.scp_fcst_root SCP_FCST_ROOT 
                                                    JOIN
                                                        [$(Databricks)].wholesale_demandplanning_afi.logresultantforecast LogResultantForecast
                                                            ON LogResultantForecast.rfcScpSeqNbr = SCP_FCST_ROOT.Scp_Seq_Nbr
                                                WHERE
                                                        SCP_FCST_ROOT.Lvl_Nbr = 2
                                                GROUP BY
                                                        LogResultantForecast.rfcItemNum 
                                                HAVING
                                                        COUNT(DISTINCT SCP_FCST_ROOT.Fcst_Plnr_Id) <> 1
                                            )                                                   MULT
                                                ON MULT.ItemSKU = LogResultantForecast.rfcItemNum
                                    WHERE
                                            SCP_FCST_ROOT.[Lvl_Nbr] = 2
                                )                                                      FP
                                    ON ItemMaster.ItemSKU = FP.[AFI Item Number]
                            LEFT JOIN
                                (
                                    SELECT
                                            I.ItemSKU,
                                            [InitialInvoicePeriod],
                                            SUM(QuantityShipped) AS [InitialInvoiceQty]
                                    FROM
                                            (
                                                SELECT DISTINCT
                                                       InvoiceDetail.ItemSKU,
                                                       YEAR([InvoiceDate])  lclYear,
                                                       MONTH([InvoiceDate]) lclPeriod,
                                                       CONVERT(
                                                                  VARCHAR(7),
                                                                  (CASE LEN(RTRIM(MONTH([InvoiceDate])))
                                                                       WHEN '1'
                                                                           THEN
                                                                           '0' + RTRIM(MONTH([InvoiceDate]))
                                                                       ELSE
                                                                           RTRIM(MONTH([InvoiceDate]))
                                                                   END + '/' + CAST(YEAR([InvoiceDate]) AS VARCHAR(4))
                                                                  ), 103
                                                              )             AS [InitialInvoicePeriod],
                                                       ROW_NUMBER() OVER (PARTITION BY
                                                                              InvoiceDetail.ItemSKU
                                                                          ORDER BY
                                                                              YEAR([InvoiceDate]),
                                                                              CAST(MONTH([InvoiceDate]) AS INT)
                                                                         )  AS [FirstPeriod],
                                                       SUM(QuantityShipped) AS [InitialInvoiceQty]
                                                FROM
                                                       [$(Wholesale_Warehouse)].SalesHistory_AFI.InvoiceDetail
                                                WHERE
                                                       [CreditCode] = ''
                                                GROUP BY
                                                       InvoiceDetail.ItemSKU,
                                                       CONVERT(
                                                                  VARCHAR(7),
                                                                  (CASE LEN(RTRIM(MONTH([InvoiceDate])))
                                                                       WHEN '1'
                                                                           THEN
                                                                           '0' + RTRIM(MONTH([InvoiceDate]))
                                                                       ELSE
                                                                           RTRIM(MONTH([InvoiceDate]))
                                                                   END + '/' + CAST(YEAR([InvoiceDate]) AS VARCHAR(4))
                                                                  ), 103
                                                              ),
                                                       CAST(YEAR([InvoiceDate]) AS VARCHAR) + '/'
                                                       + CAST(MONTH([InvoiceDate]) AS VARCHAR),
                                                       YEAR([InvoiceDate]),
                                                       MONTH([InvoiceDate])
                                                HAVING
                                                       SUM(QuantityShipped) > '0'
                                            )                                                 I
                                        JOIN
                                            [$(Wholesale_Warehouse)].SalesHistory_AFI.InvoiceDetail S
                                                ON I.ItemSKU = S.ItemSKU
                                                   AND lclYear = DATEPART(yyyy, S.[InvoiceDate])
                                                   AND lclPeriod = DATEPART(mm, S.[InvoiceDate])
                                    WHERE
                                            FirstPeriod = '1'
                                    GROUP BY
                                            I.ItemSKU,
                                            [InitialInvoicePeriod],
                                            lclPeriod,
                                            lclYear
                                )                                                      F
                                    ON F.ItemSKU = ItemMaster.ItemSKU
                            LEFT JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].Item              ITM2
                                    ON ItemMaster.ItemSKU = ITM2.ItemSKU
                            LEFT JOIN
                                [$(MasterData_Warehouse)].[Retail].RetailType                           RT
                                    ON itmRetailTypeID = RT.rttRetailTypeId
                            LEFT JOIN
                                (
                                    SELECT
                                            BusinessTypeLifeStyleArea.SeriesCode,
                                            LifeStyleArea.Description
                                    FROM
                                            [$(Wholesale_Warehouse)].Marketing.BusinessTypeLifeStyleArea
                                        JOIN
                                            [$(MasterData_Warehouse)].[ProductKnowledge].LifeStyleArea
                                                ON LifeStyleArea.LifeStyleID = BusinessTypeLifeStyleArea.LifeStyleAreaID
                                    WHERE
                                            BusinessTypeLifeStyleArea.BusinessTypeCode = '1E'
                                )                                                      AS LS
                                    ON LS.SeriesCode = ItemMaster.BlockingCode
                            LEFT JOIN
                                [$(MasterData_Warehouse)].[Retail].HomestoreRetailCategories            
                                    ON HomestoreRetailCategories.SalesCategory = ItemMaster.SalesCategory
                                       AND HomestoreRetailCategories.[Database] = ''
                            LEFT JOIN
                                [$(MasterData_Warehouse)].[Retail].HomestoreRetailCategoryMaster        
                                    ON HomestoreRetailCategoryMaster.[RetailCategory] = HomestoreRetailCategories.[RetailCategory]
                            LEFT JOIN
                                (
                                    SELECT
                                            ItemSeries.SeriesCode,
                                            CatalogImages.ImageName
                                    FROM
                                            [$(MasterData_Warehouse)].[ProductKnowledge].[ItemSeries]
                                        INNER JOIN
                                            [$(MasterData_Warehouse)].[ProductKnowledge].[CatalogImages]
                                                ON ItemSeries.SeriesCode = CatalogImages.SeriesCode
                                                   AND CatalogImages.ImageType = 'Present'
                                                   AND CatalogImages.MasterImage = 1
                                                   AND CatalogImages.ImageName NOT LIKE 'NMI%'
                                )                                                      AS cim
                                    ON cim.SeriesCode = ItemSeries.SeriesCode
                            LEFT JOIN
                                #SofaTable                                             SS
                                    ON ItemMaster.BlockingCode = SS.SeriesCode
                            LEFT JOIN
                                #Recliner                                              RS
                                    ON ItemMaster.BlockingCode = RS.SeriesCode
                            LEFT JOIN
                                #PowerMotion                                           PS
                                    ON ItemMaster.BlockingCode = PS.SeriesCode
                            LEFT JOIN
                                #WedgeOption                                           WS
                                    ON ItemMaster.BlockingCode = WS.SeriesCode
                            LEFT JOIN
                                #DiningBench                                           DS
                                    ON ItemMaster.BlockingCode = DS.SeriesCode
                            LEFT JOIN
                                (
                                    SELECT
                                        Product.Id                         AS ID,
                                        MAX(ItemThirdPartyItem)            AS ItemThirdPartyItem,
                                        MAX(SeriesThirdParty)              AS SeriesThirdParty,
                                        MAX(ItemSupplierDirectShipOnly)    AS ItemSupplierDirectShipOnly,
                                        MAX(ItemEligibleforProtectionPlan) AS EligibleForProtectionPlan,
                                        MAX(ItemIsProtectionPlan)          AS IsProtectionPlan,
                                        MAX([ItemHomeStoreProductLine])    AS [ItemHomeStoreProductLine],
                                        MAX([ItemEcomMerchantNotes])       AS [ItemEcomMerchantNotes],
                                        MAX([ItemAmazonBrandOwner])        AS [ItemAmazonBrandOwner],
                                        MAX([ItemExpressShip])             AS [ExpressShipFlag],
                                        MAX(ItemConsumerChoice)            AS [ItemConsumerChoice],
                                        MAX(ItemIsRTA)                     AS ItemIsRTA
                                    FROM
                                        [$(Source_Data)].[MasterData_PIM].[Product] Product
                                    WHERE
                                        Product.Status IS NOT NULL
                                    GROUP BY
                                        Product.Id
                                )                                                      Product
                                    ON ItemMaster.ItemSKU = Product.Id
                            LEFT JOIN
                                (
                                    SELECT
                                        productLifestylecrosswalk.id, 
                                        MAX(productLifestylecrosswalk.col) ProductLifestyle
                                    FROM
                                        [$(Databricks)].[masterdata_pim].[productlifestylecrosswalk]
                                    GROUP BY
                                        productLifestylecrosswalk.id
                                )                                                      PLC
                                    ON ItemMaster.ItemSKU = PLC.id
                            LEFT JOIN
                                [$(Source_Data)].[MasterData_PIM].[Product]                        Product1
                                    ON Product1.Id = ItemMaster.ItemSKU
                                       AND Product1.Status IS NOT NULL
                            LEFT JOIN
                                (
                                    SELECT
                                            a.Division,
                                            Divisions.DivisionCode AS AltDesc
                                    FROM
                                            (
                                                SELECT DISTINCT
                                                       Regions.Division,
                                                       Regions.AlternateDivision
                                                FROM
                                                       [$(Wholesale_Warehouse)].Marketing.Regions
                                                WHERE
                                                       Regions.AlternateDivision IS NOT NULL
                                                       AND Regions.AlternateDivision <> ''
                                            ) a
                                        LEFT JOIN
                                            [$(Wholesale_Warehouse)].Marketing.Divisions
                                                ON a.AlternateDivision = Divisions.DivisionCode
                                                   AND Divisions.DivisionCode IS NOT NULL
                                )                                                      AlternateDivision
                                    ON ItemMaster.DivisionCode = Regions.Division
                            LEFT JOIN
                                [$(Databricks)].wholesale_productsourcing_afi.controlallocationitems
                                    ON controlallocationitems.ItemSKU = TRIM(ItemMaster.ItemSKU);


            UPDATE
                AFISales_DW.DimItemMaster_Load
            SET
                PricePoint = WarRoomData.RetPrPt
            FROM
                AFISales_Enh.WarRoomData
            WHERE
                ItemSKU = WarRoomData.KeyItem
                AND WarRoomData.MinMU = CASE
                                            WHEN WarRoomData.[Group] = 9
                                                THEN
                                                50
                                            ELSE
                                                40
                                        END
                AND WarRoomData.FOBDisc = 1;

            --- retain price points for inactive items that were previously captured
            UPDATE
                AFISales_DW.DimItemMaster_Load
            SET
                PricePoint = t1.PricePoint
            FROM
                AFISales_DW.DimItemMaster t1
            WHERE
                DimItemMaster_Load.ItemSKU = t1.ItemSKU
                AND DimItemMaster_Load.PricePoint = 0;


            INSERT INTO AFISales_DW.DimItemMaster_Load
                (
                    [ItemSKU],
                    [ItemKey],
                    [Item],
                    [ItemCode],
                    [SeriesCode],
                    [ExtSeriesCode],
                    [FrameNumber],
                    [QtyInBox],
                    [UOM],
                    [Cubes],
                    [Seats],
                    [ItemDescription],
                    [SeriesName],
                    [SeriesColor],
                    [Colors],
                    [ItemDescriptionSeries],
                    [SHItemDescriptionSeries],
                    [SHSeriesDescription],
                    [ItemDescriptionSeriesItemColor],
                    [ChildStyleDescription],
                    [ParentStyleDescription],
                    [SeriesDescription],
                    [ItemConsumerDescription],
                    [RetailTypeDescription],
                    [MainPieceItem],
                    [ItemClass],
                    [ItemClassCode],
                    [ItemClassName],
                    [ProductLine],
                    [RetailCategoryCode],
                    [RetailCategoryDescription],
                    [RetailCategoryName],
                    [RetailDepartmentName],
                    [RetailCategoryGroup],
                    [AFIFinanceDivision],
                    [AFISalesCategoryCode],
                    [AFISalesCategory],
                    [ItemStyleCode],
                    [ItemStyleGroup],
                    [ItemStyle],
                    [Division],
                    [AFISalesDivisionCode],
                    [AFISalesDivision],
                    [KeyItem],
                    [SalesClassCode],
                    [SalesClassDescription],
                    [SalesClass],
                    [DiscountClassCode],
                    [DiscountClassDescription],
                    [DiscountClass],
                    [CommissionClassCode],
                    [CommissionClassDescription],
                    [CommissionClass],
                    [FreightClassCode],
                    [FreightClassDescription],
                    [FreightClass],
                    [AFIItemStatus],
                    [SellableItemFlag],
                    [ManufacturingStatus],
                    [ResponsibleOffice],
                    [ImportDomesticCode],
                    [CountryofOrigin],
                    [PrimaryVendor],
                    [ManufacturingStatusChangeDate],
                    [ItemForecastPlannerID],
                    [NewItemFlag],
                    [DiscontinuedFlag],
                    [DiscontinuedYearPeriod],
                    [CommonCarrierFlag],
                    [ExpressShipFlag],
                    [DiscontinuedDate],
                    [CEXCode],
                    [MarketIntroducedAt],
                    [MerchandisingCategory],
                    [PricePoint],
                    [ItemGrouping],
                    [AssociationCode],
                    [MarketingItemStatus],
                    [MarketingStatusDescription],
                    [Lifestyle],
                    [CommodityItem],
                    [F123ProductFlag],
                    [HSCoreProductFlag],
                    [HSProprietaryProductFlag],
                    [HSExclusiveFlag],
                    [BerklineProductFlag],
                    [BenchcraftProductFlag],
                    [NewMillenniumProductFlag],
                    [BardiniProductFlag],
                    [ShanghaiStore],
                    [DefaultGroup],
                    [GoodBetterBestForPricePoint],
                    [GBBSortID],
                    [InitialInvoicePeriod],
                    [InitialInvoiceQty],
                    [MarketBeginDate],
                    [MarketEndDate],
                    [Showroom],
                    [ItemImage],
                    [FOBArcPrice],
                    --,[DivisionRanking]
                    [TrendArrow],
                    [ItemMerchGridOverridePhoto],
                    [ExclusiveComment],
                    [SeriesImage],
                    [SofaTableSeriesFlag],
                    [ReclinerSeriesFlag],
                    [PowerMotionSeriesFlag],
                    [WedgeSeriesFlag],
                    [DiningSeriesFlag],
                    [ItemThirdPartyItem],
                    [ItemSupplierDirectShipOnly],
                    [ConsumerChoiceFlag],
                    [SeriesMainImage],
                    [CollectiveClass],
                    [CollectiveClassCode],
                    [DelayedProductFlag],
                    [ItemFluffAFI],
                    [ItemMaterial],
                    [ItemKnockout],
                    [ItemStandAloneFlag],
                    [ItemScene7ImageSet],
                    [ItemUPC],
                    [SeriesFeatures],
                    [PrimariesLifestyle],
                    [ItemIsRTA]
                )
                        SELECT
                            TRIM([ItemSKU]) AS [ItemSKU],
                            TRIM([ItemKey]) AS [ItemSKU],
                            [Item],
                            [ItemCode],
                            [SeriesCode],
                            [ExtSeriesCode],
                            [FrameNumber],
                            [QtyInBox],
                            [UOM],
                            [Cubes],
                            [Seats],
                            [ItemDescription],
                            [SeriesName],
                            [SeriesColor],
                            [Colors],
                            [ItemDescriptionSeries],
                            [SHItemDescriptionSeries],
                            [SHSeriesDescription],
                            [ItemDescriptionSeriesItemColor],
                            [ChildStyleDescription],
                            [ParentStyleDescription],
                            [SeriesDescription],
                            [ItemConsumerDescription],
                            [RetailTypeDescription],
                            [MainPieceItem],
                            [ItemClass],
                            [ItemClassCode],
                            [ItemClassName],
                            [ProductLine],
                            [RetailCategoryCode],
                            [RetailCategoryDescription],
                            [RetailCategoryName],
                            [RetailDepartmentName],
                            [RetailCategoryGroup],
                            [AFIFinanceDivision],
                            [AFISalesCategoryCode],
                            [AFISalesCategory],
                            [ItemStyleCode],
                            [ItemStyleGroup],
                            [ItemStyle],
                            [Division],
                            [AFISalesDivisionCode],
                            [AFISalesDivision],
                            [KeyItem],
                            [SalesClassCode],
                            [SalesClassDescription],
                            [SalesClass],
                            [DiscountClassCode],
                            [DiscountClassDescription],
                            [DiscountClass],
                            [CommissionClassCode],
                            [CommissionClassDescription],
                            [CommissionClass],
                            [FreightClassCode],
                            [FreightClassDescription],
                            [FreightClass],
                            [AFIItemStatus],
                            [SellableItemFlag],
                            [ManufacturingStatus],
                            [ResponsibleOffice],
                            [ImportDomesticCode],
                            [CountryofOrigin],
                            [PrimaryVendor],
                            [ManufacturingStatusChangeDate],
                            [ItemForecastPlannerID],
                            [NewItemFlag],
                            [DiscontinuedFlag],
                            [DiscontinuedYearPeriod],
                            [CommonCarrierFlag],
                            [ExpressShipFlag],
                            [DiscontinuedDate],
                            [CEXCode],
                            [MarketIntroducedAt],
                            [MerchandisingCategory],
                            [PricePoint],
                            [ItemGrouping],
                            [AssociationCode],
                            [MarketingItemStatus],
                            [MarketingStatusDescription],
                            [Lifestyle],
                            [CommodityItem],
                            [F123ProductFlag],
                            [HSCoreProductFlag],
                            [HSProprietaryProductFlag],
                            [HSExclusiveFlag],
                            [BerklineProductFlag],
                            [BenchcraftProductFlag],
                            [NewMillenniumProductFlag],
                            [BardiniProductFlag],
                            [ShanghaiStore],
                            [DefaultGroup],
                            [GoodBetterBestForPricePoint],
                            [GBBSortID],
                            [InitialInvoicePeriod],
                            [InitialInvoiceQty],
                            [MarketBeginDate],
                            [MarketEndDate],
                            [Showroom],
                            [ItemImage],
                            [FOBArcPrice],
                            --,[DivisionRanking]
                            [TrendArrow],
                            [ItemMerchGridOverridePhoto],
                            [ExclusiveComment],
                            [SeriesImage],
                            [SofaTableSeriesFlag],
                            [ReclinerSeriesFlag],
                            [PowerMotionSeriesFlag],
                            [WedgeSeriesFlag],
                            [DiningSeriesFlag],
                            [ItemThirdPartyItem],
                            [ItemSupplierDirectShipOnly],
                            [ConsumerChoiceFlag],
                            [SeriesMainImage],
                            [CollectiveClass],
                            [CollectiveClassCode],
                            [DelayedProductFlag],
                            [ItemFluffAFI],
                            [ItemMaterial],
                            [ItemKnockout],
                            [ItemStandAloneFlag],
                            [ItemScene7ImageSet],
                            [ItemUPC],
                            [SeriesFeatures],
                            [PrimariesLifestyle],
                            [ItemIsRTA]
                        FROM
                            AFISales_DW.DimItemMaster
                        WHERE
                            DimItemMaster.ItemSKU NOT IN
                                (
                                    SELECT
                                        ItemSKU
                                    FROM
                                        AFISales_DW.DimItemMaster_Load
                                );




            --- test for Duplicates, if none exist do the drop/rename to activate the new table.  If errors exist, abort the process AND trigger the error

            IF EXISTS
                (
                    SELECT
                        COUNT(*),
                        [ItemSKU] AS cnt
                    FROM
                        AFISales_DW.DimItemMaster_Load
                    GROUP BY
                        [ItemSKU]
                    HAVING
                        COUNT(*) > 1
                )
                BEGIN
                    RAISERROR('Error - Duplicates Found', 12, 1); --- severity 12 should kick into the Try/Catch functionality
                END;
            ELSE
                BEGIN

                    CREATE STATISTICS Stat_DimItemMaster_ItemSKU
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ItemSKU]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_AFISalesDivisionCode
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [AFISalesDivisionCode]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_KeyItem
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [KeyItem]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_MerchandisingCategory
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [MerchandisingCategory]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ItemKey
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ItemKey]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_SeriesName
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [SeriesName]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ItemClass
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ItemClass]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ItemStyle
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ItemStyle]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_AFIItemStatus
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [AFIItemStatus]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ProductLine
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ProductLine]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_RetailCategoryCode
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [RetailCategoryCode]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_PricePoint
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [PricePoint]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_AFISalesDivision
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [AFISalesDivision]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_AFIFinanceDivision
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [AFIFinanceDivision]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_DiscontinuedDate
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [DiscontinuedDate]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_SHSeriesDescription
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [SHSeriesDescription]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_Item
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [Item]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ItemForecastPlannerID
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ItemForecastPlannerID]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_InitialInvoicePeriod
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [InitialInvoicePeriod]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_InitialInvoiceQty
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [InitialInvoiceQty]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_MarketBeginDate
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [MarketBeginDate]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_MarketEndDate
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [MarketEndDate]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ExtSeriesCode
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ExtSeriesCode]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ItemConsumerDescription
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ItemConsumerDescription]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_RetailTypeDescription
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [RetailTypeDescription]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_CommonCarrierFlag
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [CommonCarrierFlag]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ExpressShipFlag
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ExpressShipFlag]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_Showroom
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [Showroom]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_Division
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [Division]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_QtyInBox
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [QtyInBox]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ItemImage
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ItemImage]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_MarketingItemStatus
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [MarketingItemStatus]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_DiscontinuedYearPeriod
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [DiscontinuedYearPeriod]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_Lifestyle
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [Lifestyle]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_TrendArrow
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [TrendArrow]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_FrameNumber
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [FrameNumber]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ExclusiveComment
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ExclusiveComment]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_SeriesImage
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [SeriesImage]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_SofaTableSeriesFlag
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [SofaTableSeriesFlag]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_PowerMotionSeriesFlag
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [PowerMotionSeriesFlag]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ReclinerSeriesFlag
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ReclinerSeriesFlag]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_WedgeSeriesFlag
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [WedgeSeriesFlag]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_DiningSeriesFlag
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [DiningSeriesFlag]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ItemThirdPartyItem
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ItemThirdPartyItem]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ItemSupplierDirectShipOnly
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ItemSupplierDirectShipOnly]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ConsumerChoiceFlag
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ConsumerChoiceFlag]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_GoodBetterBestForPricePoint
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [GoodBetterBestForPricePoint]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_Cubes
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [Cubes]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_DefaultGroup
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [DefaultGroup]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_SellableItemFlag
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [SellableItemFlag]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_PrimaryVendor
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [PrimaryVendor]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_UOM
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [UOM]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_RowID
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [RowID]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ItemStyleCode
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ItemStyleCode]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ItemStyleGroup
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ItemStyleGroup]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_SalesClassCode
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [SalesClassCode]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_SalesClassDescription
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [SalesClassDescription]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_DiscountClassCode
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [DiscountClassCode]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_DiscountClassDescription
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [DiscountClassDescription]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_CommissionClassCode
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [CommissionClassCode]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_CommissionClassDescription
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [CommissionClassDescription]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_FreightClassCode
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [FreightClassCode]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_FreightClassDescription
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [FreightClassDescription]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ManufacturingStatusChangeDate
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ManufacturingStatusChangeDate]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_AssociationCode
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [AssociationCode]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_F123ProductFlag
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [F123ProductFlag]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_Seats
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [Seats]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_BerklineProductFlag
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [BerklineProductFlag]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_RetailCategoryName
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [RetailCategoryName]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_NewMillenniumProductFlag
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [NewMillenniumProductFlag]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_BardiniProductFlag
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [BardiniProductFlag]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_RetailDepartmentName
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [RetailDepartmentName]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_RetailCategoryGroup
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [RetailCategoryGroup]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ShanghaiStore
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ShanghaiStore]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_FOBArcPrice
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [FOBArcPrice]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ItemMerchGridOverridePhoto
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ItemMerchGridOverridePhoto]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_AFISalesCategoryCode
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [AFISalesCategoryCode]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ItemClassCode
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ItemClassCode]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_RetailCategoryDescription
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [RetailCategoryDescription]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ItemDescription
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ItemDescription]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_AFISalesCategory
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [AFISalesCategory]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ImportDomesticCode
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ImportDomesticCode]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_CEXCode
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [CEXCode]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_CountryofOrigin
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [CountryofOrigin]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ManufacturingStatus
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ManufacturingStatus]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_MarketIntroducedAt
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [MarketIntroducedAt]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ParentStyleDescription
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ParentStyleDescription]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ChildStyleDescription
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ChildStyleDescription]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ItemClassName
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ItemClassName]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ItemGrouping
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ItemGrouping]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_FreightClass
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [FreightClass]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_SalesClass
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [SalesClass]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_CommissionClass
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [CommissionClass]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_MainPieceItem
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [MainPieceItem]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_CommodityItem
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [CommodityItem]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_DiscountClass
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [DiscountClass]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ItemCode
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ItemCode]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_Colors
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [Colors]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ResponsibleOffice
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ResponsibleOffice]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_MarketingStatusDescription
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [MarketingStatusDescription]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_GBBSortId
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [GBBSortID]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_SeriesDescription
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [SeriesDescription]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ItemDescriptionSeries
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ItemDescriptionSeries]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ItemDescriptionSeriesItemColor
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ItemDescriptionSeriesItemColor]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_SeriesColor
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [SeriesColor]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_SHItemDescriptionSeries
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [SHItemDescriptionSeries]
                        );
                    CREATE STATISTICS Stat_DimItemMaster_ItemIsRTA
                        ON AFISales_DW.DimItemMaster_Load
                        (
                            [ItemIsRTA]
                        );

                    EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                        'AFISales_DW.DimItemMaster';


                    EXECUTE sp_rename 'AFISales_DW.DimItemMaster_Load','DimItemMaster'

                END;

            DROP TABLE #ItemFlags;

        END TRY
        BEGIN CATCH
            DECLARE
                @ErrorMessage  VARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState    INT;
            SET @ErrorMessage = ERROR_MESSAGE();
            SET @ErrorSeverity = ISNULL(ERROR_SEVERITY(), 16);
            SET @ErrorState = ISNULL(ERROR_STATE(), 0);
            SET @DateValue = GETDATE();
            SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)


            INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
            VALUES
                (
                    @String, @DateValue, @User, @ErrorMessage
                );

            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        END CATCH;



        SET @DateValue = GETDATE();
        SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)

    --- Update last modified in Table Dictionary 
                    INSERT INTO [$(ETL_Framework)].DW_Developer.TableDictionary_UpdateLog
                    VALUES
                        (
                            'AFISales_DW', 'AFISales_DW', 'DimItemMaster', @DateValue
                        );

        INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
        VALUES
            (
                @String, @DateValue, @User, 'Process Complete'
            );

    END;
GO