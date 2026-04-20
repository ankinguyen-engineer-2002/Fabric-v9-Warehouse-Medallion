CREATE TABLE [Retail_Corporate_Wrk].[Product_Pricing] (

	[Operation] varchar(15) NULL, 
	[CompanyID] varchar(50) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[InvTypeCodeID] int NULL, 
	[LastBatchID] int NULL, 
	[PrimaryKey] varchar(50) NULL, 
	[ProductAdjID] varchar(50) NULL, 
	[ProductID] varchar(50) NULL, 
	[RecStatus] char(1) NULL, 
	[SaleEndDt] datetime2(6) NULL, 
	[SaleStartDt] datetime2(6) NULL, 
	[SellingPrice] numeric(19,4) NULL, 
	[SourceID] varchar(50) NULL
);