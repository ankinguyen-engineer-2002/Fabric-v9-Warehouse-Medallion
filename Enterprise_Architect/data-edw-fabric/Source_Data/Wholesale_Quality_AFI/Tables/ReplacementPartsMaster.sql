CREATE TABLE [Wholesale_Quality_AFI].[ReplacementPartsMaster] (

	[ropModel] varchar(15) NULL, 
	[ropPart] varchar(15) NULL, 
	[ropQtyUsed] int NULL, 
	[ropDesr] varchar(40) NULL, 
	[ropBasePrice] numeric(7,2) NULL, 
	[ropCallout] char(3) NULL, 
	[ropSource] char(2) NULL, 
	[ropDescSrc] char(2) NULL, 
	[ropWarrantyException] bit NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL
);