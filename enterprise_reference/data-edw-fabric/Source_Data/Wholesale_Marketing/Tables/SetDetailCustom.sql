CREATE TABLE [Wholesale_Marketing].[SetDetailCustom] (

	[Sdccustomer] char(8) NOT NULL, 
	[Sdcsetnumber] varchar(17) NOT NULL, 
	[Sdcitemnumber] varchar(17) NOT NULL, 
	[Sdcqty] decimal(3,0) NOT NULL, 
	[Sdckey] bit NOT NULL, 
	[Usra] varchar(32) NULL, 
	[Dtea] datetime2(6) NULL, 
	[Usrc] varchar(32) NULL, 
	[Dtec] datetime2(6) NULL
);