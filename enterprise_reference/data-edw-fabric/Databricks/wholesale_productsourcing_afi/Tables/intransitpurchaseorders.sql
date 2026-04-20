CREATE TABLE [wholesale_productsourcing_afi].[intransitpurchaseorders] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[invPONumber] varchar(8000) NULL, 
	[invItemSKU] varchar(8000) NULL, 
	[invVendorNumber] varchar(8000) NULL, 
	[invWarehouseCode] varchar(8000) NULL, 
	[invDueDate] datetime2(6) NULL, 
	[invInTransitDollars] decimal(38,18) NULL, 
	[invInTransitQuantity] decimal(38,18) NULL, 
	[invInTransitCubes] decimal(38,18) NULL, 
	[invInTransitWeight] decimal(38,18) NULL
);

