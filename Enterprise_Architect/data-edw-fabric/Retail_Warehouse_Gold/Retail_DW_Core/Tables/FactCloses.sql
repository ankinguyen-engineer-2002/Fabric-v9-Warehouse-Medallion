CREATE TABLE [Retail_DW_Core].[FactCloses] (

	[SuperOrderID] varchar(50) NOT NULL, 
	[SourceOrderID] varchar(100) NULL, 
	[CountTypeID] varchar(10) NULL, 
	[CustomerKey] bigint NULL, 
	[LocationKey] bigint NULL, 
	[SalesPersonKey] bigint NULL, 
	[OrderDateKey] bigint NULL, 
	[TransDateKey] bigint NULL, 
	[SPSales] decimal(19,4) NULL, 
	[SPClose] decimal(19,4) NULL, 
	[SuperOrderClose] decimal(19,4) NULL, 
	[SUOpp] decimal(19,4) NULL, 
	[SOClose] decimal(19,4) NULL, 
	[SOOpp] decimal(19,4) NULL, 
	[CurrentRec] int NULL, 
	[LYComp] int NULL, 
	[TYComp] int NULL, 
	[DateChanged] datetime2(3) NULL
);