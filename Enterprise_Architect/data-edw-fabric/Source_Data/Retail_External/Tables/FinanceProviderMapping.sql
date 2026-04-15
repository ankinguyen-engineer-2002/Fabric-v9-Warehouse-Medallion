CREATE TABLE [Retail_External].[FinanceProviderMapping] (

	[FinanceProviderMappingID] int NULL, 
	[FinanceProviderID] varchar(20) NULL, 
	[PaymentTypeVendorID] varchar(50) NULL, 
	[Tier] int NULL, 
	[Active] bit NULL, 
	[AutoApprovePending] bit NULL, 
	[IsLeasedVendor] int NULL
);