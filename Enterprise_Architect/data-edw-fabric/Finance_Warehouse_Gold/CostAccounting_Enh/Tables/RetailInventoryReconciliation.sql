CREATE TABLE CostAccounting_Enh.RetailInventoryReconciliation
    (
        [HS_Operation]             VARCHAR(30)    NULL,
        [RDC]                      VARCHAR(20)    NULL,
        [FiscalMonthYearName]      VARCHAR(50)    NULL,
        [FiscalMonthYear]          INT            NULL,
        [ItemNumber]               VARCHAR(20)    NULL,
        [CustomerPO]               VARCHAR(30)    NULL,
        [CustomerNumber]           VARCHAR(15)    NULL,
        [ShiptoNumber]             VARCHAR(10)    NULL,
        [Serial_Count]             INT            NULL,
        [Invoice_QTY]              DECIMAL(6, 3)  NULL,
        [HJ_QTY]                   INT            NULL,
        [Profit_QTY]               DECIMAL(6, 2)  NULL,
        [Price_Per_Unit]           DECIMAL(6, 2)  NULL,
        [Profit_Avg_Cost]          DECIMAL(16, 8) NULL,
        [Profit_Lst_Cost]          DECIMAL(16, 8) NULL,
        [QTY_Diff_Profit]          DECIMAL(6, 2)  NULL,
        [QTY_Diff_HJ]              INT            NULL,
        [$_Diff_Profit]            DECIMAL(12, 6) NULL,
        [$_Diff_HJ]                DECIMAL(12, 6) NULL,
        [Flag_OnWater]             VARCHAR(10)    NULL,
        [Flag_Profit_Matches]      VARCHAR(10)    NULL,
        [Flag_HJ_Matches]          VARCHAR(10)    NULL,
        [Flag_AllSerials_Captured] VARCHAR(10)    NULL
    );

GO
CREATE STATISTICS Stat_RetailInventoryReconciliation_ItemNumber
    ON CostAccounting_Enh.RetailInventoryReconciliation
    (
        ItemNumber
    );