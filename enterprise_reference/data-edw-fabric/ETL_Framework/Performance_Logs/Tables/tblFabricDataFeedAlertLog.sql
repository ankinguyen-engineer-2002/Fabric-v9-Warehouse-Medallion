CREATE TABLE [Performance_Logs].[tblFabricDataFeedAlertLog] (

	[AuditTime] datetime2(3) NOT NULL, 
	[TablesBehind] int NOT NULL, 
	[TotalTables] int NOT NULL, 
	[PercentBehind] decimal(10,4) NOT NULL
);