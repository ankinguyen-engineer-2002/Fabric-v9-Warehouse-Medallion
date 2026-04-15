CREATE TABLE [Retail_DW_NonCore].[FactInventoryDailySummary] (

	[TransDateKey] int NULL, 
	[LocationID] varchar(50) NULL, 
	[StoreBrandID] varchar(50) NOT NULL, 
	[ReasonCodeID] varchar(50) NULL, 
	[PieceStatusID] int NULL, 
	[InvSubBucketID] varchar(50) NULL, 
	[Qty] int NULL, 
	[MaterialCost] decimal(18,2) NOT NULL, 
	[LandedFreight] decimal(18,2) NOT NULL, 
	[Addon1Cost] decimal(18,2) NOT NULL, 
	[Addon2Cost] decimal(18,2) NOT NULL, 
	[Addon3Cost] decimal(18,2) NOT NULL, 
	[Addon4Cost] decimal(18,2) NOT NULL, 
	[TotalCost] decimal(18,2) NOT NULL
);