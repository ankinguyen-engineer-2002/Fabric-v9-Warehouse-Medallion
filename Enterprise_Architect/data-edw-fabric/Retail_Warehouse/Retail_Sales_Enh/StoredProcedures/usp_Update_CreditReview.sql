CREATE PROCEDURE [Retail_Sales_Enh].[usp_Update_CreditReview]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Enh.usp_Update_CreditReview';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'Retail_Sales_Enh'
	SET @DestinationTable = 'CreditReview';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		--TRUNCATE TABLE [Retail_Sales_Enh].[CreditReview];
		
		UPDATE src
		SET OriginalQueuedDateTime = CASE WHEN dst.OriginalQueuedDateTime IS NULL
									 THEN src.RequestDateTime
									 ELSE dst.OriginalQueuedDateTime END
		FROM [Retail_Sales].[CreditReview] src
		LEFT OUTER JOIN [Retail_Sales_Enh].[CreditReview] dst 
		ON src.CreditReviewID = dst.CreditReviewID
		AND	src.CreditSourceTypeID = dst.CreditSourceTypeID
		AND	src.SourceID = dst.SourceID;

		UPDATE	src
		SET CreditAppNumber = crdata.RowNum,
			AppCount = CASE WHEN crdata.RowNum = 1 THEN 1 ELSE 0 END,
			AdjustedStatusCodeID = crdata.AdjustedStatusCodeID
		FROM	
		(
			SELECT 
				ROW_NUMBER() OVER (PARTITION BY cr.StoreID, cr.CustomerID, CAST(cr.RequestDateTime AS DATE) ORDER BY cs.ShortDescription) AS RowNum,
				cr.CreditSourceTypeID,
				cr.CreditReviewID,
				cr.SourceID,
				CASE WHEN tfpm.PaymentTypeVendorID LIKE 'GENESIS%' AND cs.ShortDescription = 'Pending' THEN 7
				ELSE cr.CreditRequestStatusCodeID
				END AS AdjustedStatusCodeID
				FROM [Retail_Sales].[CreditReview] AS cr
				LEFT JOIN [$(Source_Data)].[Retail_Corporate].[CreditRequestStatusCode] AS cs
				ON cs.CreditRequestStatusCodeID = cr.CreditRequestStatusCodeID
				LEFT JOIN [$(Source_Data)].[Retail_External].[FinanceProviderMapping] AS tfpm 
				ON cr.FinanceProviderID = tfpm.FinanceProviderID
				--WHERE cr.CreditRequestStatusCodeID <> 9
		) crdata
		INNER JOIN [Retail_Sales].[CreditReview] src 
		ON src.CreditReviewID = crdata.CreditReviewID
		AND src.CreditSourceTypeID = crdata.CreditSourceTypeID
		AND src.SourceID = crdata.SourceID;

		UPDATE dst
		SET AmountApproved = src.AmountApproved
			, ConditionalLetterRequired = src.ConditionalLetterRequired
			, CosignerCustomerID = src.CosignerCustomerID
			, CreditApplicationID = src.CreditApplicationID
			, CreditBureauID = src.CreditBureauID
			, CreditReportDate = src.CreditReportDate
			, CreditRequestStatusCodeID = src.CreditRequestStatusCodeID
			, CreditReviewStatusCodeID = src.CreditReviewStatusCodeID
			, CreditScore = src.CreditScore
			, CreditStorisReferenceNumber = src.CreditStorisReferenceNumber
			, CustomerID = src.CustomerID
			, DateChanged = src.DateChanged
			, DateCreated = src.DateCreated
			, FinalLetterRequired = src.FinalLetterRequired
			, FinanceAccountNumber = src.FinanceAccountNumber
			, FinanceProviderID = src.FinanceProviderID
			, FinanceReferenceNumber = src.FinanceReferenceNumber
			, IsHistory = src.IsHistory
			, QueuedDateTime = src.QueuedDateTime
			, RecStatus = src.RecStatus
			, RequestCompletionDateTime = src.RequestCompletionDateTime
			, RequestDateTime = src.RequestDateTime
			, RequestStatusChangeDateTime = src.RequestStatusChangeDateTime
			, ReviewStatusChangeDateTime = src.ReviewStatusChangeDateTime
			, RouteToStaffID = src.RouteToStaffID
			, SalesPersonID = src.SalesPersonID
			, StoreID = src.StoreID
			, SuggestedCreditLimit = src.SuggestedCreditLimit
			, SuggestedDownPaymentPercent = src.SuggestedDownPaymentPercent
			, CreditAppNumber = src.CreditAppNumber
			, AppCount = src.AppCount
			, AdjustedStatusCodeID = src.AdjustedStatusCodeID
		FROM [Retail_Sales_Enh].[CreditReview] dst
		INNER JOIN [Retail_Sales].[CreditReview] src 
		ON dst.CreditReviewID = src.CreditReviewID
		AND dst.CreditSourceTypeID = src.CreditSourceTypeID
		AND dst.SourceID = src.SourceID;

		INSERT INTO [Retail_Sales_Enh].[CreditReview]
		(
			AmountApproved
			, ConditionalLetterRequired
			, CosignerCustomerID
			, CreditApplicationID
			, CreditBureauID
			, CreditReportDate
			, CreditRequestStatusCodeID
			, CreditReviewID
			, CreditReviewStatusCodeID
			, CreditScore
			, CreditSourceTypeID
			, CreditStorisReferenceNumber
			, CustomerID
			, DateChanged
			, DateCreated
			, FinalLetterRequired
			, FinanceAccountNumber
			, FinanceProviderID
			, FinanceReferenceNumber
			, IsHistory
			, QueuedDateTime
			, OriginalQueuedDateTime
			, RecStatus
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
			, CreditAppNumber
			, AppCount
			, AdjustedStatusCodeID
			, TransDateKey
		)

		SELECT	
			src.AmountApproved
			, src.ConditionalLetterRequired
			, src.CosignerCustomerID
			, src.CreditApplicationID
			, src.CreditBureauID
			, src.CreditReportDate
			, src.CreditRequestStatusCodeID
			, src.CreditReviewID
			, src.CreditReviewStatusCodeID
			, src.CreditScore
			, src.CreditSourceTypeID
			, src.CreditStorisReferenceNumber
			, src.CustomerID
			, src.DateChanged
			, src.DateCreated
			, src.FinalLetterRequired
			, src.FinanceAccountNumber
			, src.FinanceProviderID
			, src.FinanceReferenceNumber
			, src.IsHistory
			, src.QueuedDateTime
			, src.OriginalQueuedDateTime
			, src.RecStatus
			, src.RequestCompletionDateTime
			, src.RequestDateTime
			, src.RequestStatusChangeDateTime
			, src.ReviewStatusChangeDateTime
			, src.RouteToStaffID
			, src.SalesPersonID
			, src.SourceID
			, src.StoreID
			, src.SuggestedCreditLimit
			, src.SuggestedDownPaymentPercent
			, src.CreditAppNumber
			, src.AppCount
			, src.AdjustedStatusCodeID
			, CAST(CONVERT(VARCHAR(12), CONVERT(DATE, src.RequestDateTime), 112) AS INT) AS TransDateKey
		FROM [Retail_Sales].[CreditReview] src
		LEFT OUTER JOIN [Retail_Sales_Enh].[CreditReview] dst
		ON dst.CreditReviewID = src.CreditReviewID
		AND	dst.CreditSourceTypeID = src.CreditSourceTypeID
		AND	dst.SourceID = src.SourceID
		WHERE dst.CreditReviewID IS NULL;

		UPDATE	cr
		SET cr.RequestedAmount = ca.RequestedAmount
		FROM [Retail_Sales_Enh].[CreditReview] AS cr
		INNER JOIN [Retail_Sales_Enh].[CreditApplication] AS ca
		ON ca.CreditApplicationID = cr.CreditApplicationID;

		SELECT *
			, 0 AS LeaseOpp
			, 0 AS LeaseAttempt
		INTO #LEASE
		FROM
		(
			SELECT	
				ROW_NUMBER() OVER (PARTITION BY cr.StoreID,	cr.CustomerID, CAST(cr.QueuedDateTime AS DATE) ORDER BY tfpm.Tier, cs.ShortDescription) AS RowNum
				, COUNT(*) OVER (PARTITION BY cr.StoreID, cr.CustomerID, CAST(cr.QueuedDateTime AS DATE)) AS Attemp
				, LEAD(tfpm.Tier) OVER (PARTITION BY cr.StoreID, cr.CustomerID, CAST(cr.QueuedDateTime AS DATE) ORDER BY tfpm.Tier, cs.ShortDescription) AS NextTier
				, LAG(tfpm.Tier) OVER (PARTITION BY cr.StoreID, cr.CustomerID, CAST(cr.QueuedDateTime AS DATE) ORDER BY tfpm.Tier, cs.ShortDescription) AS PriorTier
				, cr.CreditApplicationID
				, cr.StoreID
				, cr.CustomerID
				, cr.FinanceProviderID
				, CASE WHEN tfpm.PaymentTypeVendorID LIKE 'GENESIS%' AND cs.ShortDescription = 'Pending' THEN 'Approved'
				ELSE cs.ShortDescription
				END AS [Status]
				, CAST(cr.RequestDateTime AS DATE) AS QueuedDateTime
				, tfpm.Tier
				, tfpm.IsLeasedVendor
			FROM [Retail_Sales_Enh].[CreditReview] AS cr
			INNER JOIN [$(Source_Data)].[Retail_Corporate].[CreditRequestStatusCode] AS cs
			ON cs.CreditRequestStatusCodeID = cr.CreditRequestStatusCodeID
			INNER JOIN [$(Source_Data)].[Retail_External].[FinanceProviderMapping] AS tfpm 
			ON cr.FinanceProviderID = tfpm.FinanceProviderID
			WHERE CAST(cr.RequestDateTime AS DATE) >= CAST(DATEADD(DAY, -31, GETDATE()) AS DATE)
			--BETWEEN DATEFROMPARTS(YEAR(GETDATE()) - 1, 1, 1) AND GETDATE()
			--AND cr.CustomerID = '0016740675'
			AND tfpm.Tier IS NOT NULL
		) cdt
		--WHERE cdt.RowNum = cdt.Attemp
		--AND cdt.Tier <> 3
		--AND cdt.Status = 'Declined'
		ORDER BY cdt.CustomerID, cdt.QueuedDateTime;

		/*Declined and not Submitted to Tier 3 */
		UPDATE #LEASE
		SET LeaseOpp = 1
		WHERE Status = 'Declined'
		AND NextTier IS NULL
		AND Tier < 3
		AND IsLeasedVendor <> 1;

		/*Declined and  Submitted to Tier 3 */
		UPDATE #LEASE
		SET LeaseOpp = 1
		WHERE Status <> 'Approved'
		AND NextTier = 3
		AND Tier < 3
		AND IsLeasedVendor <> 1;

		/* Submin direct to teir 3*/
		UPDATE #LEASE
		SET LeaseOpp = 1
		WHERE	Tier = 3
		AND NextTier IS NULL
		AND PriorTier IS NULL;

		UPDATE #LEASE
		SET LeaseAttempt = 1
		WHERE Tier = 3
		AND NextTier IS NULL;

		UPDATE cr
		SET cr.LeaseOpp = l.LeaseOpp,
		cr.LeaseAttempt = l.LeaseAttempt
		FROM #LEASE AS l
		INNER JOIN [Retail_Sales_Enh].[CreditReview] AS cr 
		ON cr.CreditApplicationID = l.CreditApplicationID;

		DROP TABLE #LEASE;

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