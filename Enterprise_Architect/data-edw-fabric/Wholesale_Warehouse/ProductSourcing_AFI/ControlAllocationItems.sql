CREATE TABLE [ProductSourcing_AFI].[ControlAllocationItems](
	[ItemNumber] [varchar](15) NULL,
	[ControlAllocation] [char](1) NULL,
	[Description] [varchar](30) NULL,
	[usra] [varchar](30) NULL,
	[dtea] [datetime2](6) NULL,
	[usrc] [varchar](30) NULL,
	[dtec] [datetime2](6) NULL,
	[ControlledProduct] [char](1) NULL,
	[CRD] [date] NULL,
	[ExceptionToATPSeries] [char](1) NULL,
	[Warehouse] [char](3) NULL,
	[LastUserChanged] [varchar](30) NULL
)
GO