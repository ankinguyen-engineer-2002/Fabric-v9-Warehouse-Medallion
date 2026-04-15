CREATE TABLE [Retail_Dart].[FinanceSalesAttribution] (

	[CustomerID] varchar(50) NULL, 
	[EmailAddress] varchar(70) NULL, 
	[RequestDate] date NULL, 
	[SalespersonID] varchar(50) NULL, 
	[StoreID] varchar(50) NULL, 
	[AmountApproved] decimal(19,2) NULL, 
	[FinanceProviderID] varchar(50) NULL, 
	[ApprovedByLendor] varchar(255) NULL, 
	[Region] varchar(50) NULL, 
	[Division] varchar(50) NULL, 
	[BuyDayApproval] decimal(19,2) NULL, 
	[FinanceDayApproval] decimal(38,2) NULL, 
	[SendDateOTB] date NULL, 
	[InitialOTB] decimal(38,2) NULL, 
	[BuyAfterSendEmail] decimal(19,2) NULL, 
	[FinanceAfterSendEmail] decimal(38,2) NULL, 
	[BuyAfterAproval] decimal(19,2) NULL, 
	[Attribution] varchar(30) NOT NULL, 
	[CreationDate] datetime2(6) NULL
);