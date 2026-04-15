CREATE PROC [AFISales_Enh].[usp_Rebuild_WarRoomData]
AS
    BEGIN
        /**********************************************************
*Procedure  Name: usp_rebuildWarRoomData
*Database: datawhse
*Business Function : Rebuild War Room Data
*Author: Matt Carter          Date: 07/23/03
*        Based on vb6 WarRoomData build created by B.Dotta
*Modified: Barb Dotta  1/2/04 fix current year when mo is 1 and Margin file is 11
*          Note: assumes that Margin file will never be 2 months behind
*          Removed code to get series disco back 90 days
*Mofified: Barb Dotta  1/6/04 if key item missing, get only active key from tbl_item
*Modified: B. Dotta  2/20/07  Add tableware items that are not coded as key items (ItemSKU like 'A2%')
*Modified: Bob Horton 5/3/2011 converted order and sales history queries 
*Modified: Bob Horton 12/21/2017 converted to pull from fact/dim tables
* Amy Morina 04/26/2018 changed all references to GETDate() to [$(ETL_Framework)].DW_Developer.fn_GetCSTDate(GETDate())
* 02/26/2020 Changed insert to "Values" syntax to avoid exclusive locks
* Bob Horton converted to Fabric 10/24/2023
*********************************************************/
        DECLARE
            @String    VARCHAR(5000),
            @DateValue DATETIME,
            @User      VARCHAR(500);

        SET @String = 'AFISales_DW.AFISales_Enh.usp_Rebuild_WarRoomData';
        SET @User = SYSTEM_USER;
        SET @DateValue = Getdate()
            SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)

        INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
        VALUES
            (
                @String, @DateValue, @User, 'Process Start'
            );

        BEGIN TRY

            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                'Tempdb..#tb_WarRoom';
            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                'Tempdb..#tb_WarRoomFinal';
            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                'Tempdb..#tb_options';
            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                'Tempdb..#Tempf';
            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                'Tempdb..#Tempf2';
            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                'Tempdb..#tb_historyi';
            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                'Tempdb..#tb_historyo';
            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                'Tempdb..#tb_Margins';
            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                'Tempdb..#tb_mainPieceMap';
            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                'Tempdb..#tb_MarginsFinal';


            /*** Declare working variables ***/
            DECLARE
                @currentMonth   INT,
                @currentYear    INT,
                @currentMonth1  INT,
                @currentYear1   INT,
                @currentMonth2  INT,
                @currentYear2   INT,
                @DiscountFactor DECIMAL(12,3);

            /*** Declare cursor variables ***/
            DECLARE
                @Discount INT,
                @Margin   DECIMAL(12,2),
                @Cost     DECIMAL(12,2);

            /*** Calculate current ytd month plus previous 2 months ***/
            /* To match Margin data with history data use Margin data as the basis for the current month */
            SET @currentMonth =
                (
                    SELECT
                        MAX(Month)
                    FROM
                        [$(Wholesale_Warehouse)].Marketing.MoSeriesMargins
                );
            --added code 1/2/04 to get correct data when current mo is Jan and Margin file is Nov
            IF @currentMonth <> 12
               AND DatePART(mm, @DateValue) <> 1
                SET @currentYear = DatePART(yy, @DateValue);
            ELSE
                SET @currentYear = DatePART(yy, DateADD(yy, -1, @DateValue));

            IF @currentMonth = 1
                BEGIN
                    SET @currentMonth1 = 12;
                    SET @currentYear1 = @currentYear - 1;
                    SET @currentMonth2 = 11;
                    SET @currentYear2 = @currentYear - 1;
                END;
            ELSE IF @currentMonth = 2
                     BEGIN
                         SET @currentMonth1 = 1;
                         SET @currentYear1 = @currentYear;
                         SET @currentMonth2 = 12;
                         SET @currentYear2 = @currentYear - 1;
                     END;
            ELSE
                     BEGIN
                         SET @currentMonth1 = @currentMonth - 1;
                         SET @currentYear1 = @currentYear;
                         SET @currentMonth2 = @currentMonth - 2;
                         SET @currentYear2 = @currentYear;
                     END;

            /*** Create working table with information that we need ***/
            SELECT
                Results,
                TemplateID,
                Series,
                SeriesName,
                SerDisco,
                Showroom,
                Source,
                [Group],
                IntroDate,
                ParStyle,
                ChildStyle,
                KeyItem,
                ItmDisco,
                Descr,
                [Image],
                FOBOrig,
                [MnthAveHis3],
                [MnthAveOrd3],
                MnthAveHis,
                MnthAvePro,
                DirArrow,
                MnthAveHisDol,
                MnthAveProDol,
                HardPlcmt,
                RkdMUfob,
                RkdMUact,
                PrfCntHis,
                PrfCntPro,
                PrfCntHisStd,
                PrfCntProStd,
                PrfCntHisAct,
                PrfCntProAct,
                ABC,
                GMROI,
                [Key],
                SetNumber,
                Rental,
                RkdMUCur,
                MoSeriesAmt,
                FutStatus,
                PricePointIncr = CAST(0 AS SMALLINT),
                Freight        = CAST(0 AS DECIMAL(12,3))
            INTO
                #tb_WarRoom
            FROM
                AFISales_Enh.WarRoomData
            WHERE
                Results IS NULL;


            /*** Insert Items that have Price points calculated on Key Item ***/
            INSERT INTO #tb_WarRoom
                (
                    Results,
                    TemplateID,
                    Series,
                    SeriesName,
                    SerDisco,
                    Showroom,
                    Source,
                    [Group],
                    IntroDate,
                    ParStyle,
                    ChildStyle,
                    KeyItem,
                    ItmDisco,
                    Descr,
                    Image,
                    FOBOrig,
                    [MnthAveHis3],
                    [MnthAveOrd3],
                    MnthAveHis,
                    MnthAvePro,
                    DirArrow,
                    MnthAveHisDol,
                    MnthAveProDol,
                    HardPlcmt,
                    RkdMUfob,
                    RkdMUact,
                    PrfCntHis,
                    PrfCntPro,
                    PrfCntHisStd,
                    PrfCntProStd,
                    PrfCntHisAct,
                    PrfCntProAct,
                    ABC,
                    GMROI,
                    [Key],
                    SetNumber,
                    Rental,
                    RkdMUCur,
                    MoSeriesAmt,
                    FutStatus,
                    PricePointIncr,
                    Freight
                )
                        SELECT
                                DimItemMaster.ItemSKU,
                                '',
                                DimItemMaster.SeriesNumber,
                                DimItemMaster.SeriesName,
                                DimItemMaster.SeriesDiscontinuedFlag,
                                DimItemMaster.Showroom,
                                CASE
                                    WHEN SUBSTRING(DimItemMaster.ItemClassCode, 2, 1) = 'A'
                                         OR SUBSTRING(DimItemMaster.ItemClassCode, 2, 1) = 'M'
                                        THEN
                                        'D'
                                    ELSE
                                        'I'
                                END,
                                DimItemMaster.SeriesGrouping,
                                DimItemMaster.SeriesDateArchived,
                                DimItemMaster.ParentStyleDescription,
                                DimItemMaster.ChildStyleDescription,
                                DimItemMaster.ItemSKU,
                                DiscontinuedFlag,
                                DimItemMaster.ItemName,
                                REPLACE(DimItemMaster.ItemImage, 'BIG', 'MED'),
                                ROUND(ISNULL(DimItemMaster.FOBArcPrice, 0), 0),
                                0,
                                0,
                                0,
                                0,
                                '',
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                '',
                                0,
                                0,
                                DimItemMaster.ItemSKU,
                                MonthItemDetail.Rental,
                                0,
                                0,
                                '',
                                DimItemMaster.GroupPriceIncr,
                                CASE
                                    WHEN DimItemMaster.SeriesGrouping = '1'
                                        THEN
                                        8.5
                                    WHEN DimItemMaster.SeriesGrouping = '6'
                                        THEN
                                        3
                                    WHEN DimItemMaster.SeriesGrouping = '9'
                                        THEN
                                        3
                                    WHEN DimItemMaster.SeriesGrouping = '12'
                                        THEN
                                        10
                                    WHEN DimItemMaster.SeriesGrouping = '13'
                                        THEN
                                        10
                                    ELSE
                                        CASE
                                            WHEN DimItemMaster.Showroom = 'Ashley'
                                                THEN
                                                ISNULL(DimItemMaster.FOBArcPrice, 0) * .13
                                            ELSE
                                                ISNULL(DimItemMaster.FOBArcPrice, 0) * .1
                                        END
                                END
                        FROM
                                [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster 
                            JOIN
                                AFISales_Enh.MonthItemDetail
                                    ON DimItemMaster.ItemSKU = MonthItemDetail.ItemSKU
                        WHERE
                                DimItemMaster.GroupPricePointType = 'M'
                                AND
                                    (
                                        DimItemMaster.KeyItem = 1
                                        OR DimItemMaster.ItemSKU LIKE 'a2%'
                                    )
                                AND (DimItemMaster.SeriesDiscontinuedFlag = 0);



            SELECT
                    SetDetail.SetNumber,
                    KeyItem       = MAX(   CASE
                                               WHEN DimItemMaster.KeyItem = 1
                                                   THEN
                                                   SetDetail.ItemSKU
                                               ELSE
                                                   ''
                                           END
                                       ),
                    Price         = SUM(SetDetail.Quantity * DimItemMaster.FOBArcPrice),
                    Rental        = MAX(CAST(MonthItemDetail.Rental AS INT)),
                    ItemClassCode = MAX(DimItemMaster.ItemClassCode)
            INTO
                    #Tempf
            FROM
                    [$(MasterData_Warehouse)].[ProductKnowledge].SetDetail
                JOIN
                    [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
                        ON SetDetail.ItemSKU = DimItemMaster.ItemSKU
                JOIN
                    AFISales_Enh.MonthItemDetail
                        ON DimItemMaster.ItemSKU = MonthItemDetail.ItemSKU
            GROUP BY
                    SetDetail.SetNumber;

            /*** Insert Items that have Price points calculated as packages ***/
            INSERT INTO #tb_WarRoom
                (
                    Results,
                    TemplateID,
                    Series,
                    SeriesName,
                    SerDisco,
                    Showroom,
                    Source,
                    [Group],
                    IntroDate,
                    ParStyle,
                    ChildStyle,
                    KeyItem,
                    ItmDisco,
                    Descr,
                    Image,
                    FOBOrig,
                    [MnthAveHis3],
                    [MnthAveOrd3],
                    MnthAveHis,
                    MnthAvePro,
                    DirArrow,
                    MnthAveHisDol,
                    MnthAveProDol,
                    HardPlcmt,
                    RkdMUfob,
                    RkdMUact,
                    PrfCntHis,
                    PrfCntPro,
                    PrfCntHisStd,
                    PrfCntProStd,
                    PrfCntHisAct,
                    PrfCntProAct,
                    ABC,
                    GMROI,
                    [Key],
                    SetNumber,
                    Rental,
                    RkdMUCur,
                    MoSeriesAmt,
                    FutStatus,
                    PricePointIncr,
                    Freight
                )
                        SELECT
                                Description,
                                SetTemplate.TemplateID,
                                SeriesNumber,
                                SeriesName,
                                SeriesDiscontinuedFlag,
                                Showroom,
                                CASE
                                    WHEN SUBSTRING(i.ItemClassCode, 2, 1) = 'A'
                                         OR SUBSTRING(i.ItemClassCode, 2, 1) = 'M'
                                        THEN
                                        'D'
                                    ELSE
                                        'I'
                                END,
                                SeriesGrouping,
                                SeriesDateArchived,
                                ParentStyleDescription,
                                ChildStyleDescription,
                                ItemSKU,
                                0,
                                SetName,
                                CASE
                                    WHEN SetImage <> ''
                                        THEN
                                        REPLACE(SetImage, 'BIG', 'MED')
                                    ELSE
                                        'NA_MED.gif'
                                END,
                                ROUND(Price, 0),
                                0,
                                0,
                                0,
                                0,
                                '',
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                '',
                                0,
                                CASE
                                    WHEN RTRIM(i.KeyItem) <> ''
                                        THEN
                                        1
                                    ELSE
                                        0
                                END,
                                SetHeader.SetNumber,
                                Rental,
                                0,
                                0,
                                '',
                                CASE
                                    WHEN SetTemplate.TemplateID = 'Pubbs'
                                        THEN
                                        10
                                    WHEN SetTemplate.TemplateID = 'Pubpa'
                                        THEN
                                        50
                                    WHEN SetTemplate.TemplateID = 'Pubpb'
                                        THEN
                                        50
                                    ELSE
                                        GroupPriceIncr
                                END,
                                CASE
                                    WHEN SeriesGrouping = '1'
                                        THEN
                                        8.5
                                    WHEN SeriesGrouping = '6'
                                        THEN
                                        3
                                    WHEN SeriesGrouping = '9'
                                        THEN
                                        3.5
                                    WHEN SeriesGrouping = '12'
                                        THEN
                                        10
                                    WHEN SeriesGrouping = '13'
                                        THEN
                                        10
                                    ELSE
                                        CASE
                                            WHEN Showroom = 'Ashley'
                                                THEN
                                                Price * .13
                                            ELSE
                                                Price * .1
                                        END
                                END
                        FROM
                                [$(MasterData_Warehouse)].[ProductKnowledge].SetHeader
                            JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].SetTemplate
                                    ON SetHeader.TemplateID = SetTemplate.TemplateID
                            JOIN
                                [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster i
                                    ON SetHeader.AfterSeries = SeriesNumber
                            JOIN
                                [$(MasterData_Warehouse)].[ProductKnowledge].SetApplications
                                    ON SetApplications.SetNumber = SetHeader.SetNumber
                            JOIN
                                #Tempf                                                a
                                    ON SetApplications.SetNumber = SetHeader.SetNumber
                        WHERE
                                i.GroupPricePointType = 'P'
                                AND staApplication = 'W'
                                AND (i.SeriesDiscontinuedFlag = 0);

            /* Adjust frieght */
            UPDate
                #tb_WarRoom
            SET
                Freight = Freight / 2
            WHERE
                TemplateID = 'Pubbs';

            /* UpDate main piece on packages without main piece in them */


            SELECT
                SeriesNumber,
                ItemSKU = MIN(ItemSKU)
            INTO
                #Tempf2
            FROM
                [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
            WHERE
                KeyItem = 1
                AND DiscontinuedFlag = 0
                AND SeriesNumber IN
                        (
                            SELECT
                                Series
                            FROM
                                #tb_WarRoom
                            WHERE
                                KeyItem = ''
                        )
            GROUP BY
                SeriesNumber;
            /* If item key item is missing from package then get first default war room package key item. */
            UPDate
                #tb_WarRoom
            SET
                KeyItem = ItemSKU
            FROM
                #Tempf2
            WHERE
                Series = SeriesNumber
                AND KeyItem = '';

            /*** Get Placement information ***/
            /* Summarize placement information by main piece */
            SELECT
                ItemSKU,
                placement = SUM([Current])
            INTO
                #tb_placements
            FROM
                AFISales_Enh.CustItemMonthlyPlacements
            GROUP BY
                ItemSKU;

            /* UpDate working table */
            UPDate
                #tb_WarRoom
            SET
                HardPlcmt = placement
            FROM
                #tb_placements
            WHERE
                KeyItem = ItemSKU;

            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                'Tempdb..#tb_placements';

            /*** Get 3 month order and shipment history ***/
            /* Summarize orders and shipments by each month and by main piece */

            SELECT
                    [Item SKU] AS ItemSKU,
                    QuantityShippedip1   = SUM(   CASE
                                            WHEN [Fiscal Year] = @currentYear2
                                                 AND [Fiscal Month] = @currentMonth2
                                                THEN
                                                [Quantity Shipped]
                                            ELSE
                                                0
                                        END
                                    ),
                    QuantityShippedip2   = SUM(   CASE
                                            WHEN [Fiscal Year] = @currentYear1
                                                 AND [Fiscal Month] = @currentMonth1
                                                THEN
                                                [Quantity Shipped]
                                            ELSE
                                                0
                                        END
                                    ),
                    QuantityShippedip3   = SUM(   CASE
                                            WHEN [Fiscal Year] = @currentYear
                                                 AND [Fiscal Month] = @currentMonth
                                                THEN
                                                [Quantity Shipped]
                                            ELSE
                                                0
                                        END
                                    ),
                    qtyCount1  = MAX(   CASE
                                            WHEN [Fiscal Year] = @currentYear2
                                                 AND [Fiscal Month] = @currentMonth2
                                                 AND [Quantity Shipped] > 0
                                                THEN
                                                1
                                            ELSE
                                                0
                                        END
                                    ),
                    qtyCount2  = MAX(   CASE
                                            WHEN [Fiscal Year] = @currentYear1
                                                 AND [Fiscal Month] = @currentMonth1
                                                 AND [Quantity Shipped] > 0
                                                THEN
                                                1
                                            ELSE
                                                0
                                        END
                                    ),
                    qtyCount3  = MAX(   CASE
                                            WHEN [Fiscal Year] = @currentYear
                                                 AND [Fiscal Month] = @currentMonth
                                                 AND [Quantity Shipped] > 0
                                                THEN
                                                1
                                            ELSE
                                                0
                                        END
                                    )
            INTO
                    #tb_historyi
            FROM
                    AFISales_DW.FactShippedHistory
                JOIN
                    AFISales_DW.DimItemMaster
                        ON FactShippedHistory.[Item SKU] = DimItemMaster.ItemSKU
                JOIN
                     AFISales_DW.DimDateFile
                        ON DimDateFile.[Transaction Date] = FactShippedHistory.[Invoice Date]
            WHERE
                    (
                        DimItemMaster.KeyItem = 1
                        OR DimItemMaster.ItemSKU LIKE 'a2%'
                    )
                    AND
                        (
                            (
                                [Fiscal Year] = @currentYear2
                                AND [Fiscal Month] = @currentMonth2
                            )
                            OR
                                (
                                    [Fiscal Year] = @currentYear1
                                    AND [Fiscal Month] = @currentMonth1
                                )
                            OR
                                (
                                    [Fiscal Year] = @currentYear
                                    AND [Fiscal Month] = @currentMonth
                                )
                        )
            GROUP BY
                    FactShippedHistory.[Item SKU];


            SELECT
                    FactOrderHistory.[Item SKU]   AS ItemSKU,
                    Ordered1  = SUM(   CASE
                                              WHEN [Fiscal Year] = @currentYear2
                                                   AND [Fiscal Month] = @currentMonth2
                                                  THEN
                                                  [Quantity Ordered]
                                              ELSE
                                                  0
                                          END
                                      ),
                    Ordered2  = SUM(   CASE
                                              WHEN [Fiscal Year] = @currentYear1
                                                   AND [Fiscal Month] = @currentMonth1
                                                  THEN
                                                  [Quantity Ordered]
                                              ELSE
                                                  0
                                          END
                                      ),
                    Ordered3  = SUM(   CASE
                                              WHEN [Fiscal Year] = @currentYear
                                                   AND [Fiscal Month] = @currentMonth
                                                  THEN
                                                  [Quantity Ordered]
                                              ELSE
                                                  0
                                          END
                                      ),
                    OrdCount1 = MAX(   CASE
                                              WHEN [Fiscal Year] = @currentYear2
                                                   AND [Fiscal Month] = @currentMonth2
                                                   AND [Quantity Ordered] > 0
                                                  THEN
                                                  1
                                              ELSE
                                                  0
                                          END
                                      ),
                    OrdCount2 = MAX(   CASE
                                              WHEN [Fiscal Year] = @currentYear1
                                                   AND [Fiscal Month] = @currentMonth1
                                                   AND [Quantity Ordered] > 0
                                                  THEN
                                                  1
                                              ELSE
                                                  0
                                          END
                                      ),
                    OrdCount3 = MAX(   CASE
                                              WHEN [Fiscal Year] = @currentYear
                                                   AND [Fiscal Month] = @currentMonth
                                                   AND [Quantity Ordered] > 0
                                                  THEN
                                                  1
                                              ELSE
                                                  0
                                          END
                                      )
            INTO
                    #tb_historyo
            FROM
                    AFISales_DW.FactOrderHistory
                JOIN
                    AFISales_DW.DimItemMaster
                        ON FactOrderHistory.[Item SKU] = DimItemMaster.ItemSKU
                JOIN
                     AFISales_DW.DimDateFile
                        ON CONVERT(CHAR(8), DimDateFile.[Transaction Date], 112) = FactOrderHistory.[Order Change Date]
            WHERE
                    (
                        DimItemMaster.KeyItem = 1
                        OR DimItemMaster.ItemSKU LIKE 'a2%'
                    )
                    AND
                        (
                            (
                                [Fiscal Year] = @currentYear2
                                AND [Fiscal Month] = @currentMonth2
                            )
                            OR
                                (
                                    [Fiscal Year] = @currentYear1
                                    AND [Fiscal Month] = @currentMonth1
                                )
                            OR
                                (
                                    [Fiscal Year] = @currentYear
                                    AND [Fiscal Month] = @currentMonth
                                )
                        )
            GROUP BY
                    FactOrderHistory.[Item SKU];



            /* UpDate working table */
            UPDate
                #tb_WarRoom
            SET
                [MnthAveHis3] = CASE
                                    WHEN qtyCount1 + qtyCount2 + qtyCount3 > 0
                                        THEN
                (QuantityShippedip1 + QuantityShippedip2 + QuantityShippedip3) / (qtyCount1 + qtyCount2 + qtyCount3)
                                    ELSE
                                        999
                                END
            FROM
                #tb_historyi
            WHERE
                KeyItem = ItemSKU;

            UPDate
                #tb_WarRoom
            SET
                [MnthAveOrd3] = CASE
                                    WHEN OrdCount1 + OrdCount2 + OrdCount3 > 0
                                        THEN
                (Ordered1 + Ordered2 + Ordered3) / (OrdCount1 + OrdCount2 + OrdCount3)
                                    ELSE
                                        999
                                END
            FROM
                #tb_historyo
            WHERE
                KeyItem = ItemSKU;



            /*** Get Logility Data ***/
            /* Summarize logility data by month */
            SELECT
                    DimItemMaster.ItemSKU,
                    frtPrice as Price,
                    frtAltCd3_ABC as AltCd3_ABC,
                    frtFut_Stat as Fut_Stat,
                    frtAct_Total as Act_Total,
                    frtFC_Total as FC_Total,
                    frtTrend_Comp as Trend_Comp,
                    demandCount = CASE
                                      WHEN frtAct_DemdPer_12 > 0
                                          THEN
                                          1
                                      ELSE
                                          0
                                  END + CASE
                                            WHEN frtAct_DemdPer_11 > 0
                                                THEN
                                                1
                                            ELSE
                                                0
                                        END + CASE
                                                  WHEN frtAct_DemdPer_10 > 0
                                                      THEN
                                                      1
                                                  ELSE
                                                      0
                                              END + CASE
                                                        WHEN frtAct_DemdPer_9 > 0
                                                            THEN
                                                            1
                                                        ELSE
                                                            0
                                                    END + CASE
                                                              WHEN frtAct_DemdPer_8 > 0
                                                                  THEN
                                                                  1
                                                              ELSE
                                                                  0
                                                          END + CASE
                                                                    WHEN frtAct_DemdPer_7 > 0
                                                                        THEN
                                                                        1
                                                                    ELSE
                                                                        0
                                                                END + CASE
                                                                          WHEN frtAct_DemdPer_6 > 0
                                                                              THEN
                                                                              1
                                                                          ELSE
                                                                              0
                                                                      END + CASE
                                                                                WHEN frtAct_DemdPer_5 > 0
                                                                                    THEN
                                                                                    1
                                                                                ELSE
                                                                                    0
                                                                            END + CASE
                                                                                      WHEN frtAct_DemdPer_4 > 0
                                                                                          THEN
                                                                                          1
                                                                                      ELSE
                                                                                          0
                                                                                  END + CASE
                                                                                            WHEN frtAct_DemdPer_3 > 0
                                                                                                THEN
                                                                                                1
                                                                                            ELSE
                                                                                                0
                                                                                        END + CASE
                                                                                                  WHEN frtAct_DemdPer_2 > 0
                                                                                                      THEN
                                                                                                      1
                                                                                                  ELSE
                                                                                                      0
                                                                                              END
                                  + CASE
                                        WHEN frtAct_DemdPer_1 > 0
                                            THEN
                                            1
                                        ELSE
                                            0
                                    END,
                    resultCount = CASE
                                      WHEN frtResult_FC_12 > 0
                                          THEN
                                          1
                                      ELSE
                                          0
                                  END + CASE
                                            WHEN frtResult_FC_11 > 0
                                                THEN
                                                1
                                            ELSE
                                                0
                                        END + CASE
                                                  WHEN frtResult_FC_10 > 0
                                                      THEN
                                                      1
                                                  ELSE
                                                      0
                                              END + CASE
                                                        WHEN frtResult_FC_9 > 0
                                                            THEN
                                                            1
                                                        ELSE
                                                            0
                                                    END + CASE
                                                              WHEN frtResult_FC_8 > 0
                                                                  THEN
                                                                  1
                                                              ELSE
                                                                  0
                                                          END + CASE
                                                                    WHEN frtResult_FC_7 > 0
                                                                        THEN
                                                                        1
                                                                    ELSE
                                                                        0
                                                                END + CASE
                                                                          WHEN frtResult_FC_6 > 0
                                                                              THEN
                                                                              1
                                                                          ELSE
                                                                              0
                                                                      END + CASE
                                                                                WHEN frtResult_FC_5 > 0
                                                                                    THEN
                                                                                    1
                                                                                ELSE
                                                                                    0
                                                                            END + CASE
                                                                                      WHEN frtResult_FC_4 > 0
                                                                                          THEN
                                                                                          1
                                                                                      ELSE
                                                                                          0
                                                                                  END + CASE
                                                                                            WHEN frtResult_FC_3 > 0
                                                                                                THEN
                                                                                                1
                                                                                            ELSE
                                                                                                0
                                                                                        END + CASE
                                                                                                  WHEN frtResult_FC_2 > 0
                                                                                                      THEN
                                                                                                      1
                                                                                                  ELSE
                                                                                                      0
                                                                                              END
                                  + CASE
                                        WHEN frtResult_FC_1 > 0
                                            THEN
                                            1
                                        ELSE
                                            0
                                    END
            INTO
                    #tb_logility
            FROM
                    AFISales_DW.DimItemMaster
                JOIN
                    [$(Databricks)].wholesale_demandplanning_afi.salesforecast SalesForecast
                        ON DimItemMaster.ItemSKU = SalesForecast.frtItnbr
            WHERE
                    (
                        DimItemMaster.KeyItem = 1
                        OR DimItemMaster.ItemSKU LIKE 'a2%'
                    );

            /* UpDate working table */
            UPDate
                #tb_WarRoom
            SET
                ABC = AltCd3_ABC,
                FutStatus = Fut_Stat,
                DirArrow = CASE
                               WHEN Trend_Comp * 100 > 0
                                   THEN
                                   'small_arrow_up.gif'
                               WHEN Trend_Comp * 100 <= 0
                                   THEN
                                   'small_arrow_down.gif'
                               ELSE
                                   'small_arrow_down.gif'
                           END,
                MnthAveHis = Act_Total / (CASE
                                                 WHEN demandCount <> 0
                                                     THEN
                                                     demandCount
                                                 ELSE
                                                     1
                                             END
                                            ),
                MnthAvePro = FC_Total / (CASE
                                                WHEN resultCount <> 0
                                                    THEN
                                                    resultCount
                                                ELSE
                                                    1
                                            END
                                           ),
                MnthAveHisDol = Price * ROUND(   Act_Total / (CASE
                                                                        WHEN demandCount <> 0
                                                                            THEN
                                                                            demandCount
                                                                        ELSE
                                                                            1
                                                                    END
                                                                   ), 0
                                                ),
                MnthAveProDol = Price * ROUND(   FC_Total / (CASE
                                                                       WHEN resultCount <> 0
                                                                           THEN
                                                                           resultCount
                                                                       ELSE
                                                                           1
                                                                   END
                                                                  ), 0
                                                )
            FROM
                #tb_logility
            WHERE
                KeyItem = ItemSKU;

            DROP TABLE #tb_logility;

            /*** Get Margin information ***/
            /* Summarize Margin information by series */
            SELECT
                Series,
                fob             = FOB * 100,
                cur             = CUR * 100,
                act             = ACT * 100,
                Dollars,
                GMROI           = CASE
                                      WHEN @currentMonth = 1
                                          THEN
                                          GMROI_1
                                      WHEN @currentMonth = 2
                                          THEN
                                          GMROI_2
                                      WHEN @currentMonth = 3
                                          THEN
                                          GMROI_3
                                      WHEN @currentMonth = 4
                                          THEN
                                          GMROI_4
                                      WHEN @currentMonth = 5
                                          THEN
                                          GMROI_5
                                      WHEN @currentMonth = 6
                                          THEN
                                          GMROI_6
                                      WHEN @currentMonth = 7
                                          THEN
                                          GMROI_7
                                      WHEN @currentMonth = 8
                                          THEN
                                          GMROI_8
                                      WHEN @currentMonth = 9
                                          THEN
                                          GMROI_9
                                      WHEN @currentMonth = 10
                                          THEN
                                          GMROI_10
                                      WHEN @currentMonth = 11
                                          THEN
                                          GMROI_11
                                      WHEN @currentMonth = 12
                                          THEN
                                          GMROI_12
                                  END,
                profitConHis    = Dollars * FOB,
                profitConHisStd = Dollars * CUR,
                profitConHisAct = Dollars * ACT
            INTO
                #tb_Margins
            FROM
                [$(Wholesale_Warehouse)].Marketing.MoSeriesMargins

            /* Create main piece to series mapping table */
            SELECT
                ItemSKU,
                MasterGroupCode
            INTO
                #tb_mainPieceMap
            FROM
                [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
            WHERE
                (
                    KeyItem = 1
                    OR ItemSKU LIKE 'a2%'
                );

            /* Create summary of two tables */
            SELECT
                ItemSKU = ItemSKU,
                fob,
                cur,
                act,
                Dollars,
                GMROI,
                profitConHis,
                profitConHisStd,
                profitConHisAct
            INTO
                #tb_MarginsFinal
            FROM
                #tb_mainPieceMap,
                #tb_Margins
            WHERE
                MasterGroupCode = Series;

            /* UpDate working table */
            UPDate
                #tb_WarRoom
            SET
                RkdMUfob = fob,
                RkdMUact = act,
                MoSeriesAmt = Dollars,
                GMROI = MF.GMROI,
                PrfCntHis = profitConHis,
                PrfCntPro = 0,
                PrfCntHisStd = profitConHisStd,
                PrfCntProStd = 0,
                PrfCntHisAct = profitConHisAct,
                PrfCntProAct = 0,
                RkdMUCur = cur
            FROM
                #tb_MarginsFinal MF
            WHERE
                KeyItem = ItemSKU;



            /*** Create final work table ***/
            SELECT
                Results,
                TemplateID,
                Series,
                SeriesName,
                SerDisco,
                Showroom,
                Source,
                [Group],
                IntroDate,
                ParStyle,
                ChildStyle,
                KeyItem,
                ItmDisco,
                Descr,
                Image,
                FOBOrig,
                [MnthAveHis3],
                [MnthAveOrd3],
                MnthAveHis,
                MnthAvePro,
                DirArrow,
                MnthAveHisDol,
                MnthAveProDol,
                HardPlcmt,
                RkdMUfob,
                RkdMUact,
                PrfCntHis,
                PrfCntPro,
                PrfCntHisStd,
                PrfCntProStd,
                PrfCntHisAct,
                PrfCntProAct,
                ABC,
                GMROI,
                [Key],
                SetNumber,
                Rental,
                RkdMUCur,
                MoSeriesAmt,
                FutStatus,
                MinMU,
                FOBDisc,
                RetPrPt,
                RetMU,
                Freight = CAST(0 AS DECIMAL(12,3)),
                upDated = CAST(0 AS INT)
            INTO
                #tb_WarRoomFinal
            FROM
                AFISales_Enh.WarRoomData
            WHERE
                Results IS NULL;

            /*** Create Discount / Margin option table ***/

            SELECT
                CAST(1 AS INT)     AS Rowid,
                CAST(1 AS INT) AS Discount,
                CAST(.35 AS DECIMAL(12,2)) AS Margin
            INTO
                #tb_options;

            INSERT INTO #tb_options
            VALUES
                (
                    2, 1, .37
                );
            INSERT INTO #tb_options
            VALUES
                (
                    3, 1, .39
                );
            INSERT INTO #tb_options
            VALUES
                (
                    4, 1, .4
                );
            INSERT INTO #tb_options
            VALUES
                (
                    5, 1, .42
                );
            INSERT INTO #tb_options
            VALUES
                (
                    6, 1, .44
                );
            INSERT INTO #tb_options
            VALUES
                (
                    7, 1, .45
                );
            INSERT INTO #tb_options
            VALUES
                (
                    8, 1, .48
                );
            INSERT INTO #tb_options
            VALUES
                (
                    9, 1, .5
                );
            INSERT INTO #tb_options
            VALUES
                (
                    10, 0, .35
                );
            INSERT INTO #tb_options
            VALUES
                (
                    11, 0, .37
                );
            INSERT INTO #tb_options
            VALUES
                (
                    12, 0, .39
                );
            INSERT INTO #tb_options
            VALUES
                (
                    13, 0, .4
                );
            INSERT INTO #tb_options
            VALUES
                (
                    14, 0, .42
                );
            INSERT INTO #tb_options
            VALUES
                (
                    15, 0, .44
                );
            INSERT INTO #tb_options
            VALUES
                (
                    16, 0, .45
                );
            INSERT INTO #tb_options
            VALUES
                (
                    17, 0, .48
                );
            INSERT INTO #tb_options
            VALUES
                (
                    18, 0, .5
                );

            /*** Insert records into final work table, calculating Price points as we go ***/
            DECLARE @cnt INT;
            SET @cnt = 1;


            WHILE @cnt <= 18
                BEGIN
                    SET @Discount =
                        (
                            SELECT
                                Discount
                            FROM
                                #tb_options
                            WHERE
                                Rowid = @cnt
                        );
                    SET @Margin =
                        (
                            SELECT
                                Margin
                            FROM
                                #tb_options
                            WHERE
                                Rowid = @cnt
                        );

                    SET @DiscountFactor = CASE
                                              WHEN @Discount = 1
                                                  THEN
                                                  .95
                                              ELSE
                                                  1
                                          END;

                    /* insert base of records for each option and calculate Price point */
                    INSERT INTO #tb_WarRoomFinal
                        (
                            Results,
                            TemplateID,
                            Series,
                            SeriesName,
                            SerDisco,
                            Showroom,
                            Source,
                            [Group],
                            IntroDate,
                            ParStyle,
                            ChildStyle,
                            KeyItem,
                            ItmDisco,
                            Descr,
                            Image,
                            FOBOrig,
                            [MnthAveHis3],
                            [MnthAveOrd3],
                            MnthAveHis,
                            MnthAvePro,
                            DirArrow,
                            MnthAveHisDol,
                            MnthAveProDol,
                            HardPlcmt,
                            RkdMUfob,
                            RkdMUact,
                            PrfCntHis,
                            PrfCntPro,
                            PrfCntHisStd,
                            PrfCntProStd,
                            PrfCntHisAct,
                            PrfCntProAct,
                            ABC,
                            GMROI,
                            [Key],
                            SetNumber,
                            Rental,
                            RkdMUCur,
                            MoSeriesAmt,
                            FutStatus,
                            MinMU,
                            FOBDisc,
                            RetPrPt,
                            RetMU,
                            Freight,
                            upDated
                        )
                                SELECT
                                    Results,
                                    TemplateID,
                                    Series,
                                    SeriesName,
                                    SerDisco,
                                    Showroom,
                                    Source,
                                    [Group],
                                    IntroDate,
                                    ParStyle,
                                    ChildStyle,
                                    KeyItem,
                                    ItmDisco,
                                    Descr,
                                    Image,
                                    FOBOrig,
                                    MnthAveHis3,
                                    MnthAveOrd3,
                                    MnthAveHis,
                                    MnthAvePro,
                                    DirArrow,
                                    MnthAveHisDol,
                                    MnthAveProDol,
                                    HardPlcmt,
                                    RkdMUfob,
                                    RkdMUact,
                                    PrfCntHis,
                                    PrfCntPro,
                                    PrfCntHisStd,
                                    PrfCntProStd,
                                    PrfCntHisAct,
                                    PrfCntProAct,
                                    ABC,
                                    GMROI,
                                    [Key],
                                    SetNumber,
                                    Rental,
                                    RkdMUCur,
                                    MoSeriesAmt,
                                    FutStatus,
                                    @Margin * 100,
                                    @Discount,
                                    FLOOR(((FOBOrig * @DiscountFactor) + Freight) / (1 - @Margin) / PricePointIncr)
                                    * PricePointIncr
                                    + (ROUND(
                                                (((FOBOrig * @DiscountFactor) + Freight) / (1 - @Margin)
                                                 / PricePointIncr
                                                )
                                                - FLOOR(((FOBOrig * @DiscountFactor) + Freight) / (1 - @Margin)
                                                        / PricePointIncr
                                                       ), 0
                                            ) * PricePointIncr
                                      ) - 1,
                                    0,
                                    Freight,
                                    0
                                FROM
                                    #tb_WarRoom;

                    /* UpDate the realized Price point */
                    UPDate
                        #tb_WarRoomFinal
                    SET
                        RetMU = CASE
                                    WHEN RetPrPt <> 0
                                        THEN
                                        ROUND(((RetPrPt - ((FOBOrig * @DiscountFactor) + Freight)) / RetPrPt) * 100, 0)
                                    ELSE
                                        0
                                END,
                        upDated = 1
                    WHERE
                        upDated = 0;

                    /* Get next record */
                    SET @cnt = @cnt + 1;
                END;


            DROP TABLE IF EXISTS AFISales_Enh.WarRoomData_LOAD;

            /*** Clear real table and insert new records ***/
            CREATE TABLE [AFISales_Enh].[WarRoomData_LOAD] (
                [ID]            INT            NULL,
                [Results]       VARCHAR (60)   NOT NULL,
                [TemplateID]    VARCHAR (15)   NOT NULL,
                [Series]        VARCHAR (16)   NOT NULL,
                [SeriesName]    VARCHAR (100)  NOT NULL,
                [SerDisco]      BIT            NOT NULL,
                [Showroom]      VARCHAR (25)   NOT NULL,
                [Source]        VARCHAR (50)   NOT NULL,
                [Group]         VARCHAR (26)   NOT NULL,
                [IntroDate]     DATE           NULL,
                [ParStyle]      VARCHAR (65)   NOT NULL,
                [ChildStyle]    VARCHAR (65)   NOT NULL,
                [KeyItem]       VARCHAR (15)   NOT NULL,
                [ItmDisco]      BIT            NOT NULL,
                [Descr]         VARCHAR (200)  NOT NULL,
                [Image]         VARCHAR (60)   NOT NULL,
                [FOBOrig]       INT            NOT NULL,
                [MinMU]         INT            NOT NULL,
                [FOBDisc]       BIT            NOT NULL,
                [RetPrPt]       INT            NOT NULL,
                [RetMU]         INT            NOT NULL,
                [MnthAveHis3]   NUMERIC (10)   NOT NULL,
                [MnthAveOrd3]   NUMERIC (10)   NOT NULL,
                [MnthAveHis]    NUMERIC (10)   NOT NULL,
                [MnthAvePro]    NUMERIC (10)   NOT NULL,
                [DirArrow]      VARCHAR (50)   NOT NULL,
                [MnthAveHisDol] NUMERIC (10)   NOT NULL,
                [MnthAveProDol] NUMERIC (10)   NOT NULL,
                [HardPlcmt]     INT            NOT NULL,
                [RkdMUfob]      INT            NOT NULL,
                [RkdMUact]      INT            NOT NULL,
                [PrfCntHis]     NUMERIC (10)   NOT NULL,
                [PrfCntPro]     NUMERIC (10)   NOT NULL,
                [PrfCntHisStd]  NUMERIC (10)   NOT NULL,
                [PrfCntProStd]  NUMERIC (10)   NOT NULL,
                [PrfCntHisAct]  NUMERIC (10)   NOT NULL,
                [PrfCntProAct]  NUMERIC (10)   NOT NULL,
                [ABC]           CHAR (2)       NOT NULL,
                [GMROI]         NUMERIC (6, 1) NOT NULL,
                [Key]           BIT            NOT NULL,
                [SetNumber]     VARCHAR (15)   NOT NULL,
                [Rental]        BIT            NOT NULL,
                [RkdMUCur]      INT            NOT NULL,
                [MoSeriesAmt]   NUMERIC (10)   NOT NULL,
                [FutStatus]     CHAR (1)       NOT NULL
            )

         

            INSERT INTO AFISales_Enh.WarRoomData_LOAD
                (
                    ID,
                    Results,
                    TemplateID,
                    Series,
                    SeriesName,
                    SerDisco,
                    Showroom,
                    Source,
                    [Group],
                    IntroDate,
                    ParStyle,
                    ChildStyle,
                    KeyItem,
                    ItmDisco,
                    Descr,
                    Image,
                    FOBOrig,
                    [MnthAveHis3],
                    [MnthAveOrd3],
                    MnthAveHis,
                    MnthAvePro,
                    DirArrow,
                    MnthAveHisDol,
                    MnthAveProDol,
                    HardPlcmt,
                    RkdMUfob,
                    RkdMUact,
                    PrfCntHis,
                    PrfCntPro,
                    PrfCntHisStd,
                    PrfCntProStd,
                    PrfCntHisAct,
                    PrfCntProAct,
                    ABC,
                    GMROI,
                    [Key],
                    SetNumber,
                    Rental,
                    RkdMUCur,
                    MoSeriesAmt,
                    FutStatus,
                    MinMU,
                    FOBDisc,
                    RetPrPt,
                    RetMU
                )
                        SELECT
                            ROW_NUMBER() OVER (ORDER BY
                                                   Series
                                              ) AS Rowid,
                            Results,
                            TemplateID,
                            Series,
                            SeriesName,
                            SerDisco,
                            Showroom,
                            Source,
                            [Group],
                            IntroDate,
                            ParStyle,
                            ChildStyle,
                            KeyItem,
                            ItmDisco,
                            Descr,
                            Image,
                            FOBOrig,
                            [MnthAveHis3],
                            [MnthAveOrd3],
                            MnthAveHis,
                            MnthAvePro,
                            CASE
                                WHEN DirArrow = ''
                                    THEN
                                    'small_arrow_down.gif'
                                ELSE
                                    DirArrow
                            END,
                            MnthAveHisDol,
                            MnthAveProDol,
                            Price               HardPlcmt,
                            RkdMUfob,
                            RkdMUact,
                            PrfCntHis,
                            PrfCntPro,
                            PrfCntHisStd,
                            PrfCntProStd,
                            PrfCntHisAct,
                            PrfCntProAct,
                            CASE
                                WHEN ABC = ''
                                    THEN
                                    'na'
                                ELSE
                                    ABC
                            END,
                            GMROI,
                            [Key],
                            SetNumber,
                            Rental,
                            RkdMUCur,
                            MoSeriesAmt,
                            FutStatus,
                            MinMU,
                            FOBDisc,
                            RetPrPt,
                            RetMU
                        FROM
                            #tb_WarRoomFinal;

   
            CREATE STATISTICS [Stat_WarRoomData_TemplateID]
                ON [AFISales_Enh].[WarRoomData_LOAD]([TemplateID]);

            CREATE STATISTICS [Stat_WarRoomData_SetNumber]
                ON [AFISales_Enh].[WarRoomData_LOAD]([SetNumber]);

            CREATE STATISTICS [Stat_WarRoomData_Series]
                ON [AFISales_Enh].[WarRoomData_LOAD]([Series]);

            CREATE STATISTICS [Stat_WarRoomData_ParStyle]
                ON [AFISales_Enh].[WarRoomData_LOAD]([ParStyle]);

            CREATE STATISTICS [Stat_WarRoomData_MinMU]
                ON [AFISales_Enh].[WarRoomData_LOAD]([MinMU]);

            CREATE STATISTICS [Stat_WarRoomData_KeyItem]
                ON [AFISales_Enh].[WarRoomData_LOAD]([KeyItem]);

            CREATE STATISTICS [Stat_WarRoomData_Key]
                ON [AFISales_Enh].[WarRoomData_LOAD]([Key]);

            CREATE STATISTICS [Stat_WarRoomData_ItmDisco]
                ON [AFISales_Enh].[WarRoomData_LOAD]([ItmDisco]);

            CREATE STATISTICS [Stat_WarRoomData_IntroDate]
                ON [AFISales_Enh].[WarRoomData_LOAD]([IntroDate]);

            CREATE STATISTICS [Stat_WarRoomData_ID]
                ON [AFISales_Enh].[WarRoomData_LOAD]([ID]);

            CREATE STATISTICS [Stat_WarRoomData_Group]
                ON [AFISales_Enh].[WarRoomData_LOAD]([Group]);

            CREATE STATISTICS [Stat_WarRoomData_GMROI]
                ON [AFISales_Enh].[WarRoomData_LOAD]([GMROI]);

            CREATE STATISTICS [Stat_WarRoomData_FutStatus]
                ON [AFISales_Enh].[WarRoomData_LOAD]([FutStatus]);

            CREATE STATISTICS [Stat_WarRoomData_FOBDisc]
                ON [AFISales_Enh].[WarRoomData_LOAD]([FOBDisc]);

            CREATE STATISTICS [Stat_WarRoomData_ChildStyle]
                ON [AFISales_Enh].[WarRoomData_LOAD]([ChildStyle]);
 
            CREATE STATISTICS [Stat_WarRoomData_ABC]
                ON [AFISales_Enh].[WarRoomData_LOAD]([ABC]);

            
            DROP TABLE IF EXISTS AFISales_Enh.WarRoomData;


            EXECUTE sp_rename 'AFISales_Enh.WarRoomData_LOAD','WarRoomData'

            DROP TABLE IF EXISTS Tempdb..#tb_WarRoom;
            DROP TABLE IF EXISTS Tempdb..#tb_WarRoomFinal;
            DROP TABLE IF EXISTS Tempdb..#tb_options;
            DROP TABLE IF EXISTS Tempdb..#Tempf;
            DROP TABLE IF EXISTS Tempdb..#Tempf2;
            DROP TABLE IF EXISTS Tempdb..#tb_historyi;
            DROP TABLE IF EXISTS Tempdb..#tb_historyo;
            DROP TABLE IF EXISTS Tempdb..#tb_Margins;
            DROP TABLE IF EXISTS Tempdb..#tb_mainPieceMap;
            DROP TABLE IF EXISTS Tempdb..#tb_MarginsFinal;

        END TRY
        BEGIN CATCH
            DECLARE
                @ErrorMessage  VARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState    INT;
            SET @ErrorMessage = ERROR_MESSAGE();
            SET @ErrorSeverity = ISNULL(ERROR_SEVERITY(), 16);
            SET @ErrorState = ISNULL(ERROR_STATE(), 0);
            
            SET @DateValue = Getdate()
            SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)


            INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
            VALUES
                (
                    @String, @DateValue, @User, @ErrorMessage
                );

            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        END CATCH;
        
        SET @DateValue = Getdate()
         SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)

        EXEC [$(ETL_Framework)].DW_Developer.usp_UpdateTableDictionary_ModifiedDate 
            'AFISales_DW', 'AFISales_Enh', 'WarRoomData', @String, @DateValue;

    END;