CREATE   PROCEDURE [Retail_OOM_Wrk].[usp_PieceInventory_Insert001] @TransDate DATETIME
AS
BEGIN

    --// AUDIT LOGGING START //--

    DECLARE @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
            @DestinationDatabase VARCHAR(150),
            @DestinationSchema VARCHAR(150),
            @DestinationTable VARCHAR(150);

    SET @String = 'Retail_OOM_Wrk.usp_PieceInventory_Insert001';
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

        TRUNCATE TABLE [Retail_OOM_Wrk].[PieceInventory];

        INSERT INTO [Retail_OOM_Wrk].[PieceInventory]
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
            LeadDays
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
                @TransDate,
                VendorID,
                WhseMgmtTag,
                NULL StoreBrandID,
                NULL InvSubBucketID,
                NULL TDGInvTypeID,
                NULL OrderTransCodeID,
                NULL ItemID,
                NULL OrderID,
                QtyCommitted,
                0 AS LeadDays
        FROM [$(Source_Data)].[Retail_Corporate].[PieceInventory] AS pie
        WHERE CAST(TransDate AS DATE) = DATEADD(DAY, -1, @TransDate);

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