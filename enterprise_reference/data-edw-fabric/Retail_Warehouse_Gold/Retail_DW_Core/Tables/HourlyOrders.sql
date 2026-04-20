CREATE TABLE [Retail_DW_Core].[HourlyOrders] (

	[OrderID] varchar(8000) NULL, 
	[OrderSourceID] varchar(8000) NULL, 
	[DlvyChrg] decimal(19,4) NULL, 
	[RecStatus] varchar(8000) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[OrderBookedStoreID] varchar(8000) NULL, 
	[OrderDate] date NULL, 
	[Invoiced] int NOT NULL
);