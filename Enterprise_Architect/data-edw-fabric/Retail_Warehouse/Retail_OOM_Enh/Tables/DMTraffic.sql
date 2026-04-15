CREATE TABLE [Retail_OOM_Enh].[DMTraffic] (

	[LocationID] varchar(50) NOT NULL, 
	[TransDate] date NULL, 
	[TransDay] int NOT NULL, 
	[TransHour] varchar(10) NOT NULL, 
	[TransHourMinute] varchar(10) NOT NULL, 
	[IsOpen] int NOT NULL, 
	[LastUpdated] datetime2(6) NULL, 
	[TrafficCount] decimal(18,2) NULL, 
	[TrafficGuest] decimal(29,2) NULL, 
	[RSAMinute] int NULL
);