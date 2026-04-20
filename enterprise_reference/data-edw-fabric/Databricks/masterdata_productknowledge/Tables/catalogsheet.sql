CREATE TABLE [masterdata_productknowledge].[catalogsheet] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[casFileName] varchar(8000) NULL, 
	[casSheetName] varchar(8000) NULL, 
	[casSeriesNumber] varchar(8000) NULL, 
	[casSheetStatus] varchar(8000) NULL, 
	[Acrec] varchar(8000) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[casID] int NULL, 
	[sheetCode] varchar(8000) NULL, 
	[isEvent] bit NULL, 
	[startDate] datetime2(6) NULL, 
	[endDate] datetime2(6) NULL, 
	[url] varchar(8000) NULL
);

