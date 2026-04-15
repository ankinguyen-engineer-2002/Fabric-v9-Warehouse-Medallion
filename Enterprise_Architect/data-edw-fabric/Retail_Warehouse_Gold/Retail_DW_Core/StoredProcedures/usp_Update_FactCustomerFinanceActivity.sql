CREATE PROCEDURE [Retail_DW_Core].[usp_Update_FactCustomerFinanceActivity]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Update_FactCreditReview';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'FactCreditReview';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		--TRUNCATE TABLE [Retail_DW_Core].[FactCustomerFinanceActivity];

		INSERT INTO [Retail_DW_Core].[FactCustomerFinanceActivity]
		(
			AmountApproved
			, CreditApplicationID
			, CreditRequestStatusCodeID
			, CreditReviewID
			, CreditReviewStatusCodeID
			, CreditStorisReferenceNumber
			, CustomerID
			, QueuedDateTime
			, TransDateKey
			, SalespersonID
			, StoreID
			, FinanceProviderID
		)

		SELECT
			cr.AmountApproved
			, cr.CreditApplicationID
			, cr.CreditRequestStatusCodeID
			, cr.CreditReviewID
			, cr.CreditReviewStatusCodeID
			, cr.CreditStorisReferenceNumber
			, cr.CustomerID
			, cr.QueuedDateTime
			, CONVERT(VARCHAR(8), cr.QueuedDateTime, 112) AS TransDateKey
			, cr.SalesPersonID
			, cr.StoreID
			, cr.FinanceProviderID
		FROM [$(Retail_Warehouse)].[Retail_Sales].[CreditReview] cr
		WHERE NOT EXISTS
		(
			SELECT cfa.CreditReviewID
			FROM [Retail_DW_Core].[FactCustomerFinanceActivity] cfa
			WHERE cfa.CreditReviewID = cr.CreditReviewID
		);

		UPDATE cfa
		SET cfa.AmountApproved = cr.AmountApproved
			, cfa.CreditApplicationID = cr.CreditApplicationID
			, cfa.CreditRequestStatusCodeID = cr.CreditRequestStatusCodeID
			, cfa.CreditReviewStatusCodeID = cr.CreditReviewStatusCodeID
			, cfa.CreditStorisReferenceNumber = cr.CreditStorisReferenceNumber
			, cfa.CustomerID = cr.CustomerID
			, cfa.QueuedDateTime = cr.QueuedDateTime
			, cfa.TransDateKey =  CONVERT(VARCHAR(8), cr.QueuedDateTime, 112)
			, cfa.SalespersonID = cr.SalesPersonID
			, cfa.StoreID = cr.StoreID
			, cfa.FinanceProviderID = cr.FinanceProviderID
			, cfa.CustomerKey = cm.CustomerKey
			, cfa.SalespersonKey = sp.SalesPersonKey
			, cfa.LocationKey = lm.LocationKey
		FROM [$(Retail_Warehouse)].[Retail_Sales].[CreditReview] cr
		INNER JOIN [Retail_DW_Core].[FactCustomerFinanceActivity] cfa
		ON cr.CreditReviewID = cfa.CreditReviewID
		LEFT JOIN [Retail_DW_Core].[DimStoreLocation] lm
		ON lm.StoreID = cfa.StoreID
		LEFT JOIN [Retail_DW_Core].[DimCustomerMaster] cm
		ON cm.CustomerID = cfa.CustomerID
		LEFT JOIN [Retail_DW_Core].[DimSalesPerson] sp
		ON sp.SalesPersonID = cfa.SalespersonID;

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
		EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase, @DestinationSchema, @DestinationTable;
	
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