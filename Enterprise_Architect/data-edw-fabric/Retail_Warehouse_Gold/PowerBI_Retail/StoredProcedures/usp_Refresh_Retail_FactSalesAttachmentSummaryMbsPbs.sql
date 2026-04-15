

CREATE       PROCEDURE [PowerBI_Retail].[usp_Refresh_Retail_FactSalesAttachmentSummaryMbsPbs]
(@TransDate DATE)
AS
BEGIN
    DECLARE @FromDate DATE,
            @Source VARCHAR(10) = 'W',
            @DataMapKey VARCHAR(50) = 'AttPBSToMatt',
            @TransCodeGroupMap VARCHAR(50) = 'Sales',
            @AttachementKey INT = 3,
            @AttachmentType INT = 2,
        @String VARCHAR(5000),
        @DateValue DATETIME,
        @User VARCHAR(500),
        @DestinationDatabase VARCHAR(150),
        @DestinationSchema VARCHAR(150),
        @DestinationTable VARCHAR(150);

    SET @FromDate = @TransDate;
    SET @String = 'PowerBI_Retail.usp_Refresh_Retail_FactSalesAttachmentSummaryMbsPbs';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE();
    SET @DestinationDatabase = 'Retail_Warehouse';
    SET @DestinationSchema = 'PowerBI_Retail';
    SET @DestinationTable = 'FactSalesAttachmentSummary';

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

    SELECT mpb.LocationID,
           mpb.TransDate,
           mpb.SalesPersonID,
           SUM(mpb.HasPBS * ABS(mpb.HasMBS)) AS AttachedValue,
           SUM(mpb.HasMBS) AS PrimaryValue
    INTO #SLS
    FROM
    (
        SELECT lm.StoreID as LocationID,
               OrderID,
               sp.SalesPersonID,
               CAST(dsdt.TransDateTime AS DATE) as TransDate,
               SIGN(SUM(   CASE
                               WHEN pm.GroupID = 'PBS' THEN
                                   (CASE
                             WHEN dsdt.SalesType = 'W' THEN dsdt.Sales
                             ELSE 0
                         END
                     )
                               ELSE
                                   0
                           END
                       )
                   ) AS HasPBS,
               SIGN(SUM(   CASE
                               WHEN pm.GroupID = 'MBS' THEN
                                   (CASE
                             WHEN dsdt.SalesType = 'W' THEN dsdt.Sales
                             ELSE 0
                         END
                     )
                               ELSE
                                   0
                           END
                       )
                   ) AS HasMBS
        --MAX(CASE WHEN dsdt.GroupID = 'PBS' THEN 1 ELSE 0 END) AS HasPBS,
        --MAX(CASE WHEN dsdt.GroupID = 'MBS' THEN 1 ELSE 0 END) AS HasMBS
        FROM  [Retail_DW_Core].[FactSales] AS dsdt
                  LEFT JOIN [Retail_DW_Core].[DimSalesPerson] sp ON sp.SalesPersonKey = dsdt.SalesPersonKey
         LEFT JOIN [Retail_DW_Core].[DimProductMaster] pm ON pm.ProductKey = dsdt.ProductKey
             LEFT JOIN  [Retail_DW_Core].[DimStoreLocation] AS lm
                ON dsdt.LocationKey = lm.LocationKey
        WHERE CAST(dsdt.TransDateTime AS DATE) >= @FromDate
              AND dsdt.SalesType = @Source
              AND dsdt.TransCodeID IN
                  (
                      SELECT TransCodeID
                      FROM [Retail_DW_Core].[DimTransCodeMap] AS tcm
                      WHERE tcm.TransCodeGroup = @TransCodeGroupMap
                  )
              AND
              (
                  (
                      pm.SubGroupID = 'MATTRESS'
                      AND pm.SKU NOT IN
                          (
                              SELECT MapToValue
                              FROM [PowerBI_Retail].[KpiDataMap]
                              WHERE DataMapKey = @DataMapKey
                          )
                  )
                  OR pm.GroupID = 'PBS'
              )
              AND pm.VendorID NOT IN ( 'AFSSI', 'SSI' )
        GROUP BY lm.StoreID,
                 dsdt.OrderID,
                 sp.SalesPersonID,
                 CAST(dsdt.TransDateTime AS DATE)
    ) mpb
    GROUP BY mpb.LocationID,
             mpb.SalesPersonID,
             mpb.TransDate;

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
    SELECT @AttachementKey,
           s.TransDate,
           sp.SalesPersonKey,
           lm.LocationKey,
           @AttachmentType,
           s.PrimaryValue,
           s.AttachedValue
    FROM #SLS AS s
        INNER JOIN [Retail_DW_Core].[DimStoreLocation] AS lm
            ON lm.StoreID = s.LocationID
        INNER JOIN[Retail_DW_Core].[DimSalesPerson] AS sp
            ON sp.SalesPersonID = s.SalesPersonID
    WHERE s.PrimaryValue <> 0
          OR s.AttachedValue <> 0;

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

