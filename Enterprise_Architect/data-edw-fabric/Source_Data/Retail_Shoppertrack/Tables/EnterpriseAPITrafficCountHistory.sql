CREATE TABLE [Retail_Shoppertrack].[EnterpriseAPITrafficCountHistory] (

	[sttLocID] varchar(30) NULL, 
	[sttTransDate] date NULL, 
	[sttTransTime] decimal(6,0) NULL, 
	[sttEnter] int NULL, 
	[sttExit] int NULL, 
	[sttCode] int NULL, 
	[sttLoadDate] datetime2(6) NULL, 
	[dataSource] varchar(10) NULL
);