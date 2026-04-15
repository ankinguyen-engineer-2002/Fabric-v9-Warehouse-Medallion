CREATE TABLE [Retail_External].[InvActivityRuleDetails] (

	[Operation] varchar(10) NULL, 
	[RuleDetailID] int NOT NULL, 
	[RuleID] int NULL, 
	[FieldName] varchar(50) NULL, 
	[FieldValue] varchar(100) NULL, 
	[Operator] varchar(10) NULL, 
	[RangeHiValue] varchar(50) NULL, 
	[RangeLoValue] varchar(50) NULL
);