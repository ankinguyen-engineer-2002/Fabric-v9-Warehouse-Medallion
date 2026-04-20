CREATE TABLE [Retail_Corporate_Wrk].[PurchaseOrderItem_Receipts] (

	[Operation] varchar(15) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[DateReceived] datetime2(6) NULL, 
	[Position] int NULL, 
	[ProductID] varchar(50) NULL, 
	[PurchaseOrderID] varchar(50) NULL, 
	[PurchaseOrderItemLineID] int NULL, 
	[Quantity] int NULL, 
	[RecStatus] char(1) NULL, 
	[Reference] varchar(100) NULL, 
	[SourceID] varchar(50) NULL
);