CREATE TABLE [wholesale_pricing_afi].[PriceCode] (

	[pcoPccode] char(6) NULL, 
	[pcoPcdesc] varchar(30) NULL, 
	[pcoAshfreight] char(1) NULL, 
	[pcoMilfreight] char(1) NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[acrec] char(1) NULL, 
	[pcoDefaultBasePrice] char(1) NULL, 
	[pcoIncludeVAT] varchar(10) NULL, 
	[pcoCurrencyCode] char(3) NULL
);