CREATE TABLE [wholesale_productsourcing_afi].[closedpurchaseorders] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[invPONumber] varchar(8000) NULL, 
	[invItemSKU] varchar(8000) NULL, 
	[invVendorNumber] varchar(8000) NULL, 
	[invWarehouseCode] varchar(8000) NULL, 
	[invDueDate] datetime2(6) NULL, 
	[invUnderShipmentDollars] decimal(38,18) NULL, 
	[invUnderShipmentQuantity] decimal(38,18) NULL, 
	[invUnderShipmentCubes] decimal(38,18) NULL, 
	[invUnderShipmentWeight] decimal(38,18) NULL, 
	[invOverShipmentDollars] decimal(38,18) NULL, 
	[invOverShipmentQuantity] decimal(38,18) NULL, 
	[invOverShipmentCubes] decimal(38,18) NULL, 
	[invOverShipmentWeight] decimal(38,18) NULL, 
	[invInitialReceiptDaysEarly] int NULL, 
	[invInitialReceiptDaysLate] int NULL, 
	[invLeadtimeDays] int NULL, 
	[invClosedDollars] decimal(38,18) NULL, 
	[invClosedQuantity] decimal(38,18) NULL, 
	[invClosedCubes] decimal(38,18) NULL, 
	[invClosedWeight] decimal(38,18) NULL, 
	[ETLFlag] varchar(8000) NULL
);

