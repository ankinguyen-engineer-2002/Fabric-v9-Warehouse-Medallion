CREATE TABLE [Retail_Sales_Wrk].[InvoicePaymentInfo] (

	[AuthNbr] varchar(50) NULL, 
	[CompanyID] varchar(50) NOT NULL, 
	[DateChanged] datetime2(3) NULL, 
	[DateCreated] datetime2(3) NULL, 
	[DrvLicExpDate] varchar(50) NULL, 
	[OrderID] varchar(50) NOT NULL, 
	[PaymentAmt] decimal(18,9) NOT NULL, 
	[PaymentNbr] int NOT NULL, 
	[PaymentTypeID] varchar(50) NOT NULL, 
	[PostDate] datetime2(3) NULL, 
	[PostTime] datetime2(3) NULL, 
	[RecStatus] varchar(1) NULL, 
	[ReferenceNbr] varchar(255) NULL, 
	[SourceID] varchar(50) NOT NULL, 
	[TransDate] datetime2(3) NULL
);