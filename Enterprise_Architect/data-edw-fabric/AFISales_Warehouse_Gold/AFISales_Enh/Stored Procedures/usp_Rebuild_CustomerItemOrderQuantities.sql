CREATE PROC [AFISales_Enh].[usp_Rebuild_CustomerItemOrderQuantities]
AS
    BEGIN
/**********************************************************
*Procedure  Name: usp_Rebuild_CustomerItemOrderQuantities
*Schema: AFISales_Enh
*Business Function : Build pivot off of AFISales
*Author: Andy Steinke - 2021-08-30
*        Refactored logic built by Cameron Wanek
* Bob Horton 10/18/2023 converted to Fabric
*********************************************************/

        DECLARE
            @String    VARCHAR(5000),
            @DateValue DATETIME2(6),
            @User      VARCHAR(500);
      
        SET @String = 'AFISales_DW.AFISales_Enh.usp_Rebuild_CustomerItemOrderQuantities';
        SET @User = SYSTEM_USER;
        SET @DateValue = Getdate()
        SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)

        INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
        VALUES
            (
                @String, @DateValue, @User, 'Process Start'
            );

        BEGIN TRY


            DROP TABLE IF EXISTS AFISales_Enh.CustomerItemOrderQuantities_Load;


            CREATE TABLE AFISales_Enh.CustomerItemOrderQuantities_Load
                (
                    [Item SKU]                  VARCHAR(15) NOT NULL,
                    [Order Number]              VARCHAR(10) NULL,
                    [Warehouse]                 CHAR(3)     NOT NULL,
                    [Account And Shipto Number] VARCHAR(13) NULL,
                    [Customer Account Number]   CHAR(8)     NULL,
                    [Customer Name]             VARCHAR(25) NULL,
                    [Order Type]                VARCHAR(30) NULL,
                    [Country]                   VARCHAR(30) NULL,
                    [Country Code]              VARCHAR(3)  NULL,
                    [State]                     VARCHAR(25) NULL,
                    [State Code]                CHAR(2)     NULL,
                    [ZipCode]                   VARCHAR(10) NULL,
                    [Quantity Type]             VARCHAR(64) NULL,
                    [Quantity]                  DECIMAL(38) NULL,
                    [Date Type]                 VARCHAR(64) NULL,
                    [Date]                      DATE        NULL,
                    [Shipto Address ID]         INT         NULL,
                    [Item Key]                  VARCHAR(22) NOT NULL,
                    [SalesTerritoryID]          BIGINT      NULL,
                    [Item Sequence Number]      DECIMAL(7)  NULL
                );

            DROP TABLE IF EXISTS tempdb..#ord;


            SELECT
                *
            INTO
                #ord
            FROM
                (
                    SELECT
                            O.[Item SKU],
                            O.[Order Number],
                            O.Warehouse,
                            O.[Account And Shipto Number],
                            cus.[Customer Account Number],
                            cus.[Customer Name],
                            O.[Secondary Order Type]                                        AS 'Order Type',
                            geo.Country,
                            geo.[Country Code],
                            geo.[State],
                            geo.[State Code],
                            geo.City,
                            geo.ZipCode,
                            CONVERT(DECIMAL, O.[Open Order Quantity])                       AS 'Quantity #',
                            CONVERT(DECIMAL, O.[Open Order Amount])                         AS 'Amount',
                            CONVERT(DECIMAL, (O.[Open Order Quantity] * IM.Cubes))          AS 'Total Cubes',
                            CONVERT(DECIMAL, ((O.[Open Order Quantity] * IM.Cubes) / 2350)) AS 'Total Containers',
                            CONVERT(DECIMAL, ((O.[Open Order Quantity] * IM.Cubes) / 3300)) AS 'Total Trucks',
                            O.[Order Taken Date]                                            AS 'Date Order Taken',
                            O.[Original Promise Date]                                       AS 'Date Original Promise',
                            O.[Original Request Date]                                       AS 'Date Original Request',
                            O.[Current Promise Date]                                        AS 'Date Current Promise',
                            O.[Current Request Date]                                        AS 'Date Current Request',
                            O.[Current Load Date]                                           AS 'Date Current Load',
                            O.[Shipto Address ID],
                            O.[Item Key],
                            O.[SalesTerritoryID],
                            O.[Item Sequence Number]
                    FROM
                            AFISales_DW.FactOpenOrders         O
                        LEFT JOIN
                            AFISales_DW.DimCustomers           cus
                                ON O.[Account And Shipto Number] = cus.[Account And Shipto Number]
                        LEFT JOIN
                            AFISales_DW.DimGeographicLocations geo
                                ON cus.[Shipto AddressID] = geo.[Address ID]
                        LEFT JOIN
                            [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster        IM
                                ON O.[Item SKU] = IM.ItemSKU
                ) ord;



            DROP TABLE IF EXISTS tempdb..#agg;


            SELECT
                *
            INTO
                #agg
            FROM
                (
                    SELECT
                        ord.[Item SKU],
                        ord.[Order Number],
                        ord.Warehouse,
                        ord.[Account And Shipto Number],
                        ord.[Customer Account Number],
                        ord.[Customer Name],
                        ord.[Order Type],
                        ord.Country,
                        ord.[Country Code],
                        ord.State,
                        ord.[State Code],
                        ord.City,
                        ord.ZipCode,
                        SUM(ord.[Quantity #])       AS [Quantity #],
                        SUM(ord.Amount)             AS Amount,
                        SUM(ord.[Total Cubes])      AS [Total Cubes],
                        SUM(ord.[Total Containers]) AS [Total Containers],
                        SUM(ord.[Total Trucks])     AS [Total Trucks],
                        ord.[Date Order Taken],
                        ord.[Date Original Promise],
                        ord.[Date Original Request],
                        ord.[Date Current Promise],
                        ord.[Date Current Request],
                        ord.[Date Current Load],
                        ord.[Shipto Address ID],
                        ord.[Item Key],
                        ord.[SalesTerritoryID],
                        ord.[Item Sequence Number]
                    FROM
                        #ord ord
                    GROUP BY
                        ord.[Item SKU],
                        ord.[Order Number],
                        ord.Warehouse,
                        ord.[Account And Shipto Number],
                        ord.[Customer Account Number],
                        ord.[Customer Name],
                        ord.[Order Type],
                        ord.Country,
                        ord.[Country Code],
                        ord.State,
                        ord.[State Code],
                        ord.City,
                        ord.ZipCode,
                        ord.[Date Order Taken],
                        ord.[Date Original Promise],
                        ord.[Date Original Request],
                        ord.[Date Current Promise],
                        ord.[Date Current Request],
                        ord.[Date Current Load],
                        ord.[Shipto Address ID],
                        ord.[Item Key],
                        ord.[SalesTerritoryID],
                        ord.[Item Sequence Number]
                ) agg;



            DROP TABLE IF EXISTS tempdb..#fin;


            SELECT
                *
            INTO
                #fin
            FROM
                (
                    SELECT
                        agg.[Item SKU],
                        agg.[Order Number],
                        agg.Warehouse,
                        agg.[Account And Shipto Number],
                        agg.[Customer Account Number],
                        agg.[Customer Name],
                        agg.[Order Type],
                        agg.Country,
                        agg.[Country Code],
                        agg.State,
                        agg.[State Code],
                        agg.City,
                        agg.ZipCode,
                        agg.[Quantity #],
                        agg.Amount AS [Amount $],
                        agg.[Total Cubes],
                        agg.[Total Containers],
                        agg.[Total Trucks],
                        agg.[Date Order Taken],
                        agg.[Shipto Address ID],
                        agg.[Item Key],
                        agg.[SalesTerritoryID],
                        agg.[Item Sequence Number],
                        DATEADD(
                                   wk, 1,
                                   DATEADD(
                                              DAY, 0 - DATEPART(WEEKDAY, agg.[Date Order Taken]),
                                              DATEDIFF(dd, 0, agg.[Date Order Taken])
                                          )
                               )   AS 'Week Order Taken',
                        agg.[Date Original Promise],
                        DATEADD(
                                   wk, 1,
                                   DATEADD(
                                              DAY, 0 - DATEPART(WEEKDAY, agg.[Date Original Promise]),
                                              DATEDIFF(dd, 0, agg.[Date Original Promise])
                                          )
                               )   AS 'Week Original Promise',
                        agg.[Date Original Request],
                        DATEADD(
                                   wk, 1,
                                   DATEADD(
                                              DAY, 0 - DATEPART(WEEKDAY, agg.[Date Original Request]),
                                              DATEDIFF(dd, 0, agg.[Date Original Request])
                                          )
                               )   AS 'Week Original Request',
                        agg.[Date Current Promise],
                        DATEADD(
                                   wk, 1,
                                   DATEADD(
                                              DAY, 0 - DATEPART(WEEKDAY, agg.[Date Current Promise]),
                                              DATEDIFF(dd, 0, agg.[Date Current Promise])
                                          )
                               )   AS 'Week Current Promise',
                        agg.[Date Current Request],
                        DATEADD(
                                   wk, 1,
                                   DATEADD(
                                              DAY, 0 - DATEPART(WEEKDAY, agg.[Date Current Request]),
                                              DATEDIFF(dd, 0, agg.[Date Current Request])
                                          )
                               )   AS 'Week Current Request',
                        agg.[Date Current Load],
                        DATEADD(
                                   wk, 1,
                                   DATEADD(
                                              DAY, 0 - DATEPART(WEEKDAY, agg.[Date Current Load]),
                                              DATEDIFF(dd, 0, agg.[Date Current Load])
                                          )
                               )   AS 'Week Current Load'
                    FROM
                        #agg agg
                ) FIN;



            DROP TABLE IF EXISTS tempdb..#piv;


            SELECT
                *
            INTO
                #piv
            FROM
                (
                    SELECT
                        piv.[Item SKU],
                        piv.[Order Number],
                        piv.[Warehouse],
                        piv.[Account And Shipto Number],
                        piv.[Customer Account Number],
                        piv.[Customer Name],
                        piv.[Order Type],
                        piv.Country,
                        piv.[Country Code],
                        piv.[State],
                        piv.[State Code],
                        piv.ZipCode,
                        piv.[Quantity Type],
                        piv.Quantity,
                        CONVERT(DATE, piv.[Date Order Taken])      AS [Date Order Taken],
                        CONVERT(DATE, piv.[Week Order Taken])      AS [Week Order Taken],
                        CONVERT(DATE, piv.[Date Original Promise]) AS [Date Original Promise],
                        CONVERT(DATE, piv.[Week Original Promise]) AS [Week Original Promise],
                        CONVERT(DATE, piv.[Date Original Request]) AS [Date Original Request],
                        CONVERT(DATE, piv.[Week Original Request]) AS [Week Original Request],
                        CONVERT(DATE, piv.[Date Current Promise])  AS [Date Current Promise],
                        CONVERT(DATE, piv.[Week Current Promise])  AS [Week Current Promise],
                        CONVERT(DATE, piv.[Date Current Request])  AS [Date Current Request],
                        CONVERT(DATE, piv.[Week Current Request])  AS [Week Current Request],
                        CONVERT(DATE, piv.[Date Current Load])     AS [Date Current Load],
                        CONVERT(DATE, piv.[Week Current Load])     AS [Week Current Load],
                        piv.[Shipto Address ID],
                        piv.[Item Key],
                        piv.[SalesTerritoryID],
                        piv.[Item Sequence Number]
                    FROM
                        #fin
                        UNPIVOT
                            (
                                [Quantity]
                                FOR [Quantity Type] IN (
                                                           [Quantity #], [Amount $], [Total Cubes], [Total Containers],
                                                           [Total Trucks]
                                                       )
                            ) piv
                ) a;


            INSERT INTO AFISales_Enh.CustomerItemOrderQuantities_Load
                (
                    [Item SKU],
                    [Order Number],
                    [Warehouse],
                    [Account And Shipto Number],
                    [Customer Account Number],
                    [Customer Name],
                    [Order Type],
                    [Country],
                    [Country Code],
                    [State],
                    [State Code],
                    [ZipCode],
                    [Quantity Type],
                    [Quantity],
                    [Date Type],
                    [Date],
                    [Shipto Address ID],
                    [Item Key],
                    [SalesTerritoryID],
                    [Item Sequence Number]
                )
                        SELECT
                            piv2.[Item SKU],
                            piv2.[Order Number],
                            piv2.Warehouse,
                            piv2.[Account And Shipto Number],
                            piv2.[Customer Account Number],
                            piv2.[Customer Name],
                            piv2.[Order Type],
                            piv2.Country,
                            piv2.[Country Code],
                            piv2.[State],
                            piv2.[State Code],
                            piv2.ZipCode,
                            piv2.[Quantity Type],
                            piv2.Quantity,
                            piv2.[Date Type],
                            piv2.[Date],
                            piv2.[Shipto Address ID],
                            piv2.[Item Key],
                            piv2.[SalesTerritoryID],
                            piv2.[Item Sequence Number]
                        FROM
                            #piv
                            UNPIVOT
                                (
                                    [Date]
                                    FOR [Date Type] IN (
                                                           [Date Order Taken], [Week Order Taken],
                                                           [Date Original Promise], [Week Original Promise],
                                                           [Date Original Request], [Week Original Request],
                                                           [Date Current Promise], [Week Current Promise],
                                                           [Date Current Request], [Week Current Request],
                                                           [Date Current Load], [Week Current Load]
                                                       )
                                ) piv2;


            CREATE STATISTICS stat_CustomerItemOrderQuantities_SurveyEmployeeNumber
                ON [AFISales_Enh].[CustomerItemOrderQuantities_Load]
                (
                    [Order Number]
                );
            CREATE STATISTICS stat_CustomerItemOrderQuantities_UID
                ON [AFISales_Enh].[CustomerItemOrderQuantities_Load]
                (
                    [Item SKU]
                );
            CREATE STATISTICS stat_CustomerItemOrderQuantities_msfp_questionresponseid
                ON [AFISales_Enh].[CustomerItemOrderQuantities_Load]
                (
                    [Date]
                );



            DROP TABLE IF EXISTS
                AFISales_Enh.CustomerItemOrderQuantities;

            EXECUTE sp_rename 'AFISales_Enh.CustomerItemOrderQuantities_Load','CustomerItemOrderQuantities'


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
            'AFISales_DW', 'AFISales_Enh', 'CustomerItemOrderQuantities', @String, @DateValue;

    END;




