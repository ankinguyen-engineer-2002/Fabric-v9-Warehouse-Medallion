CREATE TABLE [Performance_Logs].[EmailQueue] (

	[EmailId] bigint NOT NULL, 
	[CreatedAt] datetime2(3) NOT NULL, 
	[Recipients] varchar(max) NOT NULL, 
	[Subject] varchar(4000) NOT NULL, 
	[BodyHtml] varchar(max) NOT NULL, 
	[SentAt] datetime2(3) NULL, 
	[SentStatus] varchar(100) NULL, 
	[ErrorText] varchar(max) NULL
);