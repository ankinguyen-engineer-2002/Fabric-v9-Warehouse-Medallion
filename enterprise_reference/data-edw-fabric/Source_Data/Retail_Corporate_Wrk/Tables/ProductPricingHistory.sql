CREATE TABLE [Retail_Corporate_Wrk].[ProductPricingHistory] (

	[Operation] varchar(15) NULL, 
	[CompanyID] varchar(50) NOT NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[InvTypeCodeID] int NOT NULL, 
	[PrimaryKey] varchar(50) NOT NULL, 
	[ProductAdjID] varchar(50) NULL, 
	[ProductID] varchar(50) NOT NULL, 
	[RecStatus] varchar(1) NULL, 
	[SaleEndDt] datetime2(6) NULL, 
	[SaleStartDt] datetime2(6) NULL, 
	[SellingPrice] decimal(19,9) NOT NULL, 
	[SourceID] varchar(50) NOT NULL, 
	[TransDate] datetime2(6) NULL
);