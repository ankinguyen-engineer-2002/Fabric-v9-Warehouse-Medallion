CREATE TABLE [Retail_Corporate_Wrk].[CreditApplication] (

	[Operation] varchar(15) NULL, 
	[ApplicationDate] date NULL, 
	[ApplicationSignedByCoApplicant] bit NULL, 
	[ApplicationSignedByMainApplicant] bit NULL, 
	[CreatedByThirdParty] bit NULL, 
	[CreditApplicationID] varchar(50) NOT NULL, 
	[CreditBureauID] varchar(50) NULL, 
	[CreditSourceTypeID] varchar(10) NOT NULL, 
	[CreditStorisReferenceNumber] varchar(30) NULL, 
	[CustomerID] varchar(50) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[FinanceProviderID] varchar(50) NULL, 
	[IsHistory] bit NULL, 
	[LastBatchID] int NULL, 
	[PaymentTypeID] varchar(50) NULL, 
	[RecStatus] char(1) NULL, 
	[RequestedAmount] decimal(19,4) NULL, 
	[SalespersonID] varchar(50) NULL, 
	[SourceID] varchar(50) NOT NULL, 
	[SubmissionDate] date NULL
);