CREATE TABLE [Wholesale_Marketing].[LocationDeliveryMode] (

	[Ldmrouteaddressid] int NOT NULL, 
	[Ldmwarehouse] char(3) NOT NULL, 
	[Ldmtriptype] char(1) NOT NULL, 
	[Ldmdeliverymode] char(3) NOT NULL, 
	[Usra] varchar(32) NULL, 
	[Dtea] datetime2(6) NULL, 
	[Usrc] varchar(32) NULL, 
	[Dtec] datetime2(6) NULL, 
	[Ldmresourcerequirements] varchar(14) NOT NULL, 
	[Ldmloadleadtime] int NOT NULL, 
	[Ldmcubemax] int NOT NULL, 
	[Ldmlastuserchanged] varchar(32) NOT NULL, 
	[Ldmpackinglist] char(2) NULL, 
	[Ldmroutingleadtimeoverride] int NULL
);