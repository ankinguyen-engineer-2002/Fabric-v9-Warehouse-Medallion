CREATE TABLE [wholesale_productsourcing_afi].[barcodes] (

	[bcdOrderNum] varchar(8000) NULL, 
	[bcdItemNum] varchar(8000) NULL, 
	[bcdItemSequence] int NULL, 
	[bcdBarCodeStart] decimal(38,18) NULL, 
	[bcdBarCodeFinish] decimal(38,18) NULL, 
	[bcdDiscardLabels] bit NULL, 
	[bcdDiscardReason] varchar(8000) NULL, 
	[bcdConID] int NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[bcdCountryOfOrigin] varchar(8000) NULL, 
	[bcdTrackingNumber] varchar(8000) NULL, 
	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL
);

