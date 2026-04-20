CREATE TABLE [Wholesale_Codis_AFI].[OrderCancellationReasonCode] (

	[cnlActiveCode] char(1) NULL, 
	[cnlReasonCode] char(2) NULL, 
	[cnlReasonDescription] varchar(25) NULL, 
	[cnlMaintainDate] decimal(8,0) NULL, 
	[cnlMaintainTime] decimal(6,0) NULL, 
	[cnlMaintainUser] varchar(10) NULL, 
	[cnlTrueCancel] char(1) NULL, 
	[cnlCancelCategory] varchar(20) NULL, 
	[cnlAvailToAshleyDirect] char(1) NULL, 
	[cnlAshleyDirectDesc] varchar(25) NULL
);