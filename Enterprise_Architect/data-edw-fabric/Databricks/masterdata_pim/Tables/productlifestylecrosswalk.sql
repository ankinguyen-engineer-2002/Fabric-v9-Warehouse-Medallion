CREATE TABLE [masterdata_pim].[productlifestylecrosswalk] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[id] varchar(8000) NULL, 
	[sourceid] bigint NULL, 
	[ItemType] varchar(8000) NULL, 
	[col] varchar(8000) NULL
);