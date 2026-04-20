CREATE TABLE [Retail_DW_Core].[SMQQ_FactLocationMaster] (

	[LocationID] varchar(8000) NULL, 
	[LocationType] varchar(8000) NULL, 
	[ServiceLocationID] varchar(8000) NULL, 
	[StockLocationID] varchar(8000) NULL, 
	[ShipLocationID] varchar(8000) NULL, 
	[StoreBrandID] varchar(8000) NULL, 
	[LocationName] varchar(8000) NULL, 
	[Address1] varchar(8000) NULL, 
	[City] varchar(8000) NULL, 
	[PostalCodeID] varchar(8000) NULL, 
	[TotalSquareFeet] int NULL, 
	[ProductiveSquareFeet] decimal(18,2) NULL, 
	[OpenDate] date NULL, 
	[SameStoreDate] date NULL, 
	[CompFlag] varchar(8000) NULL, 
	[Store] varchar(8000) NULL
);