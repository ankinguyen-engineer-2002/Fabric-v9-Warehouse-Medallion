CREATE TABLE [Wholesale_ProductSourcing_AFI].[CustomerGrouping] (

	[CustomerNumber] varchar(10) NOT NULL, 
	[CustomerGroup] varchar(35) NOT NULL, 
	[CustomerGroupLevel3] varchar(35) NOT NULL, 
	[BusinessTypeCode] varchar(35) NOT NULL, 
	[usra] varchar(50) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(50) NULL, 
	[dtec] datetime2(6) NULL
);