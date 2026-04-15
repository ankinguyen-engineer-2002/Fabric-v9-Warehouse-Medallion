CREATE TABLE [wholesale_pricing_afi].[BuyGroupDefault] (

	[bgdBgCode] varchar(3) NOT NULL, 
	[bgdWhse] varchar(3) NOT NULL, 
	[bgdFrChrg] varchar(1) NOT NULL, 
	[bgdDate1] datetime2(6) NOT NULL, 
	[bgdDate2] datetime2(6) NOT NULL, 
	[bgdGcmpct] decimal(6,4) NULL, 
	[bgdLastUserChanged] varchar(30) NOT NULL, 
	[usra] varchar(30) NOT NULL, 
	[dtea] datetime2(6) NOT NULL, 
	[usrc] varchar(30) NOT NULL, 
	[dtec] datetime2(6) NOT NULL, 
	[bgdDisc1] decimal(6,4) NULL, 
	[bgdDisc2] decimal(6,4) NULL, 
	[bgdDisc3] decimal(6,4) NULL, 
	[bgdDisc4] decimal(6,4) NULL, 
	[bgdDisc5] decimal(6,4) NULL, 
	[bgdDisc6] decimal(6,4) NULL, 
	[bgdDisc7] decimal(6,4) NULL, 
	[bgdUseReduction] varchar(1) NOT NULL
);