CREATE TABLE [Retail_Miniapps].[tbl_FinanceProviderMapping] (

	[Operation] varchar(50) NOT NULL, 
	[FinanceProviderMappingID] int NOT NULL, 
	[FinanceProviderID] varchar(20) NOT NULL, 
	[PaymentTypeVendorID] varchar(100) NULL, 
	[Tier] int NULL, 
	[Active] bit NULL
);