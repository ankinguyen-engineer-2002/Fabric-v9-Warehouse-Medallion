CREATE TABLE [wholesale_productsourcing_afi].[onorderpurchaseorders] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[invPONumber] varchar(8000) NULL, 
	[invItemSKU] varchar(8000) NULL, 
	[invVendorNumber] varchar(8000) NULL, 
	[invWarehouseCode] varchar(8000) NULL, 
	[invDeliveryDate] datetime2(6) NULL, 
	[invOnOrderDollars] decimal(38,18) NULL, 
	[invOnOrderQuantity] decimal(38,18) NULL, 
	[invOnOrderCubes] decimal(38,18) NULL, 
	[invOnOrderWeight] decimal(38,18) NULL
);

