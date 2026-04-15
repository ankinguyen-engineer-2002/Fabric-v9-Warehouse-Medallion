CREATE TABLE [Retail_Shoppertrack].[TrafficCount_History] (

	[sttShopperTrakOrgID] decimal(11,0) NULL, 
	[sttLocID] varchar(28) NULL, 
	[sttTransDate] decimal(8,0) NULL, 
	[sttTransTime] decimal(6,0) NULL, 
	[sttEnter] smallint NULL, 
	[sttExit] smallint NULL, 
	[sttDataTypeIndicator] char(1) NULL, 
	[sttLoadDate] date NULL
);