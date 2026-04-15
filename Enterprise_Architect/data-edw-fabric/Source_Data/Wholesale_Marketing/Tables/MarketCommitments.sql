CREATE TABLE [Wholesale_Marketing].[MarketCommitments] (

	[Mkcmarket] varchar(12) NULL, 
	[Mkcrepid] char(5) NULL, 
	[Mkccustomernum] char(8) NULL, 
	[Mkcshiptonum] char(4) NULL, 
	[Mkchomestoreflag] bit NULL, 
	[Mkcitemnum] varchar(17) NULL, 
	[Mkcmonthlyestqty] decimal(5,2) NULL, 
	[Mkccommitment] int NULL, 
	[Mkcuserid] varchar(32) NULL, 
	[Mkcdatechanged] datetime2(6) NULL, 
	[Usra] varchar(32) NULL, 
	[Dtea] datetime2(6) NULL, 
	[Usrc] varchar(32) NULL, 
	[Dtec] datetime2(6) NULL, 
	[Mkchomestorecommitment] int NULL, 
	[Mkcregion] char(3) NULL, 
	[Mkchomestoreqty] int NULL, 
	[Mkcnonhomestoreqty] int NULL
);