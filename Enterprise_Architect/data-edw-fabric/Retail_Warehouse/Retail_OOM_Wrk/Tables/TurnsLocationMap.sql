CREATE TABLE [Retail_OOM_Wrk].[TurnsLocationMap] (

	[StoreBrandID] varchar(50) NOT NULL, 
	[LocationID] varchar(50) NOT NULL, 
	[MapToLocationID] varchar(50) NOT NULL, 
	[MapType] varchar(3) NOT NULL, 
	[VendorID] varchar(50) NOT NULL, 
	[AllocPct] decimal(13,3) NULL, 
	[LocationType] varchar(1) NULL
);