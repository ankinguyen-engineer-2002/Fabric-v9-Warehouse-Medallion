CREATE PROC [AFISales_Enh].[usp_Rebuild_MonthlyItemDetail]
AS

    /* Change Control -----------------------------------------------------------------------------------------------------------
* Procedure: [AFISales_Enh].[usp_Rebuild_MoItemDetail]
* Description: UPDATEs MonthItemDetail for Ashley War Room
* Barb Dotta (10/2/03): Created
* BD (4/5/04): Changed rental query to check only RAC AND Rentway accts.
* BD (4/6/04): Added field UPDATE for country code 
* BD (4/7/04): Changed rental queries to acct code for RAC AND Rentway
* BD (12/14/05): Added country code VN for Vietnam
* BD (8/21/06): Changed country code to come FROM WarRoomCountryCodes
* Jdenning (8/13/07): Star Equals Project
*					  Removed all occurances of table JOINs using the *= =*
*						syntax because it isn't supported in SQL 2005.
* Bob Horton (5/3/2011): Converted Order AND Sales History Queries
* Bob Horton (Jan 2018): Migrated FROM PDW Cube load view to Azure Data Warehouse
* Gabe De Mayo (3/2/18): Modified to use usp_CreateReplicateWorkTable/UPDATEd object existence check/UPDATEd error handling
* Amy Morina 04/26/2018 changed all references to GETDATE() to DW_Developer.fn_GetCSTDate(GETDATE())
* 02/26/2020 Changed insert to "Values" syntax to avoid exclusive locks
* Bob Horton, converted to Fabric  10-23-2023
---------------------------------------------------------------------------------------------------------------------------*/

    BEGIN

        DECLARE
            @String    VARCHAR(5000),
            @DateValue DATETIME2(6),
            @User      VARCHAR(500);

        SET @String = 'AFISales_DW.AFISales_Enh.usp_Rebuild_MonthlyItemDetail';
        SET @User = SYSTEM_USER;
        SET @DateValue = Getdate()
         SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)


        INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
        VALUES
            (
                @String, @DateValue, @User, 'Process Start'
            );

        BEGIN TRY

            /*DECLARE variables*/
            DECLARE @CurYear INT;
            DECLARE @12moYear INT;
            DECLARE @3moYear INT;
            DECLARE @6moYear INT;
            DECLARE @CurPeriod INT;
            DECLARE @12moPeriod INT;
            DECLARE @3moPeriod INT;
            DECLARE @6moPeriod INT;

            /*SET prev month AND years*/
            SET @CurPeriod = DATEPART(mm, DATEADD(mm, -1, @DateValue));
            SET @3moPeriod = DATEPART(mm, DATEADD(mm, -3, @DateValue));
            SET @6moPeriod = DATEPART(mm, DATEADD(mm, -6, @DateValue));
            SET @12moPeriod = DATEPART(mm, DATEADD(mm, -12, @DateValue));

            SET @CurYear = DATEPART(yyyy, DATEADD(mm, -1, @DateValue));
            SET @3moYear = DATEPART(yyyy, DATEADD(mm, -3, @DateValue));
            SET @6moYear = DATEPART(yyyy, DATEADD(mm, -6, @DateValue));
            SET @12moYear = DATEPART(yyyy, DATEADD(mm, -12, @DateValue));

            /*DECLARE working table*/

            SELECT
                ItemSKU,
                QuantityShippedipped,
                QtyOrdered,
                AmtShipped,
                AmtOrdered,
                FOBPrice,
                AvgPrice,
                Returned,
                Allowed,
                Discount,
                StdCost,
                ActCost,
                FOBMargin,
                ActMargin,
                Rental,
                TotalAmtShipped,
                TotalAmtOrdered,
                Period,
                Year,
                Landed,
                MoQty3,
                MoQty6,
                MoQty12,
                FutStatus,
                CountryCode,
                RentalAcct
            INTO
                #temp_MoItemDetail
            FROM
                AFISales_Enh.MonthItemDetail
            WHERE
                ItemSKU IS NULL;


            /*insert items....*/
            INSERT INTO #temp_MoItemDetail
                (
                    ItemSKU,
                    QuantityShippedipped,
                    QtyOrdered,
                    AmtShipped,
                    AmtOrdered,
                    FOBPrice,
                    AvgPrice,
                    Returned,
                    Allowed,
                    Discount,
                    StdCost,
                    ActCost,
                    FOBMargin,
                    ActMargin,
                    Rental,
                    TotalAmtShipped,
                    TotalAmtOrdered,
                    Period,
                    Year,
                    Landed,
                    MoQty3,
                    MoQty6,
                    MoQty12,
                    FutStatus,
                    CountryCode,
                    RentalAcct
                )
                        SELECT
                                DimItemMaster.ItemSKU,
                                0,
                                0,
                                0,
                                0,
                              --  CASE
                              --      WHEN (FOBPRICE IS NOT NULL)
                               --         THEN
                                --        FOBPRICE
                                --    ELSE
                                        0,
                               -- END,
                             --   CASE
                             --       WHEN (AVGSELL IS NOT NULL)
                                --        THEN
                               --         AVGSELL
                                 --   ELSE
                                        0,
                               -- END,
                                0,
                                0,
                                0,
                             --   CASE
                              --      WHEN (CURUC IS NOT NULL)
                              --          THEN
                               --         CURUC
                              --      ELSE
                                        0,
                              --  END,
                              --  CASE
                             --       WHEN (ACCOST IS NOT NULL)
                              --          THEN
                              --          ACCOST
                               --     ELSE
                                        0,
                               -- END
                                0,
                                0,
                                0,
                                0,
                                0,
                                @CurPeriod,
                                @CurYear,
                                0,
                                0,
                                0,
                                0,
                                CASE
                                    WHEN (SalesForecast.frtFut_Stat IS NOT NULL)
                                        THEN
                                        SalesForecast.frtFut_Stat
                                    ELSE
                                        ''
                                END,
                                '',
                                ''
                        FROM
                                AFISales_DW.DimItemMaster 
                         --   LEFT OUTER JOIN
                         --       [$(Databricks)].[masterdata_itemmaster_afi].mb_ac0701 MB_AC0701          
                         --           ON DimItemMaster.ItemSKU = MB_AC0701.ACITEM
                            INNER JOIN
                                [$(Databricks)].[wholesale_demandplanning_afi].[salesforecast] SalesForecast          
                                    ON DimItemMaster.ItemSKU = SalesForecast.frtItnbr
                        WHERE
                                (
                                    DimItemMaster.[DiscontinuedFlag] = 0
                                    OR ((DATEADD(DAY, -365, @DateValue)) < DimItemMaster.[DiscontinuedDate])
                                );

            /*get Sales Sum data*/

            SELECT
                    InvoiceDetail.ItemSKU    AS ItemSKU,
                    QuantityShippedipped    = SUM(   CASE
                                               WHEN InvoiceDetail.CreditCode NOT IN (
                                                                          'R', 'A', 'S'
                                                                      )
                                                   THEN
                                                   InvoiceDetail.QuantityShipped
                                               ELSE
                                                   0
                                           END
                                       ),
                    AmtShipped    = SUM(   CASE
                                               WHEN InvoiceDetail.CreditCode NOT IN (
                                                                          'R', 'A', 'S'
                                                                      )
                                                   THEN
                                                   InvoiceDetail.QuantityShipped * (Price + Discount - Freight - PriceAdjustment)
                                               ELSE
                                                   0
                                           END
                                       ),
                    QtyOrdered    = CAST(000000.00 AS DECIMAL(8, 2)),
                    AmtOrdered    = CAST(000000000.00 AS DECIMAL(12, 2)),
                    QtyReturned   = SUM(   CASE
                                               WHEN InvoiceDetail.CreditCode = 'R'
                                                   THEN
                                                   InvoiceDetail.QuantityShipped
                                               ELSE
                                                   0
                                           END
                                       ),
                    AmtReturned   = SUM(   CASE
                                               WHEN InvoiceDetail.CreditCode = 'R'
                                                   THEN
                                                   InvoiceDetail.QuantityShipped * (Price + Discount - Freight - PriceAdjustment)
                                               ELSE
                                                   0
                                           END
                                       ),
                    QtyAllowed    = SUM(   CASE
                                               WHEN InvoiceDetail.CreditCode = 'S'
                                                   THEN
                                                   InvoiceDetail.QuantityShipped
                                               ELSE
                                                   0
                                           END
                                       ),
                    AmtAllowed    = SUM(   CASE
                                               WHEN InvoiceDetail.CreditCode = 'S'
                                                   THEN
                                                   InvoiceDetail.QuantityShipped * (Price + Discount - Freight - PriceAdjustment)
                                               ELSE
                                                   0
                                           END
                                       ),
                    AmtDiscounted = SUM(   CASE
                                               WHEN InvoiceDetail.CreditCode NOT IN (
                                                                          'R', 'A', 'S'
                                                                      )
                                                   THEN
                                                   InvoiceDetail.QuantityShipped * Discount
                                               ELSE
                                                   0
                                           END
                                       ),
                    NetAmt        = SUM(InvoiceDetail.QuantityShipped * (Price - Freight - PriceAdjustment))
            INTO
                    #tempSalesSum
            FROM
                    [$(Wholesale_Warehouse)].SalesHistory_AFI.InvoiceDetail
                JOIN
                    AFISales_DW.DimItemMaster
                        ON InvoiceDetail.ItemSKU = DimItemMaster.ItemSKU
                JOIN
                    AFISales_DW.DimDateFile
                        ON DimDateFile.[Transaction Date] = InvoiceDetail.InvoiceDate
            WHERE
                    (
                        DimDateFile.[Fiscal Month] = @CurPeriod
                        AND DimDateFile.[Fiscal Year] = @CurYear
                    )
            GROUP BY
                    InvoiceDetail.ItemSKU;


            /*get Order Sum data */

            SELECT
                    OrderHistory.ItemSKU   AS ItemSKU,
                    QtyOrdered_O = SUM(Quantity),
                    AmtOrdered_O = SUM(NetAmount - (Quantity * Freight) - (Quantity * HiddenFreight)
                                       + (Quantity * Discount)
                                      )
            INTO
                    #tempSalesSum_O
            FROM
                    [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                JOIN
                    AFISales_DW.DimItemMaster
                        ON OrderHistory.ItemSKU = DimItemMaster.ItemSKU
                JOIN
                    AFISales_DW.DimDateFile
                        ON DimDateFile.[Transaction Date] = OrderHistory.OrderChangeDate
            WHERE
                    (
                        DimDateFile.[Fiscal Month] = @CurPeriod
                        AND DimDateFile.[Fiscal Year] = @CurYear
                    )
            GROUP BY
                    OrderHistory.ItemSKU;

            UPDATE
                #tempSalesSum
            SET
                QtyOrdered = QtyOrdered_O,
                AmtOrdered = AmtOrdered_O
            FROM
                #tempSalesSum_O tsc
            WHERE
                #tempSalesSum.ItemSKU = tsc.ItemSKU;

            INSERT INTO #tempSalesSum
                        SELECT
                                tsc.ItemSKU,
                                QuantityShippedipped    = 0,
                                AmtShipped    = 0,
                                QtyOrdered    = QtyOrdered_O,
                                AmtOrdered    = AmtOrdered_O,
                                QtyReturned   = 0,
                                AmtReturned   = 0,
                                QtyAllowed    = 0,
                                AmtAllowed    = 0,
                                AmtDiscounted = 0,
                                NetAmt        = 0
                        FROM
                                #tempSalesSum_O tsc
                            LEFT JOIN
                                #tempSalesSum   ts
                                    ON ts.ItemSKU = tsc.ItemSKU
                        WHERE
                                ts.ItemSKU IS NULL;



            /*get Sales Sum data for C uph/leather items*/

            SELECT
                    InvoiceDetail.ItemSKU      AS ItemSKU,
                    QuantityShippedipped_C    = SUM(   CASE
                                                 WHEN CreditCode NOT IN (
                                                                            'R', 'A', 'S'
                                                                        )
                                                     THEN
                                                     QuantityShipped
                                                 ELSE
                                                     0
                                             END
                                         ),
                    AmtShipped_C    = SUM(   CASE
                                                 WHEN CreditCode NOT IN (
                                                                            'R', 'A', 'S'
                                                                        )
                                                     THEN
                                                     QuantityShipped * (Price + Discount - Freight - PriceAdjustment)
                                                 ELSE
                                                     0
                                             END
                                         ),
                    QtyReturned_C   = SUM(   CASE
                                                 WHEN CreditCode = 'R'
                                                     THEN
                                                     QuantityShipped
                                                 ELSE
                                                     0
                                             END
                                         ),
                    AmtReturned_C   = SUM(   CASE
                                                 WHEN CreditCode = 'R'
                                                     THEN
                                                     QuantityShipped * (Price + Discount - Freight - PriceAdjustment)
                                                 ELSE
                                                     0
                                             END
                                         ),
                    QtyAllowed_C    = SUM(   CASE
                                                 WHEN CreditCode = 'S'
                                                     THEN
                                                     QuantityShipped
                                                 ELSE
                                                     0
                                             END
                                         ),
                    AmtAllowed_C    = SUM(   CASE
                                                 WHEN CreditCode = 'S'
                                                     THEN
                                                     QuantityShipped * (Price + Discount - Freight - PriceAdjustment)
                                                 ELSE
                                                     0
                                             END
                                         ),
                    AmtDiscounted_C = SUM(   CASE
                                                 WHEN CreditCode NOT IN (
                                                                            'R', 'A', 'S'
                                                                        )
                                                     THEN
                                                     Discount
                                                 ELSE
                                                     0
                                             END
                                         ),
                    NetAmt_C        = SUM(QuantityShipped * (Price - Freight - PriceAdjustment))
            INTO
                    #tempSalesSum_C
            FROM
                    [$(Wholesale_Warehouse)].SalesHistory_AFI.InvoiceDetail
                JOIN
                    AFISales_DW.DimItemMaster
                        ON DimItemMaster.ItemSKU = InvoiceDetail.ItemSKU + 'C'
                JOIN
                    AFISales_DW.DimDateFile
                        ON DimDateFile.[Transaction Date] = InvoiceDetail.InvoiceDate
            WHERE
                    (
                        DimDateFile.[Fiscal Month] = @CurPeriod
                        AND DimDateFile.[Fiscal Year] = @CurYear
                    )
            GROUP BY
                    InvoiceDetail.ItemSKU;


            /*get Order Sum data for C uph/leather items*/



            SELECT
                    OrderHistory.ItemSKU   AS ItemSKU,
                    QtyOrdered_C = SUM(Quantity),
                    AmtOrdered_C = SUM(NetAmount - (Quantity * Freight) - (Quantity * HiddenFreight)
                                       + (Quantity * Discount)
                                      )
            INTO
                    #tempSalesSum_CO
            FROM
                    [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                JOIN
                    AFISales_DW.DimItemMaster
                        ON OrderHistory.ItemSKU = RTRIM(DimItemMaster.ItemSKU) + 'C'
                JOIN
                   AFISales_DW.DimDateFile
                        ON DimDateFile.[Transaction Date] = OrderHistory.OrderChangeDate
            WHERE
                    (
                        DimDateFile.[Fiscal Month] = @CurPeriod
                        AND DimDateFile.[Fiscal Year] = @CurYear
                    )
            GROUP BY
                    OrderHistory.ItemSKU;

            /* UPDATE SalesSum table */
            UPDATE
                #tempSalesSum
            SET
                QuantityShippedipped = QuantityShippedipped + QuantityShippedipped_C,
                AmtShipped = AmtShipped + AmtShipped_C,
                QtyReturned = QtyReturned + QtyReturned_C,
                AmtReturned = AmtReturned + AmtReturned_C,
                QtyAllowed = QtyAllowed + QtyAllowed_C,
                AmtAllowed = AmtAllowed + AmtAllowed_C,
                AmtDiscounted = AmtDiscounted + AmtDiscounted_C,
                NetAmt = NetAmt + NetAmt_C
            FROM
                #tempSalesSum_C tsc
            WHERE
                (RTRIM(#tempSalesSum.ItemSKU) + 'C') = RTRIM(tsc.ItemSKU);

            UPDATE
                #tempSalesSum
            SET
                QtyOrdered = QtyOrdered + QtyOrdered_C,
                AmtOrdered = AmtOrdered + AmtOrdered_C
            FROM
                #tempSalesSum_CO tsc
            WHERE
                (RTRIM(#tempSalesSum.ItemSKU) + 'C') = RTRIM(tsc.ItemSKU);



            --get Returned,Allowed,Discounted,Margins AS percent
            UPDATE
                #temp_MoItemDetail
            SET
                QuantityShippedipped = ISNULL(ts.QuantityShippedipped, 0),
                QtyOrdered = ISNULL(ts.QtyOrdered, 0),
                AmtShipped = ISNULL(ts.NetAmt, 0),
                AmtOrdered = ISNULL(ts.AmtOrdered, 0),
                Returned = (CASE
                                   WHEN ts.QuantityShippedipped <> 0
                                        AND (((- (ts.QtyReturned)) / ts.QuantityShippedipped) * 100)
                                        BETWEEN 0 AND 999.9
                                       THEN
                ((- (ts.QtyReturned)) / ts.QuantityShippedipped) * 100
                                   ELSE
                                       0
                               END
                              ),
                Allowed = (CASE
                                  WHEN ts.AmtShipped <> 0
                                       AND (((- (ts.AmtAllowed)) / ts.AmtShipped) * 100)
                                       BETWEEN 0 AND 999.9
                                      THEN
                ((- (ts.AmtAllowed)) / ts.AmtShipped) * 100
                                  ELSE
                                      0
                              END
                             ),
                Discount = (CASE
                                   WHEN ts.AmtShipped <> 0
                                        AND (((ts.AmtDiscounted) / ts.AmtShipped) * 100)
                                        BETWEEN 0 AND 999.9
                                       THEN
                ((ts.AmtDiscounted) / ts.AmtShipped) * 100
                                   ELSE
                                       0
                               END
                              ),
                FOBMargin = (CASE
                                    WHEN FOBPrice <> 0
                                         AND (((FOBPrice - StdCost) / FOBPrice) * 100)
                                         BETWEEN -999 AND 999
                                        THEN
                ((FOBPrice - StdCost) / FOBPrice) * 100
                                    ELSE
                                        0
                                END
                               ),
                ActMargin = (CASE
                                    WHEN AvgPrice <> 0
                                         AND (((AvgPrice - ActCost) / AvgPrice) * 100)
                                         BETWEEN -999 AND 999
                                        THEN
                ((AvgPrice - ActCost) / AvgPrice) * 100
                                    ELSE
                                        0
                                END
                               )
            FROM
                #tempSalesSum ts
            WHERE
                RTRIM(#temp_MoItemDetail.ItemSKU) = RTRIM(ts.ItemSKU);


            DROP TABLE #tempSalesSum;
            DROP TABLE #tempSalesSum_C;
            DROP TABLE #tempSalesSum_O;
            DROP TABLE #tempSalesSum_CO;

            --determine which items were sold to Rental accounts  (Retn-a-Center AND Rentway only)
            UPDATE
                #temp_MoItemDetail
            SET
                Rental = 0;

            UPDATE
                #temp_MoItemDetail
            SET
                Rental = 1,
                RentalAcct = 'RAC'
            WHERE
                ItemSKU IN
                    (
                        SELECT  DISTINCT
                                ItemSKU
                        FROM
                                [$(Wholesale_Warehouse)].SalesHistory_AFI.InvoiceDetail
                            JOIN
                                AFISales_DW.DimDateFile
                                    ON DimDateFile.[Transaction Date] = InvoiceDetail.InvoiceDate
                        WHERE
                                [CustomerNumber] = '1256500'
                                AND DimDateFile.[Fiscal Year] = @CurYear
                                AND DimDateFile.[Fiscal Month] = @CurPeriod
                    );

            UPDATE
                #temp_MoItemDetail
            SET
                Rental = 1,
                RentalAcct = CASE
                                    WHEN (RentalAcct = 'RAC')
                                        THEN
                                        'RAR'
                                    ELSE
                                        'RWY'
                                END
            WHERE
                ItemSKU IN
                    (
                        SELECT  DISTINCT
                                ItemSKU
                        FROM
                                [$(Wholesale_Warehouse)].SalesHistory_AFI.InvoiceDetail
                            JOIN
                                AFISales_DW.DimDateFile
                                    ON DimDateFile.[Transaction Date] = InvoiceDate
                        WHERE
                                [CustomerNumber] = '927800'
                                AND DimDateFile.[Fiscal Year] = @CurYear
                                AND DimDateFile.[Fiscal Month] = @CurPeriod
                    );



            UPDATE
                #temp_MoItemDetail
            SET
                CountryCode = wrcCountryCode
            FROM
                [$(Wholesale_Warehouse)].Marketing.WarRoomCountryCodes tmb
            WHERE
                RTRIM(#temp_MoItemDetail.ItemSKU) = RTRIM(tmb.wrcItemSKU);

            --calculate 3,6 AND 12 month average Qty sales
            --get sales for last 12 months for each item


            SELECT
                    InvoiceDetail.ItemSKU          AS tmsItemSKU,
                    QuantityShippedipped          = SUM(InvoiceDetail.QuantityShipped),
                    DimDateFile.[Fiscal Year]  AS [Year],
                    DimDateFile.[Fiscal Month] AS [Period]
            INTO
                    #temp_YearPeriodSales
            FROM
                    [$(Wholesale_Warehouse)].SalesHistory_AFI.InvoiceDetail
                JOIN
                    AFISales_DW.DimItemMaster
                        ON DimItemMaster.ItemSKU = InvoiceDetail.ItemSKU
                JOIN
                     AFISales_DW.DimDateFile
                        ON DimDateFile.[Transaction Date] = InvoiceDetail.InvoiceDate
            WHERE
                    InvoiceDetail.QuantityShipped <> .000
                    AND InvoiceDetail.CreditCode NOT IN (
                                              'R', 'A', 'S'
                                          )
                    AND
                        (
                            (
                                DimDateFile.[Fiscal Year] = @12moYear
                                AND DimDateFile.[Fiscal Month] >= @12moPeriod
                            )
                            OR
                                (
                                    @CurYear <> @12moYear
                                    AND DimDateFile.[Fiscal Year] = @CurYear
                                )
                        )
            GROUP BY
                    InvoiceDetail.ItemSKU,
                    DimDateFile.[Fiscal Year],
                    DimDateFile.[Fiscal Month];


            SELECT
                tmsItemSKU,
                AVG(QuantityShippedipped) AS AVG_QuantityShippedipped_12
            INTO
                #temp_AvgYearPeriodSales_12
            FROM
                #temp_YearPeriodSales
            WHERE
                tmsItemSKU = tmsItemSKU
            GROUP BY
                tmsItemSKU;


            SELECT
                tmsItemSKU,
                AVG(QuantityShippedipped) AS AVG_QuantityShippedipped_6
            INTO
                #temp_AvgYearPeriodSales_6
            FROM
                #temp_YearPeriodSales
            WHERE
                tmsItemSKU = tmsItemSKU
                AND
                    (
                        (
                            [Year] = @6moYear
                            AND [Period] >= @6moPeriod
                        )
                        OR
                            (
                                @CurYear <> @6moYear
                                AND [Year] = @CurYear
                            )
                    )
            GROUP BY
                tmsItemSKU;


            SELECT
                tmsItemSKU,
                AVG(QuantityShippedipped) AS AVG_QuantityShippedipped_3
            INTO
                #temp_AvgYearPeriodSales_3
            FROM
                #temp_YearPeriodSales
            WHERE
                tmsItemSKU = tmsItemSKU
                AND
                    (
                        (
                            [Year] = @3moYear
                            AND [Period] >= @3moPeriod
                        )
                        OR
                            (
                                @CurYear <> @3moYear
                                AND [Year] = @CurYear
                            )
                    )
            GROUP BY
                tmsItemSKU;



            --UPDATE working table with average sales fro 3, 6 AND 12 months
            UPDATE
                #temp_MoItemDetail
            SET
                MoQty12 = AVG_QuantityShippedipped_12
            FROM
                #temp_AvgYearPeriodSales_12
            WHERE
                ItemSKU = tmsItemSKU;

            UPDATE
                #temp_MoItemDetail
            SET
                MoQty6 = AVG_QuantityShippedipped_6
            FROM
                #temp_AvgYearPeriodSales_6
            WHERE
                ItemSKU = tmsItemSKU;

            UPDATE
                #temp_MoItemDetail
            SET
                MoQty3 = AVG_QuantityShippedipped_3
            FROM
                #temp_AvgYearPeriodSales_3
            WHERE
                ItemSKU = tmsItemSKU;



            DROP TABLE #temp_YearPeriodSales;
            DROP TABLE #temp_AvgYearPeriodSales_12;
            DROP TABLE #temp_AvgYearPeriodSales_6;
            DROP TABLE #temp_AvgYearPeriodSales_3;


          DROP TABLE IF EXISTS AFISales_Enh.MonthItemDetail_LOAD;

            --Clear previous table AND insert new records

            CREATE TABLE [AFISales_Enh].[MonthItemDetail_LOAD] (
                [ItemSKU]         VARCHAR (15)    NOT NULL,
                [QuantityShippedipped]      NUMERIC (10)    NOT NULL,
                [QtyOrdered]      NUMERIC (10)    NOT NULL,
                [AmtShipped]      NUMERIC (10)    NOT NULL,
                [AmtOrdered]      NUMERIC (10)    NOT NULL,
                [FOBPrice]        NUMERIC (5)     NOT NULL,
                [AvgPrice]        NUMERIC (5)     NOT NULL,
                [Returned]        NUMERIC (4, 1)  NOT NULL,
                [Allowed]         NUMERIC (4, 1)  NOT NULL,
                [Discount]        NUMERIC (4, 1)  NOT NULL,
                [StdCost]         NUMERIC (8, 2)  NOT NULL,
                [ActCost]         NUMERIC (8, 2)  NOT NULL,
                [FOBMargin]       NUMERIC (3)     NOT NULL,
                [ActMargin]       NUMERIC (3)     NOT NULL,
                [Rental]          BIT             NOT NULL,
                [TotalAmtShipped] NUMERIC (10)    NOT NULL,
                [TotalAmtOrdered] NUMERIC (10)    NOT NULL,
                [Period]          NUMERIC (2)     NOT NULL,
                [Year]            NUMERIC (4)     NOT NULL,
                [Landed]          NUMERIC (10, 2) NOT NULL,
                [MoQty3]          NUMERIC (10)    NOT NULL,
                [MoQty6]          NUMERIC (10)    NOT NULL,
                [MoQty12]         NUMERIC (10)    NOT NULL,
                [FutStatus]       CHAR (1)        NOT NULL,
                [CountryCode]     CHAR (3)        NOT NULL,
                [RentalAcct]      CHAR (3)        NOT NULL
            )


            INSERT INTO AFISales_Enh.MonthItemDetail_LOAD
                (
                    ItemSKU,
                    QuantityShippedipped,
                    QtyOrdered,
                    AmtShipped,
                    AmtOrdered,
                    FOBPrice,
                    AvgPrice,
                    Returned,
                    Allowed,
                    Discount,
                    StdCost,
                    ActCost,
                    FOBMargin,
                    ActMargin,
                    Rental,
                    TotalAmtShipped,
                    TotalAmtOrdered,
                    Period,
                    Year,
                    Landed,
                    MoQty3,
                    MoQty6,
                    MoQty12,
                    FutStatus,
                    CountryCode,
                    RentalAcct
                )
                        SELECT DISTINCT
                               ItemSKU,
                               QuantityShippedipped,
                               QtyOrdered,
                               AmtShipped,
                               AmtOrdered,
                               FOBPrice,
                               AvgPrice,
                               Returned,
                               Allowed,
                               Discount,
                               StdCost,
                               ActCost,
                               FOBMargin,
                               ActMargin,
                               Rental,
                               TotalAmtShipped,
                               TotalAmtOrdered,
                               Period,
                               Year,
                               Landed,
                               MoQty3,
                               MoQty6,
                               MoQty12,
                               FutStatus,
                               CountryCode,
                               RentalAcct
                        FROM
                               #temp_MoItemDetail;



            CREATE STATISTICS [Stat_MonthItemDetail_Year]
                ON [AFISales_Enh].[MonthItemDetail_LOAD]([Year]);

            CREATE STATISTICS [Stat_MonthItemDetail_Period]
                ON [AFISales_Enh].[MonthItemDetail_LOAD]([Period]);

            CREATE STATISTICS [Stat_MonthItemDetail_Landed]
                ON [AFISales_Enh].[MonthItemDetail_LOAD]([Landed]);

            CREATE STATISTICS [Stat_MonthItemDetail_ItemSKU]
                ON [AFISales_Enh].[MonthItemDetail_LOAD]([ItemSKU]);

            CREATE STATISTICS [Stat_MonthItemDetail_FutStatus]
                ON [AFISales_Enh].[MonthItemDetail_LOAD]([FutStatus]);

            CREATE STATISTICS [Stat_MonthItemDetail_CountryCode]
                ON [AFISales_Enh].[MonthItemDetail_LOAD]([CountryCode]);


            DROP TABLE IF EXISTS AFISales_Enh.MonthItemDetail;
             
       
            EXECUTE sp_rename 'AFISales_Enh.MonthItemDetail_LOAD','MonthItemDetail'

            DROP TABLE #temp_MoItemDetail;

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
            'AFISales_DW', 'AFISales_Enh', 'MonthItemDetail', @String, @DateValue;
            
    END;
