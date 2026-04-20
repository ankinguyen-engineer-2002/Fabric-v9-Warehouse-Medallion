CREATE TABLE [SalesHistory_AFI].[InvoiceDetailProperties]
    (
        [InvoiceNumber]  DECIMAL(9)   NOT NULL,
        [OrderNumber]    VARCHAR(10)  NOT NULL,
        [ItemSequence]   DECIMAL(7)   NOT NULL,
        [FieldName]      VARCHAR(20)  NOT NULL,
        [FieldValue]     VARCHAR(100) NOT NULL,
        [CustomerNumber] CHAR(8)      NOT NULL,
        [ShiptoNumber]   CHAR(4)      NOT NULL,
        [InvoiceDate]    DATE         NULL
    );


