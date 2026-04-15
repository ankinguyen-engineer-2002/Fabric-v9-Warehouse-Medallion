CREATE PROCEDURE [Retail_Sales_Enh].[usp_Update_CreditApplication]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Enh.usp_Update_CreditApplication';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'Retail_Sales_Enh'
	SET @DestinationTable = 'CreditApplication';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		--TRUNCATE TABLE [Retail_Sales_Enh].[CreditApplication];
		
		INSERT INTO [Retail_Sales_Enh].[CreditApplication]
		(
			ApplicationDate
			, ApplicationSignedByCoApplicant
			, ApplicationSignedByMainApplicant
			, CreatedByThirdParty
			, CreditApplicationID
			, CreditBureauID
			, CreditSourceTypeID
			, CreditStorisReferenceNumber
			, CustomerID
			, DateChanged
			, DateCreated
			, FinanceProviderID
			, IsHistory
			, LastBatchID
			, PaymentTypeID
			, RecStatus
			, RequestedAmount
			, SalesPersonID
			, SourceID
			, SubmissionDate
		)

		SELECT	
			CAST(ca.ApplicationDate AS DATE) AS ApplicationDate
			, ca.ApplicationSignedByCoApplicant
			, ca.ApplicationSignedByMainApplicant
			, ca.CreatedByThirdParty
			, ca.CreditApplicationID
			, ca.CreditBureauID
			, ca.CreditSourceTypeID
			, ca.CreditStorisReferenceNumber
			, ca.CustomerID
			, ca.DateChanged
			, ca.DateCreated
			, ca.FinanceProviderID
			, ca.IsHistory
			, ca.LastBatchID
			, ca.PaymentTypeID
			, ca.RecStatus
			, ca.RequestedAmount
			, ca.SalesPersonID AS SalesPersonID
			, ca.SourceID
			, CAST(ca.SubmissionDate AS DATE) AS SubmissionDate
		FROM [Retail_Sales].[CreditApplication] AS ca
		WHERE NOT EXISTS
		(
			SELECT 1
			FROM [Retail_Sales_Enh].[CreditApplication] capp
			WHERE capp.CreditApplicationID = ca.CreditApplicationID
			AND capp.CreditSourceTypeID = ca.CreditSourceTypeID
		)

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
		Exec [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase,@DestinationSchema,@DestinationTable
		
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