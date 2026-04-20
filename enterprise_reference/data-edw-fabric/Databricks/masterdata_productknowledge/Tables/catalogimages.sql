CREATE TABLE [masterdata_productknowledge].[catalogimages] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[cimSeriesNumber] varchar(8000) NULL, 
	[cimImageType] varchar(8000) NULL, 
	[cimImageName] varchar(8000) NULL, 
	[cimMasterImage] bit NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[cimAcRec] varchar(8000) NULL
);

