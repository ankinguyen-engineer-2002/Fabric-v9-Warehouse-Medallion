CREATE TABLE [MasterData_Security].[GroupProfile] (

	[Grpsecurityid] int NULL, 
	[Grpgroupid] varchar(52) NULL, 
	[Grpdescription] varchar(52) NULL, 
	[Grpflagdev] bit NULL, 
	[Grpflagstage] bit NULL, 
	[Grpflagprod] bit NULL, 
	[Grpflagbeta] bit NULL, 
	[Usra] varchar(42) NULL, 
	[Dtea] datetime2(6) NULL, 
	[Usrc] varchar(42) NULL, 
	[Dtec] datetime2(6) NULL
);