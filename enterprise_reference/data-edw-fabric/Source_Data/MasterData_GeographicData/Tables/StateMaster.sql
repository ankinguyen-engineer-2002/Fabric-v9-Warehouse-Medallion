CREATE TABLE [MasterData_GeographicData].[StateMaster] (

	[staState] char(2) NULL, 
	[staDescrip] varchar(25) NULL, 
	[staCountry] char(3) NULL, 
	[staTerrcd] char(5) NULL, 
	[staState_fips] char(2) NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[acrec] char(1) NULL
);