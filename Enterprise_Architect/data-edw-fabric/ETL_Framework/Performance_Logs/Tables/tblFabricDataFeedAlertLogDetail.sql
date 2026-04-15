CREATE TABLE [Performance_Logs].[tblFabricDataFeedAlertLogDetail] (

	[AuditTime] datetime2(3) NOT NULL, 
	[SchemaName] varchar(200) NULL, 
	[TableName] varchar(200) NULL, 
	[HoursLate] int NULL, 
	[RefreshRate] int NULL, 
	[LastUpdated] datetime2(3) NULL, 
	[JobServer] varchar(256) NULL, 
	[JobName] varchar(256) NULL
);