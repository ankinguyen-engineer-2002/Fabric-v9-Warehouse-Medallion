CREATE TABLE [MasterData_Security].[GroupPermissions] (

	[Gpruserlogin] varchar(27) NULL, 
	[Gprgroupid] varchar(37) NULL, 
	[Gprflag] char(2) NULL, 
	[Gprstatflag] char(2) NULL, 
	[Gprpendflag] char(2) NULL, 
	[Usra] varchar(42) NULL, 
	[Dtea] datetime2(6) NULL, 
	[Usrc] varchar(42) NULL, 
	[Dtec] datetime2(6) NULL
);