CREATE TABLE [Wholesale_Marketing].[BusinessType] (

	[Btybtcode] char(2) NULL, 
	[Btybtdesc] varchar(32) NULL, 
	[Btybtgroup] char(5) NULL, 
	[Btylocator] bit NULL, 
	[Btybtyrental] bit NULL, 
	[Usra] varchar(32) NULL, 
	[Dtea] datetime2(6) NULL, 
	[Usrc] varchar(32) NULL, 
	[Dtec] datetime2(6) NULL, 
	[Acrec] char(1) NULL, 
	[Btyrptbustype] varchar(52) NULL
);