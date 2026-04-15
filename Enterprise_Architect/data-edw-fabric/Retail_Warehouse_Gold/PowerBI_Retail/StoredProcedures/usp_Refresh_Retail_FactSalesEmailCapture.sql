
CREATE     PROCEDURE [PowerBI_Retail].[usp_Refresh_Retail_FactSalesEmailCapture]
(@TransDate DATE)
AS
BEGIN
    DECLARE @FromDate DATE,
            @Source VARCHAR(10) = 'W',
            @AttachementKey INT = 15,
            @AttachmentType INT = 2,
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
        SET @String = 'PowerBI_Retail.usp_Refresh_Retail_FactSalesEmailCapture';
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


    SELECT oh.StoreID,
           oh.SalesPersonID,
           c.CustomerID,
           c.EmailAddress ValidEmails,
           oh.OrderDate
    INTO #BaseData
    FROM [Retail_DW_Core].[FactSalesOrderHeader] oh
            INNER JOIN [Retail_DW_Core].[DimCustomerMaster] c
                ON oh.CustomerID = c.CustomerID
            INNER JOIN [Retail_DW_Core].[DimTransCodeMap] tcm
                ON oh.TransCodeID = tcm.TransCodeID
    WHERE oh.OrderDate >= @FromDate
          AND tcm.TransCodeGroup = 'SRE'
          AND oh.SFMCFulfillmentStatus <> 'Cancelled'
    --AND oh.TransCodeID IN (0, 1, 7)
    GROUP BY oh.StoreID,
             c.CustomerID,
             oh.SalesPersonID,
             c.EmailAddress,
             oh.OrderDate;



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
           OrderDate,
           sp.SalesPersonKey,
           lm.LocationKey,
           @AttachmentType,
           SUM(1) AS PrimaryValue,
           SUM(   CASE
                      WHEN bd.ValidEmails IS NULL THEN
                          0
                      ELSE
                          1
                  END
              ) AS AttachedValue
    FROM #BaseData bd
        INNER JOIN [Retail_DW_Core].[DimSalesPerson] AS sp
                ON sp.SalesPersonID = bd.SalesPersonID
            INNER JOIN [Retail_DW_Core].[DimStoreLocation] AS lm
                ON bd.StoreID = lm.StoreID
    GROUP BY bd.OrderDate,
             sp.SalesPersonKey,
             lm.LocationKey;

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
		EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase, @DestinationSchema, @DestinationTable
	
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

