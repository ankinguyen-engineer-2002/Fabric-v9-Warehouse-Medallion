CREATE TABLE [Retail_DW_Core].[DimPaymentType] (

	[PaymentTypeKey] bigint NOT NULL, 
	[PaymentTypeID] varchar(50) NOT NULL, 
	[PaymentTypeName] varchar(100) NULL, 
	[PaymentClass] varchar(10) NULL, 
	[FinanceUseFee] decimal(19,4) NULL, 
	[IsFinanced] int NULL, 
	[PaymentTierLevel] char(1) NULL, 
	[VendorID] varchar(20) NULL, 
	[FinanceProviderName] varchar(30) NULL, 
	[PaymentTypeSubGroupID] char(4) NULL, 
	[PaymentTypeSubGroupName] varchar(20) NULL,
	[TermsDuration] [varchar](20) NULL, 
	[PaymentTypeGroupID] char(2) NULL, 
	[PaymentTermsGrouping] varchar(50) NULL, 
	[StartDate] date NOT NULL, 
	[EndDate] date NOT NULL
);