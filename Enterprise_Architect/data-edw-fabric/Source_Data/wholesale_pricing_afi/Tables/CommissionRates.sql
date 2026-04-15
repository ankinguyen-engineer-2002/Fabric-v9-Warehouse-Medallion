CREATE TABLE [wholesale_pricing_afi].[CommissionRates] (

	[Cracommcd] char(3) NOT NULL, 
	[Cracomcls] char(2) NOT NULL, 
	[Cracommpc] decimal(6,4) NOT NULL, 
	[Crasdate] datetime2(6) NULL, 
	[Craedate] datetime2(6) NULL, 
	[Cracbasad] decimal(10,3) NOT NULL, 
	[Commaudit] bit NOT NULL, 
	[Usra] varchar(32) NULL, 
	[Dtea] datetime2(6) NULL, 
	[Usrc] varchar(32) NULL, 
	[Dtec] datetime2(6) NULL, 
	[Acrec] char(1) NOT NULL
);