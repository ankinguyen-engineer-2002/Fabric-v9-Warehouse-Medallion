CREATE TABLE [Masterdata_Finance].[ResidentHomeOHOOInventoryOnHand] (

	[FileDate] date NULL, 
	[loadDate] date NULL, 
	[Product] varchar(200) NULL, 
	[Category] varchar(250) NULL, 
	[SKU] varchar(200) NULL, 
	[AFI_SKU] varchar(100) NULL, 
	[Warehouse] varchar(100) NULL, 
	[Legacy_current_WH] varchar(50) NULL, 
	[OnHandUnits] int NULL
);