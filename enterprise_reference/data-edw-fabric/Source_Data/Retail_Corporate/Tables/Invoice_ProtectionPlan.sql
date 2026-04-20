CREATE TABLE [Retail_Corporate].[invoice_protectionplan] (

	[Operation] varchar(15) NULL, 
	[CommissionPercent] numeric(18,2) NULL, 
	[CommissionType] varchar(10) NULL, 
	[CurrentPrice] numeric(19,4) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[IsLimitOverridden] bit NULL, 
	[IsPartiallyCompleted] bit NULL, 
	[IsPriceOverridden] bit NULL, 
	[OrderID] varchar(50) NULL, 
	[OriginalCost] numeric(19,4) NULL, 
	[OriginalPrice] numeric(19,4) NULL, 
	[Position] int NULL, 
	[ProtectionPlanID] varchar(100) NULL, 
	[ProtectionPlanRegisterID] varchar(50) NULL, 
	[RecStatus] char(1) NULL, 
	[SourceID] varchar(50) NULL
);