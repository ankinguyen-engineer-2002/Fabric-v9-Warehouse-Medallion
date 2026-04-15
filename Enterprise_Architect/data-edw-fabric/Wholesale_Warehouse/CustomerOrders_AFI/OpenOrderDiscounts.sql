CREATE TABLE [CustomerOrders_AFI].[OpenOrderDiscounts] (
    [OrderNumber]            CHAR (7)        NULL,
    [ItemSequence]           DECIMAL (12)    NULL,
    [DiscountType]           CHAR (1)        NULL,
    [DiscountAdjustmentCode] CHAR (3)        NULL,
    [ItemSKU]                VARCHAR (15)    NULL,
    [Amount]                 DECIMAL (12, 2) NULL,
    [RatioAmount]            DECIMAL (12, 2) NULL,
    [DiscountPercent]        DECIMAL (8, 4)  NULL,
    [ExceptionID]            DECIMAL (12)    NULL,
    [CustomerDiscountCode]   CHAR (3)        NULL,
    [ItemDiscountClass]      CHAR (2)        NULL
)



GO
CREATE STATISTICS [Stat_OpenOrderDiscounts_OrderNumber]
    ON [CustomerOrders_AFI].[OpenOrderDiscounts]([OrderNumber]);


GO
CREATE STATISTICS [Stat_OpenOrderDiscounts_ItemSequence]
    ON [CustomerOrders_AFI].[OpenOrderDiscounts]([ItemSequence]);


GO
CREATE STATISTICS [Stat_OpenOrderDiscounts_ItemSKU]
    ON [CustomerOrders_AFI].[OpenOrderDiscounts]([ItemSKU]);


GO
CREATE STATISTICS [Stat_OpenOrderDiscounts_DiscountType]
    ON [CustomerOrders_AFI].[OpenOrderDiscounts]([DiscountType]);


GO
CREATE STATISTICS [Stat_OpenOrderDiscounts_DiscountAdjustmentCode]
    ON [CustomerOrders_AFI].[OpenOrderDiscounts]([DiscountAdjustmentCode]);

