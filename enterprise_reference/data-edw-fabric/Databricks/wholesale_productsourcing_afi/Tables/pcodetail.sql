CREATE TABLE [wholesale_productsourcing_afi].[pcodetail] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[codPCONumber] int NULL, 
	[codItemNumber] varchar(8000) NULL, 
	[codWarehouse] varchar(8000) NULL, 
	[codVendorNumber] varchar(8000) NULL, 
	[codOldSplit] decimal(38,18) NULL, 
	[codNewSplit] decimal(38,18) NULL, 
	[codOldEAU] decimal(38,18) NULL, 
	[codNewEAU] decimal(38,18) NULL, 
	[codOldPrice] decimal(38,18) NULL, 
	[codNewPrice] decimal(38,18) NULL, 
	[codOldFreight] decimal(38,18) NULL, 
	[codNewFreight] decimal(38,18) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL
);

