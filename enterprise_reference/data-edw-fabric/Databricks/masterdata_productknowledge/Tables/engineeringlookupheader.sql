CREATE TABLE [masterdata_productknowledge].[engineeringlookupheader] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[elhLookupCode] int NULL, 
	[elhLookupTitle] varchar(8000) NULL, 
	[elhLookupName] varchar(8000) NULL, 
	[elhLookupDescription] varchar(8000) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[elhSQLConnection] varchar(8000) NULL, 
	[elhSQLDatabaseName] varchar(8000) NULL, 
	[elhSQLCommand] varchar(8000) NULL, 
	[elhIsSQLCommand] bit NULL, 
	[elhIsMultiColumn] bit NULL
);

