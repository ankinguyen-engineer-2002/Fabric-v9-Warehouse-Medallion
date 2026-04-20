CREATE TABLE [Retail_Corporate].[Order_TaxDetail] (

	[Operation] varchar(15) NULL, 
	[CompanyID] varchar(50) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[DlvyTypeCodeID] varchar(50) NULL, 
	[OrderID] varchar(50) NULL, 
	[RecStatus] char(1) NULL, 
	[SequenceNbr] int NULL, 
	[SourceID] varchar(50) NULL, 
	[TaxAmt] numeric(19,4) NULL, 
	[TaxCodeID] varchar(100) NULL, 
	[TaxMerchAmt] numeric(19,4) NULL, 
	[TaxRate] numeric(18,4) NULL
);