CREATE TABLE [Retail_Dart].[DMTraffic] (

	[LocationID] varchar(50) NULL, 
	[TransDate] date NULL, 
	[TransDay] int NULL, 
	[TransHour] varchar(10) NULL, 
	[TransHourMinute] varchar(10) NULL, 
	[IsOpen] int NULL, 
	[LastUpdated] datetime2(6) NULL, 
	[TrafficCount] decimal(18,2) NULL, 
	[TrafficGuest] decimal(29,2) NULL, 
	[RSAMinutes] int NULL
);