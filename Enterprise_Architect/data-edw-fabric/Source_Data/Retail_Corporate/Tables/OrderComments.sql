CREATE TABLE [Retail_Corporate].[OrderComments] (

	[Operation] varchar(15) NULL, 
	[Comment] varchar(max) NULL, 
	[CommentDate] date NULL, 
	[CommentDateTime] datetime2(6) NULL, 
	[CommentScope] int NULL, 
	[CommentsID] varchar(100) NULL, 
	[CommentSourceID] int NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[IsEncrypted] bit NULL, 
	[LastBatchID] int NULL, 
	[ManualEntry] bit NULL, 
	[RecordID] varchar(200) NULL, 
	[RecStatus] char(1) NULL, 
	[Sequence] int NULL, 
	[SourceID] varchar(50) NULL, 
	[StaffID] varchar(50) NULL, 
	[StorisUserDef1] varchar(1024) NULL, 
	[StorisUserDef2] varchar(1024) NULL, 
	[StorisUserDef3] varchar(1024) NULL, 
	[StorisUserDef4] varchar(1024) NULL
);