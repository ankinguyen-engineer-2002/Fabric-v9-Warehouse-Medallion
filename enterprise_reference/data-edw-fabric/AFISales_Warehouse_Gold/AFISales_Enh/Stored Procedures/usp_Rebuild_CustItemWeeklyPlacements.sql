CREATE PROC [AFISales_Enh].[usp_Rebuild_CustItemWeeklyPlacements]
AS

    /* Change Control -----------------------------------------------------------------------------------------------------------
* Procedure: AFISales_Enh.usp_Rebuild_WeeklyOrderPlacements  Called from usp_BuildOrderPlacements
* Description: Get order Placement Data - re-engineered logic
* Author: Matt Carter          Date: 01/05/05
* Optimized by Bob Horton, July 2006
* bh added salescategory/region logic 10/2007
* Ed Obaseki remove item with ZZ category
* BH converted to PDW Jan, 2017
* BH converted to Weekly Buckets, 4/20/2017
* Gabe De Mayo (2/26/18): Modified to use usp_CreateReplicateWorkTable/updated object existence check/updated error handling
* Amy Morina 04/26/2018 changed all references to GETDATE() to DW_Developer.fn_GetCSTDate(GETDATE())
* Bob Horton 05/08/2019 swapped out references to MainPiece with dimItemMaster
* 02/26/2020 Changed insert to "Values" syntax to avoid exclusive locks
* Bob Horton 10/18/2023 converted to Fabric
---------------------------------------------------------------------------------------------------------------------------*/

    BEGIN

        DECLARE
            @String    VARCHAR(5000),
            @DateValue DATETIME2(6),
            @User      VARCHAR(500);
        SET @String = 'AFISales_DW.AFISales_Enh.usp_Rebuild_CustItemWeeklyPlacements';
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
                @currentYear  SMALLINT,
                @CurrentWeek  SMALLINT,
                @PreviousYear SMALLINT,
                @PreviousWeek SMALLINT,
                @StartDate    DATE


            /*** Establish dates ***/

            SET @currentYear =
                (
                    SELECT
                        [Fiscal Year]
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] = CAST(@DateValue as DATE)
                );

            SET @CurrentWeek =
                (
                    SELECT
                        [Fiscal Week]
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] = CAST(@DateValue as DATE)
                );
 

            SET @PreviousYear =
                (
                    SELECT
                        [Fiscal Year]
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] = DATEADD(DAY, -7, CAST(@DateValue AS DATE))
                );
            SET @PreviousWeek =
                (
                    SELECT
                        [Fiscal Week]
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                         [Transaction Date] = DATEADD(DAY, -7, CAST(@DateValue AS DATE))
                );
 
            SET @StartDate = GETDATE() - 2290;


            /*** Get Item and item status history ***/


            DROP TABLE IF EXISTS AFISales_Wrk.ItemStatus_WOP;


            CREATE TABLE AFISales_Wrk.ItemStatus_WOP
                (
                    Year             SMALLINT,
                    Week             INT,
                    WeekDate         DATE,
                    ItemSKU          VARCHAR(15),
                    ItemStatus       CHAR(1),
                    CanLosePlacement INT
                );

            --- AFIItemStatus is the current item status
            --- imapmfpus is the previous item status
            --- imaItscdt is the date the previous status changed to the current status
            --- Status typically go move from 'T' -> 'N' --> 'I' --> '' --> 'D' -> 'R'   (if there is an overlap in status histories, default to the earliest in the lifecycle)

            INSERT INTO AFISales_Wrk.ItemStatus_WOP
                (
                    Year,
                    Week,
                    WeekDate,
                    ItemSKU,
                    ItemStatus,
                    CanLosePlacement
                )
                        SELECT
                                D.Year,
                                D.Week,
                                D.WeekDate,
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
                                --Anything coded as "I" status will not lose a Placement until after 86 days
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
                                                            AND DATEDIFF(d, ISNULL(T7.StatusDate, WeekDate), WeekDate) < 85
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
                                            WeekDate = MIN([Transaction Date]),
                                            Year     = [Fiscal Year],
                                            Week     = [Fiscal Week]
                                    FROM
                                            AFISales_DW.DimDateFile
                                    WHERE
                                            [Transaction Date]
                                    BETWEEN @StartDate AND DATEADD(DAY, 1, @DateValue)
                                    GROUP BY
                                            [Fiscal Year],
                                            [Fiscal Week]
                                ) D
                            LEFT JOIN
                                (
                                    SELECT
                                        'T'                   AS ItemStatus,
                                        MAX([OrderDate]) AS StatusDate,
                                        [ItemSKU]
                                    FROM
                                        [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                    WHERE
                                        [OrderDate]
                                        BETWEEN @StartDate AND @DateValue
                                        AND ItemStatus = ('T')
                                    GROUP BY
                                        [ItemSKU]
                                ) T1
                                    ON DimItemMaster.ItemSKU = T1.[ItemSKU]
                                       AND D.WeekDate <= T1.StatusDate
                            LEFT JOIN
                                (
                                    SELECT
                                        'N'                   AS ItemStatus,
                                        MAX([OrderDate]) AS StatusDate,
                                        [ItemSKU]
                                    FROM
                                        [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                    WHERE
                                        [OrderDate]
                                        BETWEEN @StartDate AND @DateValue
                                        AND ItemStatus = ('N')
                                    GROUP BY
                                        [ItemSKU]
                                ) T2
                                    ON DimItemMaster.ItemSKU = T2.[ItemSKU]
                                       AND D.WeekDate <= T2.StatusDate
                            LEFT JOIN
                                (
                                    SELECT
                                        'I'                   AS ItemStatus,
                                        MAX([OrderDate]) AS StatusDate,
                                        [ItemSKU]
                                    FROM
                                        [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                    WHERE
                                        [OrderDate]
                                        BETWEEN @StartDate AND @DateValue
                                        AND ItemStatus = ('I')
                                    GROUP BY
                                        [ItemSKU]
                                ) T3
                                    ON DimItemMaster.ItemSKU = T3.[ItemSKU]
                                       AND D.WeekDate <= T3.StatusDate
                            LEFT JOIN
                                (
                                    SELECT
                                        ' '                   AS ItemStatus,
                                        MAX([OrderDate]) AS StatusDate,
                                        [ItemSKU]
                                    FROM
                                        [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                    WHERE
                                        [OrderDate]
                                        BETWEEN @StartDate AND @DateValue
                                        AND ItemStatus = ('D')
                                    GROUP BY
                                        [ItemSKU]
                                ) T4
                                    ON DimItemMaster.ItemSKU = T4.[ItemSKU]
                                       AND D.WeekDate <= T4.StatusDate
                            LEFT JOIN
                                (
                                    SELECT
                                        'D'                   AS ItemStatus,
                                        MAX([OrderDate]) AS StatusDate,
                                        [ItemSKU]
                                    FROM
                                        [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                    WHERE
                                        [OrderDate]
                                        BETWEEN @StartDate AND @DateValue
                                        AND ItemStatus = ('D')
                                    GROUP BY
                                        [ItemSKU]
                                ) T5
                                    ON DimItemMaster.ItemSKU = T5.[ItemSKU]
                                       AND D.WeekDate <= T5.StatusDate
                            LEFT JOIN
                                (
                                    SELECT
                                        'R'                   AS ItemStatus,
                                        MAX([OrderDate]) AS StatusDate,
                                        [ItemSKU]
                                    FROM
                                        [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                    WHERE
                                        [OrderDate]
                                        BETWEEN @StartDate AND @DateValue
                                        AND ItemStatus = ('R')
                                    GROUP BY
                                        [ItemSKU]
                                ) T6
                                    ON DimItemMaster.ItemSKU = T6.[ItemSKU]
                                       AND D.WeekDate <= T6.StatusDate
                            LEFT JOIN
                                (
                                    SELECT
                                        'N'                   AS ItemStatus,
                                        MAX([OrderDate]) AS StatusDate,
                                        [ItemSKU]
                                    FROM
                                        [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                    WHERE
                                        [OrderDate]
                                        BETWEEN @StartDate AND @DateValue
                                        AND ItemStatus = ('N')
                                    GROUP BY
                                        [ItemSKU]
                                ) T7
                                    ON DimItemMaster.ItemSKU = T7.[ItemSKU]
                        WHERE
                                DimItemMaster.AFISalesCategory <> 'ZZ'
                                AND DimItemMaster.KeyItem = 1;



            /*** Get Orders - by Bill-to's, by Shipto if there are execptions (need up to 27 months of hisotry for a proper calculation) ***/

            CREATE TABLE #Weekly_History
                (
                    [Year]     SMALLINT,
                    [Week]     INT,
                    WeekDate   DATE,
                    CustomerNumber CHAR(8),
                    ShiptoNumber    CHAR(4),
                    ItemSKU    VARCHAR(15),
                    OrderQty   BIGINT,
                    OrderAmt   DECIMAL(10, 2),
                    Placement  BIGINT,
                    Lost       BIGINT
                );

            --print 'insert tb_history'
            -- Summarize orders By Account where not billto Exceptions, net out same week cancellations
            INSERT INTO #Weekly_History
                (
                    Year,
                    Week,
                    WeekDate,
                    CustomerNumber,
                    ShiptoNumber,
                    ItemSKU,
                    OrderQty,
                    OrderAmt,
                    Placement,
                    Lost
                )
                        SELECT
                                WD.[Fiscal Year],
                                WD.[Fiscal Week],
                                WD.[Transaction Date],
                                OrderHistory.CustomerNumber AS CustomerNumber,
                                ''                         AS ShiptoNumber,
                                OrderHistory.ItemSKU     AS ItemSKU,
                                SUM(OrderHistory.[Quantity])  AS OrderQty,
                                SUM(OrderHistory.[NetAmount]) AS OrderAmt,
                                1                AS Placement,
                                0                AS Lost
                        FROM
                                [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                            JOIN
                                [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
                                    ON OrderHistory.[ItemSKU] = DimItemMaster.ItemSKU
                                       AND DimItemMaster.KeyItem = 1
                            JOIN
                                AFISales_DW.DimDateFile D1
                                    ON D1.[Transaction Date] = CONVERT(DATE, CONVERT(CHAR(8), OrderDate))
                            JOIN
                               AFISales_DW.DimDateFile WD
                                    ON D1.[Fiscal Year] = WD.[Fiscal Year]
                                       AND D1.[Fiscal Week] = WD.[Fiscal Week]
                                       AND DATEPART(dw, WD.[Transaction Date]) = 1
                        WHERE
                                [OrderDate] >= @StartDate
                                AND [CustomerNumber] NOT IN
                                        (
                                            SELECT
                                                CustomerNumber
                                            FROM
                                                [$(Wholesale_Warehouse)].Marketing.PresBillToExceptions
                                        )
                        GROUP BY
                                WD.[Fiscal Year],
                                WD.[Fiscal Week],
                                WD.[Transaction Date],
                                OrderHistory.[CustomerNumber],
                                OrderHistory.[ItemSKU]
                        HAVING
                                SUM([Quantity]) <> 0;

            --  Get Orders - by Ship-to's where there are entries in the Billto Exceptions, net out same week cancellations
            INSERT INTO #Weekly_History
                (
                    Year,
                    Week,
                    WeekDate,
                    CustomerNumber,
                    ShiptoNumber,
                    ItemSKU,
                    OrderQty,
                    OrderAmt,
                    Placement,
                    Lost
                )
                        SELECT
                                WD.[Fiscal Year],
                                WD.[Fiscal Week],
                                WD.[Transaction Date],
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
                                    ON DimItemMaster.ItemSKU = OrderHistory.ItemSKU
                                       AND KeyItem = 1
                            JOIN
                                AFISales_DW.DimDateFile D1
                                    ON [Transaction Date] = CONVERT(DATE, CONVERT(CHAR(8), OrderDate))
                            JOIN
                                AFISales_DW.DimDateFile WD
                                    ON D1.[Fiscal Year] = WD.[Fiscal Year]
                                       AND D1.[Fiscal Week] = WD.[Fiscal Week]
                                       AND DATEPART(dw, WD.[Transaction Date]) = 1
                        WHERE
                                OrderHistory.OrderDate >= @StartDate
                                AND OrderHistory.CustomerNumber IN
                                        (
                                            SELECT
                                                PresBillToExceptions.CustomerNumber
                                            FROM
                                                [$(Wholesale_Warehouse)].Marketing.PresBillToExceptions
                                        )
                        GROUP BY
                                WD.[Fiscal Year],
                                WD.[Fiscal Week],
                                WD.[Transaction Date],
                                OrderHistory.[CustomerNumber],
                                OrderHistory.[ShiptoNumber],
                                OrderHistory.[ItemSKU]
                        HAVING
                                SUM([Quantity]) <> 0;



            /*** add future buckets for current Placements where future buckets don't exist 12 weeks out **/

            INSERT INTO #Weekly_History
                (
                    Year,
                    Week,
                    WeekDate,
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
                                1 AS Placement,
                                0 AS Lost
                        FROM
                                (
                                    SELECT
                                            [Fiscal Year],
                                            [Fiscal Week],
                                            [Transaction Date] AS WeekDate,
                                            t1.CustomerNumber,
                                            t1.ShiptoNumber,
                                            t1.ItemSKU,
                                            0         AS OrderQty,
                                            0         AS OrderAmt
                                    FROM
                                            #Weekly_History t1
                                        JOIN
                                            AFISales_DW.DimDateFile
                                                ON [Transaction Date]
                                                   BETWEEN DATEADD(DAY, 7, WeekDate) AND DATEADD(DAY, 84, WeekDate)
                                                   AND DATEPART(dw, [Transaction Date]) = 1
                                    WHERE
                                            OrderQty > 0
                                )               t4
                            LEFT JOIN
                                #Weekly_History t2
                                    ON t4.WeekDate = t2.WeekDate
                                       AND t4.CustomerNumber = t2.CustomerNumber
                                       AND t4.ShiptoNumber = t2.ShiptoNumber
                                       AND t4.ItemSKU = t2.ItemSKU
                        WHERE
                                t2.CustomerNumber IS NULL;


            /*** add future buckets for current Placements for any weeks after where can't lose Placement **/

            INSERT INTO #Weekly_History
                (
                    Year,
                    Week,
                    WeekDate,
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
                                1 AS Placement,
                                0 AS Lost
                        FROM
                                (
                                    SELECT
                                            T3.Year,
                                            T3.Week,
                                            T3.WeekDate,
                                            t1.CustomerNumber,
                                            t1.ShiptoNumber,
                                            t1.ItemSKU,
                                            0 AS OrderQty,
                                            0 AS OrderAmt
                                    FROM
                                            #Weekly_History             t1
                                        JOIN
                                            AFISales_Wrk.ItemStatus_WOP T3
                                                ON t1.ItemSKU = T3.ItemSKU
                                                   AND T3.CanLosePlacement = 0
                                                   AND T3.WeekDate > t1.WeekDate
                                    WHERE
                                            OrderQty > 0
                                )               t4
                            LEFT JOIN
                                #Weekly_History t2
                                    ON t4.WeekDate = t2.WeekDate
                                       AND t4.CustomerNumber = t2.CustomerNumber
                                       AND t4.ShiptoNumber = t2.ShiptoNumber
                                       AND t4.ItemSKU = t2.ItemSKU
                        WHERE
                                t2.CustomerNumber IS NULL;



            /*** add future buckets for Lost Placement, check future week for missing Placements **/

            INSERT INTO #Weekly_History
                (
                    Year,
                    Week,
                    WeekDate,
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
                                            [Fiscal Week],
                                            [Transaction Date] AS WeekDate,
                                            t1.CustomerNumber,
                                            t1.ShiptoNumber,
                                            t1.ItemSKU
                                    FROM
                                            #Weekly_History t1
                                        JOIN
                                            AFISales_DW.DimDateFile
                                                ON [Transaction Date] = DATEADD(DAY,7 ,WeekDate)
                                    WHERE
                                            Placement > 0
                                )               t4
                            LEFT JOIN
                                #Weekly_History FW
                                    ON FW.WeekDate = t4.WeekDate
                                       AND t4.CustomerNumber = FW.CustomerNumber
                                       AND t4.ShiptoNumber = FW.ShiptoNumber
                                       AND t4.ItemSKU = FW.ItemSKU
                        WHERE
                                FW.CustomerNumber IS NULL;

            /*** Create Data Structures for Long History ***/

            DROP TABLE IF EXISTS AFISales_Enh.CustItemWeeklyPlacements_LOAD;

            CREATE TABLE AFISales_Enh.[CustItemWeeklyPlacements_LOAD]
                (
                    [CustomerNumber] CHAR (8)        NOT NULL,
                    [ShiptoNumber]   CHAR (4)        NOT NULL,
                    [ItemSKU]     VARCHAR (15)    NOT NULL,
                    [ItemStatus]     CHAR (1)        NULL,
                    [Division]       CHAR (1)        NOT NULL,
                    [YearWeek]       INT             NOT NULL,
                    [Quantity]       DECIMAL (10, 2) NULL,
                    [Amount]         DECIMAL (10, 2) NULL,
                    [Placement]      SMALLINT        NULL,
                    [Gained]         SMALLINT        NULL,
                    [Lost ]          SMALLINT        NULL,
                    [AtRisk]         SMALLINT        NULL,
                    [Current]        SMALLINT        NULL,
                    [Year]           INT             NULL,
                    [Week]           INT             NULL
                );


            INSERT INTO AFISales_Enh.CustItemWeeklyPlacements_LOAD
                (
                    CustomerNumber,
                    ShiptoNumber,
                    ItemSKU,
                    ItemStatus,
                    Division,
                    YearWeek,
                    Quantity,
                    Amount,
                    Placement,
                    Gained,
                    Lost,
                    AtRisk,
                    [Current],
                    Year,
                    Week
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
                                           + REPLICATE('0', ABS(LEN(CONVERT(VARCHAR(2), h.Week)) - 2))
                                           + CONVERT(VARCHAR(2), h.Week)
                                       ),
                                h.OrderQty,
                                h.OrderAmt,
                                h.Placement,

                                --- If qytord > 0 and there is no active Placement for the previous week, count it as a gained Placement
                                CASE
                                    WHEN h.OrderQty > 0
                                         AND ISNULL(PW.Placement, 0) = 0
                                        THEN
                                        1
                                    ELSE
                                        0
                                END    AS [gained],
                                h.Lost,

                                --- Count at risk if Active Placement in Last week and Item Status = D or R
                                CASE
                                    WHEN h.Year = @PreviousYear
                                         AND h.Week >= @PreviousWeek
                                         AND i.ItemStatus IN (
                                                                 'D', 'R'
                                                             )
                                        THEN
                                        h.Placement * -1
                                    WHEN h.Year = @currentYear
                                         AND h.Week = @CurrentWeek
                                        THEN
                                        h.Lost * -1
                                END    AS AtRisk,

                                --- If Placement is active for last week,  count as a current Placement    
                                CASE
                                    WHEN h.Year = @PreviousYear
                                         AND h.Week = @PreviousWeek
                                        THEN
                                        h.Placement
                                    ELSE
                                        0
                                END    AS [Current],
                                h.Year,
                                h.Week
                        FROM
                                #Weekly_History                                       h
                            JOIN
                                AFISales_Wrk.ItemStatus_WOP                           i
                                    ON h.ItemSKU = i.ItemSKU
                                       AND h.[Year] = i.[Year]
                                       AND h.Week = i.Week
                            JOIN
                                [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster m
                                    ON h.ItemSKU = m.ItemSKU
                            LEFT JOIN
                                #Weekly_History                                       PW
                                    ON PW.WeekDate = h.WeekDate - 7
                                       AND h.CustomerNumber = PW.CustomerNumber
                                       AND h.ShiptoNumber = PW.ShiptoNumber
                                       AND h.ItemSKU = PW.ItemSKU
                        WHERE
                                h.WeekDate
                        BETWEEN GETDATE() - 2190 AND @DateValue;



            CREATE STATISTICS [Stat_CustItemWeeklyPlacements_CustomerNumber]
                ON AFISales_Enh.[CustItemWeeklyPlacements_LOAD]
                (
                    [CustomerNumber]
                );
            CREATE STATISTICS [Stat_CustItemWeeklyPlacements_ShiptoNumber]
                ON AFISales_Enh.[CustItemWeeklyPlacements_LOAD]
                (
                    [ShiptoNumber]
                );
            CREATE STATISTICS [Stat_CustItemWeeklyPlacements_ItemSKU]
                ON AFISales_Enh.[CustItemWeeklyPlacements_LOAD]
                (
                    [ItemSKU]
                );
            CREATE STATISTICS [Stat_CustItemWeeklyPlacements_ItemStatus]
                ON AFISales_Enh.[CustItemWeeklyPlacements_LOAD]
                (
                    [ItemStatus]
                );
            CREATE STATISTICS [Stat_CustItemWeeklyPlacements_Division]
                ON AFISales_Enh.[CustItemWeeklyPlacements_LOAD]
                (
                    [Division]
                );
            CREATE STATISTICS [Stat_CustItemWeeklyPlacements_YearWeek]
                ON AFISales_Enh.[CustItemWeeklyPlacements_LOAD]
                (
                    [YearWeek]
                );
            CREATE STATISTICS Stat_CustItemWeeklyPlacements_Week
                ON AFISales_Enh.[CustItemWeeklyPlacements_LOAD]
                (
                    [Week]
                );
            CREATE STATISTICS Stat_CustItemWeeklyPlacements_Quantity
                ON AFISales_Enh.[CustItemWeeklyPlacements_LOAD]
                (
                    [Quantity]
                );
            CREATE STATISTICS Stat_CustItemWeeklyPlacements_Placement
                ON AFISales_Enh.[CustItemWeeklyPlacements_LOAD]
                (
                    [Placement]
                );
            CREATE STATISTICS Stat_CustItemWeeklyPlacements_Year
                ON AFISales_Enh.[CustItemWeeklyPlacements_LOAD]
                (
                    [Year]
                );

            DROP TABLE IF EXISTS AFISales_Enh.CustItemWeeklyPlacements;

            EXECUTE sp_rename 'AFISales_Enh.CustItemWeeklyPlacements_LOAD','CustItemWeeklyPlacements'

  
            DROP TABLE #Weekly_History;

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


        DROP TABLE IF EXISTS AFISales_Wrk.ItemStatus_WOP;

        SET @DateValue = GETDATE();
        SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)
 
        EXEC [$(ETL_Framework)].DW_Developer.usp_UpdateTableDictionary_ModifiedDate 
            'AFISales_DW', 'AFISales_Enh', 'CustItemWeeklyPlacements', @String, @DateValue;

    END;-- Write your own SQL object definition here, and it'll be included in your package.
