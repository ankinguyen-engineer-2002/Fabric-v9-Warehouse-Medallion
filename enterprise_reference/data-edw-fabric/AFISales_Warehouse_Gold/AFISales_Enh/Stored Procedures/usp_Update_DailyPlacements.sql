CREATE PROC [AFISales_Enh].[usp_Update_DailyPlacements]
AS

    /* Change Control -----------------------------------------------------------------------------------------------------------
* Procedure: [AFISales_Enh].[usp_Update_DailyPlacements]
* Description: 	Procedure created to have a daily update of order placements with the date of actual placement  
* Leandra Edgar (06/05/2009): Created
* Lhulberg (02/20/2017): oving procedure to PDW and changed syntax
* Bob Horton (Jan 2018): Migrated from PDW Cube load view to Azure Data Warehouse
* Gabe De Mayo (3/2/18): Modified to use usp_CreateReplicateWorkTable/updated object existence check/updated error handling
* Amy Morina 04/26/2018 changed all references to GETDATE() to DW_Developer.fn_GetCSTDate(GETDATE())
* Bob Horton 6/18/2018  added Min() function in last insert to associate the placement to the first day the new sale shows up for within the week and not double count throughout the week
* Bob Horton 05/08/2019 swapped out references to MainPiece with dimItemMaster
* 02/26/2020 Changed insert to "Values" syntax to avoid exclusive locks
* Bob Horton 10/24/2023 convert to Fabric
---------------------------------------------------------------------------------------------------------------------------*/

    BEGIN

        DECLARE
            @String    VARCHAR(5000),
            @DateValue DATETIME2(6),
            @User      VARCHAR(500);

        SET @String = 'AFISales_DW.AFISales_Enh.usp_Update_DailyPlacements';
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
                @currentYear      SMALLINT,
                @CurrentMonth     SMALLINT,
                @CurrentYearMonth INT,
                @MinDate          DATE;


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
                        [Transaction Date] = CAST(@DateValue AS DATE)
                );
            SET @CurrentYearMonth =
                (
                    SELECT
                        MIN([FiscalWeekYear])
                    FROM
                       AFISales_DW.DimDateFile
                    WHERE
                        [Fiscal Year] = @currentYear
                        AND [Fiscal Month] = @CurrentMonth
                );
            SET @MinDate =
                (
                    SELECT
                        MIN([Transaction Date])
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Fiscal Year] = @currentYear
                        AND [Fiscal Month] = @CurrentMonth
                );


            CREATE TABLE #tblOrders
                (
                    [Year]         SMALLINT,
                    [Period]       INT,
                    OrderDate      DATE,
                    CustomerNumber VARCHAR(8),
                    ShiptoNumber   VARCHAR(4),
                    ItemSKU     VARCHAR(15),
                    OrderQuantity  INT
                );



            INSERT INTO #tblOrders
                (
                    [Year],
                    [Period],
                    OrderDate,
                    CustomerNumber,
                    ShiptoNumber,
                    ItemSKU,
                    OrderQuantity
                )
                        SELECT
                                Year   = [Fiscal Year],
                                Period = [Fiscal Month],
                                OrderDate,
                                CustomerNumber,
                                ShiptoNumber,
                                ItemSKU,
                                OrderQuantity
                        FROM
                                (
                                    SELECT
                                            OrderDate      = OrderHistory.OrderDate ,
                                            CustomerNumber = OrderHistory.[CustomerNumber],
                                            ShiptoNumber   = '',
                                            ItemSKU        = OrderHistory.ItemSKU,
                                            OrderQuantity  = SUM([Quantity])
                                    FROM
                                            [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                        JOIN
                                            AFISales_DW.DimItemMaster
                                                ON OrderHistory.ItemSKU = DimItemMaster.ItemSKU
                                                   AND DimItemMaster.KeyItem = 1
                                    WHERE
                                            OrderHistory.[OrderDate] >= @MinDate
                                            AND OrderHistory.CustomerNumber NOT IN
                                                    (
                                                        SELECT
                                                            PresBillToExceptions.CustomerNumber
                                                        FROM
                                                            [$(Wholesale_Warehouse)].Marketing.PresBillToExceptions
                                                    )
                                    GROUP BY
                                            OrderHistory.OrderDate,
                                            OrderHistory.CustomerNumber,
                                            OrderHistory.ItemSKU,
                                            OrderHistory.Quantity
                                    UNION
                                    SELECT
                                            OrderHistory.OrderDate,
                                            OrderHistory.CustomerNumber ,
                                            OrderHistory.ShiptoNumber ,
                                            OrderHistory.ItemSKU ,
                                            OrderQuantity  = SUM(OrderHistory.Quantity)
                                    FROM
                                            [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
                                        JOIN
                                            AFISales_DW.DimItemMaster
                                                ON OrderHistory.ItemSKU = DimItemMaster.ItemSKU
                                                   AND DimItemMaster.KeyItem = 1
                                    WHERE
                                            OrderHistory.[OrderDate] >= @MinDate
                                            AND OrderHistory.[CustomerNumber] IN
                                                    (
                                                        SELECT
                                                            PresBillToExceptions.CustomerNumber
                                                        FROM
                                                            [$(Wholesale_Warehouse)].Marketing.PresBillToExceptions
                                                    )
                                    GROUP BY
                                            OrderHistory.OrderDate,
                                            OrderHistory.[CustomerNumber],
                                            OrderHistory.[ShiptoNumber],
                                            OrderHistory.[ItemSKU],
                                            OrderHistory.[Quantity]
                                ) t1
                            JOIN
                                AFISales_DW.DimDateFile
                                    ON t1.OrderDate = DimDateFile.[Transaction Date]
                        WHERE
                                t1.OrderQuantity <> 0;



            CREATE TABLE #tblOrdersDetail
                (
                    [Year]         SMALLINT,
                    [Period]       INT,
                    OrderDate      DATE,
                    CustomerNumber VARCHAR(8),
                    ShiptoNumber   VARCHAR(4),
                    ItemSKU     VARCHAR(15),
                    OrderQuantity  INT
                );


            INSERT INTO #tblOrdersDetail
                (
                    [Year],
                    [Period],
                    OrderDate,
                    CustomerNumber,
                    ShiptoNumber,
                    ItemSKU,
                    OrderQuantity
                )
                        SELECT
                                #tblOrders.Year,
                                #tblOrders.Period,
                                #tblOrders.OrderDate,
                                #tblOrders.CustomerNumber,
                                #tblOrders.ShiptoNumber,
                                #tblOrders.ItemSKU,
                                SUM(#tblOrders.OrderQuantity) AS OrderQuantity
                        FROM
                                #tblOrders
                            LEFT JOIN
                                AFISales_Enh.CustItemMonthlyPlacements
                                    ON AccountNum                             = #tblOrders.CustomerNumber
                                       AND CustItemMonthlyPlacements.ShipNum  = #tblOrders.ShiptoNumber
                                       AND CustItemMonthlyPlacements.ItemNum  = #tblOrders.ItemSKU
                                       AND CustItemMonthlyPlacements.YearMonth = @CurrentYearMonth
                                       AND CustItemMonthlyPlacements.Placement <> 0
                            --AND Current <> 0
                            LEFT JOIN
                                AFISales_Enh.DailyPlacements
                                    ON DailyPlacements.CustomerNumber      = #tblOrders.CustomerNumber
                                       AND DailyPlacements.ShiptoNumber    = #tblOrders.ShiptoNumber
                                       AND DailyPlacements.ItemSKU      = #tblOrders.ItemSKU
                                       AND DailyPlacements.DateOfPlacement = #tblOrders.OrderDate
                        WHERE
                                 CustItemMonthlyPlacements.AccountNum IS NULL
                                AND #tblOrders.OrderQuantity > 0
                                AND DailyPlacements.CustomerNumber IS NULL
                        GROUP BY
                                #tblOrders.Year,
                                #tblOrders.Period,
                                #tblOrders.OrderDate,
                                #tblOrders.CustomerNumber,
                                #tblOrders.ShiptoNumber,
                                #tblOrders.ItemSKU;
            --ORDER BY CustomerNumber, ShiptoNumber

            INSERT INTO AFISales_Enh.DailyPlacements
                        SELECT
                            CustomerNumber,
                            ShiptoNumber,
                            ItemSKU,
                            MIN(OrderDate)
                        FROM
                            #tblOrdersDetail
                        WHERE
                            OrderQuantity > 0
                        GROUP BY
                            CustomerNumber,
                            ShiptoNumber,
                            ItemSKU;


            DROP TABLE #tblOrdersDetail;
            DROP TABLE #tblOrders;

            DELETE FROM
            AFISales_Enh.DailyPlacements
            WHERE
                DateOfPlacement < GETDATE() - 2560;

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
            'AFISales_DW', 'AFISales_Enh', 'DailyPlacements', @String, @DateValue;

    END;