CREATE TABLE [Retail_Corporate].[UserSettingValue] (

	[Operation] char(3) NULL, 
	[RecStatus] char(1) NULL, 
	[SourceID] varchar(50) NOT NULL, 
	[UserSettingValueID] varchar(50) NOT NULL, 
	[UserSettingSourceID] varchar(10) NOT NULL, 
	[ValueSourceID] varchar(50) NULL, 
	[UserSettingID] varchar(50) NULL, 
	[Value] varchar(50) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[LastBatchID] int NULL
);