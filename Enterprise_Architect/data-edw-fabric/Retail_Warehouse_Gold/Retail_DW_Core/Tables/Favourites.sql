CREATE TABLE [Retail_DW_Core].[Favourites] (

	[RelationshipId] varchar(100) NULL, 
	[CustomerId] varchar(100) NULL, 
	[FullName] varchar(255) NULL, 
	[Email] varchar(320) NULL, 
	[PhoneNumber] varchar(50) NULL, 
	[DateCreated] date NULL, 
	[CartId] varchar(100) NULL, 
	[rDateCreated] datetime2(6) NULL, 
	[CartNumber] varchar(100) NULL, 
	[ProductID] varchar(100) NULL, 
	[Quantity] int NULL
);