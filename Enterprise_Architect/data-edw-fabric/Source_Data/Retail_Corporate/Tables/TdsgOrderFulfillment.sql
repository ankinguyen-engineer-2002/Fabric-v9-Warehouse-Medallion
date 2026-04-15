CREATE TABLE [Retail_Corporate].[TdsgOrderFulfillment] (

	[operation] char(3) NULL, 
	[OrderFulfillmentID] varchar(36) NULL, 
	[OrderID] varchar(13) NULL, 
	[FulfillmentMethod] char(1) NULL, 
	[FulfillmentDate] datetime2(6) NULL, 
	[FulfillmentStatus] char(4) NULL, 
	[FulfillmentStoreID] char(5) NULL, 
	[RouteCodeID] char(5) NULL, 
	[DeliveryContactStatusID] varchar(36) NULL, 
	[DeliveryContactDate] datetime2(6) NULL, 
	[IsInvoiced] bit NULL, 
	[DlvyChrg] numeric(38,18) NULL, 
	[InstallationChrg] numeric(38,18) NULL, 
	[MerchSubTot] numeric(38,18) NULL, 
	[RoutingNbr] int NULL
);