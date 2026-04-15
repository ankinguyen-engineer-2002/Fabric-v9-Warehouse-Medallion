
CREATE           PROCEDURE [PowerBI_Retail].[usp_Refresh_Retail_FactSalesAttachmentSummaryLoadPPPDataOverall]

(@TransDate DATE)
AS
BEGIN
 

    DECLARE @FromDate DATE,
            @Source VARCHAR(10) = 'W',
            --@DataMapKey VARCHAR(50) = 'AttPBSToMatt',
            @TransCodeGroupMap VARCHAR(50) = 'Sales',
            @AttachementKey INT = 8,
            @AttachmentType INT = 2,
        @String VARCHAR(5000),
        @DateValue DATETIME,
        @User VARCHAR(500),
        @DestinationDatabase VARCHAR(150),
        @DestinationSchema VARCHAR(150),
        @DestinationTable VARCHAR(150);

    SET @FromDate = @TransDate;
    SET @String = 'PowerBI_Retail.usp_Refresh_Retail_FactSalesAttachmentSummaryLoadPPPDataOverall';
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

    SELECT ppp.LocationID,
           ppp.OrderID,
           ppp.PPPGroupID,
           ppp.SalespersonID,
           ppp.TransDate,
           SUM(ppp.Opp) PPPOpp,
           SUM(ppp.Closes) PPPClose
    INTO #SLS
    FROM
    (
        SELECT StoreID as LocationID,
              TransDate,
               OrderID,
               SalesPersonID,
               PPPGroupID,
               SIGN(SUM(PPPOpp)) AS Opp,
               SIGN(SUM(PPPClose)) AS Closes
        FROM [Retail_DW_Core].[FactOrderDetailTrans] dsdt
     
        WHERE TransDate  >= @FromDate
              AND SalesType = 'W'
              AND PPPGroupID IS NOT NULL
        GROUP BY StoreID,
                TransDate,
                 OrderID,
                 SalesPersonID,
                 PPPGroupID
    ) ppp
    GROUP BY ppp.LocationID,
             ppp.OrderID,
             ppp.PPPGroupID,
             ppp.SalespersonID,
             ppp.TransDate;

    --SELECT	s.LocationID,
    --		s.OrderID,
    --		s.PPPGroupID,
    --		s.SalespersonID,
    --		s.TransDate,
    --		SIGN(SUM(s.PPPOpp)) AS PPPOpp,
    --		SIGN(SUM(s.PPPClose)) AS PppClose
    --	INTO	#PPP
    --	FROM	#SLS AS s
    --	GROUP BY s.LocationID,
    --			 s.OrderID,
    --			 s.PPPGroupID,
    --			 s.SalesPersonID,
    --			 s.TransDate;
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
           SUM(s.PPPOpp) AS PrimaryValue,
           SUM(s.PPPClose) AttachedValue
    FROM #SLS AS s
        INNER JOIN [Retail_DW_Core].[DimStoreLocation] AS lm
            ON lm.StoreID = s.LocationID
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

