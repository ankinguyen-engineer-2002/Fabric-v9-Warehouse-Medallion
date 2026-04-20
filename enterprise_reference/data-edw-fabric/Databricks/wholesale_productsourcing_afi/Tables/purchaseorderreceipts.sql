CREATE TABLE [wholesale_productsourcing_afi].[purchaseorderreceipts] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[invPOReceiptSurrogate] int NULL, 
	[invPONumber] varchar(8000) NULL, 
	[invItemSKU] varchar(8000) NULL, 
	[invReceiptDate] datetime2(6) NULL, 
	[invVendorNumber] varchar(8000) NULL, 
	[invWarehouseCode] varchar(8000) NULL, 
	[invReceiptDollars] decimal(38,18) NULL, 
	[invReceiptQuantity] decimal(38,18) NULL, 
	[invReceiptCubes] decimal(38,18) NULL, 
	[invReceiptWeight] decimal(38,18) NULL, 
	[ETLFlag] varchar(8000) NULL
);

