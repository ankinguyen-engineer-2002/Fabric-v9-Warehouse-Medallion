CREATE TABLE [Retail_Dart].[FinanceProvider] (

	[Address1] varchar(255) NULL, 
	[Address2] varchar(255) NULL, 
	[AllowFinanceB4Approval] bit NULL, 
	[City] varchar(255) NULL, 
	[Contact] varchar(255) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[Fax] varchar(12) NULL, 
	[FinanceProviderID] varchar(50) NOT NULL, 
	[NAME] varchar(255) NULL, 
	[NotifyFinanceProvider] bit NULL, 
	[PaymentTypeID] varchar(50) NULL, 
	[Phone] varchar(12) NULL, 
	[PhoneExt] varchar(10) NULL, 
	[PostalCodeID] varchar(50) NULL, 
	[PostMethod] char(5) NULL, 
	[RecStatus] char(1) NULL, 
	[SettlementType] varchar(10) NULL, 
	[SourceID] varchar(50) NULL, 
	[STATE] varchar(10) NULL, 
	[XmitBothExchangeTransations] bit NULL
);