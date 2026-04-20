CREATE TABLE [Retail_Corporate_Wrk].[Invoice_PaymentInfo] (

	[Operation] varchar(15) NULL, 
	[AuthNbr] varchar(50) NULL, 
	[CompanyID] varchar(50) NOT NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[DrvLicExpDate] varchar(50) NULL, 
	[OrderID] varchar(50) NOT NULL, 
	[PaymentAmt] decimal(19,4) NULL, 
	[PaymentNbr] int NOT NULL, 
	[PaymentTypeID] varchar(50) NOT NULL, 
	[PostDate] datetime2(6) NULL, 
	[PostTime] datetime2(6) NULL, 
	[RecStatus] char(1) NULL, 
	[ReferenceNbr] varchar(255) NULL, 
	[SourceID] varchar(50) NOT NULL, 
	[TransDate] datetime2(6) NULL
);