CREATE TABLE [Retail_Dart].[CartDetail] (

	[CartNumber] varchar(200) NOT NULL, 
	[ProductID] varchar(100) NOT NULL, 
	[Price] decimal(18,2) NOT NULL, 
	[DiscountedPrice] decimal(18,2) NOT NULL, 
	[Quantity] int NOT NULL
);