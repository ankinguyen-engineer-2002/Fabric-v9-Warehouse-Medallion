CREATE TABLE [SalesHistory_AFI].[ShippedHistoryCommAdjustment] (
    [InvoiceNumber]            DECIMAL (9)     NOT NULL,
    [OrderNumber]              VARCHAR (10)    NOT NULL,
    [ItemSKU]                  VARCHAR (15)    NOT NULL,
    [ItemSequence]             DECIMAL (7)     NOT NULL,
    [CommissionAdjustmentCode] CHAR (3)        NOT NULL,
    [ExceptionAmount]          DECIMAL (12, 2) NOT NULL,
    [ExceptionId]              DECIMAL (7)     NOT NULL,
    [PriceCode]                CHAR (6)        NOT NULL,
    [CustomerNumber]           CHAR (8)        NOT NULL,
    [ShiptoNumber]             CHAR (4)        NOT NULL,
    [InvoiceDate]              DATE            NULL
)
