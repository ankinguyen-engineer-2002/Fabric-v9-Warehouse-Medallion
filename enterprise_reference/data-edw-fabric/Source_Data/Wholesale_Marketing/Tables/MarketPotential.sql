CREATE TABLE [Wholesale_Marketing].[MarketPotential] (

	[Mkpyear] int NULL, 
	[Mkpstate] char(2) NULL, 
	[Mkpcountyfips] char(3) NULL, 
	[Mkpproductline] char(1) NULL, 
	[Mkpamount] decimal(19,4) NULL, 
	[Mkppercentage] decimal(5,4) NULL, 
	[Usra] varchar(32) NULL, 
	[Dtea] datetime2(6) NULL, 
	[Usrc] varchar(32) NULL, 
	[Dtec] datetime2(6) NULL
);