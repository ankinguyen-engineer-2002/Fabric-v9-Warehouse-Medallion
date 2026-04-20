CREATE TABLE [SalesHistory_AFI].[InvoiceValueAddedTax]
    (
        [CustomerNumber] CHAR(8)        NULL,
        [ShiptoNumber]   CHAR(4)        NULL,
        [InvoiceNumber]  DECIMAL(9)     NOT NULL,
        [OrderNumber]    VARCHAR(10)    NOT NULL,
        [InvoiceDate]    DATE           NOT NULL,
        [TaxCode]        CHAR(5)        NOT NULL,
        [TaxAmount]      DECIMAL(13, 2) NOT NULL,
        [TaxPostCode]    VARCHAR(10)    NOT NULL
    );

