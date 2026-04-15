CREATE TABLE [SalesHistory_AFI].[SpecialCharges] (
    [InvoiceNumber]  DECIMAL (9)     NOT NULL,
    [OrderNumber]    VARCHAR (10)    NOT NULL,
    [SequenceNumber] DECIMAL (3)     NOT NULL,
    [CustomerNumber] CHAR (8)        NOT NULL,
    [Code]           CHAR (1)        NOT NULL,
    [Description]    VARCHAR (50)    NOT NULL,
    [Amount]         DECIMAL (10, 2) NOT NULL,
    [PostingMonth]   CHAR (2)        NOT NULL,
    [ShiptoNumber]   CHAR (4)        NOT NULL,
    [InvoiceDate]    DATE            NULL,
    [Warehouse]      CHAR (3)        NULL,
    [CurrencyCode]   CHAR (3)        NOT NULL,
    [CreditCode]     CHAR (3)        NULL
)


