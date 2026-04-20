CREATE TABLE [Retail_Corporate].[OrderItemCommissionInfo]
(
	[Operation] [varchar](15) NULL,
	[CommCalcCode] [int] NULL,
	[CommFlg] [bit] NULL,
	[CommPct] [decimal](18,2) NULL,
	[CompanyID] [varchar](50) NOT NULL,
	[DateChanged] [datetime2](6) NULL,
	[DateCreated] [datetime2](6) NULL,
	[ItemCommCategory] [varchar](10) NULL,
	[ItemID] [int] NOT NULL,
	[OrderCommCategory] [varchar](10) NULL,
	[OrderID] [varchar](50) NOT NULL,
	[PosID] [int] NOT NULL,
	[ProductID] [varchar](50) NOT NULL,
	[RecStatus] [char](1) NULL,
	[SalesPersonID] [varchar](50) NOT NULL,
	[SourceID] [varchar](50) NOT NULL,
	[SplitPct] [decimal](18,2) NULL
)
Go