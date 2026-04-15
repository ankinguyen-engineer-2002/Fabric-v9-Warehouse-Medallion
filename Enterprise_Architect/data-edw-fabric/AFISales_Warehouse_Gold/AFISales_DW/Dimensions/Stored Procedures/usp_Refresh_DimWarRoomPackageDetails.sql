CREATE PROC [AFISales_DW].[usp_Refresh_DimWarRoomPackageDetails]
AS

    /* Change Control -----------------------------------------------------------------------------------------------------------
* Procedure: [AFISales_DW].[usp_Refresh_DimWarRoomPackageDetails]
* Description: Process rebuilds AFISales_DW.DimWarRoomPackageDetails using a "Create, Drop and Rename" method
*   The char(10) War Room Package ID column is unique and is leveraged as the PK for the Dimension
* Bob Horton (Jan 2018): Migrated from PDW Cube load view to Azure Data Warehouse
* Gabe De Mayo (3/1/18): Modified to use usp_CreateReplicateWorkTable/updated object existence check/updated error handling
* Amy Morina 04/26/2018 changed all references to GETDATE() to [$(ETL_Framework)].DW_Developer.fn_GetCSTDate(GETDATE())
* 02/28/2020 Changed insert to "Values" syntax to avoid exclusive locks
* 03/16/2020 Changed script Update to insert tpkmodified column in Table Dictionary
* Srinath 7/2/2021 changed [$(Wholesale_Warehouse)].Pricing schema to [$(Wholesale_Warehouse)].Pricing_AFI
---------------------------------------------------------------------------------------------------------------------------*/

    BEGIN
        DECLARE
            @String    VARCHAR(5000),
            @DateValue DATETIME,
            @User      VARCHAR(500);

        SET @String = 'AFISales_DW.AFISales_DW.usp_Refresh_DimWarRoomPackageDetails';
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
                PriceList.PriceCode,
                PriceList.ItemSKU,
                PriceList.Price
            INTO
                #PriceList
            FROM
                [$(Wholesale_Warehouse)].Pricing_AFI.PriceList
            WHERE
                PriceList.PriceCode = 'FOBARC';





            SELECT
                    SetDetail.SetNumber                         [FOB Package ID],
                    SUM(SetPriceTmp.Price * SetDetail.Quantity) AS [main]
            INTO
                    #SetPriceTmp 
            FROM
                    [$(MasterData_Warehouse)].[ProductKnowledge].SetDetail
                JOIN
                    #PriceList Pricelist
                        ON SetDetail.ItemSKU = PriceList.ItemSKU
            GROUP BY
                    SetDetail.SetNumber;



            SELECT
                SetNumber,
                RetPrPt,
                MinMU,
                RetMU,
                PrfCntPro,
                PrfCntProStd,
                PrfCntProAct
            INTO
                #WarRoomTmp 
            FROM
                AFISales_Enh.WarRoomData
            WHERE
                (WarRoomData.MinMU = CASE
                                         WHEN WarRoomData.[Group] = 9
                                             THEN
                                             50
                                         ELSE
                                             40
                                     END
                )
                AND FOBDisc = 1
                AND TemplateID <> ''
                AND KeyItem <> '';


     

            SELECT
                    T.[Package Item],
                    M.ItemSKU,
                    M.SeriesNumber
            INTO
                    #SetDetailTmp 
            FROM
                    (
                        SELECT
                                SetDetail.SetNumber AS [Package Item],
                                SetHeader.AfterSeries
                        FROM
                                [$(MasterData_Warehouse)].[ProductKnowledge].SetDetail
                            JOIN
                                [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
                                    ON SetDetail.ItemSKU = DimItemMaster.ItemSKU
                            JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].SetHeader
                                    ON SetDetail.SetNumber = SetHeader.SetNumber
                        WHERE
                                DimItemMaster.KeyItem = 0
                                AND SetDetail.SetNumber NOT IN
                                        (
                                            SELECT
                                                    SetDetail.SetNumber
                                            FROM
                                                    [$(MasterData_Warehouse)].[ProductKnowledge].SetDetail
                                                JOIN
                                                    [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
                                                        ON SetDetail.ItemSKU = DimItemMaster.ItemSKU
                                                           AND DimItemMaster.KeyItem = 1
                                            GROUP BY
                                                    SetDetail.SetNumber,
                                                    SetDetail.ItemSKU
                                        )
                        GROUP BY
                                SetDetail.SetNumber,
                                SetHeader.AfterSeries
                    ) T
                JOIN
                    (
                        SELECT
                            DimItemMaster.SeriesNumber,
                            ItemSKU = MIN(DimItemMaster.ItemSKU)
                        FROM
                            [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
                        WHERE
                            DimItemMaster.KeyItem = 1
                            AND DimItemMaster.DiscontinuedFlag = 0
                        GROUP BY
                            DimItemMaster.SeriesNumber,
                            DimItemMaster.KeyItem
                    ) M
                        ON T.AfterSeries = M.SeriesNumber;



            SELECT DISTINCT
                   SalesForecast.frtItnbr as ItemSKU,
                   SalesForecast.frtPrice as Price,
                   SalesForecast.frtAltCd3_ABC as AltCd3_ABC,
                   SalesForecast.frtFut_Stat as Fut_Stat,
                   SalesForecast.frtAct_Total as Act_Total,
                   SalesForecast.frtFC_Total as FC_Total,
                   SalesForecast.frtTrend_Comp as Trend_Comp,
                   demandCount                = CASE
                                                    WHEN SalesForecast.frtAct_DemdPer_12 > 0
                                                        THEN
                                                        1
                                                    ELSE
                                                        0
                                                END + CASE
                                                          WHEN SalesForecast.frtAct_DemdPer_11 > 0
                                                              THEN
                                                              1
                                                          ELSE
                                                              0
                                                      END + CASE
                                                                WHEN SalesForecast.frtAct_DemdPer_10 > 0
                                                                    THEN
                                                                    1
                                                                ELSE
                                                                    0
                                                            END + CASE
                                                                      WHEN SalesForecast.frtAct_DemdPer_9 > 0
                                                                          THEN
                                                                          1
                                                                      ELSE
                                                                          0
                                                                  END + CASE
                                                                            WHEN SalesForecast.frtAct_DemdPer_8 > 0
                                                                                THEN
                                                                                1
                                                                            ELSE
                                                                                0
                                                                        END + CASE
                                                                                  WHEN SalesForecast.frtAct_DemdPer_7 > 0
                                                                                      THEN
                                                                                      1
                                                                                  ELSE
                                                                                      0
                                                                              END + CASE
                                                                                        WHEN SalesForecast.frtAct_DemdPer_6 > 0
                                                                                            THEN
                                                                                            1
                                                                                        ELSE
                                                                                            0
                                                                                    END + CASE
                                                                                              WHEN SalesForecast.frtAct_DemdPer_5 > 0
                                                                                                  THEN
                                                                                                  1
                                                                                              ELSE
                                                                                                  0
                                                                                          END + CASE
                                                                                                    WHEN SalesForecast.frtAct_DemdPer_4 > 0
                                                                                                        THEN
                                                                                                        1
                                                                                                    ELSE
                                                                                                        0
                                                                                                END
                                                + CASE
                                                      WHEN SalesForecast.frtAct_DemdPer_3 > 0
                                                          THEN
                                                          1
                                                      ELSE
                                                          0
                                                  END + CASE
                                                            WHEN SalesForecast.frtAct_DemdPer_2 > 0
                                                                THEN
                                                                1
                                                            ELSE
                                                                0
                                                        END + CASE
                                                                  WHEN SalesForecast.frtAct_DemdPer_1 > 0
                                                                      THEN
                                                                      1
                                                                  ELSE
                                                                      0
                                                              END,
                   resultCount                = CASE
                                                    WHEN SalesForecast.frtResult_FC_12 > 0
                                                        THEN
                                                        1
                                                    ELSE
                                                        0
                                                END + CASE
                                                          WHEN SalesForecast.frtResult_FC_11 > 0
                                                              THEN
                                                              1
                                                          ELSE
                                                              0
                                                      END + CASE
                                                                WHEN SalesForecast.frtResult_FC_10 > 0
                                                                    THEN
                                                                    1
                                                                ELSE
                                                                    0
                                                            END + CASE
                                                                      WHEN SalesForecast.frtResult_FC_9 > 0
                                                                          THEN
                                                                          1
                                                                      ELSE
                                                                          0
                                                                  END + CASE
                                                                            WHEN SalesForecast.frtResult_FC_8 > 0
                                                                                THEN
                                                                                1
                                                                            ELSE
                                                                                0
                                                                        END + CASE
                                                                                  WHEN SalesForecast.frtResult_FC_7 > 0
                                                                                      THEN
                                                                                      1
                                                                                  ELSE
                                                                                      0
                                                                              END + CASE
                                                                                        WHEN SalesForecast.frtResult_FC_6 > 0
                                                                                            THEN
                                                                                            1
                                                                                        ELSE
                                                                                            0
                                                                                    END + CASE
                                                                                              WHEN SalesForecast.frtResult_FC_5 > 0
                                                                                                  THEN
                                                                                                  1
                                                                                              ELSE
                                                                                                  0
                                                                                          END + CASE
                                                                                                    WHEN SalesForecast.frtResult_FC_4 > 0
                                                                                                        THEN
                                                                                                        1
                                                                                                    ELSE
                                                                                                        0
                                                                                                END
                                                + CASE
                                                      WHEN SalesForecast.frtResult_FC_3 > 0
                                                          THEN
                                                          1
                                                      ELSE
                                                          0
                                                  END + CASE
                                                            WHEN SalesForecast.frtResult_FC_2 > 0
                                                                THEN
                                                                1
                                                            ELSE
                                                                0
                                                        END + CASE
                                                                  WHEN SalesForecast.frtResult_FC_1 > 0
                                                                      THEN
                                                                      1
                                                                  ELSE
                                                                      0
                                                              END, 
                   SalesForecast.frtResult_FC_1  AS [Forecast Result1],
                   SalesForecast.frtResult_FC_2  AS [Forecast Result2],
                   SalesForecast.frtResult_FC_3  AS [Forecast Result3],
                   SalesForecast.frtResult_FC_4  AS [Forecast Result4],
                   SalesForecast.frtResult_FC_5  AS [Forecast Result5],
                   SalesForecast.frtResult_FC_6  AS [Forecast Result6],
                   SalesForecast.frtResult_FC_7  AS [Forecast Result7],
                   SalesForecast.frtResult_FC_8  AS [Forecast Result8],
                   SalesForecast.frtResult_FC_9  AS [Forecast Result9],
                   SalesForecast.frtResult_FC_10 AS [Forecast Result10],
                   SalesForecast.frtResult_FC_11 AS [Forecast Result11],
                   SalesForecast.frtResult_FC_12 AS [Forecast Result12]
            INTO
                   #SalesForecastTmp 
            FROM
                   [$(Databricks)].wholesale_demandplanning_afi.salesforecast SalesForecast;


  
            SELECT
                    SetDetail.SetNumber,
                    MAX(   CASE
                               WHEN DimItemMaster.KeyItem = 1
                                   THEN
                                   SetDetail.ItemSKU
                               ELSE
                                   ''
                           END
                       )                                         AS KeyItem,
                    '1'                                          AS [Package Item Flag],
                    SetDetail.ItemSKU,
                    DimItemMaster.ItemMerchGridOverridePhoto,
                    SUM(SetDetail.Quantity)                      AS Quantity,
                    SUM(PriceList.Price)                         AS Price,
                    MAX(MonthItemDetail.Allowed)                 AS Allowed,
                    MAX(MonthItemDetail.AvgPrice)                AS AvgPrice,
                    MAX(MonthItemDetail.StdCost)                 AS StdCost,
                    MAX(MonthItemDetail.ActCost)                 AS ActCost,
                    MAX(MonthItemDetail.RentalAcct)              AS RentalAcct,
                    MAX(CAST(MonthItemDetail.Rental AS INT)) AS Rental,
                    MAX(DimItemMaster.ItemClass)                 AS ItemClass,
                    MAX(MonthItemDetail.FOBPrice)                AS FOBPrice,
                    MAX(MonthItemDetail.Returned)                AS Returned,
                    MAX(MonthItemDetail.Discount)                AS MDiscount,
                    MAX(MonthItemDetail.FOBMargin)               AS FOBMargin,
                    MAX(MonthItemDetail.ActMargin)               AS ActMargin
            INTO
                #SetDetailTmp2
            FROM
                    [$(MasterData_Warehouse)].[ProductKnowledge].SetDetail
                JOIN
                    #PriceList PriceList
                        ON SetDetail.ItemSKU = PriceList.ItemSKU 
                JOIN
                    [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
                        ON DimItemMaster.ItemSKU = SetDetail.ItemSKU
                JOIN
                    AFISales_Enh.MonthItemDetail
                        ON DimItemMaster.ItemSKU = MonthItemDetail.ItemNum
            GROUP BY
                    SetDetail.SetNumber,
                    SetDetail.ItemSKU,
                    DimItemMaster.ItemMerchGridOverridePhoto
            UNION ALL
            SELECT
                    SetDetailTmp.[Package Item],
                    SetDetailTmp.ItemSKU,
                    '0'                                     AS [Package Item Flag],
                    SetDetailTmp.ItemSKU                    ,
                    DimItemMaster.ItemMerchGridOverridePhoto,
                    1                                       AS Quantity ,
                    PriceList.Price,
                    MonthItemDetail.Allowed,
                    MonthItemDetail.AvgPrice,
                    MonthItemDetail.StdCost,
                    MonthItemDetail.ActCost,
                    MonthItemDetail.RentalAcct,
                    CAST(MonthItemDetail.Rental AS INT) AS Rental,
                    DimItemMaster.ItemClass,
                    MonthItemDetail.FOBPrice,
                    MonthItemDetail.Returned,
                    MonthItemDetail.Discount,
                    MonthItemDetail.FOBMargin,
                    MonthItemDetail.ActMargin
            FROM
                    #SetDetailTmp SetDetailTmp
                JOIN
                    #PriceList PriceList
                        ON SetDetailTmp.ItemSKU = PriceList.ItemSKU
                JOIN
                    [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
                        ON DimItemMaster.ItemSKU = PriceList.ItemSKU
                JOIN
                    AFISales_Enh.MonthItemDetail
                        ON DimItemMaster.ItemSKU = MonthItemDetail.ItemNum;




            SELECT
                    SetDetail.SetNumber,
                    MAX(   CASE
                               WHEN DimItemMaster.KeyItem = 1
                                   THEN
                                   SetDetail.ItemSKU
                               ELSE
                                   ''
                           END
                       )                                         AS KeyItem,
                    '1'                                          AS [Package Item Flag],
                    SetDetail.ItemSKU,
                    DimItemMaster.ItemMerchGridOverridePhoto,
                    SUM(SetDetail.Quantity)                      AS Quantity,
                    SUM(PriceList.Price)                         AS Price,
                    MAX(MonthItemDetail.Allowed)                 AS Allowed,
                    MAX(MonthItemDetail.AvgPrice)                AS AvgPrice,
                    MAX(MonthItemDetail.StdCost)                 AS StdCost,
                    MAX(MonthItemDetail.ActCost)                 AS ActCost,
                    MAX(MonthItemDetail.RentalAcct)              AS RentalAcct,
                    MAX(CAST(MonthItemDetail.Rental AS INT)) AS Rental,
                    MAX(DimItemMaster.ItemClass)                 AS ItemClass,
                    MAX(MonthItemDetail.FOBPrice)                AS FOBPrice,
                    MAX(MonthItemDetail.Returned)                AS Returned,
                    MAX(MonthItemDetail.Discount)                AS Discount,
                    MAX(MonthItemDetail.FOBMargin)               AS FOBMargin,
                    MAX(MonthItemDetail.ActMargin)               AS ActMargin
            INTO
                #ValidItmTmp 
            FROM
                    [$(MasterData_Warehouse)].[ProductKnowledge].SetDetail
                JOIN
                    #PriceList PriceList
                        ON SetDetail.ItemSKU = PriceList.ItemSKU
                JOIN
                    [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
                        ON DimItemMaster.ItemSKU = SetDetail.ItemSKU
                JOIN
                    AFISales_Enh.MonthItemDetail
                        ON DimItemMaster.ItemSKU = MonthItemDetail.ItemNum
            GROUP BY
                    SetDetail.SetNumber,
                    SetDetail.ItemSKU,
                    DimItemMaster.ItemMerchGridOverridePhoto
            UNION ALL
            SELECT
                    SetDetailTmp.[Package Item],
                    SetDetailTmp.ItemSKU,
                    '0'                                     AS [Package Item Flag],
                    SetDetailTmp.ItemSKU,
                    DimItemMaster.ItemMerchGridOverridePhoto,
                    1                                       AS Quantity,
                    PriceList.Price,
                    MonthItemDetail.Allowed,
                    MonthItemDetail.AvgPrice,
                    MonthItemDetail.StdCost,
                    MonthItemDetail.ActCost,
                    MonthItemDetail.RentalAcct,
                    CAST(MonthItemDetail.Rental AS INT) AS Rental,
                    DimItemMaster.ItemClass,
                    MonthItemDetail.FOBPrice,
                    MonthItemDetail.Returned,
                    MonthItemDetail.Discount,
                    MonthItemDetail.FOBMargin,
                    MonthItemDetail.ActMargin
            FROM
                    #SetDetailTmp SetDetailTmp
                JOIN
                    #PriceList PriceList
                        ON SetDetailTmp.ItemSKU = PriceList.ItemSKU
                JOIN
                    [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
                        ON DimItemMaster.ItemSKU = SetDetailTmp.ItemSKU
                JOIN
                    AFISales_Enh.MonthItemDetail
                        ON DimItemMaster.ItemSKU = MonthItemDetail.ItemNum
            UNION ALL
            SELECT
                    Itms.[War Room Package ID] AS SetNumber,
                    Itms.KeyItem,
                    Itms.[Package Item Flag],
                    Itms.ItemSKU,
                    Itms.ItemMerchGridOverridePhoto,
                    ValidItems.Quantity,
                    Itms.Price,
                    Itms.Allowed,
                    Itms.AvgPrice,
                    Itms.StdCost,
                    Itms.ActCost,
                    Itms.RentalAcct,
                    Itms.Rental,
                    Itms.ItemClass,
                    Itms.FOBPrice,
                    Itms.Returned,
                    Itms.Discount,
                    Itms.FOBMargin,
                    Itms.ActMargin
            FROM
                    (
                        SELECT
                                ValidSeries.[War Room Package ID],
                                KeyItem                              = NULL,
                                '0'                                  AS [Package Item Flag],
                                AllItms.SeriesNumber,
                                AllItms.ItemSKU,
                                AllItms.ItemMerchGridOverridePhoto,
                                SUM(AllItms.Price)                   AS Price,
                                MAX(AllItms.Allowed)                 AS Allowed,
                                MAX(AllItms.AvgPrice)                AS AvgPrice,
                                MAX(AllItms.StdCost)                 AS StdCost,
                                MAX(AllItms.ActCost)                 AS ActCost,
                                MAX(AllItms.RentalAcct)              AS RentalAcct,
                                MAX(CAST(AllItms.Rental AS INT)) AS Rental,
                                MAX(AllItms.ItemClass)               AS ItemClass,
                                MAX(AllItms.FOBPrice)                AS FOBPrice,
                                MAX(AllItms.Returned)                AS Returned,
                                MAX(AllItms.Discount)                AS Discount,
                                MAX(AllItms.FOBMargin)               AS FOBMargin,
                                MAX(AllItms.ActMargin)               AS ActMargin
                        FROM
                                (
                                    SELECT
                                            DimItemMaster.ItemSKU,
                                            DimItemMaster.SeriesNumber,
                                            DimItemMaster.ItemMerchGridOverridePhoto,
                                            DimItemMaster.KeyItem,
                                            PriceList.Price,
                                            MonthItemDetail.Allowed,
                                            MonthItemDetail.AvgPrice,
                                            MonthItemDetail.StdCost,
                                            MonthItemDetail.ActCost,
                                            MonthItemDetail.RentalAcct,
                                            MonthItemDetail.Rental,
                                            DimItemMaster.ItemClass,
                                            MonthItemDetail.FOBPrice,
                                            MonthItemDetail.Returned,
                                            MonthItemDetail.Discount,
                                            MonthItemDetail.FOBMargin,
                                            MonthItemDetail.ActMargin
                                    FROM
                                            #PriceList PriceList
                                        JOIN
                                            [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
                                                ON DimItemMaster.ItemSKU = PriceList.ItemSKU
                                        JOIN
                                            AFISales_Enh.MonthItemDetail
                                                ON DimItemMaster.ItemSKU = MonthItemDetail.ItemNum
                                ) AllItms
                            LEFT JOIN
                                (
                                    SELECT
                                            SetDetailTmp2.SetNumber          AS [War Room Package ID],
                                            SetHeader.AfterSeries            AS [Package Series Number]
                                    FROM
                                            [$(MasterData_Warehouse)].[ProductKnowledge].SetHeader
                                        JOIN
                                            [$(MasterData_Warehouse)].[ProductKnowledge].SetTemplate
                                                ON SetTemplate.TemplateID = SetHeader.TemplateID
                                        JOIN
                                            [$(MasterData_Warehouse)].[ProductKnowledge].ItemSeries
                                                ON SetHeader.AfterSeries = ItemSeries.SeriesCode
                                        JOIN
                                            [$(MasterData_Warehouse)].[ProductKnowledge].SeriesGroupingLookup
                                                ON ItemSeries.Grouping = SeriesGroupingLookup.LookupID
                                        JOIN
                                            [$(MasterData_Warehouse)].[ProductKnowledge].SetApplications
                                                ON SetApplications.SetNumber = SetHeader.SetNumber
                                        JOIN
                                            [$(MasterData_Warehouse)].[ProductKnowledge].ParentStyleLookup
                                                ON ItemSeries.Style = ParentStyleLookup.ParentStyleCode
                                        JOIN
                                            [$(MasterData_Warehouse)].[ProductKnowledge].ChildStyleLookup
                                                ON ItemSeries.ChildStyleCode = ChildStyleLookup.ChildStyleCode
                                        JOIN
                                            #SetDetailTmp2 SetDetailTmp2
                                                ON SetApplications.SetNumber = SetDetailTmp2.SetNumber
                                    WHERE
                                            SeriesGroupingLookup.PrPointType = 'P'
                                            AND SetApplications.Application IN (
                                                                                   'W', 'P', 'D'
                                                                               )
                                            AND (ItemSeries.Discontinued = 0)
                                    GROUP BY
                                            SetDetailTmp2.SetNumber,
                                            SetHeader.AfterSeries
                                ) ValidSeries
                                    ON AllItms.SeriesNumber = ValidSeries.[Package Series Number]
                        GROUP BY
                                [War Room Package ID],
                                AllItms.SeriesNumber,
                                AllItms.ItemSKU,
                                AllItms.ItemMerchGridOverridePhoto
                    ) Itms
                LEFT JOIN
                    (
                        SELECT
                                SetDetailTmp2.SetNumber AS [War Room Package ID],
                                SetHeader.AfterSeries   AS [Package Series Number],
                                SetDetailTmp2.ItemSKU,
                                SetDetailTmp2.Quantity
                        FROM
                                [$(MasterData_Warehouse)].[ProductKnowledge].SetHeader
                            JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].SetTemplate
                                    ON SetTemplate.TemplateID = SetHeader.TemplateID
                            JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].ItemSeries
                                    ON SetHeader.AfterSeries = ItemSeries.SeriesCode
                            JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].SeriesGroupingLookup
                                    ON ItemSeries.Grouping = SeriesGroupingLookup.LookupID
                            JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].SetApplications
                                    ON SetApplications.SetNumber = SetHeader.SetNumber
                            JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].ParentStyleLookup
                                    ON ItemSeries.Style = ParentStyleLookup.ParentStyleCode
                            JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].ChildStyleLookup
                                    ON ItemSeries.ChildStyleCode = ChildStyleLookup.ChildStyleCode
                            JOIN
                                #SetDetailTmp2 SetDetailTmp2
                                    ON SetApplications.SetNumber = SetDetailTmp2.SetNumber
                        WHERE
                                SeriesGroupingLookup.PrPointType = 'P'
                                AND SetApplications.Application IN (
                                                                       'W', 'P', 'D'
                                                                   )
                                AND (ItemSeries.Discontinued = 0)
                        GROUP BY
                                SetDetailTmp2.SetNumber,
                                SetHeader.AfterSeries,
                                SetDetailTmp2.ItemSKU,
                                SetDetailTmp2.Quantity
                    ) ValidItems
                        ON Itms.[War Room Package ID] = ValidItems.[War Room Package ID]
                           AND Itms.SeriesNumber = ValidItems.[Package Series Number]
                           AND Itms.ItemSKU = ValidItems.ItemSKU
            WHERE
                    ValidItems.ItemSKU IS NULL
                    AND Itms.[War Room Package ID] IS NOT NULL;




            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                'AFISales_DW.DimWarRoomPackageDetails_LOAD';


            CREATE TABLE AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [War Room Package ID]            VARCHAR(15)    NULL,
                    [Item Number]                    VARCHAR(15)    NULL,
                    [Package Description]            VARCHAR(60)    NULL,
                    [Template ID]                    VARCHAR(15)    NULL,
                    [Package Detail]                 VARCHAR(60)    NULL,
                    [Package Series Number]          VARCHAR(16)    NULL,
                    [Item Merch Grid Override Photo] VARCHAR(8000)  NULL,
                    [Package Image]                  VARCHAR(8000)  NULL,
                    [FOB Arcadia]                    DECIMAL(9, 2)  NULL,
                    [ABC Code]                       CHAR(1)        NULL,
                    [Logility Status]                CHAR(1)        NULL,
                    [Trend Arrow]                    VARCHAR(20)    NULL,
                    [Series Margin FOB]              DECIMAL(9, 2)  NULL,
                    [Series Margin Current]          DECIMAL(9, 2)  NULL,
                    [Series Margin Actual]           DECIMAL(9, 2)  NULL,
                    [Monthly Totals for]             VARCHAR(30)    NULL,
                    [GMROI]                          DECIMAL(8, 1)  NULL,
                    [Profit Cnt His]                 DECIMAL(12, 4) NULL,
                    [Profit Cnt Pro]                 NUMERIC(10, 0) NULL,
                    [Profit Cnt His Std]             DECIMAL(12, 4) NULL,
                    [Profit Cnt Pro Std]             NUMERIC(10, 0) NULL,
                    [Profit Cnt His Act]             DECIMAL(21, 4) NULL,
                    [Profit Cnt Pro Act]             NUMERIC(10, 0) NULL,
                    [Logility Month Ave His]         DECIMAL(12, 4) NULL,
                    [Logility Month Ave Pro]         DECIMAL(12, 4) NULL,
                    [Logility Month Ave His Dol]     DECIMAL(12, 4) NULL,
                    [Logility Month Ave Pro Dol]     DECIMAL(12, 4) NULL,
                    [Item AVG]                       NUMERIC(5, 0)  NULL,
                    [Item STD]                       NUMERIC(8, 2)  NULL,
                    [Item ACT]                       NUMERIC(8, 2)  NULL,
                    [Rental Acct]                    VARCHAR(3)     NULL,
                    [Rental]                         INT        NULL,
                    [Source]                         VARCHAR(1)     NULL,
                    [Ret Pr Pt]                      INT            NULL,
                    [Min MU]                         INT            NULL,
                    [Ret MU]                         INT            NULL,
                    [package Type]                   CHAR(2)        NULL,
                    [War Room Key Item]              INT            NULL,
                    [Amount Returned]                NUMERIC(4, 1)  NULL,
                    [Forecast Result1]               DECIMAL(9, 0)  NULL,
                    [Forecast Result2]               DECIMAL(9, 0)  NULL,
                    [Forecast Result3]               DECIMAL(9, 0)  NULL,
                    [Forecast Result4]               DECIMAL(9, 0)  NULL,
                    [Forecast Result5]               DECIMAL(9, 0)  NULL,
                    [Forecast Result6]               DECIMAL(9, 0)  NULL,
                    [Forecast Result7]               DECIMAL(9, 0)  NULL,
                    [Forecast Result8]               DECIMAL(9, 0)  NULL,
                    [Forecast Result9]               DECIMAL(9, 0)  NULL,
                    [Forecast Result10]              DECIMAL(9, 0)  NULL,
                    [Forecast Result11]              DECIMAL(9, 0)  NULL,
                    [Forecast Result12]              DECIMAL(9, 0)  NULL,
                    [Dollars]                        DECIMAL(12, 2) NULL,
                    [FOB price]                      NUMERIC(5, 0)  NULL,
                    [Quantity Returned]              NUMERIC(4, 1)  NULL,
                    [Discounted]                     NUMERIC(4, 1)  NULL,
                    [FOB]                            NUMERIC(3, 0)  NULL,
                    [ACT]                            NUMERIC(3, 0)  NULL,
                    [Package Item Flag]              VARCHAR(1)     NULL,
                    [Package FOB Arcadia Price]      DECIMAL(12, 3) NULL,
                    [Package Series Name]            VARCHAR(100)   NULL,
                    [Series Item Flag]               INT            NULL
                );

            INSERT INTO AFISales_DW.DimWarRoomPackageDetails_LOAD
                        SELECT  DISTINCT
                                SetHeader.SetNumber                                                  AS [War Room Package ID],
                                ValidItmTmp.ItemSKU                                                  AS [Item Number],
                                SetTemplate.Description                                              AS [Package Description],
                                SetTemplate.TemplateID                                               AS [Template ID],
                                SetHeader.SetName                                                    AS [Package Detail],
                                SetHeader.AfterSeries                                                AS [Package Series Number],
                                CASE
                                    WHEN ValidItmTmp.ItemMerchGridOverridePhoto <> ''
                                        THEN
                                        REPLACE(ValidItmTmp.ItemMerchGridOverridePhoto, 'BIG', 'MED')
                                    ELSE
                                        'NA_MED.gif'
                                END                                                                  AS [Item Merch Grid Override Photo],
                                CASE
                                    WHEN SetHeader.SetImage <> ''
                                        THEN
                                        REPLACE(SetHeader.SetImage, 'BIG', 'MED')
                                    ELSE
                                        'NA_MED.gif'
                                END                                                                  AS [Package Image],
                                ValidItmTmp.Price * ValidItmTmp.Quantity                             AS [FOB Arcadia],
                                SalesForecastTmp.AltCd3_ABC                                          AS [ABC Code],
                                SalesForecastTmp.Fut_Stat                                            AS [Logility Status],
                                [Trend Arrow]                                                        = CASE
                                                                                                           WHEN SalesForecastTmp.Trend_Comp * 100 > 0
                                                                                                               THEN
                                                                                                               'small_arrow_up.gif'
                                                                                                           WHEN SalesForecastTmp.Trend_Comp * 100 <= 0
                                                                                                               THEN
                                                                                                               'small_arrow_down.gif'
                                                                                                           ELSE
                                                                                                               'small_arrow_down.gif'
                                                                                                       END,
                                [Series Margin FOB]                                                  = MoSeriesMargins.FOB * 100,
                                [Series Margin Current]                                              = MoSeriesMargins.CUR * 100,
                                [Series Margin Actual]                                               = MoSeriesMargins.ACT * 100,
                                DATENAME(mm, DATEADD(mm, MoSeriesMargins.MoSeriesMargins.Month, -1)) AS [Monthly Totals for],
                                [GMROI]                                                              = CASE
                                                                                                           WHEN MONTH([$(ETL_Framework)].DW_Developer.fn_GetCSTDate(GETDATE())) = 1
                                                                                                               THEN
                                                                                                               MoSeriesMargins.GMROI_1
                                                                                                           WHEN MONTH([$(ETL_Framework)].DW_Developer.fn_GetCSTDate(GETDATE())) = 2
                                                                                                               THEN
                                                                                                               MoSeriesMargins.GMROI_2
                                                                                                           WHEN MONTH([$(ETL_Framework)].DW_Developer.fn_GetCSTDate(GETDATE())) = 3
                                                                                                               THEN
                                                                                                               MoSeriesMargins.GMROI_3
                                                                                                           WHEN MONTH([$(ETL_Framework)].DW_Developer.fn_GetCSTDate(GETDATE())) = 4
                                                                                                               THEN
                                                                                                               MoSeriesMargins.GMROI_4
                                                                                                           WHEN MONTH([$(ETL_Framework)].DW_Developer.fn_GetCSTDate(GETDATE())) = 5
                                                                                                               THEN
                                                                                                               MoSeriesMargins.GMROI_5
                                                                                                           WHEN MONTH([$(ETL_Framework)].DW_Developer.fn_GetCSTDate(GETDATE())) = 6
                                                                                                               THEN
                                                                                                               MoSeriesMargins.GMROI_6
                                                                                                           WHEN MONTH([$(ETL_Framework)].DW_Developer.fn_GetCSTDate(GETDATE())) = 7
                                                                                                               THEN
                                                                                                               MoSeriesMargins.GMROI_7
                                                                                                           WHEN MONTH([$(ETL_Framework)].DW_Developer.fn_GetCSTDate(GETDATE())) = 8
                                                                                                               THEN
                                                                                                               MoSeriesMargins.GMROI_8
                                                                                                           WHEN MONTH([$(ETL_Framework)].DW_Developer.fn_GetCSTDate(GETDATE())) = 9
                                                                                                               THEN
                                                                                                               MoSeriesMargins.GMROI_9
                                                                                                           WHEN MONTH([$(ETL_Framework)].DW_Developer.fn_GetCSTDate(GETDATE())) = 10
                                                                                                               THEN
                                                                                                               MoSeriesMargins.GMROI_10
                                                                                                           WHEN MONTH([$(ETL_Framework)].DW_Developer.fn_GetCSTDate(GETDATE())) = 11
                                                                                                               THEN
                                                                                                               MoSeriesMargins.GMROI_11
                                                                                                           WHEN MONTH([$(ETL_Framework)].DW_Developer.fn_GetCSTDate(GETDATE())) = 12
                                                                                                               THEN
                                                                                                               MoSeriesMargins.GMROI_12
                                                                                                       END,
                                [Profit Cnt His]                                                     = MoSeriesMargins.Dollars * MoSeriesMargins.FOB,
                                [Profit Cnt Pro]                                                     = WarRoomTmp.PrfCntPro,
                                [Profit Cnt His Std]                                                 = MoSeriesMargins.Dollars * MoSeriesMargins.CUR,
                                [Profit Cnt Pro Std]                                                 = WarRoomTmp.PrfCntProStd,
                                [Profit Cnt His Act]                                                 = MoSeriesMargins.Dollars * MoSeriesMargins.ACT,
                                [Profit Cnt Pro Act]                                                 = WarRoomTmp.PrfCntProAct,
                                [Logility Month Ave His]                                             = SalesForecastTmp.Act_Total / (CASE
                                                                                                                                         WHEN demandCount <> 0
                                                                                                                                             THEN
                                                                                                                                             demandCount
                                                                                                                                         ELSE
                                                                                                                                             1
                                                                                                                                     END
                                                                                                                                    ),
                                [Logility Month Ave Pro]                                             = SalesForecastTmp.FC_Total / (CASE
                                                                                                                                        WHEN resultCount <> 0
                                                                                                                                            THEN
                                                                                                                                            resultCount
                                                                                                                                        ELSE
                                                                                                                                            1
                                                                                                                                    END
                                                                                                                                   ),
                                [Logility Month Ave His Dol]                                         = SalesForecastTmp.Price
                                                                                                       * ROUND(
                                                                                                                  SalesForecastTmp.Act_Total
                                                                                                                  / (CASE
                                                                                                                         WHEN demandCount <> 0
                                                                                                                             THEN
                                                                                                                             demandCount
                                                                                                                         ELSE
                                                                                                                             1
                                                                                                                     END
                                                                                                                    ), 0
                                                                                                              ),
                                [Logility Month Ave Pro Dol]                                         = SalesForecastTmp.Price
                                                                                                       * ROUND(
                                                                                                                  SalesForecastTmp.FC_Total
                                                                                                                  / (CASE
                                                                                                                         WHEN resultCount <> 0
                                                                                                                             THEN
                                                                                                                             resultCount
                                                                                                                         ELSE
                                                                                                                             1
                                                                                                                     END
                                                                                                                    ), 0
                                                                                                              ),
                                ValidItemTemp.AvgPrice                                               [Item AVG],
                                ValidItemTemp.StdCost                                                [Item STD],
                                ValidItemTemp.ActCost                                                [Item ACT],
                                ValidItemTemp.RentalAcct                                             [Rental Acct],
                                ValidItemTemp.Rental                                                 [Rental],
                                [Source]                                                             = CASE
                                                                                                           WHEN SUBSTRING(ValidItmTmp.ItemClass, 2, 1) = 'A'
                                                                                                                OR SUBSTRING(ValidItmTmp.ItemClass, 2, 1) = 'M'
                                                                                                               THEN
                                                                                                               'D'
                                                                                                           ELSE
                                                                                                               'I'
                                                                                                       END,
                                WarRoomTmp.RetPrPt                                                   [Ret Pr Pt],
                                WarRoomTmp.MinMU                                                     [Min MU],
                                WarRoomTmp.RetMU                                                     [Ret MU],
                                SetApplications.Application                                          [Package Type],
                                CASE
                                    WHEN ValidItmTmp.KeyItem IS NOT NULL
                                         AND ValidItmTmp.KeyItem <> ''
                                        THEN
                                        1
                                END                                                                  [War Room Key Item],
                                ValidItemTemp.Allowed                                                [Amount Returned],
                                SalesForecastTmp.[Forecast Result1],
                                SalesForecastTmp.[Forecast Result2],
                                SalesForecastTmp.[Forecast Result3],
                                SalesForecastTmp.[Forecast Result4],
                                SalesForecastTmp.[Forecast Result5],
                                SalesForecastTmp.[Forecast Result6],
                                SalesForecastTmp.[Forecast Result7],
                                SalesForecastTmp.[Forecast Result8],
                                SalesForecastTmp.[Forecast Result9],
                                SalesForecastTmp.[Forecast Result10],
                                SalesForecastTmp.[Forecast Result11],
                                SalesForecastTmp.[Forecast Result12],
                                MoSeriesMargins.MoSeriesMargins.Dollars                              AS [Dollars],
                                ValidItemTemp.FOBPrice                                               AS [FOB price],
                                ValidItemTemp.Returned                                               AS [Quantity Returned],
                                ValidItemTemp.Discount                                               AS [Discounted],
                                ValidItemTemp.FOBMargin                                              AS [FOB],
                                ValidItemTemp.ActMargin                                              AS [ACT],
                                ValidItmTmp.[Package Item Flag],
                                SetPriceTmp.main                                                     AS [Package FOB Arcadia Price],
                                ItemSeries.SeriesName                                                AS [Package Series Name],
                                CASE
                                    WHEN i.ItemSKU IS NULL
                                        THEN
                                        0
                                    ELSE
                                        1
                                END                                                                  AS [Series Item Flag]
                        FROM
                                [$(MasterData_Warehouse)].[ProductKnowledge].SetHeader
                            JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].SetTemplate
                                    ON SetTemplate.TemplateID = SetHeader.TemplateID
                            JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].ItemSeries
                                    ON SetHeader.AfterSeries = ItemSeries.SeriesCode
                            JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].SeriesGroupingLookup
                                    ON ItemSeries.Grouping = SeriesGroupingLookup.LookupID
                            JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].SetApplications
                                    ON SetApplications.SetNumber = SetHeader.SetNumber
                            JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].ParentStyleLookup
                                    ON ItemSeries.Style = ParentStyleLookup.ParentStyleCode
                            JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].ChildStyleLookup
                                    ON ItemSeries.ChildStyleCode = ChildStyleLookup.ChildStyleCode
                            JOIN
                                #ValidItmTmp ValidItmTmp
                                    ON SetApplications.SetNumber = ValidItmTmp.SetNumber
                            LEFT JOIN
                                #SetPriceTmp SetPriceTmp
                                    ON ValidItmTmp.SetNumber = SetPriceTmp.[FOB Package ID]
                            LEFT JOIN
                                #SalesForecastTmp SalesForecastTmp
                                    ON ValidItmTmp.ItemSKU = SalesForecastTmp.ItemSKU
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Marketing.MoSeriesMargins
                                    ON ItemSeries.SeriesCode = MoSeriesMargins.Series
                            LEFT JOIN
                                #WarRoomTmp WarRoomTmp
                                    ON WarRoomTmp.SetNumber = SetHeader.SetNumber
                            LEFT JOIN
                                [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
                                    ON SetHeader.AfterSeries = DimItemMaster.SeriesNumber
                                       AND ValidItmTmp.ItemSKU = DimItemMaster.ItemSKU
                        WHERE
                                SeriesGroupingLookup.PrPointType = 'P'
                                AND SetApplications.Application IN (
                                                                       'W', 'P', 'D'
                                                                   )
                                AND (ItemSeries.Discontinued = 0);


            INSERT INTO AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Item Number],
                    [War Room Package ID],
                    [Package Description],
                    [Package Detail]
                )
                        SELECT
                            DimItemMaster.ItemSKU,
                            'None',
                            'None',
                            'None'
                        FROM
                            [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
                        WHERE
                            ItemSKU NOT IN
                                (
                                    SELECT
                                        [Item Number]
                                    FROM
                                        AFISales_DW.DimWarRoomPackageDetails_LOAD
                                );


            CREATE STATISTICS Stat_DimmWarRoomPackageDetails_PackageID
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [War Room Package ID]
                );
            CREATE STATISTICS Stat_DimmWarRoomPackageDetails_ItemSKU
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Item Number]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Item_STD
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Item STD]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Ret_Pr_Pt
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Ret Pr Pt]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Amount_Returned
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Amount Returned]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Forecast_Result4
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Forecast Result4]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Forecast_Result5
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Forecast Result5]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Forecast_Result9
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Forecast Result9]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Forecast_Result12
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Forecast Result12]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Package_SeriesName
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Package Series Name]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Series_Item_Flag
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Series Item Flag]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Template_ID
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Template ID]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_FOB_Arcadia
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [FOB Arcadia]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Trend_Arrow
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Trend Arrow]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Profit_Cnt_His_Act
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Profit Cnt His Act]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Logility_Month_Ave_His_Dol
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Logility Month Ave His Dol]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Profit_Cnt_Pro_Act
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Profit Cnt Pro Act]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Item_ACT
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Item ACT]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_package_Type
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [package Type]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_War_Room_Key_Item
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [War Room Key Item]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Forecast_Result3
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Forecast Result3]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Forecast_Result7
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Forecast Result7]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Forecast_Result8
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Forecast Result8]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Discounted
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Discounted]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Package_FOB_Arcadia_Price
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Package FOB Arcadia Price]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Package_Series_Number
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Package Series Number]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Package_Image
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Package Image]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Series_Margin_Current
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Series Margin Current]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_GMROI
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [GMROI]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Profit_Cnt_Pro_Std
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Profit Cnt Pro Std]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Logility_Month_Ave_Pro
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Logility Month Ave Pro]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Item_Number
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Item Number]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Package_Description
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Package Description]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Package_Detail
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Package Detail]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_ABC_Code
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [ABC Code]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Series_Margin_Actual
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Series Margin Actual]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Profit_Cnt_His
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Profit Cnt His]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Logility_Month_Ave_His
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Logility Month Ave His]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Logility_Month_Ave_Pro_Dol
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Logility Month Ave Pro Dol]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Rental
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Rental]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Rental_Acct
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Rental Acct]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Ret_MU
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Ret MU]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Forecast_Result6
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Forecast Result6]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Forecast_Result10
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Forecast Result10]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_FOB_price
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [FOB price]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Quantity_Returned
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Quantity Returned]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_ACT
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [ACT]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Item_AVG
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Item AVG]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Source
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Source]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Min_MU
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Min MU]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Forecast_Result1
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Forecast Result1]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Forecast_Result2
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Forecast Result2]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Forecast_Result11
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Forecast Result11]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Dollars
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Dollars]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_FOB
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [FOB]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Package_Item_Flag
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Package Item Flag]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Item_Merch_Grid_Override_Photo
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Item Merch Grid Override Photo]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Logility_Status
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Logility Status]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Series_Margin_FOB
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Series Margin FOB]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Profit_Cnt_Pro
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Profit Cnt Pro]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Monthly_Totals_for
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Monthly Totals for]
                );
            CREATE STATISTICS Stat_DimWarRoomPackageDetails_Profit_Cnt_His_Std
                ON AFISales_DW.DimWarRoomPackageDetails_LOAD
                (
                    [Profit Cnt His Std]
                );


            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                'AFISales_DW.DimWarRoomPackageDetails';


            EXECUTE sp_rename 'AFISales_DW.DimWarRoomPackageDetails_LOAD','DimWarRoomPackageDetails'
            
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


        INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
        VALUES
            (
                @String, @DateValue, @User, 'Process Complete'
            );


        -- Update last modified in Table Dictionary 
        INSERT INTO [$(ETL_Framework)].DW_Developer.TableDictionary_UpdateLog
        VALUES
            (
                'AFISales_DW', 'AFISales_DW', 'DimWarRoomPackageDetails', @DateValue
            );



    END;