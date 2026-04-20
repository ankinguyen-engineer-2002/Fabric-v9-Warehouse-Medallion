CREATE TABLE [wholesale_pricing_afi].[FreightClass] (

	[fclFrtcls] char(2) NULL, 
	[fclFrtdesc] varchar(25) NULL, 
	[fclFrtype] varchar(10) NULL, 
	[fclDivision] char(1) NULL, 
	[fcldefwhse] bit NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[acrec] char(1) NULL, 
	[fclExtendedCode] char(2) NULL
);