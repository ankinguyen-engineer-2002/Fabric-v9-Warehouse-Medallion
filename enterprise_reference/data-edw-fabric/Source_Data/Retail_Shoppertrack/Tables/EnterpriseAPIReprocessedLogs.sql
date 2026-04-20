CREATE TABLE [Retail_Shoppertrack].[EnterpriseAPIReprocessedLogs] (

	[dataSource] varchar(10) NULL, 
	[sttLocID] varchar(28) NULL, 
	[sttTransDate] date NULL, 
	[sttTransTime] decimal(6,0) NULL, 
	[initialLoadDate] datetime2(6) NULL, 
	[initialEnter] int NULL, 
	[initialExit] int NULL, 
	[initialCode] int NULL, 
	[reprocessedLoadDate] datetime2(6) NULL, 
	[reprocessedEnter] int NULL, 
	[reprocessedExit] int NULL, 
	[reprocessedCode] int NULL
);