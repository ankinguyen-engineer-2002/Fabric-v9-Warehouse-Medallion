CREATE PROC [AFISales_Enh].[usp_Update_OnTimeDeliveryDetail]
AS

    /* Change Control -----------------------------------------------------------------------------------------------------------
* Procedure:[AFISales_Enh].[usp_Update_OnTimeDeliveryDetail]
*
*  Bob Horton 10/24/2023 converted to Fabric
---------------------------------------------------------------------------------------------------------------------------*/

    BEGIN

        DECLARE
            @String    VARCHAR(5000),
            @DateValue DATETIME2(6),
            @User      VARCHAR(500);

        SET @String = 'AFISales_DW.AFISales_Enh.usp_Update_OnTimeDeliveryDetail';
        SET @User = SYSTEM_USER;

        SET @DateValue = Getdate()
          SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)


        INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
        VALUES
            (
                @String, @DateValue, @User, 'Process Start'
            );

        BEGIN TRY

            -- Get previous week StartDate and EndDate

            DECLARE
                @StartPrevWeek DATE,
                @EndPrevWeek   DATE;
            SELECT
                @StartPrevWeek =  DATEADD(DAY, -6,[Fiscal Week Ended]),
                @EndPrevWeek   =  [Fiscal Week Ended]
            FROM 
                AFISales_DW.DimDateFile
            WHERE
                [Transaction Date] = DATEADD(DAY, -7, CAST(@DateValue as DATE));

            SELECT
                @StartPrevWeek,
                @EndPrevWeek;

            -- Aggregate Invoice Detail table

            DROP TABLE IF EXISTS
                AFISales_Wrk.InvoiceDetail_Aggregated;

            CREATE TABLE AFISales_Wrk.InvoiceDetail_Aggregated
                (
                    Warehouse           [CHAR](3)       NULL,
                    TripNumber          [DECIMAL](7, 0) NULL,
                    CustomerNumber      [CHAR](8)       NULL,
                    ShiptoNumber        [CHAR](4)       NULL,
                    ItemSKU             [VARCHAR](15)   NULL,
                    InvoiceDate         [DATE]          NULL,
                    HomeStore           [CHAR](3)       NULL,
                    OrderType           [VARCHAR](30)   NULL,
                    OrderType3          [VARCHAR](30)   NULL,
                    OrderDate           [DATE]          NULL,
                    DeliveryDate        [DATE]          NULL,
                    OriginalPromiseDate [DATE]          NULL,
                    CurrentRequestDate  [DATE]          NULL,
                    FirstScanDate       [DATETIME2] (6)       NULL,
                    TripCreateDate      [DATETIME2] (6)       NULL,
                    TripCloseDate       [DATETIME2] (6)       NULL,
                    CurrentPromiseDate  [DATE]          NULL,
                    OriginalRequestDate [DATE]          NULL,
                    QuantityShipped     INT
                );

            INSERT INTO AFISales_Wrk.InvoiceDetail_Aggregated
                        SELECT
                                [Warehouse],
                                [TripNumber],
                                CustomerNumber,
                                ShiptoNumber,
                                ItemSKU,
                                [InvoiceDate],
                                '' as HomeStore,  -- should swap in a CASE statement using Business Type
                                OrderType,
                                OrderType3,
                                OrderDate,
                                DeliveryDate,
                                OriginalPromiseDate,
                                CurrentRequestDate,
                                FirstScanDate,
                                TripCreateDate,
                                TripCloseDate,
                                CurrentPromiseDate,
                                OriginalRequestDate,
                                SUM(QuantityShipped) AS QuantityShipped
                        FROM
                                [$(Wholesale_Warehouse)].SalesHistory_AFI.[InvoiceDetail]
                        WHERE
                                InvoiceDate
                        BETWEEN @StartPrevWeek AND @EndPrevWeek
                        GROUP BY
                                [Warehouse],
                                [TripNumber],
                                CustomerNumber,
                                ShiptoNumber,
                                ItemSKU,
                                [InvoiceDate],
                                --HomeStore,
                                OrderType,
                                OrderType3,
                                OrderDate,
                                DeliveryDate,
                                OriginalPromiseDate,
                                CurrentRequestDate,
                                FirstScanDate,
                                TripCreateDate,
                                TripCloseDate,
                                CurrentPromiseDate,
                                OriginalRequestDate;

            --select top 100 * from AFISales_Wrk.InvoiceDetail_Aggregated

            -- Building Previous week OnTimeDeliveryDetail

            DROP TABLE IF EXISTS
                AFISales_Wrk.OnTimeDeliveryDetail_LOAD;

            CREATE TABLE [AFISales_Wrk].[OnTimeDeliveryDetail_LOAD]
                (
                    [Week]                     INT             NULL,
                    [Warehouse]                CHAR (3)        NULL,
                    [TripNumber]               DECIMAL (7)     NULL,
                    [CustomerNumber]           CHAR (8)        NOT NULL,
                    [ShiptoNumber]             CHAR (4)        NULL,
                    [ItemSKU]                  VARCHAR (15)    NULL,
                    [Year]                     INT             NULL,
                    [Period]                   INT             NULL,
                    [InvoiceDate]              DATE            NULL,
                    [ItemStatus]               CHAR (1)        NULL,
                    [HomeStore]                CHAR (1)        NULL,
                    [OrderType2]               CHAR (1)        NULL,
                    [ShippedQuantity]          DECIMAL (10, 3) NULL,
                    [OrderToDelivery]          DECIMAL (9, 1)  NULL,
                    [OrgPromToDelivery]        DECIMAL (9, 1)  NULL,
                    [InvoiceToDelivery]        DECIMAL (9, 1)  NULL,
                    [CurReqToDelivery]         DECIMAL (9, 1)  NULL,
                    [FirstScanToTripClose]     DECIMAL (9, 1)  NULL,
                    [TripCloseToDelivery]      DECIMAL (9, 1)  NULL,
                    [OrigReqtoDelivery]        DECIMAL (9, 1)  NULL,
                    [OrderToFirstScan]         DECIMAL (9, 1)  NULL,
                    [TripCreateToTripClose]    DECIMAL (9, 1)  NULL,
                    [TripCreateToFirstScan]    DECIMAL (9, 1)  NULL,
                    [OrdertoTripCreate]        DECIMAL (9, 1)  NULL,
                    [CurPromisetoDelivery]     DECIMAL (9, 1)  NULL,
                    [OrderToOriginalRequest]   DECIMAL (9, 1)  NULL,
                    [QtyOnTimeOrigPromiseDay]  DECIMAL (10, 3) NULL,
                    [QtyOnTimeOrigPromiseWeek] DECIMAL (10, 3) NULL,
                    [QtyOnTimeCurReqDay]       DECIMAL (10, 3) NULL,
                    [QtyOnTimeCurReqWeek]      DECIMAL (10, 3) NULL,
                    [QtyOnTimeOrigReqDay]      DECIMAL (10, 3) NULL,
                    [QtyOnTimeOrigReqWeek]     DECIMAL (10, 3) NULL,
                    [QtyOnTimeCurPromDay]      DECIMAL (10, 3) NULL,
                    [QtyOnTimeCurPromWeek]     DECIMAL (10, 3) NULL,
                    [State]                    CHAR (2)        NULL,
                    [Country]                  CHAR (3)        NULL,
                    [MSA]                      CHAR (5)        NULL,
                    [ItemClass]                CHAR (4)        NULL,
                    [Division]                 CHAR (1)        NULL,
                    [TerritoryCode]            CHAR (5)        NULL,
                    [RouteZone]                CHAR (3)        NULL,
                    [RouteRegion]              CHAR (3)        NULL,
                    [SalesCategory]            CHAR (3)        NULL,
                    [CssRep]                   CHAR (5)        NULL,
                    [BusinessType]             CHAR (2)        NULL,
                    [County]                   CHAR (3)        NULL,
                    [ImportDomestic]           CHAR (1)        NULL,
                    [OrderDate]                DATE            NULL,
                    [DeliveryDate]             DATE            NULL,
                    [OriginalPromiseDate]      DATE            NULL,
                    [CurrentRequestDate]       DATE            NULL,
                    [FirstScanDate]            DATETIME2 (6)   NULL,  -- DATETIME
                    [TripCreateDate]           DATETIME2 (6)   NULL,  -- DATETIME
                    [TripCloseDate]            DATETIME2 (6)   NULL,  -- DATETIME
                    [CurrentPromiseDate]       DATE            NULL,
                    [OriginalRequestDate]      DATE            NULL,
                    [InvoiceDate]              DATE            NULL,
                    [OrderType3]               CHAR (1)        Null
                );

            INSERT INTO [AFISales_Wrk].[OnTimeDeliveryDetail_LOAD]
                (
                    [Week],
                    [Warehouse],
                    [TripNumber],
                    [CustomerNumber],
                    [ShiptoNumber],
                    [ItemSKU],
                    [Year],
                    [Period],
                    [InvoiceDate],
                    [ItemStatus],
                    HomeStore,
                    [OrderType2],
                    [OrderType3],
                    [ShippedQuantity],
                    [OrderToDelivery],
                    [OrgPromToDelivery],
                    [InvoiceToDelivery],
                    [CurReqToDelivery],
                    [FirstScanToTripClose],
                    [TripCloseToDelivery],
                    [OrigReqtoDelivery],
                    [OrderToFirstScan],
                    [TripCreateToTripClose],
                    [TripCreateToFirstScan],
                    [OrdertoTripCreate],
                    [CurPromisetoDelivery],
                    [OrderToOriginalRequest],
                    [QtyOnTimeOrigPromiseDay],
                    [QtyOnTimeOrigPromiseWeek],
                    [QtyOnTimeCurReqDay],
                    [QtyOnTimeCurReqWeek],
                    [QtyOnTimeOrigReqDay],
                    [QtyOnTimeOrigReqWeek],
                    [QtyOnTimeCurPromDay],
                    [QtyOnTimeCurPromWeek],
                    [State],
                    [Country],
                    [MSA],
                    [ItemClass],
                    [Division],
                    [TerritoryCode],
                    [RouteZone],
                    [RouteRegion],
                    [SalesCategory],
                    [CssRep],
                    [BusinessType],
                    [County],
                    [ImportDomestic],
                    OrderDate,
                    DeliveryDate,
                    OriginalPromiseDate,
                    CurrentRequestDate,
                    FirstScanDate,
                    TripCreateDate,
                    TripCloseDate,
                    CurrentPromiseDate,
                    OriginalRequestDate
                )
                        SELECT  DISTINCT
                                InvoiceDate.FiscalWeek,
                                Warehouse,
                                TripNumber,
                                CustomerNumber,
                                ShiptoNumber,
                                ItemSKU,
                                InvoiceDate.[Fiscal Year],
                                InvoiceDate.[Fiscal Month],
                                CONVERT(DATE, InvoiceWeekDate.[Transaction Date])                                   AS InvoiceDate,
                                ISNULL(   CASE
                                              WHEN DimItemMaster.PreviousStatusCode = 'N'
                                                   AND DATEDIFF(m, DimItemMaster.ManufacturingStatusChangeDate, InvoiceWeekDate.[Transaction Date])
                                                   BETWEEN 0 AND 5
                                                  THEN
                                                  'I'
                                              WHEN DimItemMaster.PreviousStatusCode = 'N'
                                                   AND DATEDIFF(m, DimItemMaster.ManufacturingStatusChangeDate, InvoiceWeekDate.[Transaction Date]) < 0
                                                  THEN
                                                  'N'
                                              WHEN DimItemMaster.PreviousStatusCode = ''
                                                   AND DATEDIFF(m, DimItemMaster.ManufacturingStatusChangeDate, InvoiceWeekDate.[Transaction Date]) < 0
                                                  THEN
                                                  ''
                                              ELSE
                                                  DimItemMaster.AFIItemStatus
                                          END, 'Z'
                                      )                                                                    AS [ItemStatus],
                                 '' as HomeStore,  -- should swap in a CASE statement using Business TypeHomeStore,
                                OrderType                                                                  AS OrderType2,
                                OrderType3,
                                QuantityShipped                                                            AS ShippedQuantity,
                                DATEDIFF(HOUR, OrderDate, DeliveryDate) * QuantityShipped                  AS OrderToDelivery,
                                DATEDIFF(HOUR, OriginalPromiseDate, DeliveryDate) * QuantityShipped        AS OrgPromToDelivery,
                                DATEDIFF(HOUR, InvoiceDate, DeliveryDate) * QuantityShipped                AS InvoiceToDelivery,
                                DATEDIFF(HOUR, CurrentRequestDate, DeliveryDate) * QuantityShipped         AS CurReqToDelivery,
                                (DATEDIFF(MINUTE, FirstScanDate, TripCloseDate) / 60.0) * QuantityShipped  AS FirstScanToTripClose,
                                DATEDIFF(HOUR, TripCloseDate, DeliveryDate) * QuantityShipped              AS TripCloseToDelivery,
                                DATEDIFF(HOUR, CurrentRequestDate, DeliveryDate) * QuantityShipped         AS OrigReqtoDelivery,
                                DATEDIFF(HOUR, OrderDate, FirstScanDate) * QuantityShipped                 AS OrderToFirstScan,
                                (DATEDIFF(MINUTE, TripCreateDate, TripCloseDate) / 60.0) * QuantityShipped AS TripCreateToTripClose,
                                (DATEDIFF(MINUTE, TripCreateDate, FirstScanDate) / 60.0) * QuantityShipped AS TripCreateToFirstScan,
                                DATEDIFF(HOUR, OrderDate, TripCreateDate) * QuantityShipped                AS OrderToTripCreate,
                                DATEDIFF(HOUR, CurrentPromiseDate, DeliveryDate) * QuantityShipped         AS CurPromisetoDelivery,
                                DATEDIFF(HOUR, OrderDate, OriginalRequestDate) * QuantityShipped           AS OrderToOriginalRequest,
                                CASE
                                    WHEN DeliveryDate <= OriginalPromiseDate
                                        THEN
                                        QuantityShipped
                                    ELSE
                                        0
                                END                                                                        AS QtyOnTimeOrigPromiseDay,
                                CASE
                                    WHEN CONVERT(INT, DeliveryDate.FiscalWeekYear) = CONVERT(INT, OriPromDate.FiscalWeekYear)
                                        THEN
                                        QuantityShipped
                                    ELSE
                                        0
                                END                                                                        AS QtyOnTimeOrigPromiseWeek,
                                CASE
                                    WHEN DeliveryDate <= CurrentRequestDate
                                        THEN
                                        QuantityShipped
                                    ELSE
                                        0
                                END                                                                        AS QtyOnTimeCurReqDay,
                                CASE
                                    WHEN CONVERT(INT, DeliveryDate.FiscalWeekYear) = CONVERT(INT, CurReqDate.FiscalWeekYear)
                                        THEN
                                        QuantityShipped
                                    ELSE
                                        0
                                END                                                                        AS QtyOnTimeCurReqWeek,
                                CASE
                                    WHEN DeliveryDate <= OriginalRequestDate
                                        THEN
                                        QuantityShipped
                                    ELSE
                                        0
                                END                                                                        AS QtyOnTimeOrigReqDay,
                                CASE
                                    WHEN CONVERT(INT, DeliveryDate.FiscalWeekYear) = CONVERT(INT, OriReqDate.FiscalWeekYear)
                                        THEN
                                        QuantityShipped
                                    ELSE
                                        0
                                END                                                                        AS QtyOnTimeOrigReqWeek,
                                CASE
                                    WHEN DeliveryDate <= CurrentPromiseDate
                                        THEN
                                        QuantityShipped
                                    ELSE
                                        0
                                END                                                                        AS QtyOnTimeCurPromDay,
                                CASE
                                    WHEN CONVERT(INT, DeliveryDate.FiscalWeekYear) = CONVERT(INT, CurPromDate.FiscalWeekYear)
                                        THEN
                                        QuantityShipped
                                    ELSE
                                        0
                                END                                                                        AS QtyOnTimeCurPromWeek,
                                DimGeographicLocations.[State Code]                                                           AS [State],
                                DimGeographicLocations.[Country Code]                                                         [Country],
                                DimGeographicLocations.[Msa Fips Code]                                                        AS [MSA],
                                DimItemMaster.ItemClassCode                                                          AS [ItemClass],
                                DimItemMaster.AFISalesDivisionCode                                                   AS [Division],
                                DimCustomers.[Shipto Sales Territory]                                                AS [Territory],
                                DimCustomers.[Route Zone]                                                            AS [RouteZone],
                                DimCustomers.[Route Region]                                                          AS [RouteRegion],
                                DimItemMaster.AFISalesCategoryCode                                                   AS [SalesCategory],
                                DimCustomers.[Customer Service RepID]                                                AS [CssRep],
                                DimCustomers.[Business Type Code]                                                    AS [BusinessType],
                                DimGeographicLocations.[County Code]                                                          AS [County],
                                DimItemMaster.ImportDomesticCode                                                     AS [ImportDomestic],
                                OrderDate,
                                DeliveryDate,
                                OriginalPromiseDate,
                                CurrentRequestDate,
                                FirstScanDate,
                                TripCreateDate,
                                TripCloseDate,
                                CurrentPromiseDate,
                                OriginalRequestDate
                        FROM
                                AFISales_Wrk.InvoiceDetail_Aggregated
                            JOIN
                                AFISales_DW.DimItemMaster 
                                    ON InvoiceDetail_Aggregated.ItemSKU = DimItemMaster.ItemSKU
                            JOIN
                                AFISales_DW.DimCustomers                              
                                    ON InvoiceDetail_Aggregated.ShiptoNumber = DimCustomers.[Customer Shipto Number]
                                       AND InvoiceDetail_Aggregated.CustomerNumber = DimCustomers.[Customer Account Number]
                            JOIN
                                AFISales_DW.DimGeographicLocations                    
                                    ON DimGeographicLocations.[Address ID] = DimCustomers.[Shipto AddressID]
                            LEFT JOIN
                                AFISales_DW.DimDateFile OriPromDate
                                    ON OriPromDate.[Transaction Date] = InvoiceDetail_Aggregated.OriginalPromiseDate
                            LEFT JOIN
                                AFISales_DW.DimDateFile CurPromDate
                                    ON CurPromDate.[Transaction Date] = InvoiceDetail_Aggregated.CurrentPromiseDate
                            LEFT JOIN
                                AFISales_DW.DimDateFile OriReqDate
                                    ON OriReqDate.[Transaction Date] = InvoiceDetail_Aggregated.OriginalRequestDate
                            LEFT JOIN
                                AFISales_DW.DimDateFile CurReqDate
                                    ON CurReqDate.[Transaction Date] = InvoiceDetail_Aggregated.CurrentRequestDate
                            LEFT JOIN
                                AFISales_DW.DimDateFile DeliveryDate
                                    ON DeliveryDate.[Transaction Date] = InvoiceDetail_Aggregated.DeliveryDate
                            LEFT JOIN
                                AFISales_DW.DimDateFile InvoiceDate
                                    ON InvoiceDate.[Transaction Date] = InvoiceDetail_Aggregated.InvoiceDate
                            LEFT JOIN
                                AFISales_DW.DimDateFile InvoiceWeekDate
                                    ON InvoiceWeekDate.[Fiscal Year] = InvoiceDate.[Fiscal Year]
                                       AND InvoiceWeekDate.[Fiscal Month] = InvoiceDate.[Fiscal Month]
                                       AND InvoiceWeekDate.[Fiscal Week] = InvoiceDate.[Fiscal Week]
                                       AND DATEPART(dw, InvoiceWeekDate.[Transaction Date]) = 7;

            -- Delete records in the curated table where the Year and Week match 

            DELETE FROM
            AFISales_Enh.OnTimeDeliveryDetail
            WHERE
                EXISTS
                (
                    SELECT DISTINCT
                           Year,
                           Week
                    FROM
                           AFISales_Wrk.OnTimeDeliveryDetail_LOAD wt
                    WHERE
                           AFISales_Enh.OnTimeDeliveryDetail.Year = wt.Year
                           AND AFISales_Enh.OnTimeDeliveryDetail.Week = wt.Week
                );

            -- Final Insert

            INSERT INTO AFISales_Enh.OnTimeDeliveryDetail
                (
                    [Week],
                    [Warehouse],
                    [TripNumber],
                    [CustomerNumber],
                    [ShiptoNumber],
                    [ItemSKU],
                    [Year],
                    [Period],
                    [InvoiceDate], 
                    [ItemStatus],
                    [HomeStore],
                    [OrderType2],
                    [OrderType3],
                    [ShippedQuantity],
                    [OrderToDelivery],
                    [OrgPromToDelivery],
                    [InvoiceToDelivery],
                    [CurReqToDelivery],
                    [FirstScanToTripClose],
                    [TripCloseToDelivery],
                    [OrigReqtoDelivery],
                    [OrderToFirstScan],
                    [TripCreateToTripClose],
                    [TripCreateToFirstScan],
                    [OrdertoTripCreate],
                    [CurPromisetoDelivery],
                    [OrderToOriginalRequest],
                    [QtyOnTimeOrigPromiseDay],
                    [QtyOnTimeOrigPromiseWeek],
                    [QtyOnTimeCurReqDay],
                    [QtyOnTimeCurReqWeek],
                    [QtyOnTimeOrigReqDay],
                    [QtyOnTimeOrigReqWeek],
                    [QtyOnTimeCurPromDay],
                    [QtyOnTimeCurPromWeek],
                    [State],
                    [Country],
                    [MSA],
                    [ItemClass],
                    [Division],
                    [TerritoryCode],
                    [RouteZone],
                    [RouteRegion],
                    [SalesCategory],
                    [CssRep],
                    [BusinessType],
                    [County],
                    [ImportDomestic],
                    OrderDate,
                    DeliveryDate,
                    OriginalPromiseDate,
                    CurrentRequestDate,
                    FirstScanDate,
                    TripCreateDate,
                    TripCloseDate,
                    CurrentPromiseDate,
                    OriginalRequestDate
                )
                        SELECT
                            [Week],
                            [Warehouse],
                            [TripNumber],
                            [CustomerNumber],
                            [ShiptoNumber],
                            [ItemSKU],
                            [Year],
                            [Period],
                            [InvoiceDate],
                            [ItemStatus],
                             '' as HomeStore,  -- should swap in a CASE statement using Business Type  [HomeStore],
                            [OrderType2],
                            [OrderType3],
                            [ShippedQuantity],
                            [OrderToDelivery],
                            [OrgPromToDelivery],
                            [InvoiceToDelivery],
                            [CurReqToDelivery],
                            [FirstScanToTripClose],
                            [TripCloseToDelivery],
                            [OrigReqtoDelivery],
                            [OrderToFirstScan],
                            [TripCreateToTripClose],
                            [TripCreateToFirstScan],
                            [OrdertoTripCreate],
                            [CurPromisetoDelivery],
                            [OrderToOriginalRequest],
                            [QtyOnTimeOrigPromiseDay],
                            [QtyOnTimeOrigPromiseWeek],
                            [QtyOnTimeCurReqDay],
                            [QtyOnTimeCurReqWeek],
                            [QtyOnTimeOrigReqDay],
                            [QtyOnTimeOrigReqWeek],
                            [QtyOnTimeCurPromDay],
                            [QtyOnTimeCurPromWeek],
                            [State],
                            [Country],
                            [MSA],
                            [ItemClass],
                            [Division],
                            [TerritoryCode],
                            [RouteZone],
                            [RouteRegion],
                            [SalesCategory],
                            [CssRep],
                            [BusinessType],
                            [County],
                            [ImportDomestic],
                            OrderDate,
                            DeliveryDate,
                            OriginalPromiseDate,
                            CurrentRequestDate,
                            FirstScanDate,
                            TripCreateDate,
                            TripCloseDate,
                            CurrentPromiseDate,
                            OriginalRequestDate
                        FROM
                            [AFISales_Wrk].[OnTimeDeliveryDetail_LOAD];


            DROP TABLE IF EXISTS
                AFISales_Wrk.OnTimeDeliveryDetail_LOAD;

            DROP TABLE IF EXISTS
                AFISales_Wrk.InvoiceDetail_Aggregated;


            SET @DateValue = GETDATE();

            SET @DateValue
                = DATEADD(
                             hh,
                             CASE
                                 WHEN @DateValue >= '3/'
                                                    + CAST(ABS(8
                                                               - DATEPART(
                                                                             dw,
                                                                             '3/1/' + CAST(YEAR(@DateValue) AS VARCHAR)
                                                                         )
                                                              ) % 7 + 8 AS VARCHAR) + '/'
                                                    + CAST(YEAR(@DateValue) AS VARCHAR) + ' 2:00'
                                      AND @DateValue < '11/'
                                                       + CAST(ABS(8
                                                                  - DATEPART(
                                                                                dw,
                                                                                '11/1/'
                                                                                + CAST(YEAR(@DateValue) AS VARCHAR)
                                                                            )
                                                                 ) % 7 + 1 AS VARCHAR) + '/'
                                                       + CAST(YEAR(@DateValue) AS VARCHAR) + ' 2:00'
                                     THEN
                                     -5
                                 ELSE
                                     -6
                             END, @DateValue
                         );


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
            'AFISales_DW', 'AFISales_Enh', 'OnTimeDeliveryDetail', @String, @DateValue;
                        
    END;
GO


