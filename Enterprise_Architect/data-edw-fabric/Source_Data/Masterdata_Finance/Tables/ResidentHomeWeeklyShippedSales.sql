CREATE TABLE [Masterdata_Finance].[ResidentHomeWeeklyShippedSales] (

	[WhsTitle] varchar(50) NULL, 
	[OrderCreatedDate] date NULL, 
	[InvoiceDate] date NULL, 
	[AdminPriceNoTax] float NULL, 
	[ShippingCost] float NULL, 
	[ItemTax] float NULL, 
	[Company] varchar(100) NULL, 
	[Geo] varchar(80) NULL, 
	[Channel] varchar(50) NULL, 
	[ShipmentSku] varchar(100) NULL, 
	[MattressCount] int NULL, 
	[NonMattressCount] int NULL, 
	[ItemPriceIncludeTax] float NULL, 
	[ProductName] varchar(100) NULL, 
	[ShipmentCreatedDate] date NULL, 
	[ItemId] varchar(50) NULL, 
	[AdjustableCount] int NULL, 
	[Brand] varchar(80) NULL, 
	[ProductCost] float NULL, 
	[ShortId] int NULL
);