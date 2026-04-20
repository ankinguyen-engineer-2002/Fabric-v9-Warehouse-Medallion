CREATE TABLE [Retail_DW_Core].[LEAS_DimLocation] (

	[LocationID] varchar(8000) NULL, 
	[LocationKey] int NULL, 
	[LocationType] varchar(8000) NULL, 
	[ServiceLocationID] varchar(8000) NULL, 
	[StockLocationID] varchar(8000) NULL, 
	[ShipLocationID] varchar(8000) NULL, 
	[StoreBrandID] varchar(8000) NULL, 
	[AFHSFlag] int NULL, 
	[LocationName] varchar(8000) NULL, 
	[Store] varchar(8000) NULL, 
	[Address1] varchar(8000) NULL, 
	[City] varchar(8000) NULL, 
	[PostalCodeID] varchar(8000) NULL, 
	[TotalSquareFeet] int NULL, 
	[ProductiveSquareFeet] decimal(18,4) NULL, 
	[OpenDate] date NULL, 
	[SameStoreDate] date NULL, 
	[CompFlag] varchar(8000) NULL
);