CREATE TABLE [masterdata_security].[grouppermissions] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[gprUserLogin] varchar(8000) NULL, 
	[gprGroupId] varchar(8000) NULL, 
	[gprFlag] varchar(8000) NULL, 
	[gprStatFlag] varchar(8000) NULL, 
	[gprPendFlag] varchar(8000) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL
);

