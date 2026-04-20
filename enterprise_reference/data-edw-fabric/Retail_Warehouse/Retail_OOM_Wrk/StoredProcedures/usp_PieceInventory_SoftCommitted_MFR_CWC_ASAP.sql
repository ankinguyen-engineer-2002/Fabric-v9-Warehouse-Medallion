CREATE   PROCEDURE [Retail_OOM_Wrk].[usp_PieceInventory_SoftCommitted_MFR_CWC_ASAP] @TransDate DATETIME
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

    SET @String = 'Retail_OOM_wrk.usp_PieceInventory_SoftCommitted_MFR_CWC_ASAP';
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
            SELECT  oi.StoreID,
                    '01' AS SourceID,
                    oi.ProductID,
                    SUM(oi.QtyOrdered) AS TotalCommitted
            FROM [$(Source_Data)].[Retail_Corporate].[OrderItem] AS oi
                INNER JOIN [$(Source_Data)].[Retail_Corporate].[Product] AS p
                    ON oi.ProductID = p.ProductID
            WHERE p.ProductTypeID = '1'
                  AND p.SpecialOrder = 0
                  AND p.PurchaseStatusCodeID IN ('D', 'T')
            GROUP BY oi.StoreID,
                     oi.ProductID
        ),
        HardCommitted
        AS
        (
            SELECT  ProductID,
                    StoreID,
                    SUM(SoftCommitted) AS HardCommitted
            FROM [Retail_OOM_Wrk].[PieceInventory]
            WHERE TransDate = @TransDate AND QtyNonSale = 0
            GROUP BY ProductID,
                     StoreID
        ),
        SoftCommitNeeded
        AS
        (
            SELECT  co.ProductID,
                    co.StoreID,
                    co.SourceID,
                    co.TotalCommitted - ISNULL(hc.HardCommitted, 0) AS SoftCommitted
            FROM CommittedOrders co
                LEFT JOIN HardCommitted hc
                    ON co.ProductID = hc.ProductID
                       AND co.StoreID = hc.StoreID
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
                    scn.SoftCommitted AS NeededQty,
                    ROW_NUMBER() OVER (PARTITION BY pie.ProductID,
                                                    pie.StoreID,
                                                    pie.SourceID
                                       ORDER BY pie.QtyCommitted DESC,
                                                pie.DateIn,
                                                pie.SerialNbrID
                                      ) AS RowNum
            FROM [Retail_OOM_Wrk].[PieceInventory] pie
                INNER JOIN SoftCommitNeeded scn
                    ON pie.ProductID = scn.ProductID
                       AND pie.StoreID = scn.StoreID
                       AND pie.SourceID = scn.SourceID
            WHERE pie.TransDate = @TransDate
                  AND pie.QtyNonSale = 0
                  AND pie.SoftCommitted = 0
                  AND pie.PieceStatusID = 0
        )
        UPDATE pie
        SET SoftCommitted = 1
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