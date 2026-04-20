CREATE TABLE [Masterdata_Finance].[ResidentHomeOHOOInventoryOnOrder] (

	[FileDate] date NULL, 
	[loadDate] date NULL, 
	[Product] varchar(200) NULL, 
	[Category] varchar(250) NULL, 
	[SKU] varchar(200) NULL, 
	[AFI_SKU] varchar(100) NULL, 
	[Warehouse] varchar(200) NULL, 
	[Legacy_current_WH] varchar(70) NULL, 
	[ForecastDate] date NULL, 
	[OnOrderUnits] int NULL
);