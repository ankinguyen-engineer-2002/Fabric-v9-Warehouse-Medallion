CREATE TABLE [Retail_Ecommerce].[RetailDiscountPriceGroup] (

	[DefinitionGroup] varchar(60) NOT NULL, 
	[ExecutionID] varchar(90) NOT NULL, 
	[IsSelected] int NOT NULL, 
	[TransferStatus] int NOT NULL, 
	[OfferID] varchar(20) NOT NULL, 
	[PriceGroupID] varchar(10) NOT NULL, 
	[Partition] varchar(20) NOT NULL, 
	[DataAreaID] char(4) NOT NULL, 
	[SyncStartDatetime] datetime2(6) NOT NULL, 
	[RecID] bigint NOT NULL
);