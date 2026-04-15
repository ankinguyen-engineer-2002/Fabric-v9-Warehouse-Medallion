CREATE TABLE [Retail_Corporate_Wrk].[OrderComments] (

	[Operation] varchar(15) NULL, 
	[Comment] varchar(max) NOT NULL, 
	[CommentDate] date NULL, 
	[CommentDateTime] datetime2(6) NOT NULL, 
	[CommentScope] int NOT NULL, 
	[CommentsID] varchar(100) NOT NULL, 
	[CommentSourceID] int NOT NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NOT NULL, 
	[IsEncrypted] bit NOT NULL, 
	[LastBatchID] int NULL, 
	[ManualEntry] bit NOT NULL, 
	[RecordID] varchar(200) NOT NULL, 
	[RecStatus] char(1) NULL, 
	[Sequence] int NOT NULL, 
	[SourceID] varchar(50) NOT NULL, 
	[StaffID] varchar(50) NULL, 
	[StorisUserDef1] varchar(1024) NULL, 
	[StorisUserDef2] varchar(1024) NULL, 
	[StorisUserDef3] varchar(1024) NULL, 
	[StorisUserDef4] varchar(1024) NULL
);