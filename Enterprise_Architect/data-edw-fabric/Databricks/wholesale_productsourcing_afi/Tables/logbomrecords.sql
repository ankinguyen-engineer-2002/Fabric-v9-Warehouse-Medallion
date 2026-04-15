CREATE TABLE [wholesale_productsourcing_afi].[logbomrecords] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[lbrParentItemID] varchar(8000) NULL, 
	[lbrParentLocation] varchar(8000) NULL, 
	[lbrStructureSeqNum] int NULL, 
	[lbrComponentItemID] varchar(8000) NULL, 
	[lbrComponentLocation] varchar(8000) NULL, 
	[lbrUsageRate] decimal(38,18) NULL, 
	[lbrPopularity] decimal(38,18) NULL, 
	[lbrBeginDate] datetime2(6) NULL, 
	[lbrEndDate] datetime2(6) NULL, 
	[lbrImportString] varchar(8000) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL
);

