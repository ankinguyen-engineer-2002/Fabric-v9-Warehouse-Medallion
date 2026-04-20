CREATE TABLE [Wholesale_ProductSourcing].[Carrier] (

	[carid] int NOT NULL, 
	[carname] varchar(15) NOT NULL, 
	[carSCAC] char(4) NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[carActive] bit NOT NULL, 
	[carWebsite] varchar(100) NOT NULL, 
	[carParentCarrierID] int NOT NULL, 
	[carCLSQualified] bit NOT NULL
);