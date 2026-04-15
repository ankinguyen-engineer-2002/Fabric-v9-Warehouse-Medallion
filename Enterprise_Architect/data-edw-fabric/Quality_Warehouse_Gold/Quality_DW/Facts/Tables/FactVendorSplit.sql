CREATE TABLE [Quality_DW].[FactVendorSplit]
(
	[ItemNumber] [varchar](15) NOT NULL,
	[Description] [varchar](100)  NULL,
	[Status] [varchar](5) NULL,
	[FinanceDivision] [varchar](100) NULL,
	[VendorNumber] CHAR (8) NULL,
	[VendorName] [varchar](100) NULL,
	[VendorOffice] [varchar](30) NULL,
	[VendorSplit] int NULL
	
)

go
CREATE STATISTICS [Stat_FactVendorSplit_ItemNumber]
    ON [Quality_DW].[FactVendorSplit]([ItemNumber])

go
CREATE STATISTICS [Stat_FactVendorSplit_FinanceDivision]
    ON [Quality_DW].[FactVendorSplit](FinanceDivision)
go

CREATE STATISTICS [Stat_FactVendorSplit_VendorNumber]
    ON [Quality_DW].[FactVendorSplit](VendorNumber)
go