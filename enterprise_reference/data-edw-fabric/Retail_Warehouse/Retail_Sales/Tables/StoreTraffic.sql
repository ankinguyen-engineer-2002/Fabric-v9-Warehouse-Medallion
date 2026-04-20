CREATE TABLE [Retail_Sales].[StoreTraffic] (

	[DataSource] varchar(10) NULL, 
	[DeviceSourceID] varchar(20) NOT NULL, 
	[LocationKey] varchar(20) NOT NULL, 
	[TransDate] date NOT NULL, 
	[TransTime] datetime2(3) NOT NULL, 
	[GuestEntry] int NULL, 
	[GuestExit] int NULL, 
	[DataIndicator] char(5) NULL, 
	[LoadDate] datetime2(3) NULL
);
