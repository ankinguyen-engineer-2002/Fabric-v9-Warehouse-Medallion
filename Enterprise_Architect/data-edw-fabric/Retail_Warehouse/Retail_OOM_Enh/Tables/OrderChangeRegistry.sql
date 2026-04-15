CREATE TABLE [Retail_OOM_Enh].[OrderChangeRegistry] (

	[OrderChangeRegistryID] varchar(50) NOT NULL, 
	[Comment] varchar(max) NULL, 
	[CommentDate] date NULL, 
	[CommentDateTime] datetime2(3) NULL, 
	[CommentScope] int NULL, 
	[CommentSourceID] int NULL, 
	[DateChanged] datetime2(3) NULL, 
	[DateCreated] datetime2(3) NULL, 
	[IsEncrypted] bit NULL, 
	[LastBatchID] int NULL, 
	[ManualEntry] bit NULL, 
	[OrderID] varchar(100) NULL, 
	[ItemID] int NULL, 
	[Sequence] int NULL, 
	[SourceID] varchar(50) NULL, 
	[StaffID] varchar(50) NULL, 
	[OrderChangeRegistryTypeID] int NULL, 
	[FromValue] varchar(100) NULL, 
	[ToValue] varchar(100) NULL, 
	[RowType] int NULL, 
	[RecStatus] varchar(1) NULL
);