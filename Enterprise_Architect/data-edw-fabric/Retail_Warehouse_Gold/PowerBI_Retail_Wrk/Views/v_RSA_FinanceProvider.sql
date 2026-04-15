CREATE   VIEW [PowerBI_Retail_Wrk].[v_RSA_FinanceProvider] AS
SELECT  FP.FinanceProviderID,
		PT.PaymentTypeID, 
		FP.IsLeasedVendor
FROM [$(Source_Data)].[Retail_External].[FinanceProviderMapping] FP
		INNER JOIN [Retail_DW_Core].[DimPaymentType] PT
			ON FP.FinanceProviderID = PT.VendorID
WHERE FP.Active = 1
GO

