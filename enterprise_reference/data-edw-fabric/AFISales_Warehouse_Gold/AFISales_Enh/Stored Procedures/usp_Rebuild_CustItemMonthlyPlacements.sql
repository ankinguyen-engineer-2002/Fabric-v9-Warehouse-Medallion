CREATE PROC [AFISales_Enh].[usp_Rebuild_CustItemMonthlyPlacements]
AS

    /* Change Control -----------------------------------------------------------------------------------------------------------
* Procedure: AFISales_Enh.usp_rebuildOrderPlacements  Called from usp_BuildOrderPlacements
* Business Function : Get order Placement Data - re-engineered logic
* Author: Matt Carter          Date: 01/05/05
* Optimized by Bob Horton, July 2006
* bh added salescategory/region logic 10/2007
* Ed Obaseki remove item with ZZ category
* BH converted to PDW Jan, 2017, converted to ADW JAN 2018
* Gabe De Mayo (2/26/18): Modified to use usp_CreateReplicateWorkTable/updated object existence check/updated error handling
* BH moved start date back to 7 years
* Amy Morina 04/26/2018 changed all references to GETDATE() to DW_Developer.fn_GetCSTDate(GETDATE())
* Bob Horton 05/08/2019 swapped out references to MainPiece with dimItemMaster
* 02/26/2020 Changed insert to "Values" syntax to avoid exclusive locks
* Ragavan V (02/18/2021) -Changed Afisales_Enh to Wholesale_[$(Wholesale_Warehouse)].SalesHistory_AFI 
* Bob Horton 10/18/2023 converted to Fabric
---------------------------------------------------------------------------------------------------------------------------*/

    BEGIN

        DECLARE
            @String    VARCHAR(5000),
            @DateValue DATETIME2(6),
            @User      VARCHAR(500);

        SET @String = 'AFISales_DW.AFISales_Enh.usp_Rebuild_CustItemMonthlyPlacements';
        SET @User = SYSTEM_USER;
        SET @DateValue = GETDATE();
        SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)


        INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
        VALUES
            (
                @String, @DateValue, @User, 'Process Start'
            );

        BEGIN TRY

            /* declare working variables */
            DECLARE
                @currentYear   SMALLINT,
                @CurrentMonth  SMALLINT,
                @PreviousYear  SMALLINT,
                @PreviousMonth SMALLINT,
                @MidMonthDate  DATE;
            DECLARE
                @StartDate         DATE,
                @StartYear         SMALLINT,
                @StartMonth        SMALLINT
  
            /*** Establish dates ***/

            SET @currentYear =
                (
                    SELECT
                        [Fiscal Year]
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] = CAST(@DateValue AS DATE)
                );
            SET @CurrentMonth =
                (
                    SELECT
                        [Fiscal Month]
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] =  CAST(@DateValue AS DATE)
                );

            SET @MidMonthDate = CAST(@CurrentMonth AS VARCHAR(2)) + '/15/' + CAST(@currentYear AS CHAR(4));

            SET @PreviousYear =
                (
                    SELECT
                        [Fiscal Year]
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] = DATEADD(DAY,-30,CAST(@DateValue AS DATE))
                );
            SET @PreviousMonth =
                (
                    SELECT
                        [Fiscal Month]
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] = DATEADD(DAY, -30, CAST(@DateValue AS DATE))
                );

            SET @StartYear =
                (
                    SELECT
                        [Fiscal Year]
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] = DATEADD(DAY,-2560, CAST(@DateValue AS DATE))
                );
            SET @StartMonth =
                (
                    SELECT
                        [Fiscal Month]
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] = DATEADD(DAY,-2560, CAST(@DateValue AS DATE))
                );



            SET @StartDate =
                (
                    SELECT
                        MIN([Transaction Date])
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Fiscal Year] = @StartYear
                        AND [Fiscal Month] = @StartMonth
                );

 
             DROP TABLE IF EXISTS Tempdb..#PlacementMonthDate;


            SELECT
                MIN([Transaction Date]) AS [Transaction Date],
                [Fiscal Year],
                [Fiscal Month]
            INTO
                #PlacementMonthDate
            FROM
                AFISales_DW.DimDateFile
            GROUP BY
                [Fiscal Year],
                [Fiscal Month];


            DROP TABLE IF EXISTS AFISales_Wrk.ItemStatus_MOP;


            CREATE TABLE AFISales_Wrk.ItemStatus_MOP
                (
                    Year             SMALLINT,
                    Month            INT,
                    MonthDate        DATE,
                    ItemSKU          VARCHAR(15),
                    ItemStatus       CHAR(1),
                    CanLosePlacement INT
                );


            /*** Get Item and item status history ***/

            --- imastatus is the current item status
            --- imapmfpus is the previous item status
            --- imaItscdt is the date the previous status changed to the current status
            --- Status typically go move from 'T' -> 'N' --> 'I' --> '' --> 'D' -> 'R'   (if there is an overlap in status histories, default to the earliest in the lifecycle)

            INSERT INTO AFISales_Wrk.ItemStatus_MOP
                (
                    Year,
                    Month,
                    MonthDate,
                    ItemSKU,
                    ItemStatus,
                    CanLosePlacement
                )
                        SELECT
                                Year,
                                Month,
                                MonthDate,
                                ItemSKU          = DimItemMaster.ItemSKU,
                                ItemStatus       = CASE
                                                       WHEN ISNULL(T1.ItemStatus, '') = 'T'
                                                            OR AFIItemStatus = 'T'
                                                           THEN
                                                           'T'
                                                       WHEN ISNULL(T2.ItemStatus, '') = 'N'
                                                            OR AFIItemStatus = 'N'
                                                           THEN
                                                           'N'
                                                       WHEN ISNULL(T3.ItemStatus, '') = 'I'
                                                           THEN
                                                           'I'
                                                       WHEN ISNULL(T4.ItemStatus, '') = ' '
                                                           THEN
                                                           ' '
                                                       WHEN ISNULL(T5.ItemStatus, '') = 'D'
                                                           THEN
                                                           'D'
                                                       WHEN ISNULL(T6.ItemStatus, '') = 'R'
                                                           THEN
                                                           'R'
                                                       ELSE
                                                           ''
                                                   END,
                                -- New ("N" Status); Tentative ("T" Status); or Introduced ("I" status) until after 86 days, will not lose a Placement
                                canLosePlacement = CASE
                                                       WHEN ISNULL(T1.ItemStatus, '') = 'T'
                                                            OR AFIItemStatus = 'T'
                                                           THEN
                                                           0
                                                       WHEN ISNULL(T2.ItemStatus, '') = 'N'
                                                            OR AFIItemStatus = 'N'
                                                           THEN
                                                           0
                                                       WHEN ISNULL(T3.ItemStatus, '') = 'I'
                                                            AND DATEDIFF(d, ISNULL(T7.StatusDate, MonthDate), MonthDate) < 85
                                                           THEN
                                                           0
                                                       ELSE
                                                           1
                                                   END
                        FROM
                                [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
                            CROSS JOIN
                                (
                                    SELECT
                                            MonthDate = MIN([Transaction Date]),
                                            Year      = [Fiscal Year],
                                            Month     = [Fiscal Month]
                                    FROM
                                            AFISales_DW.DimDateFile
                                    WHERE
                                            [Transaction Date]
                                    BETWEEN @StartDate AND DATEADD(DAY,1,@DateValue)
                                    GROUP BY
                                            [Fiscal Year],
                                            [Fiscal Month]
                                ) d
                            LEFT JOIN
                                (
                                    SELECT
                                        'T'                   AS ItemStatus,
                                        MAX(OrderHistory.OrderDate) AS StatusDate,
                                        OrderHistory.ItemSKU
                                    FROM
                                        [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                    WHERE
                                        OrderHistory.[OrderDate]
                                        BETWEEN @StartDate AND @DateValue
                                        AND OrderHistory.ItemStatus = ('T')
                                    GROUP BY
                                        OrderHistory.ItemSKU
                                ) T1
                                    ON DimItemMaster.ItemSKU = T1.ItemSKU
                                       AND MonthDate <= T1.StatusDate
                            LEFT JOIN
                                (
                                    SELECT
                                        'N'                   AS ItemStatus,
                                        MAX(OrderHistory.OrderDate) AS StatusDate,
                                        OrderHistory.ItemSKU
                                    FROM
                                        [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                    WHERE
                                        OrderHistory.OrderDate
                                        BETWEEN @StartDate AND @DateValue
                                        AND OrderHistory.ItemStatus = ('N')
                                    GROUP BY
                                        OrderHistory.ItemSKU
                                ) T2
                                    ON DimItemMaster.ItemSKU = T2.ItemSKU
                                       AND MonthDate <= T2.StatusDate
                            LEFT JOIN
                                (
                                    SELECT
                                        'I'                   AS ItemStatus,
                                        MAX(OrderHistory.OrderDate) AS StatusDate,
                                        OrderHistory.ItemSKU
                                    FROM
                                        [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                    WHERE
                                        OrderHistory.OrderDate
                                        BETWEEN @StartDate AND @DateValue
                                        AND OrderHistory.ItemStatus = ('I')
                                    GROUP BY
                                        OrderHistory.ItemSKU
                                ) T3
                                    ON DimItemMaster.ItemSKU = T3.ItemSKU
                                       AND MonthDate <= T3.StatusDate
                            LEFT JOIN
                                (
                                    SELECT
                                        ' '                   AS ItemStatus,
                                        MAX(OrderHistory.OrderDate) AS StatusDate,
                                        OrderHistory.ItemSKU
                                    FROM
                                        [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                    WHERE
                                        OrderHistory.OrderDate
                                        BETWEEN @StartDate AND @DateValue
                                        AND OrderHistory.ItemStatus = (' ')
                                    GROUP BY
                                        OrderHistory.ItemSKU
                                ) T4
                                    ON DimItemMaster.ItemSKU = T4.ItemSKU
                                       AND MonthDate <= T4.StatusDate
                            LEFT JOIN
                                (
                                    SELECT
                                        'D'                   AS ItemStatus,
                                        MAX(OrderHistory.OrderDate) AS StatusDate,
                                        OrderHistory.ItemSKU
                                    FROM
                                        [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                    WHERE
                                        [OrderDate]
                                        BETWEEN @StartDate AND @DateValue
                                        AND OrderHistory.ItemStatus = ('D')
                                    GROUP BY
                                        OrderHistory.ItemSKU
                                ) T5
                                    ON DimItemMaster.ItemSKU = T5.ItemSKU
                                       AND MonthDate <= T5.StatusDate
                            LEFT JOIN
                                (
                                    SELECT
                                        'R'                   AS ItemStatus,
                                        MAX([OrderDate]) AS StatusDate,
                                        OrderHistory.ItemSKU
                                    FROM
                                        [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                    WHERE
                                        OrderHistory.[OrderDate]
                                        BETWEEN @StartDate AND @DateValue
                                        AND OrderHistory.ItemStatus = ('R')
                                    GROUP BY
                                        OrderHistory.ItemSKU
                                ) T6
                                    ON DimItemMaster.ItemSKU = T6.ItemSKU
                                       AND MonthDate <= T6.StatusDate
                            LEFT JOIN
                                (
                                    SELECT
                                        'N'                   AS ItemStatus,
                                        MAX(OrderHistory.OrderDate) AS StatusDate,
                                        OrderHistory.ItemSKU
                                    FROM
                                        [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                    WHERE
                                        OrderHistory.OrderDate
                                        BETWEEN @StartDate AND @DateValue
                                        AND ItemStatus = ('N')
                                    GROUP BY
                                        OrderHistory.ItemSKU
                                ) T7
                                    ON DimItemMaster.ItemSKU = T7.[ItemSKU]
                        WHERE
                                DimItemMaster.AFISalesCategoryCode <> 'ZZ'
                                AND DimItemMaster.KeyItem = 1;


            /*** Get Orders - by Bill-to's, by Shipto if there are execptions (need up to 39 Months of hisotry for a proper calculation) ***/

            CREATE TABLE #Monthly_History
                (
                    [Year]     SMALLINT,
                    [Month]    INT,
                    MonthDate  DATE,
                    CustomerNumber CHAR(8),
                    ShiptoNumber    CHAR(4),
                    ItemSKU    VARCHAR(15),
                    OrderQty   BIGINT,
                    OrderAmt   DECIMAL,
                    Placement  BIGINT,
                    Lost       BIGINT
                );


            PRINT 'insert tb_history';
            -- Summarize orders By Account where not billto Exceptions, net out same Month cancellations
            INSERT INTO #Monthly_History
                (
                    [Year],
                    [Month],
                    MonthDate,
                    CustomerNumber,
                    ShiptoNumber,
                    ItemSKU,
                    OrderQty,
                    OrderAmt,
                    Placement,
                    Lost
                )
                        SELECT
                                MD.[Fiscal Year],
                                MD.[Fiscal Month],
                                MD.[Transaction Date],
                                OrderHistory.[CustomerNumber] AS CustomerNumber,
                                ''               AS ShiptoNumber,
                                OrderHistory.[ItemSKU]     AS ItemSKU,
                                SUM(OrderHistory.[Quantity])  AS OrderQty,
                                SUM(OrderHistory.[NetAmount]) AS OrderAmt,
                                1                AS Placement,
                                0                AS Lost
                        FROM
                                [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                            JOIN
                                AFISales_DW.DimItemMaster
                                    ON DimItemMaster.ItemSKU = OrderHistory.ItemSKU
                                       AND DimItemMaster.KeyItem = 1
                            JOIN
                                AFISales_DW.DimDateFile D1
                                    ON D1.[Transaction Date] = CONVERT(DATE, CONVERT(CHAR(8), OrderHistory.OrderDate))
                            JOIN
                                #PlacementMonthDate                               MD
                                    ON MD.[Fiscal Year] = D1.[Fiscal Year]
                                       AND MD.[Fiscal Month] = D1.[Fiscal Month]
                        WHERE
                                OrderHistory.[OrderDate] >= @StartDate
                                AND OrderHistory.[CustomerNumber] NOT IN
                                        (
                                            SELECT
                                                PresBillToExceptions.CustomerNumber
                                            FROM
                                                [$(Wholesale_Warehouse)].Marketing.PresBillToExceptions
                                        )
                        GROUP BY
                                MD.[Fiscal Year],
                                MD.[Fiscal Month],
                                MD.[Transaction Date],
                                OrderHistory.[CustomerNumber],
                                OrderHistory.[ItemSKU]
                        HAVING
                                SUM([Quantity]) <> 0;

            --  Get Orders - by Ship-to's where there are entries in the Billto Exceptions, net out same Month cancellations
            INSERT INTO #Monthly_History
                (
                    [Year],
                    [Month],
                    MonthDate,
                    CustomerNumber,
                    ShiptoNumber,
                    ItemSKU,
                    OrderQty,
                    OrderAmt,
                    Placement,
                    Lost
                )
                        SELECT
                                MD.[Fiscal Year],
                                MD.[Fiscal Month],
                                MD.[Transaction Date],
                                OrderHistory.[CustomerNumber] AS CustomerNumber,
                                OrderHistory.[ShiptoNumber]   AS ShiptoNumber,
                                OrderHistory.[ItemSKU]     AS ItemSKU,
                                SUM(OrderHistory.[Quantity])  AS OrderQty,
                                SUM(OrderHistory.[NetAmount]) AS OrderAmt,
                                1                AS Placement,
                                0                AS Lost
                        FROM
                                [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                            JOIN
                                AFISales_DW.DimItemMaster
                                    ON OrderHistory.ItemSKU = DimItemMaster.ItemSKU
                                       AND DimItemMaster.KeyItem = 1
                            JOIN
                                AFISales_DW.DimDateFile D1
                                    ON D1.[Transaction Date] = CONVERT(DATE, CONVERT(CHAR(8), OrderDate))
                            JOIN
                                #PlacementMonthDate                               MD
                                    ON MD.[Fiscal Year] = D1.[Fiscal Year]
                                       AND MD.[Fiscal Month] = D1.[Fiscal Month]
                        WHERE
                                OrderHistory.[OrderDate] >= @StartDate
                                AND OrderHistory.[CustomerNumber] IN
                                        (
                                            SELECT
                                                PresBillToExceptions.CustomerNumber
                                            FROM
                                                [$(Wholesale_Warehouse)].Marketing.PresBillToExceptions
                                        )
                        GROUP BY
                                MD.[Fiscal Year],
                                MD.[Fiscal Month],
                                MD.[Transaction Date],
                                OrderHistory.[CustomerNumber],
                                OrderHistory.[ShiptoNumber],
                                OrderHistory.[ItemSKU]
                        HAVING
                                SUM([Quantity]) <> 0;


            /*** add future buckets for current Placements where future buckets don't exist 2 Months out **/

            INSERT INTO #Monthly_History
                (
                    Year,
                    Month,
                    MonthDate,
                    CustomerNumber,
                    ShiptoNumber,
                    ItemSKU,
                    OrderQty,
                    OrderAmt,
                    Placement,
                    Lost
                )
                        SELECT  DISTINCT
                                t4.*,
                                0 AS OrderQty,
                                0 AS OrderAmt,
                                1 AS Placement,
                                0 AS Lost
                        FROM
                                (
                                    SELECT
                                            [Fiscal Year],
                                            [Fiscal Month],
                                            [Transaction Date] AS MonthDate,
                                            t1.CustomerNumber,
                                            t1.ShiptoNumber,
                                            t1.ItemSKU
                                    FROM
                                            #Monthly_History    t1
                                        JOIN
                                            #PlacementMonthDate dates
                                                ON [Transaction Date]
                                                   BETWEEN DATEADD(DAY, 7, MonthDate) AND DATEADD(DAY,85, MonthDate)
                                    WHERE
                                            OrderQty > 0
                                )                t4
                            LEFT JOIN
                                #Monthly_History t2
                                    ON t4.MonthDate = t2.MonthDate
                                       AND t4.CustomerNumber = t2.CustomerNumber
                                       AND t4.ShiptoNumber = t2.ShiptoNumber
                                       AND t4.ItemSKU = t2.ItemSKU
                        WHERE
                                t2.CustomerNumber IS NULL;


            /*** add future buckets for current Placements for any Months after where can't lose Placement **/

            INSERT INTO #Monthly_History
                (
                    Year,
                    Month,
                    MonthDate,
                    CustomerNumber,
                    ShiptoNumber,
                    ItemSKU,
                    OrderQty,
                    OrderAmt,
                    Placement,
                    Lost
                )
                        SELECT  DISTINCT
                                t4.*,
                                0 AS OrderQty,
                                0 AS OrderAmt,
                                1 AS Placement,
                                0 AS Lost
                        FROM
                                (
                                    SELECT
                                            T3.Year,
                                            T3.Month,
                                            T3.MonthDate,
                                            t1.CustomerNumber,
                                            t1.ShiptoNumber,
                                            t1.ItemSKU
                                    FROM
                                            #Monthly_History            t1
                                        JOIN
                                            AFISales_Wrk.ItemStatus_MOP T3
                                                ON t1.ItemSKU = T3.ItemSKU
                                                   AND T3.CanLosePlacement = 0
                                                   AND T3.MonthDate > t1.MonthDate
                                    WHERE
                                            OrderQty > 0
                                )                t4
                            LEFT JOIN
                                #Monthly_History t2
                                    ON t4.MonthDate = t2.MonthDate
                                       AND t4.CustomerNumber = t2.CustomerNumber
                                       AND t4.ShiptoNumber = t2.ShiptoNumber
                                       AND t4.ItemSKU = t2.ItemSKU
                        WHERE
                                t2.CustomerNumber IS NULL;


            /*** add future buckets for Lost Placement calulations where future buckets don't exist 3 Months out **/

            INSERT INTO #Monthly_History
                (
                    Year,
                    Month,
                    MonthDate,
                    CustomerNumber,
                    ShiptoNumber,
                    ItemSKU,
                    OrderQty,
                    OrderAmt,
                    Placement,
                    Lost
                )
                        SELECT  DISTINCT
                                t4.*,
                                0 AS OrderQty,
                                0 AS OrderAmt,
                                0 AS Placement,
                                1 AS Lost
                        FROM
                                (
                                    SELECT
                                            [Fiscal Year],
                                            [Fiscal Month],
                                            [Transaction Date] AS MonthDate,
                                            t1.CustomerNumber,
                                            t1.ShiptoNumber,
                                            t1.ItemSKU
                                    FROM
                                            #Monthly_History    t1
                                        JOIN
                                            #PlacementMonthDate dates
                                                ON [Fiscal Month] = CASE
                                                                  WHEN t1.Month = 12
                                                                      THEN
                                                                      1
                                                                  ELSE
                                                                      t1.Month + 1
                                                              END
                                                   AND [Fiscal Year] = CASE
                                                                     WHEN t1.Month = 12
                                                                         THEN
                                                                         t1.Year + 1
                                                                     ELSE
                                                                         t1.Year
                                                                 END
                                    WHERE
                                            Placement > 0
                                )                t4
                            LEFT JOIN
                                #Monthly_History FM
                                    ON FM.Month = [Fiscal Month]
                                       AND FM.Year = [Fiscal Year]
                                       AND t4.CustomerNumber = FM.CustomerNumber
                                       AND t4.ShiptoNumber = FM.ShiptoNumber
                                       AND t4.ItemSKU = FM.ItemSKU
                        WHERE
                                FM.CustomerNumber IS NULL;


            /*** Create Data Structures ***/

            DROP TABLE IF EXISTS AFISales_Enh.CustItemMonthlyPlacements_LOAD;

            CREATE TABLE AFISales_Enh.[CustItemMonthlyPlacements_LOAD]
                (
                    [CustomerNumber] VARCHAR (8)     NOT NULL,
                    [ShiptoNumber]   VARCHAR (4)     NOT NULL,
                    [ItemSKU]     VARCHAR (15)    NOT NULL,
                    [ItemStatus]     CHAR (1)        NULL,
                    [Division]       CHAR (1)        NOT NULL,
                    [YearMonth]      INT             NOT NULL,
                    [Quantity]       DECIMAL (10, 2) NULL,
                    [Amount]         DECIMAL (10, 2) NULL,
                    [Placement]      SMALLINT        NULL,
                    [Gained]         SMALLINT        NULL,
                    [lost]           SMALLINT        NULL,
                    [AtRisk]         SMALLINT        NULL,
                    [Current]        SMALLINT        NULL,
                    [Year]           INT             NULL,
                    [Month]          INT             NULL
                )

            INSERT INTO AFISales_Enh.CustItemMonthlyPlacements_LOAD
                (
                    CustomerNumber,
                    ShiptoNumber,
                    ItemSKU,
                    ItemStatus,
                    Division,
                    YearMonth,
                    Quantity,
                    Amount,
                    Placement,
                    Gained,
                    Lost,
                    AtRisk,
                    [Current],
                    Year,
                    Month
                )
                        SELECT
                                h.CustomerNumber,
                                h.ShiptoNumber,
                                h.ItemSKU,
                                i.ItemStatus,
                                m.AFISalesDivisionCode,
                                CONVERT(
                                           INT,
                                           CONVERT(CHAR(4), h.[Year])
                                           + REPLICATE('0', ABS(LEN(CONVERT(VARCHAR(2), h.Month)) - 2))
                                           + CONVERT(VARCHAR(2), h.Month)
                                       ),
                                h.OrderQty,
                                h.OrderAmt,
                                h.Placement,

                                --- If qytord > 0 and there is no active Placement for the previous Month, count it as a gained Placement
                                CASE
                                    WHEN h.OrderQty > 0
                                         AND ISNULL(PM.Placement, 0) = 0
                                        THEN
                                        1
                                    ELSE
                                        0
                                END    AS [gained],
                                h.Lost,

                                --- Count at risk if Active Placement in Last Month and Item Status = D or R
                                CASE
                                    WHEN h.Year = @PreviousYear
                                         AND h.Month >= @PreviousMonth
                                         AND i.ItemStatus IN (
                                                                 'D', 'R'
                                                             )
                                        THEN
                                        h.Placement * -1
                                    WHEN h.Year = @currentYear
                                         AND h.Month = @CurrentMonth
                                        THEN
                                        h.Lost * -1
                                END    AS AtRisk,

                                --- If Placement is active for last Month,  count as a current Placement    
                                CASE
                                    WHEN h.Year = @PreviousYear
                                         AND h.Month = @PreviousMonth
                                        THEN
                                        h.Placement
                                    ELSE
                                        0
                                END    AS [Current],
                                h.Year,
                                h.Month
                        FROM
                                #Monthly_History                                      h
                            JOIN
                                AFISales_Wrk.ItemStatus_MOP                           i
                                    ON h.ItemSKU = i.ItemSKU
                                       AND h.[Year] = i.[Year]
                                       AND h.Month = i.Month
                            JOIN
                                [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster m
                                    ON h.ItemSKU = m.ItemSKU
                            LEFT JOIN
                                #Monthly_History                                      PM
                                    ON PM.Month = CASE
                                                      WHEN h.Month = 1
                                                          THEN
                                                          12
                                                      ELSE
                                                          h.Month - 1
                                                  END
                                       AND PM.Year = CASE
                                                         WHEN h.Month = 1
                                                             THEN
                                                             h.Year - 1
                                                         ELSE
                                                             h.Year
                                                     END
                                       AND h.CustomerNumber = PM.CustomerNumber
                                       AND h.ShiptoNumber = PM.ShiptoNumber
                                       AND h.ItemSKU = PM.ItemSKU
                        WHERE
                                h.MonthDate
                        BETWEEN @DateValue - 2460 AND @DateValue;



            -- Filter on 2460 days...include 6.75 years (history holds 7 years but we can't include 1st 3 Months in final results 
            --- because they are just used to identify active Placements in the first period included in the final results)

     

            CREATE STATISTICS [Stat_CustItemMonthlyPlacements_CustomerNumber]
                ON AFISales_Enh.[CustItemMonthlyPlacements_LOAD]
                (
                    [CustomerNumber]
                );
            CREATE STATISTICS [Stat_CustItemMonthlyPlacements_ShiptoNumber]
                ON AFISales_Enh.[CustItemMonthlyPlacements_LOAD]
                (
                    [ShiptoNumber]
                );
            CREATE STATISTICS [Stat_CustItemMonthlyPlacements_ItemSKU]
                ON AFISales_Enh.[CustItemMonthlyPlacements_LOAD]
                (
                    [ItemSKU]
                );
            CREATE STATISTICS [Stat_CustItemMonthlyPlacements_ItemStatus]
                ON AFISales_Enh.[CustItemMonthlyPlacements_LOAD]
                (
                    [ItemStatus]
                );
            CREATE STATISTICS [Stat_CustItemMonthlyPlacements_Division]
                ON AFISales_Enh.[CustItemMonthlyPlacements_LOAD]
                (
                    [Division]
                );
            CREATE STATISTICS [Stat_CustItemMonthlyPlacements_YearMonth]
                ON AFISales_Enh.[CustItemMonthlyPlacements_LOAD]
                (
                    [YearMonth]
                );
            CREATE STATISTICS Stat_CustItemMonthlyPlacements_Year
                ON AFISales_Enh.[CustItemMonthlyPlacements_LOAD]
                (
                    [Year]
                );
            CREATE STATISTICS Stat_CustItemMonthlyPlacements_Current
                ON AFISales_Enh.[CustItemMonthlyPlacements_LOAD]
                (
                    [Current]
                );
            CREATE STATISTICS Stat_CustItemMonthlyPlacements_Quantity
                ON AFISales_Enh.[CustItemMonthlyPlacements_LOAD]
                (
                    [Quantity]
                );
            CREATE STATISTICS Stat_CustItemMonthlyPlacements_Placement
                ON AFISales_Enh.[CustItemMonthlyPlacements_LOAD]
                (
                    [Placement]
                );
            CREATE STATISTICS Stat_CustItemMonthlyPlacements_Month
                ON AFISales_Enh.[CustItemMonthlyPlacements_LOAD]
                (
                    [Month]
                );
            CREATE STATISTICS Stat_CustItemMonthlyPlacements_Gained
                ON AFISales_Enh.[CustItemMonthlyPlacements_LOAD]
                (
                    [Gained]
                );


            DROP TABLE IF EXISTS AFISales_Enh.CustItemMonthlyPlacements;

            EXECUTE sp_rename 'AFISales_Enh.CustItemMonthlyPlacements_LOAD','CustItemMonthlyPlacements'


            DROP TABLE #Monthly_History;

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


        DROP TABLE IF EXISTS AFISales_Wrk.ItemStatus_MOP;


        DROP TABLE IF EXISTS Temp..#PlacementMonthDat;


        SET @DateValue = GETDATE();
        SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)

        EXEC [$(ETL_Framework)].DW_Developer.usp_UpdateTableDictionary_ModifiedDate 
            'AFISales_DW', 'AFISales_Enh', 'CustItemMonthlyPlacements', @String, @DateValue;

    END;-- Write your own SQL object definition here, and it'll be included in your package.
