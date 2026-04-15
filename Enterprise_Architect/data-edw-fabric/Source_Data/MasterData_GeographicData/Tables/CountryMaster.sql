CREATE TABLE [MasterData_GeographicData].[CountryMaster] (

	[ctrCountry] char(3) NULL, 
	[ctrDescrip] varchar(30) NULL, 
	[ctrTerrcd] char(5) NULL, 
	[ctrEscheduleSession] varchar(100) NULL, 
	[ctrDescartesCntryCd] char(2) NULL, 
	[ctrRouteZone] varchar(3) NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[acrec] char(1) NULL, 
	[ctrCurrencyCode] char(3) NULL, 
	[ctrCountryOfOriginShipLabel] int NULL
);