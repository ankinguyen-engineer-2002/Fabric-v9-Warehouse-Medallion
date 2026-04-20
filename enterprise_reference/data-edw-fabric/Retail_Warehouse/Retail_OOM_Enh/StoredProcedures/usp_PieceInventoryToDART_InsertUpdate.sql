CREATE   PROCEDURE [Retail_OOM_Enh].[usp_PieceInventoryToDART_InsertUpdate]
AS
BEGIN

    --// AUDIT LOGGING START //--

    DECLARE @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
            @DestinationDatabase VARCHAR(150),
            @DestinationSchema VARCHAR(150),
            @DestinationTable VARCHAR(150);

    SET @String = 'Retail_OOM_Enh.usp_PieceInventoryToDART_InsertUpdate';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE();
    SET @DestinationDatabase = 'Retail_Warehouse';
    SET @DestinationSchema = 'Retail_OOM_Enh';
    SET @DestinationTable = 'PieceInventoryToDART';

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

        TRUNCATE TABLE [Retail_OOM_Enh].[PieceInventoryToDART];

        INSERT INTO [Retail_OOM_Enh].[PieceInventoryToDART]
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
            SoftCommitted,
            LeadDays,
            OrderDate,
            DlvyDate,
            ABC,
            PoType,
            DateInStorageID,
            DateInReasonCodeID,
            InvBucketID
        )
        SELECT  Addon1Cost,
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
                src.InvSubBucketID,
                TDGInvTypeID,
                OrderTransCodeID,
                ItemID,
                OrderID,
                SoftCommitted,
                LeadDays,
                OrderDate,
                DlvyDate,
                ABC,
                PoType,
                DateInStorageID,
                DateInReasonCodeID,
                InvBucketID
        FROM [Retail_OOM_Wrk].[PieceInventory] src
            LEFT JOIN [$(Source_Data)].[Retail_External].[InventorySubBuckets] bckt
                ON src.InvSubBucketID = bckt.InvSubBucketID
        WHERE CONVERT(DATE, TransDate) = @TransDate;

        UPDATE [Retail_OOM_Enh].[PieceInventoryToDART]
        SET StoreBrandID = 'TDSG'
        WHERE StoreBrandID IS NULL;

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