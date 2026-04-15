CREATE TABLE [Retail_DW_Core].[FactTraffic_Hourly] (

	[StoreID] int NULL, 
	[TransDate] date NULL, 
	[TransDay] int NULL, 
	[TransHour] decimal(18,2) NULL, 
	[TransHourMinute] decimal(18,2) NULL, 
	[IsOpen] int NOT NULL, 
	[IsOverride] int NOT NULL, 
	[TrafficCount] decimal(19,4) NULL
);