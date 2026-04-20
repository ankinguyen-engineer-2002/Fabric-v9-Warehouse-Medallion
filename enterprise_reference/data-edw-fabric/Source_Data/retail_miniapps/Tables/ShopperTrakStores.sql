CREATE TABLE [Retail_Miniapps].[ShopperTrakStores] (

	[Operation] varchar(10) NOT NULL, 
	[StoreID] varchar(50) NOT NULL, 
	[StoreName] varchar(50) NULL, 
	[IsActive] bit NOT NULL, 
	[AFHS] bit NULL, 
	[DivideBy] numeric(5,2) NULL, 
	[APIStoreID] varchar(50) NULL, 
	[APIEntranceID] varchar(20) NULL, 
	[IPAddress] varchar(50) NULL
);