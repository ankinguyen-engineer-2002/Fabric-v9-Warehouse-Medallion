CREATE TABLE [Retail_Corporate].[PieceInventorySpecialOrderOptions] (

	[Operation] varchar(15) NULL, 
	[Cost] numeric(19,4) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[Grade] varchar(50) NULL, 
	[OptionCode] varchar(50) NULL, 
	[OptionTypeCode] varchar(50) NULL, 
	[Position] int NOT NULL, 
	[Price] numeric(19,4) NULL, 
	[ProductID] varchar(50) NOT NULL, 
	[RecStatus] varchar(1) NULL, 
	[SerialNbrID] varchar(50) NOT NULL, 
	[SourceID] varchar(50) NOT NULL
);