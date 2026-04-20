CREATE TABLE [Retail_Corporate].[ProductCollection] (

	[Operation] varchar(15) NULL, 
	[CollectionID] varchar(50) NULL, 
	[CollectionPos] int NOT NULL, 
	[CompanyID] varchar(50) NOT NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[ProductID] varchar(50) NOT NULL, 
	[RecStatus] varchar(1) NULL, 
	[SourceID] varchar(50) NOT NULL
);