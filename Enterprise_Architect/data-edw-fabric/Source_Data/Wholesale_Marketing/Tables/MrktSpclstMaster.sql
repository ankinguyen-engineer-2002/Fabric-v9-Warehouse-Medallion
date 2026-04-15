CREATE TABLE [Wholesale_Marketing].[MrktSpclstMaster] (

	[Msmslsno] char(5) NULL, 
	[Msmslsnm] varchar(27) NULL, 
	[Msmbusnm] varchar(43) NULL, 
	[Msmrepid] char(5) NULL, 
	[Msmmgrid] char(1) NULL, 
	[Msmmhscode] char(8) NULL, 
	[Msmposition] char(1) NULL, 
	[Msmfid] varchar(12) NULL, 
	[Msmhomec] int NULL, 
	[Usra] varchar(32) NULL, 
	[Dtea] datetime2(6) NULL, 
	[Usrc] varchar(32) NULL, 
	[Dtec] datetime2(6) NULL, 
	[Acrec] char(1) NULL, 
	[Msmstartdate] datetime2(6) NULL, 
	[Msmenddate] datetime2(6) NULL, 
	[Msmuse1099] bit NULL, 
	[Msmterritorydate] date NULL, 
	[Msmgeography] varchar(62) NULL
);