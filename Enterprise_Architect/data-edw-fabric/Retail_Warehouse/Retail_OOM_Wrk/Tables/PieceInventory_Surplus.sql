CREATE TABLE [Retail_OOM_Wrk].[PieceInventory_Surplus] (

	[StoreID] varchar(50) NOT NULL, 
	[ProductID] varchar(50) NOT NULL, 
	[TBOnHand] numeric(18,2) NOT NULL, 
	[DBOnHand] numeric(18,2) NULL, 
	[RateOfSale] numeric(15,2) NULL, 
	[DBDaysOfSupply] numeric(15,2) NULL, 
	[TBDaysOfSupply] numeric(15,2) NULL, 
	[QtyOnFloor] int NULL, 
	[Backordered] int NULL, 
	[BackorderedDespisedMCode] int NULL
);