CREATE TABLE [SupplyChain_Enh].[ActualsCustItemWH_AFI] (

	[AccountAndShipToNumber] varchar(13) NULL, 
	[ItemSKU] varchar(15) NULL, 
	[Warehouse] char(3) NULL, 
	[OrderQuantity] int NULL, 
	[OrderAmount] numeric(10,3) NULL, 
	[OrigReqWkEnding] date NULL, 
	[CurReqWkEnding] date NULL, 
	[ShipWkEnding] date NULL, 
	[SalesType] char(7) NULL, 
	[Status] varchar(10) NULL, 
	[InsertedDate] datetime2(6) NULL
);