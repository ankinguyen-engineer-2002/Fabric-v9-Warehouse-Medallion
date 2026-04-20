CREATE TABLE [SalesHistory_AFI].[ShippedHistoryDiscounts] (
    [InvoiceNumber]             DECIMAL (9)     NOT NULL,
    [OrderNumber]               VARCHAR (10)    NOT NULL,
    [ItemSequence]              DECIMAL (7)     NOT NULL,
    [DiscountType]              CHAR (1)        NULL,
    [DiscountAdjustmentCode]    CHAR (3)        NULL,
    [ItemSKU]                   VARCHAR (15)    NOT NULL,
    [Amount]                    DECIMAL (12, 2) NULL,
    [RatioAmount]               DECIMAL (12, 2) NULL,
    [DiscountPercent]           DECIMAL (12, 4) NULL,
    [ExceptionId]               DECIMAL (12)    NULL,
    [DiscountCode]              CHAR (3)        NULL,
    [DiscountSalesClass]        CHAR (2)        NULL,
    [InvoiceDate]               DATE            NOT NULL,
    [CustomerNumber]            CHAR (8)        NULL,
    [ShiptoNumber]              CHAR (4)        NULL
)


