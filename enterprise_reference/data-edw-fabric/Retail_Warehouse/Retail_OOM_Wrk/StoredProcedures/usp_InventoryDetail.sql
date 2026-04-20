CREATE   PROCEDURE [Retail_OOM_Wrk].[usp_InventoryDetail]
AS
BEGIN

    --// AUDIT LOGGING START //--

    DECLARE @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
            @DestinationDatabase VARCHAR(150),
            @DestinationSchema VARCHAR(150),
            @DestinationTable VARCHAR(150);

    SET @String = 'Retail_OOM_Wrk.usp_InventoryDetail';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE();
    SET @DestinationDatabase = 'Retail_Warehouse';
    SET @DestinationSchema = 'Retail_OOM_Wrk';
    SET @DestinationTable = 'PieceInventory_Surplus';

    SELECT @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    --// AUDIT LOGGING END //--

    BEGIN TRY

        --Update Store Values

        WITH temp
        AS
        (
            SELECT  ProductID,
                    StoreID,
                    SUM(QtyOnHand) AS Qty
            FROM [Retail_OOM_Wrk].[PieceInventory]
            WHERE ReasonCodeID = 'FLR'
            GROUP BY ProductID,
                     StoreID
        )
        UPDATE id
        SET QtyOnFloor = Qty
        FROM [Retail_OOM_Wrk].[PieceInventory_Surplus] id
            INNER JOIN temp
                ON temp.ProductID = id.ProductID
                   AND temp.StoreID = id.StoreID;

        --Update WH values

        WITH temp
        AS
        (
            SELECT  SUM(pi.QtyOnHand) AS Qty,
                    pi.ProductID,
                    m.MapToLocationID
            FROM [Retail_OOM_Wrk].[TurnsLocationMap] m
                INNER JOIN [Retail_OOM_Wrk].[PieceInventory] pi
                    ON m.LocationID = pi.StoreID
                       AND m.StoreBrandID = pi.StoreBrandID
            WHERE m.MapType = 2 AND pi.ReasonCodeID = 'FLR'
            GROUP BY pi.ProductID,
                     m.MapToLocationID
        )
        MERGE [Retail_OOM_Wrk].[PieceInventory_Surplus] id
        USING temp
        ON temp.ProductID = id.ProductID AND temp.MapToLocationID = id.StoreID
        WHEN MATCHED THEN
            UPDATE SET id.QtyOnFloor = temp.Qty
        WHEN NOT MATCHED THEN
            INSERT
            (
                ProductID,
                StoreID,
                TBOnHand,
                QtyOnFloor
            )
            VALUES
            (temp.ProductID, temp.MapToLocationID, 0, temp.Qty);

        --Update backorder values

        WITH temp
        AS
        (
            SELECT  ProductID,
                    t.MapToLocationID,
                    SUM(QtyOrdered) - SUM(QtyCommitted) AS Qty
            FROM [$(Source_Data)].[Retail_Corporate].[OrderItem] o
                INNER JOIN [Retail_OOM_Wrk].[TurnsLocationMap] t
                    ON t.LocationID = StoreID
            WHERE t.MapType = 3 AND TransCodeID NOT IN (30, 31)
            GROUP BY ProductID,
                     t.MapToLocationID
        )
        UPDATE id
        SET Backordered = Qty
        FROM [Retail_OOM_Wrk].[PieceInventory_Surplus] id
            INNER JOIN temp
                ON temp.ProductID = id.ProductID
                   AND temp.MapToLocationID = id.StoreID;

        WITH temp2
        AS
        (
            SELECT  o.ProductID,
                    t.MapToLocationID,
                    SUM(QtyOrdered) - SUM(QtyCommitted) AS Qty
            FROM [$(Source_Data)].[Retail_Corporate].[OrderItem] o
                INNER JOIN [$(Source_Data)].[Retail_Corporate].[Product]
                    ON Product.ProductID = o.ProductID
                INNER JOIN [Retail_OOM_Wrk].[TurnsLocationMap] t
                    ON t.LocationID = StoreID
            WHERE t.MapType = 3 AND Status = 'MFR-DISCO'
            GROUP BY o.ProductID,
                     t.MapToLocationID
        )
        UPDATE id
        SET BackorderedDespisedMCode = Qty
        FROM [Retail_OOM_Wrk].[PieceInventory_Surplus] id
            INNER JOIN temp2
                ON temp2.ProductID = id.ProductID
                   AND temp2.MapToLocationID = id.StoreID;

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
        Exec [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase,@DestinationSchema,@DestinationTable

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