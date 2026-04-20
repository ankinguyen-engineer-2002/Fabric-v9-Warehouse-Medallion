CREATE   PROCEDURE Retail_OOM_Enh.[usp_PieceHist_Insert001] @TransDate DATETIME
AS
BEGIN

    --// AUDIT LOGGING START //--

    DECLARE @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
            @DestinationDatabase VARCHAR(150),
            @DestinationSchema VARCHAR(150),
            @DestinationTable VARCHAR(150);

    SET @String = 'Retail_OOM_Enh.usp_PieceHist_Insert001';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE();
    SET @DestinationDatabase = 'Retail_Warehouse';
    SET @DestinationSchema = 'Retail_OOM_Enh';
    SET @DestinationTable = 'PieceHist';

    SELECT @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    --// AUDIT LOGGING END //--

    BEGIN TRY

        DECLARE @TransDate1 DATE;

        SET @TransDate1 = CAST(@TransDate AS DATE);

        PRINT @TransDate1;

        DELETE FROM [Retail_OOM_Enh].[PieceHist]
        WHERE TransDate = @TransDate1;

        INSERT INTO [Retail_OOM_Enh].[PieceHist]
        (
            Addon1Cost,
            Addon2Cost,
            Addon3Cost,
            Addon4Cost,
            BrandID,
            CategoryID,
            CollectionID,
            COMCost,
            Comments,
            CompanyID,
            DateAsIs,
            DateChanged,
            DateCreated,
            DateIn,
            FrameInfo,
            GroupID,
            InvStatus,
            LandedFreight,
            MaterialCost,
            MaximumPrice,
            PieceStatusID,
            POLineID,
            ProductID,
            ProductTypeID,
            PurchaseOrderID,
            QtyCommitted,
            QtyNonSale,
            QtyNSCommitted,
            QtyNSReserved,
            QtyOnHand,
            QtyReserved,
            RcvdStatus,
            RcvdStoreID,
            ReasonCodeID,
            RecStatus,
            Repossessed,
            SellingPrice,
            SerialNbrID,
            SourceID,
            StorageID,
            StoreID,
            TotalCost,
            TransDate,
            VendorID,
            WhseMgmtTag,
            StoreBrandID,
            InvSubBucketID,
            TDGInvTypeID,
            OrderTransCodeID,
            ItemID,
            OrderID,
            SoftCommitted
        )
        SELECT  Addon1Cost,
                Addon2Cost,
                Addon3Cost,
                Addon4Cost,
                pie.BrandID,
                g.CategoryID,
                CollectionID,
                COMCost,
                Comments,
                pie.CompanyID,
                DateAsIs,
                pie.DateChanged,
                pie.DateCreated,
                DateIn,
                FrameInfo,
                pie.GroupID,
                InvStatus,
                LandedFreight,
                MaterialCost,
                MaximumPrice,
                PieceStatusID,
                POLineID,
                pie.ProductID,
                pie.ProductTypeID,
                PurchaseOrderID,
                QtyCommitted,
                QtyNonSale,
                QtyNSCommitted,
                QtyNSReserved,
                QtyOnHand,
                QtyReserved,
                RcvdStatus,
                RcvdStoreID,
                ReasonCodeID,
                pie.RecStatus,
                Repossessed,
                SellingPrice,
                SerialNbrID,
                pie.SourceID,
                StorageID,
                StoreID,
                TotalCost,
                TransDate,
                pie.VendorID,
                WhseMgmtTag,
                StoreBrandID,
                InvSubBucketID,
                TDGInvTypeID,
                OrderTransCodeID,
                ItemID,
                OrderID,
                SoftCommitted
        FROM [Retail_OOM_Wrk].[PieceInventory] AS pie
            INNER JOIN [$(Source_Data)].[Retail_Corporate].[Product] p
                ON pie.ProductID = p.ProductID
            INNER JOIN [$(Source_Data)].[Retail_Corporate].[Groups] g
                ON p.GroupID = g.GroupID
        WHERE TransDate = @TransDate1;

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