CREATE TABLE [wholesale_pricing_afi].[BuyGroupMember] (

	[bmeCusno] char(8) NULL, 
	[bmeShpno] char(4) NULL, 
	[bmeSdate] datetime2(6) NULL, 
	[bmeEdate] datetime2(6) NULL, 
	[bmeBgcode] char(3) NULL, 
	[commaudit] bit NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[acrec] char(1) NULL, 
	[bmeUseDiscountProgram] char(1) NULL
);