CREATE TABLE [wholesale_pricing_afi].[CustomerPricingSetup] (

	[cprCustomerNumber] varchar(8) NOT NULL, 
	[cprShiptoNumber] varchar(4) NOT NULL, 
	[cprID] varchar(2) NOT NULL, 
	[cprStartDate] datetime2(6) NOT NULL, 
	[cprCode] varchar(6) NOT NULL, 
	[cprLastUserChanged] varchar(30) NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[commaudit2] bit NULL
);