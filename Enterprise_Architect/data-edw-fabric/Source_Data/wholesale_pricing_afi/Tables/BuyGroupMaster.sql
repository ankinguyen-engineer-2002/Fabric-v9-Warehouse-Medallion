CREATE TABLE [wholesale_pricing_afi].[BuyGroupMaster] (

	[bmaBgcode] char(3) NULL, 
	[bmaBgdesc] varchar(25) NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[acrec] char(1) NULL, 
	[bmaShowOnInquiry] bit NULL, 
	[bmaCurrencyCode] char(3) NULL
);