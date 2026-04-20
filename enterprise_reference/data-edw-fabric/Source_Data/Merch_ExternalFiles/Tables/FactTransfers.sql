CREATE TABLE [Merch_ExternalFiles].[FactTransfers] (

	[TransferNumber] varchar(13) NULL, 
	[TransferDate] datetime2(6) NULL, 
	[SendingLocation] int NULL, 
	[TransferFor] varchar(44) NULL, 
	[Product] varchar(20) NULL, 
	[Brand] varchar(5) NULL, 
	[OrderQty] int NULL, 
	[ResQty] int NULL, 
	[BOyQty] int NULL, 
	[ManifestNumber] int NULL, 
	[ReceivingStore] int NULL, 
	[Description11] varchar(30) NULL, 
	[ReceivingRegion] varchar(10) NULL, 
	[Description13] varchar(10) NULL
);