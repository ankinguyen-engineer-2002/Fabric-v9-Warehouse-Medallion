CREATE PROC [AFISales_Enh].[usp_Update_DailyPlacementsSaved]
AS

    /* Change Control -----------------------------------------------------------------------------------------------------------
* Procedure: [AFISales_Enh].[Update_DailyPlacementSaved] 
* Description: Append data into the table DailyPlacementsSaved
* Ram Dhilip (8/5/2014): Created
* Bob Horton (2/22/2017): Converted to PDW
* Bob Horton (Jan 2018): Migrated from PDW Cube load view to Azure Data Warehouse
* Gabe De Mayo (3/2/18): Modified to use usp_CreateReplicateWorkTable/updated object existence check/updated error handling
* Amy Morina 04/26/2018 changed all references to GETDATE() to DW_Developer.fn_GetCSTDate(GETDATE())
* Bob Horton 05/15/2018  change end date to yesterday.   In PDW the OrderHistory table does not have today in it... partial days breaks the process
* Bob Horton 6/8/2018   removed join to territory alloctaion table and changed the structure of the table to only hold the sales category.
*                       territory allocations will be performed as the fact table gets reloaded to be consistant with weekly/monthly processes
* 02/26/2020 Changed insert to "Values" syntax to avoid exclusive locks
* Bob Horton 10/23/2023  converted to Fabric
---------------------------------------------------------------------------------------------------------------------------*/

    BEGIN

        DECLARE
            @String    VARCHAR(5000),
            @DateValue DATETIME2(6),
            @User      VARCHAR(500);
        SET @String = 'AFISales_DW.AFISales_Enh.usp_Update_DailyPlacementsSaved';
        SET @User = SYSTEM_USER;

        SET @DateValue = Getdate()
          SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)


        INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
        VALUES
            (
                @String, @DateValue, @User, 'Process Start'
            );

        BEGIN TRY

            /* declare working variables */
            DECLARE
                @PeriodStartDate DATE,
                @startYear       SMALLINT,
                @startPeriod     SMALLINT,
                @OrderStartDate  DATE,
                @OrderEndDate    DATE;

            /*** Establish dates ***/
            -- Get starting Year/Period from Sales History data - we always keep 2 Years plus current Year
            -- of data in Sales History data and placement data will match that.
            SET @startYear = DATEPART(yy, @DateValue) - 3;
            SET @startPeriod = 1;

            --- table should never be empty, if it is go back 7 days
            SET @OrderStartDate =
                (
                    SELECT
                        ISNULL(MAX(ChangeDate), DATEADD(DAY, -7, @DateValue))
                    FROM
                        AFISales_Enh.DailyPlacementsSaved
                );
            SET @OrderEndDate = DATEADD(DAY, -1, @DateValue);

            -- Get date of starting Year/Period
            SET @PeriodStartDate =
                (
                    SELECT
                        MIN([Transaction Date])
                    FROM
                         AFISales_DW.DimDateFile
                    WHERE
                        [Fiscal Year] = @startYear
                        AND [Fiscal Month] = @startPeriod
                );


            CREATE TABLE #tb_history
                (
                    OrderDate  DATE,
                    ChangeDate DATE,
                    [Year]     SMALLINT,
                    [Period]   INT,
                    CustomerNumber VARCHAR(8),
                    ShiptoNumber    VARCHAR(4),
                    ItemSKU    VARCHAR(15),
                    OrderQty   BIGINT
                );

            INSERT INTO #tb_history
                        SELECT
                            OrderDate,
                            ChangeDate,
                            [Year],
                            [Period],
                            CustomerNumber,
                            ShiptoNumber,
                            ItemSKU,
                            OrderQty = SUM(OrderQty)
                        FROM
                            (
                                /*** Get Orders - by Bill-to's ***/
                                -- Summarize orders to net out cancellations
                                SELECT
                                        tb_ordersDetail.OrderDate,
                                        tb_ordersDetail.ChangeDate,
                                        [Year]          = DimDateFile.[Fiscal Year],
                                        [Period]        = DimDateFile.[Fiscal Month],
                                        tb_ordersDetail.CustomerNumber,
                                        tb_ordersDetail.ShiptoNumber,
                                        tb_ordersDetail.ItemSKU,
                                        SUM(tb_ordersDetail.OrderQty) OrderQty
                                FROM
                                        (
                                            SELECT
                                                    OrderDate  = OrderHistory.[OrderDate],
                                                    ChangeDate = OrderHistory.[OrderChangeDate],
                                                    CustomerNumber = OrderHistory.[CustomerNumber],
                                                    ShiptoNumber    = CAST('' AS VARCHAR(4)),
                                                    ItemSKU    = OrderHistory.[ItemSKU],
                                                    OrderQty   = SUM(OrderHistory.[Quantity])
                                            FROM
                                                    [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                                JOIN
                                                     [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
                                                        ON OrderHistory.[ItemSKU] = DimItemMaster.ItemSKU
                                                           AND DimItemMaster.KeyItem = 1
                                            WHERE
                                                    [OrderDate] >= @PeriodStartDate
                                                    AND OrderHistory.[CustomerNumber] NOT IN
                                                            (
                                                                SELECT
                                                                    PresBillToExceptions.CustomerNumber
                                                                FROM
                                                                    [$(Wholesale_Warehouse)].Marketing.PresBillToExceptions
                                                            )
                                                    AND OrderHistory.[OrderChangeDate] > @OrderStartDate
                                                    AND OrderHistory.[OrderChangeDate] <= @OrderEndDate
                                            GROUP BY
                                                    OrderHistory.[OrderDate],
                                                    OrderHistory.[OrderChangeDate],
                                                    OrderHistory.[CustomerNumber],
                                                    OrderHistory.[ItemSKU]
                                        ) tb_ordersDetail
                                    JOIN
                                         AFISales_DW.DimDateFile
                                            ON tb_ordersDetail.OrderDate =DimDateFile.[Transaction Date]
                                GROUP BY
                                        DimDateFile.[Fiscal Year],
                                        DimDateFile.[Fiscal Month],
                                        tb_ordersDetail.CustomerNumber,
                                        tb_ordersDetail.ShiptoNumber,
                                        tb_ordersDetail.ItemSKU,
                                        tb_ordersDetail.OrderDate,
                                        tb_ordersDetail.ChangeDate
                                HAVING
                                        SUM(OrderQty) <> 0
                                UNION ALL
                                /*** Get Orders - by Ship-to's ***/
                                -- Summarize orders to net out cancellations
                                SELECT
                                        tb_ordersDetail2.OrderDate,
                                        tb_ordersDetail2.ChangeDate,
                                        [Year]          = DimDateFile.[Fiscal Year],
                                        [Period]        = DimDateFile.[Fiscal Month],
                                        tb_ordersDetail2.CustomerNumber,
                                        tb_ordersDetail2.ShiptoNumber,
                                        tb_ordersDetail2.ItemSKU,
                                        SUM(tb_ordersDetail2.OrderQty) OrderQty
                                FROM
                                        (
                                            SELECT
                                                    OrderDate  = OrderHistory.[OrderDate],
                                                    ChangeDate = OrderHistory.[OrderChangeDate],
                                                    CustomerNumber = OrderHistory.[CustomerNumber],
                                                    ShiptoNumber    = OrderHistory.[ShiptoNumber],
                                                    ItemSKU    = OrderHistory.[ItemSKU],
                                                    OrderQty   = SUM(OrderHistory.[Quantity])
                                            FROM
                                                    [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                                JOIN
                                                     [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
                                                        ON OrderHistory.[ItemSKU] = DimItemMaster.ItemSKU
                                                           AND DimItemMaster.KeyItem = 1
                                            WHERE
                                                    [OrderDate] >= @PeriodStartDate
                                                    AND OrderHistory.[CustomerNumber] IN
                                                            (
                                                                SELECT
                                                                    CustomerNumber
                                                                FROM
                                                                    [$(Wholesale_Warehouse)].Marketing.PresBillToExceptions
                                                            )
                                                    AND OrderHistory.[OrderChangeDate] > @OrderStartDate
                                                    AND OrderHistory.[OrderChangeDate] <= @OrderEndDate
                                            GROUP BY
                                                    OrderHistory.[OrderDate],
                                                    OrderHistory.[OrderChangeDate],
                                                    OrderHistory.[CustomerNumber],
                                                    OrderHistory.[ShiptoNumber],
                                                    OrderHistory.[ItemSKU]
                                        ) tb_ordersDetail2
                                    JOIN
                                         AFISales_DW.DimDateFile
                                            ON tb_ordersDetail2.OrderDate = DimDateFile.[Transaction Date]
                                GROUP BY
                                        DimDateFile.[Fiscal Year],
                                        tb_ordersDetail2.OrderDate,
                                        tb_ordersDetail2.ChangeDate,
                                        DimDateFile.[Fiscal Month],
                                        tb_ordersDetail2.CustomerNumber,
                                        tb_ordersDetail2.ShiptoNumber,
                                        tb_ordersDetail2.ItemSKU
                                HAVING
                                        SUM(OrderQty) <> 0
                            ) tb_orders
                        GROUP BY
                            Year,
                            OrderDate,
                            ChangeDate,
                            Period,
                            CustomerNumber,
                            ShiptoNumber,
                            ItemSKU;
            --order by Year, Period, OrderDate, CustomerNumber, ShiptoNumber, ItemSKU

            /*** Get Item and item status history ***/

            CREATE TABLE #tb_ItemStatus
                (
                    [Year]           SMALLINT,
                    Period           INT,
                    ItemSKU          VARCHAR(15),
                    ItemStatus       CHAR(1),
                    CanLosePlacement INT
                );


            INSERT INTO #tb_ItemStatus
                (
                    [Year],
                    Period,
                    ItemSKU,
                    ItemStatus,
                    CanLosePlacement
                )
                        SELECT
                                [Year],
                                Period,
                                ItemSKU          = ItemSKU,
                                ItemStatus       = CASE
                                                       WHEN [PreviousStatusCode] = 'N'
                                                            AND DATEDIFF(m, [StatusCodeChangeDate], monthDate)
                                                            BETWEEN 0 AND 5
                                                           THEN
                                                           'I'
                                                       WHEN [PreviousStatusCode] = 'N'
                                                            AND DATEDIFF(m, [StatusCodeChangeDate], monthDate) < 0
                                                           THEN
                                                           'N'
                                                       WHEN [PreviousStatusCode] = ''
                                                            AND DATEDIFF(m, [StatusCodeChangeDate], monthDate) < 0
                                                           THEN
                                                           ''
                                                       ELSE
                                                           AFIItemStatus
                                                   END,
                                CanLosePlacement = CASE
                                                       WHEN [PreviousStatusCode] = 'N'
                                                            AND DATEDIFF(m, [StatusCodeChangeDate], monthDate)
                                                            BETWEEN 0 AND 2
                                                           THEN
                                                           0
                                                       WHEN [PreviousStatusCode] = 'N'
                                                            AND DATEDIFF(m, [StatusCodeChangeDate], monthDate)
                                                            BETWEEN 3 AND 5
                                                           THEN
                                                           1
                                                       WHEN [PreviousStatusCode] = 'N'
                                                            AND DATEDIFF(m, [StatusCodeChangeDate], monthDate) < 0
                                                           THEN
                                                           0
                                                       WHEN [PreviousStatusCode] = 'N'
                                                           THEN
                                                           0
                                                       WHEN AFIItemStatus = 'T'
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
                                        monthDate = MIN([Transaction Date]),
                                        Year      = [Fiscal Year],
                                        Period    = [Fiscal Month]
                                    FROM
                                         AFISales_DW.DimDateFile
                                    WHERE
                                        [Transaction Date] >= @PeriodStartDate
                                    GROUP BY
                                        [Fiscal Year],
                                        [Fiscal Month]
                                ) d
                        WHERE
                                KeyItem = 1;


            INSERT INTO AFISales_Enh.DailyPlacementsSaved
                (
                    [CustomerNumber],
                    [ShiptoNumber],
                    [ItemSKU],
                    [OrderDate],
                    [ChangeDate],
                    [YearPeriod],
                    [Quantity],
                    [ShiptoAddressID],
                    [AccountAndShiptoNumber],
                    [Territory],
                    [SalesCategory]
                )
                        SELECT
                                DPD.CustomerNumber,
                                DPD.ShiptoNumber,
                                DPD.ItemSKU,
                                DPD.OrderDate,
                                DPD.ChangeDate,
                                DPD.[YearPeriod],
                                DPD.OrderQty,
                                CSL.[Shipto AddressID],
                                CSL.[Account And Shipto Number],
                                CASE
                                    WHEN DPD.ShiptoNumber IS NULL
                                        THEN
                                        [CSL].[Primary Sales Territory]
                                    ELSE
                                        CAST(CSL.[Primary Sales Territory] AS CHAR(5))
                                        + CAST(CSL.[Shipto Sales Territory] AS CHAR(5))
                                END AS Territory,
                                IMA.[AFISalesCategoryCode]
                        FROM
                                (
                                    SELECT
                                            h.CustomerNumber,
                                            h.ShiptoNumber,
                                            h.ItemSKU,
                                            h.OrderDate,
                                            h.ChangeDate,
                                            CONVERT(
                                                       INT,
                                                       CONVERT(CHAR(4), h.Year)
                                                       + REPLICATE('0', ABS(LEN(CONVERT(VARCHAR(2), h.Period)) - 2))
                                                       + CONVERT(VARCHAR(2), h.Period)
                                                   ) [YearPeriod],
                                            h.OrderQty
                                    FROM
                                            #tb_history    h
                                        JOIN
                                            #tb_ItemStatus i
                                                ON h.ItemSKU = i.ItemSKU
                                                   AND h.Year = i.Year
                                                   AND h.Period = i.Period
                                        JOIN
                                             [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
                                                ON h.ItemSKU = DimItemMaster.ItemSKU
                                                   AND DimItemMaster.KeyItem = 1
                                )                           DPD
                            LEFT JOIN
                                AFISales_DW.DimCustomers    CSL
                                    ON [CSL].[Customer Account Number] = CustomerNumber
                                       AND CSL.[Customer Shipto Number] = ShiptoNumber
                            LEFT JOIN
                                 [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster IMA
                                    ON [IMA].[ItemSKU] = DPD.ItemSKU;

            DROP TABLE #tb_history;
            DROP TABLE #tb_ItemStatus;

            DELETE FROM
            AFISales_Enh.DailyPlacementsSaved
            WHERE
                [ChangeDate] < GETDATE() - 2560;

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
            'AFISales_DW', 'AFISales_Enh', 'DailyPlacementsSaved', @String, @DateValue;

    END;