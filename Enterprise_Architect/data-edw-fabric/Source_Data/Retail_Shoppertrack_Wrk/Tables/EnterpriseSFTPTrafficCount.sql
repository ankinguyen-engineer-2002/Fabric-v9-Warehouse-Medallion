CREATE TABLE [Retail_Shoppertrack_Wrk].[EnterpriseSFTPTrafficCount] (

	[sttShopperTrakOrgID] decimal(11,0) NULL, 
	[sttLocID] varchar(30) NULL, 
	[sttTransDate] decimal(8,0) NULL, 
	[sttTransTime] decimal(6,0) NULL, 
	[sttEnter] int NULL, 
	[sttExit] int NULL, 
	[sttDataTypeIndicator] char(1) NULL, 
	[sttLoadDate] datetime2(6) NULL
);