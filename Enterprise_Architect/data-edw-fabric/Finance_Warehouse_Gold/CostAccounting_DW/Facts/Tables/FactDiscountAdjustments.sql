CREATE TABLE [CostAccounting_DW].[FactDiscountAdjustments] (
    [Invoice Number]           DECIMAL (9)     NOT NULL,
    [Order Number]             VARCHAR (10)    NOT NULL,
    [Item Number]              VARCHAR (15)    NOT NULL,
    [Item Sequence Number]     DECIMAL (7)     NOT NULL,
    [Invoice Date]             DATE        NOT NULL,
    [Discount Type]            CHAR (3)        NOT NULL,
    [Discount Adjustment Code] CHAR (3)        NOT NULL,
    [Amount]                   DECIMAL (29, 6) NOT NULL,
    [Adjustment Amount]        DECIMAL (29, 2) NULL,
    [WarehouseDetailsKey]      INT             NOT NULL,
    [DiscountAdjDetailsKey]    INT             NOT NULL,
    [ShippedHistoryDetailKey]  INT             NOT NULL,
    [ItemDetailKey]            BIGINT          NOT NULL,
    [CustomerDetailKey]        INT             NOT NULL
)
GO
CREATE STATISTICS [Stat_FactDiscountAdjustments_Invoice_Date]
    ON [CostAccounting_DW].[FactDiscountAdjustments]([Invoice Date]);

