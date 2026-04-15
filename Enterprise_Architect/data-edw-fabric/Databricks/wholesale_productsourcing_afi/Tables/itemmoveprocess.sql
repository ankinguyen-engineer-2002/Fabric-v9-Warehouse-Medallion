CREATE TABLE [wholesale_productsourcing_afi].[itemmoveprocess] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[impID] int NULL, 
	[impASProcessID] int NULL, 
	[impFromOrderNum] varchar(8000) NULL, 
	[impFromSequence] int NULL, 
	[impToOrderNum] varchar(8000) NULL, 
	[impToSequence] int NULL, 
	[impItemNum] varchar(8000) NULL, 
	[impQuantity] decimal(38,18) NULL, 
	[impFromAdjustPlanReq] varchar(8000) NULL, 
	[impToAdjustPlanReq] varchar(8000) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL
);

