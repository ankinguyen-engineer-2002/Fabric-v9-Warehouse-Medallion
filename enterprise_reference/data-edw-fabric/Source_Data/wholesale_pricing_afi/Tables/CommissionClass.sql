CREATE TABLE [wholesale_pricing_afi].[CommissionClass] (

	[cclComCls] char(2) NULL, 
	[cclCommDesc] varchar(25) NULL, 
	[cclDivCode] char(1) NULL, 
	[cclCmrtbl] char(1) NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[acrec] char(1) NULL, 
	[cclSalesCategory] char(3) NULL
);