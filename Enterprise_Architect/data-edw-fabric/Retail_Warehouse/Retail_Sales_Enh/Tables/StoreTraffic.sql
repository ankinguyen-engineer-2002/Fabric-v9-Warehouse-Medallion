CREATE TABLE [Retail_Sales_Enh].[StoreTraffic] (

	[DataSource] varchar(5) NULL, 
	[DeviceSourceID] varchar(20) NULL, 
	[StoreID] int NOT NULL, 
	[TransDate] date NOT NULL, 
	[TransDay] int NOT NULL, 
	[TransHour] decimal(18,2) NOT NULL, 
	[TransHourMinute] decimal(18,2) NOT NULL, 
	[TransCount] decimal(18,2) NULL, 
	[IsOpen] int NULL, 
	[LastUpdated] datetime2(3) NULL, 
	[TrafficCount] decimal(18,2) NULL, 
	[RSAMinutes] int NULL, 
	[IsOverride] int NULL
);


