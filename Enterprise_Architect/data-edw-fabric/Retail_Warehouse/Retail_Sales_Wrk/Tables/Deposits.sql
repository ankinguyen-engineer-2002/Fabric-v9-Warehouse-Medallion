CREATE TABLE [Retail_Sales_Wrk].[Deposits] (

	[CustomerID] varchar(50) NOT NULL, 
	[DateChanged] datetime2(3) NULL, 
	[DateCreated] datetime2(3) NULL, 
	[DepositDate] date NOT NULL, 
	[DepositsId] varchar(50) NOT NULL, 
	[IsFinanced] bit NULL, 
	[IsHistory] bit NOT NULL, 
	[OrderID] varchar(50) NOT NULL, 
	[PaymentAmt] decimal(18,2) NULL, 
	[PaymentAuthNbr] varchar(50) NULL, 
	[PaymentDLorCheckNumber] varchar(50) NULL, 
	[PaymentExpDate] date NULL, 
	[PaymentNbr] varchar(50) NULL, 
	[PaymentNSFReference] varchar(50) NOT NULL, 
	[PaymentTypeID] varchar(50) NOT NULL, 
	[RecStatus] varchar(1) NOT NULL, 
	[ReferenceNbr] varchar(100) NULL, 
	[Sequence] int NOT NULL, 
	[SourceID] varchar(50) NOT NULL, 
	[WorkStatus] varchar(50) NULL
);