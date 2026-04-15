-- Auto Generated (Do not modify) 03306CB1AC3206BCEA8EC346395668C65B248BC0747A91B6B5C7C7B3B7421FC5
CREATE VIEW [Retail_Sales_Wrk].[v_CreditReview]
AS
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
    , RouteTo_StaffID AS RouteToStaffID
    , SalespersonID AS SalesPersonID
    , SourceID
    , StoreID
    , SuggestedCreditLimit
    , SuggestedDownPaymentPercent
    , CreditStorisReferenceNumber
    , RecStatus
	, CAST(NULL AS DATETIME2(3)) AS OriginalQueuedDateTime
	, NULL AS CreditAppNumber
	, NULL AS AppCount
	, NULL AS AdjustedStatusCodeID
FROM [$(Source_Data)].[MasterData_Retail].[CreditReview]
WHERE QueuedDateTime > CAST(GETDATE()-30 AS DATE);