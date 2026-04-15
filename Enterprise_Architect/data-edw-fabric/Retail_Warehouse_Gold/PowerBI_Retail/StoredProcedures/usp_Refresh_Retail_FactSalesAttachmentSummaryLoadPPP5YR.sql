CREATE   PROCEDURE [PowerBI_Retail].[usp_Refresh_Retail_FactSalesAttachmentSummaryLoadPPP5YR]
    @TransDate DATE
AS
BEGIN
    
    DECLARE 
        @FromDate DATE,
        @Source VARCHAR(10) = 'W',
        @AttachementKey INT = 20,
        @AttachmentType INT = 2,
        @String VARCHAR(5000),
        @DateValue DATETIME,
        @User VARCHAR(500),
        @DestinationDatabase VARCHAR(150),
        @DestinationSchema VARCHAR(150),
        @DestinationTable VARCHAR(150);
        
    SET @String = 'PowerBI_Retail.usp_Refresh_Retail_FactSalesAttachmentSummaryLoadPPP5YR';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE();
    SET @DestinationDatabase = 'Retail_Warehouse';
    SET @DestinationSchema = 'PowerBI_Retail';
    SET @DestinationTable = 'FactSalesAttachmentSummary';   
    SET @FromDate = @TransDate;
    
    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    BEGIN TRY

        DELETE FROM PowerBI_Retail.FactSalesAttachmentSummary
        WHERE AttachmentKey = @AttachementKey
              AND AttachmentType = @AttachmentType
              AND TransDate >= @FromDate;

        SELECT 
            odt.StoreID,
            TransDate,
            SalesPersonID,
            SUM(odt.Sales) AS Sales
        INTO #SLS
        FROM [Retail_DW_Core].[FactOrderDetailTrans] odt
        WHERE TransDate >= @TransDate
              AND SalesType = 'W'
              AND SKU IN ('EXTFURN')
        GROUP BY StoreID,
                 TransDate,
                 SalespersonID;

        INSERT INTO PowerBI_Retail.FactSalesAttachmentSummary
        (
            AttachmentKey,
            TransDate,
            SalesPersonKey,
            LocationKey,
            AttachmentType,
            PrimaryValue,
            AttachedValue
        )
        SELECT 
            @AttachementKey,
            s.TransDate,
            sp.SalesPersonKey,
            lm.LocationKey,
            @AttachmentType,
            SUM(s.Sales) AS PrimaryValue,
            0 AttachedValue
        FROM #SLS AS s
            INNER JOIN [Retail_DW_Core].[DimStoreLocation] AS lm
                ON lm.StoreID = s.StoreID
            INNER JOIN [Retail_DW_Core].[DimSalesPerson] AS sp
                ON sp.SalesPersonID = s.SalesPersonID
        GROUP BY s.TransDate,
                 sp.SalesPersonKey,
                 lm.LocationKey;

        DROP TABLE #SLS;
        
        SET @DateValue = GETDATE();

        SELECT
            @DateValue = CSTDateValue
        FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

        INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
        VALUES
        (
            @String, @DateValue, @User, 'Process Complete'
        );

        --- Update last modified in Table Dictionary 
        EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] 
            @DestinationDatabase, 
            @DestinationSchema, 
            @DestinationTable;
    
    END TRY

    BEGIN CATCH
        
        DECLARE
            @ErrorMessage  VARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState    INT;

        SET @ErrorMessage = ERROR_MESSAGE();
        SET @ErrorSeverity = ISNULL(ERROR_SEVERITY(), 16);
        SET @ErrorState = ISNULL(ERROR_STATE(), 0);
        SET @DateValue = GETDATE();

        SELECT
            @DateValue = CSTDateValue
        FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

        INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
        VALUES
        (
            @String, @DateValue, @User, @ErrorMessage
        );

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

    END CATCH

END
GO

