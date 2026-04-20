

CREATE TABLE [CostAccounting_DW].[FactShippedHistoryDetail] (
    [Invoice Number]             DECIMAL (9)     NOT NULL,
    [Order Number]               VARCHAR (10)    NOT NULL,
    [Item Number]                VARCHAR (15)    NOT NULL,
    [Item Sequence Number]       DECIMAL (7)     NOT NULL,
    [Invoice Date]               DATE            NULL,
    [Fiscal Year Period]         VARCHAR (6)     NOT NULL,
    [Margin Warehouse]           CHAR (3)        NOT NULL,
    [Gross Quantity Shipped]     DECIMAL (29, 3) NULL,
    [Gross Amount Shipped]       DECIMAL (13, 2) NULL,
    [Return Quantity]            DECIMAL (29, 3) NULL,
    [Return Amount]              DECIMAL (29, 2) NULL,
    [Short Ship Quantity]        DECIMAL (29, 3) NULL,
    [Short Ship Amount]          DECIMAL (29, 2) NULL,
    [Quality Credit Amount]      DECIMAL (29, 2) NULL,
    [Net Quantity Shipped]       DECIMAL (29, 3) NULL,
    [Net Amount Shipped]         DECIMAL (29, 2) NULL,
    [Ext Selling Price]          DECIMAL (29, 5) NULL,
    [Ext Price Exception Amount] DECIMAL (29, 6) NULL,
    [Ext Line Item Freight]      DECIMAL (29, 5) NULL,
    [Ext Line Item Discounts]    DECIMAL (29, 5) NULL,
    [Ext Advertising Accrual]    DECIMAL (29, 5) NULL,
    [Ext DFI Discounts]          DECIMAL (29, 5) NULL,
    [Ext Contract Price]         DECIMAL (29, 5) NULL,
    [Invoice Tax Amount]         DECIMAL (29, 2) NULL,
    [Ext Comm Adj - Freight]     DECIMAL (13, 2) NULL,
    [Ext Comm Adj - Gross]       DECIMAL (13, 2) NULL,
    [Ext Comm Adj - Warranty]    DECIMAL (13, 2) NULL,
    [Ext FOB at Order Time]      DECIMAL (29, 5) NULL,
    [Ext FOB at Invoice Time]    DECIMAL (29, 6) NULL,
    [Special Charge Amount]      DECIMAL (29, 2) NULL,
    [Bonded Warehouse Transfer Quantity] [decimal](29, 3) NULL,
	[Bonded Warehouse Transfer Amount]  [decimal](13, 2) NULL,
	[Special Charge Freight]       [decimal](29, 2) NULL,
	[Special Charge Non-Freight]   [decimal](29, 2) NULL,
	[Special Charge Discounts]      [decimal](29, 2) NULL,
	[Special Charge Non-Discounts]  [decimal](29, 2) NULL,
    [WarehouseDetailsKey]        INT             NOT NULL,
    [MarginDetailsKey]           INT             NOT NULL,
    [ShippedHistoryDetailKey]    INT             NOT NULL,
    [ItemDetailKey]              BIGINT          NOT NULL,
    [CustomerDetailKey]          INT             NOT NULL
)

GO
CREATE STATISTICS [Stat_FactShippedHistoryDetail_Special_Charge_Amount]
    ON [CostAccounting_DW].[FactShippedHistoryDetail]([Special Charge Amount]);


GO
CREATE STATISTICS [Stat_FactShippedHistoryDetail_ShippedHistoryDetailKey]
    ON [CostAccounting_DW].[FactShippedHistoryDetail]([ShippedHistoryDetailKey]);


GO
CREATE STATISTICS [Stat_FactShippedHistoryDetail_Order_Number]
    ON [CostAccounting_DW].[FactShippedHistoryDetail]([Order Number]);


GO
CREATE STATISTICS [Stat_FactShippedHistoryDetail_Net_Quantity_Shipped]
    ON [CostAccounting_DW].[FactShippedHistoryDetail]([Net Quantity Shipped]);


GO
CREATE STATISTICS [Stat_FactShippedHistoryDetail_Net_Amount_Shipped]
    ON [CostAccounting_DW].[FactShippedHistoryDetail]([Net Amount Shipped]);


