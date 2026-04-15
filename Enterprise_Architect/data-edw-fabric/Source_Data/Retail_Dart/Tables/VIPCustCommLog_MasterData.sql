CREATE TABLE [Retail_Dart].[VIPCustCommLog_MasterData] (

	[Operation] char(3) NULL, 
	[MasterDataID] int NOT NULL, 
	[Type] varchar(100) NOT NULL, 
	[Value] varchar(250) NOT NULL, 
	[Order] numeric(18,0) NULL, 
	[ActiveStatus] bit NOT NULL, 
	[CreatedBy] varchar(50) NULL, 
	[CreatedDate] datetime2(6) NULL
);