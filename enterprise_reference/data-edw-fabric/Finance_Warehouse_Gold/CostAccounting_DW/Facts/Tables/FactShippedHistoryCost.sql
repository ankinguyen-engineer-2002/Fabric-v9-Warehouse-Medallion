CREATE TABLE [CostAccounting_DW].[FactShippedHistoryCost]
(
	[Invoice Number] [decimal](9, 0) NOT NULL,
	[Order Number] [varchar](10) NOT NULL,
	[Item Number] [varchar](15) NOT NULL,
	[Item Sequence Number] [decimal](7, 0) NOT NULL,
	[Invoice Date] [date] NULL,
	[Fiscal Year Period] [varchar](6) NOT NULL,
	[Margin Warehouse] [char](3) NOT NULL,
	[Security Tag] [char](4) NOT NULL,
	[Ext Standard Unit Cost] [decimal](21, 11) NULL,
	[Ext Import Vendor Price] [decimal](29, 6) NULL,
	[Ext Import Vendor Overhead] [decimal](29, 5) NULL,
	[Ext Material Cost] [decimal](21, 11) NULL,
	[Ext Freight Cost] [decimal](21, 11) NULL,
	[Ext Labor Cost] [decimal](21, 11) NULL,
	[Ext Labor Overhead Cost] [decimal](21, 11) NULL,
	[Ext Material Overhead Cost] [decimal](21, 11) NULL,
	[Ext AFT Import Vendor Markup] [decimal](30, 11) NULL,
	[Ext AFT Markup] [decimal](30, 11) NULL,
	[Bonded Warehouse Transfer Cost] [decimal](29, 6) NULL,
	[WarehouseDetailsKey] [int] NOT NULL,
	[MarginDetailsKey] [int] NOT NULL,
	[ShippedHistoryDetailKey] [int] NOT NULL,
	[ItemDetailKey] [bigint] NOT NULL,
	[CustomerDetailKey] [int] NOT NULL
)

GO
CREATE STATISTICS [Stat_FactShippedHistoryCost_Invoice_Date]
    ON [CostAccounting_DW].[FactShippedHistoryCost]([Invoice Date]);

