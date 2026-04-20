CREATE TABLE [wholesale_pricing_afi].[PriceList] (

	[pliPcode] char(6) NULL, 
	[pliItnbr] varchar(15) NULL, 
	[pliPrice] numeric(13,3) NULL, 
	[pliPcmadj] numeric(13,3) NULL, 
	[pliPwhsop] numeric(5,2) NULL, 
	[pliSdate] datetime2(6) NULL, 
	[pliEdate] datetime2(6) NULL, 
	[commaudit] bit NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[acrec] char(1) NULL
);