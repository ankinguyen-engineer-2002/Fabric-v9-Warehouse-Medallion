CREATE TABLE [masterdata_security].[customer] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[secCusno] varchar(8000) NULL, 
	[secShpno] varchar(8000) NULL, 
	[secMhs_name] varchar(8000) NULL, 
	[secCustomerRank] decimal(38,18) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL
);

