CREATE TABLE [Retail_DW_Core].[FactCustomerFinanceActivity] (

	[AmountApproved] decimal(18,2) NULL, 
	[CreditApplicationID] varchar(50) NULL, 
	[CreditRequestStatusCodeID] int NULL, 
	[CreditReviewID] varchar(50) NOT NULL, 
	[CreditReviewStatusCodeID] varchar(10) NULL, 
	[CreditStorisReferenceNumber] varchar(50) NULL, 
	[CustomerID] varchar(50) NULL, 
	[CustomerKey] int NULL, 
	[QueuedDateTime] datetime2(3) NULL, 
	[TransDateKey] int NULL, 
	[SalespersonID] varchar(50) NULL, 
	[SalespersonKey] int NULL, 
	[StoreID] varchar(50) NULL, 
	[LocationKey] int NULL, 
	[FinanceProviderID] varchar(20) NULL
);