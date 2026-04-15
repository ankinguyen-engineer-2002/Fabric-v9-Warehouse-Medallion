CREATE TABLE [CostAccounting_Enh].[FinVis_ChinaKitPriceVsWanekPrice]
(
	[Item Sku] [varchar](20) NULL,
	[Item_Type] [varchar](20) NULL,
	[QTY_Ordered] [decimal](10, 3) NULL,
	[Cost_Purchase_Amount] [decimal](10, 4) NULL,
	[Cost_OceanFreight] [decimal](10, 2) NULL,
	[Cost_Total] [decimal](10, 2) NULL,
	[CPU_Landed_ChinaKit] [decimal](10, 6) NULL,
	[CPU_PurchPrice_ChinaKit] [decimal](10, 6) NULL,
	[China_WeekCount] [int] NULL,
	[WnkMil_WeekCount] [int] NULL,
	[CPU_Landed_WnkMilKit] [decimal](10, 6) NULL,
	[CPU_PurchPrice_WnkMilKit] [decimal](10, 6) NULL,
	[Flag_OnOrdWanek_Mil] [varchar](50) NULL,
	[WnkMil_QTYOrdered] [decimal](10, 3) NULL,
	[Savings_Week_PurchPrice] [decimal](12, 6) NULL,
	[Savings_Week_Landed] [decimal](12, 6) NULL
)