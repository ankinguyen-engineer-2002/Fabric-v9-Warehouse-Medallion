CREATE TABLE [Manufacturing_Masterdata].[WMSOLSTS] (

	[Warehouse] char(3) NULL, 
	[OrderNo] char(7) NULL, 
	[ReferenceNo] decimal(6,0) NULL, 
	[LineItemSeq] decimal(7,0) NULL, 
	[WMSStatus] char(30) NULL, 
	[LastUpdatedTimestamp] datetime2(6) NULL
);