CREATE TABLE [wholesale_pricing_afi].[FreightCodes] (

	[fcoFrcode] char(3) NULL, 
	[fcoFrdesc] varchar(30) NULL, 
	[fcoFrtype] char(1) NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[acrec] char(1) NULL, 
	[fcoCurrencyCode] char(3) NULL
);