CREATE TABLE [Retail_DW_Core].[SOCloseHour]
 (
	[SuperOrderID] [varchar](8000) NOT NULL,
	[CustomerID] [varchar](8000) NULL,
	[StoreID] [varchar](8000) NULL,
	[OrderDateKey] [varchar](8) NULL,
	[SalesPersonID] [varchar](8000) NULL,
	[TransDateKey] [varchar](8) NULL,
	[OrderID] [varchar](8000) NULL,
	[Sales] [decimal](38,4) NULL,
	[SPClose] [decimal](38,4) NULL,
	[SUClose] [decimal](18,2) NULL,
	[SOClose] [decimal](18,2) NULL
);