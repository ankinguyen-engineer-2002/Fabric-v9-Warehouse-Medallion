CREATE   PROCEDURE [Retail_DW_Core].[usp_Update_FactCreditReview]
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

		--TRUNCATE TABLE [Retail_DW_Core].[FactCreditReview];

		DECLARE @StartDate DATE = GETDATE()-180
				, @EndDate DATE = GETDATE();

	    DROP TABLE IF EXISTS [Retail_DW_Core].[FactCreditReviewHolding];

		CREATE TABLE [Retail_DW_Core].[FactCreditReviewHolding]
		(
			[AmountApproved] [decimal](19,4) NULL,
			[CreditApplicationID] [varchar](50) NULL,
			[CreditReportDate] [date] NULL,
			[CreditRequestStatusCodeID] [int] NULL,
			[CreditReviewStatusCodeID] [varchar](10) NULL,
			[CreditReviewID] [varchar](50) NOT NULL,
			[CreditScore] [varchar](50) NULL,
			[CreditSourceTypeID] [varchar](10) NOT NULL,
			[CustomerID] [varchar](50) NULL,
			[ConditionalLetterRequired] [bit] NULL,
			[CosignerCustomerID] [varchar](50) NULL,
			[CreditBureauID] [varchar](50) NULL,
			[FinalLetterRequired] [bit] NULL,
			[IsHistory] [bit] NULL,
			[DateChanged] [datetime2](3) NULL,
			[DateCreated] [datetime2](3) NULL,
			[FinanceAccountNumber] [varchar](50) NULL,
			[FinanceProviderID] [varchar](50) NULL,
			[FinanceReferenceNumber] [varchar](50) NULL,
			[QueuedDateTime] [datetime2](3) NULL,
			[RequestCompletionDateTime] [datetime2](3) NULL,
			[RequestDateTime] [datetime2](3) NULL,
			[RequestStatusChangeDateTime] [datetime2](3) NULL,
			[ReviewStatusChangeDateTime] [datetime2](3) NULL,
			[RouteToStaffID] [varchar](50) NULL,
			[SalesPersonID] [varchar](50) NULL,
			[SourceID] [varchar](50) NOT NULL,
			[StoreID] [int] NULL,
			[SuggestedCreditLimit] [decimal](19, 4) NULL,
			[SuggestedDownPaymentPercent] [int] NULL,
			[CreditStorisReferenceNumber] [varchar](50) NULL,
			[RecStatus] [varchar](1) NULL,
			[OriginalQueuedDateTime] [datetime2](3) NULL,
			[CreditAppNumber] [int] NULL,
			[AppCount] [int] NULL,
			[AdjustedStatusCodeID] [int] NULL,
			[TransDateKey] [bigint] NULL,
			[RequestedAmount] [decimal](19,4) NULL,
			[LeaseOpp] [int] NULL,
			[LeaseAttempt] [int] NULL
		)
	
		INSERT INTO [Retail_DW_Core].[FactCreditReviewHolding]
		(
			AmountApproved
			, CreditApplicationID
			, CreditReportDate
			, CreditRequestStatusCodeID
			, CreditReviewStatusCodeID
			, CreditReviewID
			, CreditScore
			, CreditSourceTypeID
			, CustomerID
			, ConditionalLetterRequired
			, CosignerCustomerID
			, CreditBureauID
			, FinalLetterRequired
			, IsHistory
			, DateChanged
			, DateCreated
			, FinanceAccountNumber
			, FinanceProviderID
			, FinanceReferenceNumber
			, QueuedDateTime
			, RequestCompletionDateTime
			, RequestDateTime
			, RequestStatusChangeDateTime
			, ReviewStatusChangeDateTime
			, RouteToStaffID
			, SalesPersonID
			, SourceID
			, StoreID
			, SuggestedCreditLimit
			, SuggestedDownPaymentPercent
			, CreditStorisReferenceNumber
			, RecStatus
			, OriginalQueuedDateTime
			, CreditAppNumber
			, AppCount
			, AdjustedStatusCodeID
			, TransDateKey
			, RequestedAmount
			, LeaseOpp
			, LeaseAttempt
		)

		SELECT
			AmountApproved
			, CreditApplicationID
			, CreditReportDate
			, CreditRequestStatusCodeID
			, CreditReviewStatusCodeID
			, CreditReviewID
			, CreditScore
			, CreditSourceTypeID
			, CustomerID
			, ConditionalLetterRequired
			, CosignerCustomerID
			, CreditBureauID
			, FinalLetterRequired
			, IsHistory
			, DateChanged
			, DateCreated
			, FinanceAccountNumber
			, FinanceProviderID
			, FinanceReferenceNumber
			, QueuedDateTime
			, RequestCompletionDateTime
			, RequestDateTime
			, RequestStatusChangeDateTime
			, ReviewStatusChangeDateTime
			, RouteToStaffID
			, SalesPersonID
			, SourceID
			, StoreID
			, SuggestedCreditLimit
			, SuggestedDownPaymentPercent
			, CreditStorisReferenceNumber
			, RecStatus
			, OriginalQueuedDateTime
			, CreditAppNumber
			, AppCount
			, AdjustedStatusCodeID
			, TransDateKey
			, RequestedAmount
			, LeaseOpp
			, LeaseAttempt
		FROM [$(Retail_Warehouse)].[Retail_Sales_Enh].[CreditReview]
		WHERE COALESCE(CAST(DateChanged AS DATE), CAST(DateCreated AS DATE)) BETWEEN @StartDate AND @EndDate;

		DELETE FROM [Retail_DW_Core].[FactCreditReview]
		WHERE COALESCE(CAST(DateChanged AS DATE), CAST(DateCreated AS DATE)) BETWEEN @StartDate AND @EndDate;

		INSERT INTO [Retail_DW_Core].[FactCreditReview]
		(
			AmountApproved
			, CreditApplicationID
			, CreditReportDate
			, CreditRequestStatusCodeID
			, CreditReviewStatusCodeID
			, CreditReviewID
			, CreditScore
			, CreditSourceTypeID
			, CustomerID
			, ConditionalLetterRequired
			, CosignerCustomerID
			, CreditBureauID
			, FinalLetterRequired
			, IsHistory
			, DateChanged
			, DateCreated
			, FinanceAccountNumber
			, FinanceProviderID
			, FinanceReferenceNumber
			, QueuedDateTime
			, RequestCompletionDateTime
			, RequestDateTime
			, RequestStatusChangeDateTime
			, ReviewStatusChangeDateTime
			, RouteToStaffID
			, SalesPersonID
			, SourceID
			, StoreID
			, SuggestedCreditLimit
			, SuggestedDownPaymentPercent
			, CreditStorisReferenceNumber
			, RecStatus
			, OriginalQueuedDateTime
			, CreditAppNumber
			, AppCount
			, AdjustedStatusCodeID
			, TransDateKey
			, RequestedAmount
			, LeaseOpp
			, LeaseAttempt
		)

		SELECT
			AmountApproved
			, CreditApplicationID
			, CreditReportDate
			, CreditRequestStatusCodeID
			, CreditReviewStatusCodeID
			, CreditReviewID
			, CreditScore
			, CreditSourceTypeID
			, CustomerID
			, ConditionalLetterRequired
			, CosignerCustomerID
			, CreditBureauID
			, FinalLetterRequired
			, IsHistory
			, DateChanged
			, DateCreated
			, FinanceAccountNumber
			, FinanceProviderID
			, FinanceReferenceNumber
			, QueuedDateTime
			, RequestCompletionDateTime
			, RequestDateTime
			, RequestStatusChangeDateTime
			, ReviewStatusChangeDateTime
			, RouteToStaffID
			, SalesPersonID
			, SourceID
			, StoreID
			, SuggestedCreditLimit
			, SuggestedDownPaymentPercent
			, CreditStorisReferenceNumber
			, RecStatus
			, OriginalQueuedDateTime
			, CreditAppNumber
			, AppCount
			, AdjustedStatusCodeID
			, TransDateKey
			, RequestedAmount
			, LeaseOpp
			, LeaseAttempt
		FROM [Retail_DW_Core].[FactCreditReviewHolding];

	    DROP TABLE [Retail_DW_Core].[FactCreditReviewHolding];

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