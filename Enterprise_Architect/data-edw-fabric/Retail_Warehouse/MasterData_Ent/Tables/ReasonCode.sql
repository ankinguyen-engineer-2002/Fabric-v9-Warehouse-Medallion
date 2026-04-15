CREATE TABLE [MasterData_Ent].[ReasonCode] (

	[ReasonCodeID] varchar(50) NOT NULL, 
	[ReasonCodeName] varchar(255) NULL, 
	[ReasonType] varchar(50) NULL, 
	[RollUpCode] varchar(20) NULL, 
	[DateCreated] datetime2(3) NULL, 
	[DateChanged] datetime2(3) NULL
);