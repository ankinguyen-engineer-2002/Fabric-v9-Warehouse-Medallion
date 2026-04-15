CREATE   PROCEDURE [Retail_OOM_Wrk].[usp_PieceInventory_OISoftCommitted] @TransDate DATETIME
AS
BEGIN

    SET NOCOUNT ON;

    --// AUDIT LOGGING START //--

    DECLARE @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
            @DestinationDatabase VARCHAR(150),
            @DestinationSchema VARCHAR(150),
            @DestinationTable VARCHAR(150);

    SET @String = 'Retail_OOM_wrk.usp_PieceInventory_OISoftCommitted';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE();
    SET @DestinationDatabase = 'Retail_Warehouse';
    SET @DestinationSchema = 'Retail_OOM_Wrk';
    SET @DestinationTable = 'PieceInventory';

    SELECT @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    --// AUDIT LOGGING END //--

    BEGIN TRY

        WITH CommittedOrders
        AS
        (
            SELECT  '01' AS SourceID,
                    oi.LocationID AS StoreID,
                    oi.ProductID,
                    oi.OrderID,
                    oi.ItemID,
                    oi.QtyCommitted AS TotalCommitted
            FROM [Retail_OOM_Enh].[BucketOrders] AS oi
                INNER JOIN [$(Source_Data)].[Retail_Corporate].[Product] AS p
                    ON oi.ProductID = p.ProductID
            WHERE oi.OrderType = 'D'
                  AND p.ProductTypeID = '1'
                  AND p.SpecialOrder = 0
                  AND oi.QtyCommitted <> 0 and oi.TransDate = @TransDate
        ),
        HardCommitted
        AS
        (
            SELECT  ProductID,
                    StoreID,
                    OrderID,
                    ItemID,
                    SUM(QtyCommitted) AS HardCommitted
            FROM [Retail_OOM_Wrk].[PieceInventory]
            WHERE TransDate = @TransDate
                  AND OrderID IS NOT NULL
                  AND ItemID IS NOT NULL
            GROUP BY ProductID,
                     StoreID,
                     OrderID,
                     ItemID
        ),
        SoftCommitNeeded
        AS
        (
            SELECT  co.ProductID,
                    co.StoreID,
                    co.SourceID,
                    co.OrderID,
                    co.ItemID,
                    co.TotalCommitted - ISNULL(hc.HardCommitted, 0) AS SoftCommitted
            FROM CommittedOrders co
                LEFT JOIN HardCommitted hc
                    ON co.ProductID = hc.ProductID
                       AND co.StoreID = hc.StoreID
                       AND co.OrderID = hc.OrderID
                       AND co.ItemID = hc.ItemID
            WHERE co.TotalCommitted - ISNULL(hc.HardCommitted, 0) > 0
        ),
        RankedInventory
        AS
        (
            SELECT  pie.ProductID,
                    pie.StoreID,
                    pie.SourceID,
                    pie.SerialNbrID,
                    pie.TransDate,
                    scn.OrderID,
                    scn.ItemID,
                    scn.SoftCommitted AS NeededQty,
                    ROW_NUMBER() OVER (PARTITION BY pie.ProductID,
                                                    pie.StoreID,
                                                    pie.SourceID,
                                                    scn.OrderID,
                                                    scn.ItemID
                                       ORDER BY pie.DateIn,
                                                pie.SerialNbrID
                                      ) AS RowNum
            FROM [Retail_OOM_Wrk].[PieceInventory] pie
                INNER JOIN SoftCommitNeeded scn
                    ON pie.ProductID = scn.ProductID
                       AND pie.StoreID = scn.StoreID
                       AND pie.SourceID = scn.SourceID
            WHERE pie.TransDate = @TransDate
                  AND pie.ReasonCodeID IS NULL
                  AND pie.SoftCommitted = 1
                  AND pie.PieceStatusID = 0
                  AND pie.OrderID IS NULL
                  AND pie.ItemID IS NULL
        )
        UPDATE pie
        SET OrderID = ri.OrderID,
            ItemID = ri.ItemID
        FROM [Retail_OOM_Wrk].[PieceInventory] pie
            INNER JOIN RankedInventory ri
                ON pie.ProductID = ri.ProductID
                   AND pie.SerialNbrID = ri.SerialNbrID
                   AND pie.SourceID = ri.SourceID
                   AND pie.StoreID = ri.StoreID
                   AND pie.TransDate = ri.TransDate
        WHERE ri.RowNum <= ri.NeededQty AND pie.TransDate = @TransDate;

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