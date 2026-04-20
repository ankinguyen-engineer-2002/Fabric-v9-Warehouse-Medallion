CREATE TABLE [MasterData_GeographicData].[CountyMaster] (

	[ctnCntycd] char(3) NULL, 
	[ctnTerrcd] char(5) NULL, 
	[ctnState] char(2) NULL, 
	[ctnCounty] varchar(30) NULL, 
	[ctnCensus] int NULL, 
	[ctnRzone] char(3) NULL, 
	[ctnMsa_fips] char(4) NULL, 
	[ctnCountry] char(3) NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[acrec] char(1) NULL, 
	[ctnResponsibleRegion] char(3) NULL, 
	[ctnCountyFips] char(5) NULL, 
	[ctnDMAName] varchar(40) NULL, 
	[ctnCBSAName] varchar(50) NULL, 
	[ctnCBSACode] char(5) NULL, 
	[ctnCBSAType] char(5) NULL
);