CREATE TABLE [masterdata_productknowledge].[multipleitemdimensions] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[mdmID] int NULL, 
	[mdmItnbr] varchar(8000) NULL, 
	[mdmDimDescr] varchar(8000) NULL, 
	[mdmDimString] varchar(8000) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[mdmWidthIn] decimal(38,18) NULL, 
	[mdmDepthIn] decimal(38,18) NULL, 
	[mdmHeightIn] decimal(38,18) NULL, 
	[mdmAlternateDimIn] decimal(38,18) NULL, 
	[mdmWidthMm] decimal(38,18) NULL, 
	[mdmDepthMm] decimal(38,18) NULL, 
	[mdmHeightMm] decimal(38,18) NULL, 
	[mdmAlternateDimMm] decimal(38,18) NULL
);

