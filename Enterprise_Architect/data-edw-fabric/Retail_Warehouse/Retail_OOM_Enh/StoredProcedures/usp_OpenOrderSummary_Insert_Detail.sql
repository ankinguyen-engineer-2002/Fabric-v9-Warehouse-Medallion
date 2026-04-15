CREATE   PROCEDURE Retail_OOM_Enh.[usp_OpenOrderSummary_Insert_Detail]
AS
BEGIN

    --// AUDIT LOGGING START //--

    DECLARE @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
            @DestinationDatabase VARCHAR(150),
            @DestinationSchema VARCHAR(150),
            @DestinationTable VARCHAR(150);

    SET @String = 'Retail_OOM_Enh.usp_OpenOrderSummary_Insert_Detail';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE();
    SET @DestinationDatabase = 'Retail_Warehouse';
    SET @DestinationSchema = 'Retail_OOM_Enh';
    SET @DestinationTable = 'OpenOrderSummaryDetail';

    SELECT @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    --// AUDIT LOGGING END //--

    BEGIN TRY

        DECLARE @TransDate DATE = GETDATE();

        DELETE FROM Retail_OOM_Enh.[OpenOrderSummaryDetail];

        SELECT  o.OrderID,
                o.OrderDate,
                ofu.OrderFulfillmentID,
                o.OrderBookedStoreID AS StoreID,
                oi.ShipLocnID AS ShipLocationID,
                tc.Description AS OrderType,
                ofu.FulfillmentMethod,
                ofu.FulfillmentStatus,
                ofu.FulfillmentDate,
                NULL AS ContactStatus,
                ofu.DeliveryContactDate AS ContactDate,
                CASE WHEN ofu.FulfillmentDate < CAST(GETDATE() AS DATE) THEN 'Y' ELSE 'N' END AS PastDue,
                o.CustomerID,
                MAX(ofu.MerchSubTot) AS MerchSubTot,
                (
                    SELECT SUM(TaxAmt)
                    FROM [$(Source_Data)].[Retail_Corporate].[OrderFulfillment_TaxDetail] ft
                    WHERE ft.OrderFulfillmentID = ofu.OrderFulfillmentID
                ) fTaxAmt,
                COUNT(DISTINCT ofu.OrderFulfillmentID) AS TotalFulfilment,
                SUM(oi.QtyOrdered) AS QtyOrdered,
                SUM(CASE WHEN o.TransCodeID IN (30, 34, 37) THEN oi.QtyOrdered ELSE oi.QtyCommitted END) AS QtyCommitted,
                MAX(DISTINCT ofu.DlvyChrg) AS DlvyChrg,
                SUM(oi.TotCost * oi.QtyOrdered) AS TotalCost,
                SUM(oi.TotCost * CASE WHEN o.TransCodeID IN (30, 34, 37) THEN oi.QtyOrdered ELSE oi.QtyCommitted END) AS ReservedCost,
                SUM(oi.CaseSellingPrice * oi.QtyOrdered) AS TotalSales,
                SUM(oi.CaseSellingPrice * CASE WHEN o.TransCodeID IN (30, 34, 37) THEN oi.QtyOrdered ELSE oi.QtyCommitted END) AS ReservedSales,
                SUM(p.CubicFeet * oi.QtyOrdered) AS TotalVolume,
                SUM(p.CubicFeet * CASE WHEN o.TransCodeID IN (30, 34, 37) THEN oi.QtyOrdered ELSE oi.QtyCommitted END) AS ReservedVolume,
                SUM(p.CaseWeight * oi.QtyOrdered) AS TotalWeight,
                SUM(p.CaseWeight * CASE WHEN o.TransCodeID IN (30, 31) THEN oi.QtyOrdered ELSE oi.QtyCommitted END) AS ReservedWeight,
                CASE WHEN SUM(oi.QtyOrdered) - SUM(CASE WHEN o.TransCodeID IN (30, 34, 37) THEN oi.QtyOrdered ELSE oi.QtyCommitted END) = 0 THEN 'Y' ELSE 'N' END AS Filled
        INTO #OOM
        FROM [$(Source_Data)].[Retail_Corporate].[Orders] AS o
            INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderItem] AS oi
                ON oi.OrderID = o.OrderID
            INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderFulfillment] AS ofu
                ON ofu.OrderFulfillmentID = oi.OrderFulfillmentID
            INNER JOIN [$(Source_Data)].[Retail_Corporate].[TransCode] AS tc
                ON tc.TransCodeID = o.TransCodeID
            INNER JOIN [$(Source_Data)].[Retail_Corporate].[Product] AS p
                ON p.ProductID = oi.ProductID
        WHERE tc.TransCodeID IN (0, 1, 3, 6, 7, 30, 34, 37)
        GROUP BY o.OrderID,
                 o.OrderDate,
                 ofu.OrderFulfillmentID,
                 o.OrderBookedStoreID,
                 CASE WHEN ofu.FulfillmentDate < CAST(GETDATE() AS DATE) THEN 'Y' ELSE 'N' END,
                 oi.ShipLocnID,
                 tc.Description,
                 ofu.FulfillmentMethod,
                 ofu.FulfillmentStatus,
                 ofu.FulfillmentDate,
                 ofu.DeliveryContactDate,
                 o.CustomerID;

        INSERT INTO Retail_OOM_Enh.[OpenOrderSummaryDetail]
        (
            BODTransDate,
            OrderID,
            OrderDate,
            StoreID,
            ShipLocationID,
            OrderType,
            FulfillmentMethod,
            FulfillmentStatus,
            ContactStatus,
            ContactDate,
            FulfillmentDate,
            PastDue,
            Filled,
            CustomerID,
            CustomerName,
            SalesPerson,
            MerchSubTot,
            TaxAmt,
            DlvyChrg,
            TotalFulfilment,
            TotalPieces,
            ReservedPieces,
            TotalCost,
            ReservedCost,
            TotalSales,
            ReservedSales,
            TotalVolume,
            ReservedVolume,
            TotalWeight,
            ReservedWeight
        )
        SELECT  @TransDate AS BODTransDate,
                o.OrderID,
                o.OrderDate,
                o.StoreID,
                o.ShipLocationID,
                o.OrderType,
                o.FulfillmentMethod,
                o.FulfillmentStatus,
                o.ContactStatus,
                o.ContactDate,
                FulfillmentDate,
                o.PastDue,
                o.Filled,
                o.CustomerID,
                (
                    SELECT TOP 1 FullName
                    FROM [$(Source_Data)].[Retail_Corporate].[Customer]
                    WHERE CustomerID = o.CustomerID
                ) CustomerName,
                (
                    SELECT TOP 1 ISNULL(s.Name, c.SalesPersonID)
                    FROM [$(Source_Data)].[Retail_Corporate].[OrderItem_CommissionInfo] c
                        INNER JOIN [$(Source_Data)].[Retail_Corporate].[Salesperson] s
                            ON S.SalespersonID = C.SalesPersonID
                    WHERE c.OrderID = o.OrderID
                          AND c.RecStatus <> 'D'
                          AND c.SplitPct =
                          (
                              SELECT MAX(c2.SplitPct)
                              FROM [$(Source_Data)].[Retail_Corporate].[OrderItem_CommissionInfo] c2
                              WHERE c2.OrderID = o.OrderID AND c2.RecStatus <> 'D'
                          )
                ) SalesPerson,
                (o.MerchSubTot) AS MerchSubTot,
                fTaxAmt,
                (o.DlvyChrg) AS DlvyChrg,
                (o.TotalFulfilment) AS TotalFulfilment,
                (o.QtyOrdered) AS TotalPieces,
                (o.QtyCommitted) AS ReservedPieces,
                (o.TotalCost) AS TotalCost,
                (o.ReservedCost) AS ReservedCost,
                (o.TotalSales) AS TotalSales,
                (o.ReservedSales) AS ReservedSales,
                (o.TotalVolume) AS TotalVolume,
                (o.ReservedVolume) AS ReservedVolume,
                (o.TotalWeight) AS TotalWeight,
                (o.ReservedWeight) AS ReservedWeight
        FROM #OOM AS o;

        DROP TABLE #OOM;

        --// AUDIT LOGGING START //--

        SET @DateValue = GETDATE();

        SELECT @DateValue = CSTDateValue
        FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

        INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
        VALUES
        (
            @String, @DateValue, @User, 'Process Complete'
        );

        --- Update last modified in Table Dictionary
        DECLARE @Exists INT;
        SET @Exists =
        (
            SELECT COUNT(*)
            FROM [$(ETL_Framework)].[DW_Developer].[TableDictionary]
            WHERE DatabaseName = @DestinationDatabase
                  AND SchemaName = @DestinationSchema
                  AND TableName = @DestinationTable
        );

        IF @Exists = 0
        BEGIN
            INSERT INTO [$(ETL_Framework)].[DW_Developer].[TableDictionary]
            (
                ServerName,
                DatabaseName,
                SchemaName,
                TableName,
                ObjectType,
                StorageType,
                UpdateQuery
            )
            VALUES
            (
                'EDW-Fabric', @DestinationDatabase, @DestinationSchema, @DestinationTable, 'Table', 'Delta', @String
            );
        END;

        UPDATE [$(ETL_Framework)].[DW_Developer].[TableDictionary]
        SET Modified = @DateValue
        WHERE DatabaseName = @DestinationDatabase
              AND SchemaName = @DestinationSchema
              AND TableName = @DestinationTable;

        INSERT INTO [$(ETL_Framework)].[DW_Developer].[TableDictionary_UpdateLog]
        VALUES
        (
            @DestinationDatabase, @DestinationSchema, @DestinationTable, @DateValue
        );

        --// AUDIT LOGGING END //--

    END TRY
    BEGIN CATCH

        --// ERROR LOGGING START //--

        DECLARE @ErrorMessage VARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState INT;

        SET @ErrorMessage = ERROR_MESSAGE();
        SET @ErrorSeverity = ISNULL(ERROR_SEVERITY(), 16);
        SET @ErrorState = ISNULL(ERROR_STATE(), 0);
        SET @DateValue = GETDATE();

        SELECT @DateValue = CSTDateValue
        FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

        INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
        VALUES
        (
            @String, @DateValue, @User, @ErrorMessage
        );

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

        --// ERROR LOGGING END //--

    END CATCH;

END;