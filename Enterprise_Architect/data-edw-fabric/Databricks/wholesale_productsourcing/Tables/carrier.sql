CREATE TABLE [wholesale_productsourcing].[carrier] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[carid] int NULL, 
	[carname] varchar(8000) NULL, 
	[carSCAC] varchar(8000) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[carActive] bit NULL, 
	[carWebsite] varchar(8000) NULL, 
	[carParentCarrierID] int NULL, 
	[carCLSQualified] bit NULL
);

