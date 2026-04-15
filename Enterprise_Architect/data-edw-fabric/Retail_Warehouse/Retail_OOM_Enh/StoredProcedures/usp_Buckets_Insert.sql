CREATE   PROCEDURE [Retail_OOM_Enh].usp_Buckets_Insert
AS
BEGIN

    --// AUDIT LOGGING START //--

    DECLARE @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
            @DestinationDatabase VARCHAR(150),
            @DestinationSchema VARCHAR(150),
            @DestinationTable VARCHAR(150);

    SET @String = 'Retail_OOM_Enh.usp_Buckets_Insert';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE();
    SET @DestinationDatabase = 'Retail_Warehouse';
    SET @DestinationSchema = 'Retail_OOM_Enh';
    SET @DestinationTable = 'Buckets';

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

        DROP TABLE IF EXISTS #BucketInv;
        DROP TABLE IF EXISTS #BucketOrderItem;
        DROP TABLE IF EXISTS #BucketPOI;

        --INSERT INTO tdg.wrk_BucketInv (StoreID, ProductID, QtyOnHand, TotalCost, QtyCommitted, PieceStatusID, ProductTypeID, GroupID, TransDate, DateChanged)
        SELECT  StoreID,
                p.ProductID,
                p.QtyOnHand,
                p.TotalCost,
                COALESCE(p.QtyCommitted, 0) + COALESCE(p.QtySoftCommitted, 0) AS QtyCommitted,
                p.PieceStatusID,
                p.ProductTypeID,
                p.GroupID,
                p.TransDate,
                COALESCE(p.DateChanged, p.DateCreated) AS DateChanged
        INTO #BucketInv
        FROM [$(Source_Data)].[Retail_Corporate].[ProductInventory] p
        WHERE TransDate >= @TransDate;

        INSERT INTO [Retail_OOM_Enh].[Buckets]
        (
            LocationID,
            ProductID,
            QtyOnHand,
            ProcessStatus
        )
        SELECT  StoreID,
                ProductID,
                QOH,
                0 AS ProcessStatus
        FROM
        (
            SELECT  StoreID,
                    ProductID,
                    SUM(QtyOnHand) AS QOH
            FROM #BucketInv ph
            WHERE TransDate = @TransDate
                  AND PieceStatusID < 3
                  AND ProductTypeID = '1'
                  AND GroupID NOT IN ('MST', 'SVT')
                  AND ph.StoreID IS NOT NULL
            GROUP BY StoreID,
                     ProductID
        ) oh
        WHERE ProductID NOT IN
        (
            SELECT ProductID FROM [Retail_OOM_Enh].[Buckets] b WHERE b.LocationID = oh.StoreID
        );


        SELECT  oi.OrderID,
                oi.ItemID,
                o.OrderBookedStoreID AS BookedStoreID,
                oi.ShipLocnID,
                oi.ProductID,
                oi.DlvyDate,
                oi.TransCodeID,
                oi.QtyOrdered,
                oi.QtyCommitted,
                oi.AutoFillDays,
                oi.PurchaseOrderID,
                oi.POLineID,
                COALESCE(oi.SpecOrderFlg, 0) AS SpecOrderFlg,
                o.OrderDate,
                o.CustomerID,
                oi.DlvyStatus,
                oi.DlvyTypeCodeID,
                oi.ProductTypeID,
                oi.AutoTransCodeID,
                oi.VendorID,
                COALESCE(oi.DateChanged, oi.DateCreated) AS DateChanged,
                oi.GroupID
        INTO #BucketOrderItem
        FROM [$(Source_Data)].[Retail_Corporate].[OrderItem] oi
            INNER JOIN [$(Source_Data)].[Retail_Corporate].[Orders] o
                ON o.OrderID = oi.OrderID
        WHERE (oi.RecStatus <> 'D' OR COALESCE(oi.DateChanged, oi.DateCreated) > @TransDate);

        INSERT INTO [Retail_OOM_Enh].[Buckets]
        (
            LocationID,
            ProductID,
            QtyOnHand,
            ProcessStatus
        )
        SELECT  ShipLocnID,
                oi.ProductID,
                0 AS QOH,
                0 AS ProcessStatus
        FROM #BucketOrderItem oi
            LEFT OUTER JOIN [Retail_OOM_Enh].[Buckets] b
                ON oi.ProductID = b.ProductID
                   AND oi.ShipLocnID = b.LocationID
        WHERE ProductTypeID = '1'
              AND oi.GroupID NOT IN ('MST', 'SVT')
              AND DlvyDate IS NOT NULL
              AND (oi.AutoTransCodeID IS NULL OR oi.AutoTransCodeID <> 1)
              AND oi.ShipLocnID IS NOT NULL
        GROUP BY oi.ShipLocnID,
                 oi.ProductID;

        SELECT  poi.PurchaseOrderID,
                poi.LineID,
                po.StoreID,
                poi.ProductID,
                poi.DlvyDate,
                po.RequestDate,
                poi.QtyOrdered - poi.QtyReceived AS Qty,
                poi.VendorID,
                po.PurchaseOrderTypeID,
                COALESCE(poi.DateChanged, poi.DateCreated) AS DateChanged,
                poi.GroupID
        INTO #BucketPOI
        FROM [$(Source_Data)].[Retail_Corporate].[PurchaseOrderItem] AS poi
            INNER JOIN [$(Source_Data)].[Retail_Corporate].[PurchaseOrder] AS po
                ON poi.PurchaseOrderID = po.PurchaseOrderID
        WHERE poi.QtyOrdered - poi.QtyReceived > 0
              OR COALESCE(poi.DateChanged, poi.DateCreated) > @TransDate;

        INSERT INTO [Retail_OOM_Enh].[Buckets]
        (
            LocationID,
            ProductID,
            QtyOnHand,
            ProcessStatus
        )
        SELECT  oi.StoreID,
                oi.ProductID,
                0 QOH,
                0 AS ProcessStatus
        FROM #BucketPOI AS oi
            LEFT OUTER JOIN [Retail_OOM_Enh].[Buckets] b
                ON oi.ProductID = b.ProductID
                   AND oi.StoreID = b.LocationID
        WHERE oi.GroupID NOT IN ('MST', 'SVT')
              AND oi.StoreID IS NOT NULL
        GROUP BY oi.StoreID,
                 oi.ProductID;

        INSERT INTO [Retail_OOM_Enh].[Buckets]
        (
            LocationID,
            ProductID,
            QtyOnHand,
            ProcessStatus
        )
        SELECT  slp.ShipToLocationID,
                p.ProductID,
                0 QOH,
                0 AS ProcessStatus
        FROM [$(Source_Data)].[Retail_Corporate].[Product] AS p
            INNER JOIN [$(Source_Data)].[Retail_External].[stocklocationproducts] AS slp
                ON p.ProductID = slp.ProductID
        WHERE p.ProductTypeID = 1
              AND p.ObsoleteID = 'A'
              AND p.KitStatusID = 'N'
              AND GroupID NOT IN ('MST', 'SVT')
              AND NOT EXISTS
        (
            SELECT b.LocationID
            FROM [Retail_OOM_Enh].[Buckets] AS b
            WHERE b.ProductID = slp.ProductID AND b.LocationID = slp.ShipToLocationID
        )
        GROUP BY p.ProductID,
                 slp.ShipToLocationID;

        INSERT INTO [Retail_OOM_Enh].BucketOrders
        (
            OrderID,
            ItemID,
            OrderType,
            StoreID,
            LocationID,
            ProductID,
            TransDate,
            TransCodeID,
            Qty,
            QtyCommitted,
            BucketID,
            PeriodID,
            AutoFillDays,
            PurchaseOrderID,
            PurchaseOrderItemID,
            SpecialOrder,
            QtyInStock
        )
        SELECT  oi.OrderID,
                oi.ItemID,
                'D' OrderType,
                oi.BookedStoreID,
                oi.ShipLocnID,
                oi.ProductID,
                CASE WHEN oi.DlvyDate < @TransDate THEN @TransDate ELSE oi.DlvyDate END,
                oi.TransCodeID,
                oi.QtyOrdered,
                CASE WHEN (oi.SpecOrderFlg = 1 OR oi.TransCodeID = 1) THEN oi.QtyOrdered ELSE oi.QtyCommitted END,
                BucketID,
                CASE WHEN oi.DlvyDate < @TransDate THEN @TransDate ELSE oi.DlvyDate END,
                oi.AutoFillDays,
                oi.PurchaseOrderID,
                oi.POLineID,
                COALESCE(oi.SpecOrderFlg, 0) AS SpecOrderFlg,
                0 AS qis
        FROM #BucketOrderItem oi
            INNER JOIN [Retail_OOM_Enh].[Buckets] b
                ON oi.ProductID = b.ProductID
                   AND oi.ShipLocnID = b.LocationID
        WHERE oi.ProductTypeID = '1'
              AND oi.TransCodeID IN (0, 1, 7, 60, 63, 67)
              AND oi.DlvyStatus NOT IN ('CWC', 'ASAP')
              AND ProcessStatus = 0
              AND DlvyDate IS NOT NULL
              AND (oi.AutoTransCodeID IS NULL OR oi.AutoTransCodeID <> 1);


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