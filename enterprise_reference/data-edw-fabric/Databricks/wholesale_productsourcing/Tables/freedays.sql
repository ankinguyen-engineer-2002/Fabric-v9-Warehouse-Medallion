CREATE TABLE [wholesale_productsourcing].[freedays] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[frdCarrierId] int NULL, 
	[frdWarehouse] varchar(8000) NULL, 
	[frdFreeDays] int NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[frdDailyPerDiemRate] int NULL, 
	[frdStopClock] varchar(8000) NULL, 
	[SnapShotDate] datetime2(6) NULL, 
	[frdID] int NULL, 
	[frdEffectiveDate] datetime2(6) NULL, 
	[frdDateEffectivity] int NULL, 
	[frdOutgateDateDay1] varchar(8000) NULL, 
	[frdETAPortID] int NULL
);

