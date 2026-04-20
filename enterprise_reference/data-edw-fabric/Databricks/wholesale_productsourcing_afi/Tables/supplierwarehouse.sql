CREATE TABLE [wholesale_productsourcing_afi].[supplierwarehouse] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[scwWarehouse] varchar(8000) NULL, 
	[scwPurchasingWhse] bit NULL, 
	[scwOverhead] bit NULL, 
	[scwFreight] bit NULL, 
	[scwContainerDirect] bit NULL, 
	[scwActive] bit NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[scwDefaultPricingWarehouse] bit NULL, 
	[scwDefaultCntrLimitWarehouse] bit NULL, 
	[scwManufacturingWhse] varchar(8000) NULL, 
	[scwActiveForLogility] bit NULL, 
	[scwDefaultControlFile] varchar(8000) NULL, 
	[scwDefaultMakeBuyCode] varchar(8000) NULL, 
	[scwDirectShipWarehouse] bit NULL, 
	[scwBondedShipTo] varchar(8000) NULL
);

