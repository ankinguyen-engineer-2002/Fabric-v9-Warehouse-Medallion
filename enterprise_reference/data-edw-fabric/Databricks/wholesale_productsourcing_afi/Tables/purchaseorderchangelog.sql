CREATE TABLE [wholesale_productsourcing_afi].[purchaseorderchangelog] (

	[invPurchaseOrderChangeSurrogate] int NULL, 
	[invPONumber] varchar(8000) NULL, 
	[invItemSKU] varchar(8000) NULL, 
	[invVendorNumber] varchar(8000) NULL, 
	[invWarehouseCode] varchar(8000) NULL, 
	[invUserID] varchar(8000) NULL, 
	[invSnapshotPODueDate] datetime2(6) NULL, 
	[invSnapshotPOClosedDate] datetime2(6) NULL, 
	[invSnapshotPOStatusCode] varchar(8000) NULL, 
	[invSnapshotPOStatusDescription] varchar(8000) NULL, 
	[invSnapshotItemDueDate] datetime2(6) NULL, 
	[invSnapshotItemClosedDate] datetime2(6) NULL, 
	[invSnapshotItemStatusCode] varchar(8000) NULL, 
	[invSnapshotItemStatusDescription] varchar(8000) NULL, 
	[invPOLogTransactionDate] datetime2(6) NULL, 
	[invOrderedDollars] decimal(38,18) NULL, 
	[invOrderedQuantity] decimal(38,18) NULL, 
	[invOrderedCubes] decimal(38,18) NULL, 
	[invOrderedWeight] decimal(38,18) NULL
);

