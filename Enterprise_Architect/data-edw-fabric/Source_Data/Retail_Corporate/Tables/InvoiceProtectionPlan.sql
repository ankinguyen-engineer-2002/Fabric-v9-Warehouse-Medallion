CREATE TABLE [Retail_Corporate].[InvoiceProtectionPlan]
(
	[Operation] [varchar](15) NULL,
	[CommissionPercent] [decimal](18,2) NULL,
	[CommissionType] [varchar](10) NULL,
	[CurrentPrice] [decimal](19,4) NULL,
	[DateChanged] [datetime2](6) NULL,
	[DateCreated] [datetime2](6) NULL,
	[IsLimitOverridden] [bit] NULL,
	[IsPartiallyCompleted] [bit] NULL,
	[IsPriceOverridden] [bit] NULL,
	[OrderID] [varchar](50) NOT NULL,
	[OriginalCost] [decimal](19,4) NULL,
	[OriginalPrice] [decimal](19,4) NULL,
	[Position] [int] NOT NULL,
	[ProtectionPlanID] [varchar](100) NOT NULL,
	[ProtectionPlanRegisterID] [varchar](50) NULL,
	[RecStatus] [char](1) NULL,
	[SourceID] [varchar](50) NOT NULL
)
Go