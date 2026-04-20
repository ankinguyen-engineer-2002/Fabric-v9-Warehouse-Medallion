CREATE TABLE [Retail_Corporate_Wrk].[OrderFulfillment_TaxDetail] (

	[Operation] varchar(15) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[NonRebateTaxableAmount] numeric(19,4) NULL, 
	[OrderFulfillmentID] varchar(50) NULL, 
	[RebateTaxableSubtotal] numeric(19,4) NULL, 
	[RecStatus] char(1) NULL, 
	[SourceID] varchar(50) NULL, 
	[TaxableMerchAmt] numeric(19,4) NULL, 
	[TaxAmt] numeric(19,4) NULL, 
	[TaxCodeID] varchar(50) NULL, 
	[TaxRate] numeric(18,6) NULL, 
	[TaxRateReduced] bit NULL, 
	[TaxType] varchar(10) NULL
);