CREATE TABLE [masterdata_productknowledge].[catalogsheetitem] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[csiFileName] varchar(8000) NULL, 
	[csiItemNumber] varchar(8000) NULL, 
	[csiPlannedDrop] bit NULL, 
	[csiBlockItem] bit NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[casID] int NULL
);

