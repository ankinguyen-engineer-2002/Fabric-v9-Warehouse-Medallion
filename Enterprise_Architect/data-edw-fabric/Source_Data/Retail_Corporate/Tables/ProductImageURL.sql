CREATE TABLE [Retail_Corporate].[ProductImageURL] (

	[Operation] varchar(15) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[ImageURL] varchar(450) NULL, 
	[ProductID] varchar(50) NOT NULL, 
	[RecStatus] varchar(1) NULL, 
	[SourceID] varchar(50) NOT NULL
);