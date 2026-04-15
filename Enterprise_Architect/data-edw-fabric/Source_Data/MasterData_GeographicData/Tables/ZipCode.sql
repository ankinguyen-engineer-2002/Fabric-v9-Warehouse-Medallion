CREATE TABLE [MasterData_GeographicData].[ZipCode] (

	[zipZzipcd] varchar(5) NOT NULL, 
	[zipZstate] varchar(2) NOT NULL, 
	[zipZctynm] varchar(25) NOT NULL, 
	[zipZctyab] varchar(10) NOT NULL, 
	[zipZconyn] varchar(3) NOT NULL, 
	[zipZcountry] varchar(3) NOT NULL, 
	[zipMSA] varchar(4) NOT NULL, 
	[zipTimeZoneCode] varchar(5) NOT NULL, 
	[zipDayLightSavings] char(1) NOT NULL, 
	[zipLat] decimal(7,4) NOT NULL, 
	[zipLong] decimal(8,4) NOT NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[acrec] varchar(1) NULL, 
	[zipPreferred] bit NULL
);