GO
CREATE STATISTICS [Stat_FactShippedHistoryDetail_Item_Sequence_Number]
    ON [CostAccounting_DW].[FactShippedHistoryDetail]([Item Sequence Number]);


GO
CREATE STATISTICS [Stat_FactShippedHistoryDetail_Item_Number]
    ON [CostAccounting_DW].[FactShippedHistoryDetail]([Item Number]);


GO
CREATE STATISTICS [Stat_FactShippedHistoryDetail_Invoice_Tax_Amount]
    ON [CostAccounting_DW].[FactShippedHistoryDetail]([Invoice Tax Amount]);


GO
CREATE STATISTICS [Stat_FactShippedHistoryDetail_Invoice_Number]
    ON [CostAccounting_DW].[FactShippedHistoryDetail]([Invoice Number]);


GO
CREATE STATISTICS [Stat_FactShippedHistoryDetail_Invoice_Date]
    ON [CostAccounting_DW].[FactShippedHistoryDetail]([Invoice Date]);


GO
CREATE STATISTICS [Stat_FactShippedHistoryDetail_Gross_Quantity_Shipped]
    ON [CostAccounting_DW].[FactShippedHistoryDetail]([Gross Quantity Shipped]);


GO
CREATE STATISTICS [Stat_FactShippedHistoryDetail_Gross_Amount_Shipped]
    ON [CostAccounting_DW].[FactShippedHistoryDetail]([Gross Amount Shipped]);


GO
CREATE STATISTICS [Stat_FactShippedHistoryDetail_Fiscal_Year_Period]
    ON [CostAccounting_DW].[FactShippedHistoryDetail]([Fiscal Year Period]);


GO
CREATE STATISTICS [Stat_FactShippedHistoryDetail_Ext_Line_Item_Freight]
    ON [CostAccounting_DW].[FactShippedHistoryDetail]([Ext Line Item Freight]);


GO
CREATE STATISTICS [Stat_FactShippedHistoryDetail_Ext_Line_Item_Discounts]
    ON [CostAccounting_DW].[FactShippedHistoryDetail]([Ext Line Item Discounts]);


GO
CREATE STATISTICS [Stat_FactShippedHistoryDetail_Ext_DFI_Discounts]
    ON [CostAccounting_DW].[FactShippedHistoryDetail]([Ext DFI Discounts]);


GO
CREATE STATISTICS [Stat_FactShippedHistoryDetail_Ext_Comm_Adj___Freight]
    ON [CostAccounting_DW].[FactShippedHistoryDetail]([Ext Comm Adj - Freight]);
GO

 CREATE STATISTICS [Stat_FactShippedHistoryDetail_Bonded_Warehouse_Transfer_Quantity]
    ON [CostAccounting_DW].[FactShippedHistoryDetail] ([Bonded Warehouse Transfer Quantity]);

 GO
  CREATE STATISTICS [Stat_FactShippedHistoryDetail_Bonded_Warehouse_Transfer_Amount]
    ON [CostAccounting_DW].[FactShippedHistoryDetail] ([Bonded Warehouse Transfer Amount])

 GO
  CREATE STATISTICS [Stat_FactShippedHistoryDetail_Special_Charge_Freight] 
	ON [CostAccounting_DW].[FactShippedHistoryDetail] ([Special Charge Freight]);
	
  GO
  CREATE STATISTICS [Stat_FactShippedHistoryDetail_Special_Charge_NonFreight] 
	ON [CostAccounting_DW].[FactShippedHistoryDetail] ([Special Charge Non-Freight]);
	
	GO
  CREATE STATISTICS [Stat_FactShippedHistoryDetail_Special_Charge_Discounts]
	ON [CostAccounting_DW].[FactShippedHistoryDetail] ([Special Charge Discounts]);
	
	GO
  CREATE STATISTICS [Stat_FactShippedHistoryDetail_Special_Charge_NonDiscounts] 
	ON [CostAccounting_DW].[FactShippedHistoryDetail] ([Special Charge Non-Discounts]);
	
	GO
