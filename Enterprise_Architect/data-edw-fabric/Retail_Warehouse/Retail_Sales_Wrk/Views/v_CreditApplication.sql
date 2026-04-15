-- Auto Generated (Do not modify) 45074C2769D809709EC41F79A5E2C6BAA2807E470FA6DA0847D3437898704AAC
CREATE VIEW [Retail_Sales_Wrk].[v_CreditApplication]
AS
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
	, ca.SalespersonID AS SalesPersonID
	, ca.SourceID
	, CAST(ca.SubmissionDate AS DATE) AS SubmissionDate
FROM [$(Source_Data)].[Retail_Corporate].[CreditApplication] AS ca
WHERE COALESCE(CAST(ca.DateChanged AS DATE), CAST(ca.DateCreated AS DATE)) BETWEEN CAST(GETDATE()-3 AS DATE) AND CAST(GETDATE() AS DATE);