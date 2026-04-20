CREATE PROC [Placements].[usp_Update_DailyPlacements]
AS

    /* Change Control -----------------------------------------------------------------------------------------------------------
* Procedure: [Placements].[usp_Update_DailyPlacements]
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

        SET @String = 'AFISales_DW.Placements.usp_Update_DailyPlacements';
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
                        [FiscalYear]
                    FROM
                        [$(MasterData_Warehouse)].MasterData_DW.DimDate_NonRetail
                    WHERE
                        [DateID] = CAST(@DateValue AS DATE)
                );
            SET @CurrentMonth =
                (
                    SELECT
                        [FiscalMonth]
                    FROM
                        [$(MasterData_Warehouse)].MasterData_DW.DimDate_NonRetail
                    WHERE
                        [DateID] = CAST(@DateValue AS DATE)
                );
            SET @CurrentYearMonth =
                (
                    SELECT
                        MIN([FiscalWeekYear])
                    FROM
                       [$(MasterData_Warehouse)].MasterData_DW.DimDate_NonRetail
                    WHERE
                        [FiscalYear] = @currentYear
                        AND [FiscalMonth] = @CurrentMonth
                );
            SET @MinDate =
                (
                    SELECT
                        MIN([DateID])
                    FROM
                        [$(MasterData_Warehouse)].MasterData_DW.DimDate_NonRetail
                    WHERE
                        [FiscalYear] = @currentYear
                        AND [FiscalMonth] = @CurrentMonth
                );


            CREATE TABLE Placements_Wrk.tblOrders
                (
                    [Year]         SMALLINT,
                    [Period]       INT,
                    OrderDate      DATE,
                    CustomerNumber VARCHAR(8),
                    ShiptoNumber   VARCHAR(4),
                    ItemSKU     VARCHAR(15),
                    OrderQuantity  INT
                );



            INSERT INTO Placements_Wrk.tblOrders
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
                                Year   = [FiscalYear],
                                Period = [FiscalMonth],
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
                                            SalesHistory_AFI.OrderHistory
                                        JOIN
                                            [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
                                                ON OrderHistory.ItemSKU = DimItemMaster.ItemSKU
                                                   AND DimItemMaster.KeyItem = 1
                                    WHERE
                                            OrderHistory.[OrderDate] >= @MinDate
                                            AND OrderHistory.CustomerNumber NOT IN
                                                    (
                                                        SELECT
                                                            PresBillToExceptions.CustomerNumber
                                                        FROM
                                                            Marketing.PresBillToExceptions
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
                                            SalesHistory_AFI.OrderHistory
                                        JOIN
                                            [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
                                                ON OrderHistory.ItemSKU = DimItemMaster.ItemSKU
                                                   AND DimItemMaster.KeyItem = 1
                                    WHERE
                                            OrderHistory.[OrderDate] >= @MinDate
                                            AND OrderHistory.[CustomerNumber] IN
                                                    (
                                                        SELECT
                                                            PresBillToExceptions.CustomerNumber
                                                        FROM
                                                            Marketing.PresBillToExceptions
                                                    )
                                    GROUP BY
                                            OrderHistory.OrderDate,
                                            OrderHistory.[CustomerNumber],
                                            OrderHistory.[ShiptoNumber],
                                            OrderHistory.[ItemSKU],
                                            OrderHistory.[Quantity]
                                ) t1
                            JOIN
                                [$(MasterData_Warehouse)].MasterData_DW.DimDate_NonRetail
                                    ON t1.OrderDate = DimDate_NonRetail.[DateID]
                        WHERE
                                t1.OrderQuantity <> 0;



            CREATE TABLE Placements_Wrk.tblOrdersDetail
                (
                    [Year]         SMALLINT,
                    [Period]       INT,
                    OrderDate      DATE,
                    CustomerNumber VARCHAR(8),
                    ShiptoNumber   VARCHAR(4),
                    ItemSKU     VARCHAR(15),
                    OrderQuantity  INT
                );


            INSERT INTO Placements_Wrk.tblOrdersDetail
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
                                Placements_Wrk.tblOrders.Year,
                                Placements_Wrk.tblOrders.Period,
                                Placements_Wrk.tblOrders.OrderDate,
                                Placements_Wrk.tblOrders.CustomerNumber,
                                Placements_Wrk.tblOrders.ShiptoNumber,
                                Placements_Wrk.tblOrders.ItemSKU,
                                SUM(Placements_Wrk.tblOrders.OrderQuantity) AS OrderQuantity
                        FROM
                                Placements_Wrk.tblOrders
                            LEFT JOIN
                                Placements.CustItemMonthlyPlacements
                                    ON CustItemMonthlyPlacements.CustomerNumber   = Placements_Wrk.tblOrders.CustomerNumber
                                       AND CustItemMonthlyPlacements.ShiptoNumber  = Placements_Wrk.tblOrders.ShiptoNumber
                                       AND CustItemMonthlyPlacements.ItemSKU  = Placements_Wrk.tblOrders.ItemSKU
                                       AND CustItemMonthlyPlacements.YearMonth = @CurrentYearMonth
                                       AND CustItemMonthlyPlacements.Placement <> 0
                            --AND Current <> 0
                            LEFT JOIN
                                Placements.DailyPlacements
                                    ON DailyPlacements.CustomerNumber      = Placements_Wrk.tblOrders.CustomerNumber
                                       AND DailyPlacements.ShiptoNumber    = Placements_Wrk.tblOrders.ShiptoNumber
                                       AND DailyPlacements.ItemSKU      = Placements_Wrk.tblOrders.ItemSKU
                                       AND DailyPlacements.DateOfPlacement = Placements_Wrk.tblOrders.OrderDate
                        WHERE
                                 CustItemMonthlyPlacements.CustomerNumber IS NULL
                                AND Placements_Wrk.tblOrders.OrderQuantity > 0
                                AND DailyPlacements.CustomerNumber IS NULL
                        GROUP BY
                                Placements_Wrk.tblOrders.Year,
                                Placements_Wrk.tblOrders.Period,
                                Placements_Wrk.tblOrders.OrderDate,
                                Placements_Wrk.tblOrders.CustomerNumber,
                                Placements_Wrk.tblOrders.ShiptoNumber,
                                Placements_Wrk.tblOrders.ItemSKU;
            --ORDER BY CustomerNumber, ShiptoNumber

            INSERT INTO Placements.DailyPlacements
                        SELECT
                            CustomerNumber,
                            ShiptoNumber,
                            ItemSKU,
                            MIN(OrderDate)
                        FROM
                            Placements_Wrk.tblOrdersDetail
                        WHERE
                            OrderQuantity > 0
                        GROUP BY
                            CustomerNumber,
                            ShiptoNumber,
                            ItemSKU;


            DROP TABLE Placements_Wrk.tblOrdersDetail;
            DROP TABLE Placements_Wrk.tblOrders;

            DELETE FROM
            Placements.DailyPlacements
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
            'AFISales_DW', 'Placements', 'DailyPlacements', @String, @DateValue;

    END;