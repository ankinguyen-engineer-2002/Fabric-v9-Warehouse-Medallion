CREATE TABLE [Retail_Corporate].[ProductBOM] (

	[Operation] varchar(15) NULL, 
	[BomID] int NOT NULL, 
	[BomListElement] varchar(50) NOT NULL, 
	[CompanyID] varchar(50) NOT NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[ProductID] varchar(50) NOT NULL, 
	[ProductSubstitutionID] varchar(50) NULL, 
	[Qty] int NULL, 
	[RecStatus] varchar(1) NULL, 
	[SourceID] varchar(50) NOT NULL
);