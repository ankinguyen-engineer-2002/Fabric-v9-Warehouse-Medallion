CREATE TABLE [wholesale_pricing_afi].[FreightZones] (

	[fzoCountry] char(3) NULL, 
	[fzoState] char(2) NULL, 
	[fzoZip] char(5) NULL, 
	[fzoZipext] char(4) NULL, 
	[fzoFzone] char(5) NULL, 
	[fzoFwhse] char(3) NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[acrec] char(1) NULL
);