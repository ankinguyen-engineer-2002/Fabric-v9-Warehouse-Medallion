CREATE TABLE [Retail_Sales].[CreditApplication] (

	[ApplicationDate] date NULL, 
	[ApplicationSignedByCoApplicant] bit NULL, 
	[ApplicationSignedByMainApplicant] bit NULL, 
	[CreatedByThirdParty] bit NULL, 
	[CreditApplicationID] varchar(50) NOT NULL, 
	[CreditBureauID] varchar(50) NULL, 
	[CreditSourceTypeID] varchar(10) NOT NULL, 
	[CreditStorisReferenceNumber] varchar(50) NULL, 
	[CustomerID] varchar(50) NULL, 
	[DateChanged] datetime2(3) NULL, 
	[DateCreated] datetime2(3) NULL, 
	[FinanceProviderID] varchar(50) NULL, 
	[IsHistory] bit NULL, 
	[LastBatchID] int NULL, 
	[PaymentTypeID] varchar(50) NULL, 
	[RecStatus] char(1) NULL, 
	[RequestedAmount] decimal(19,4) NULL, 
	[SalesPersonID] varchar(50) NULL, 
	[SourceID] varchar(50) NOT NULL, 
	[SubmissionDate] date NULL
);