CREATE TABLE [SalesHistory_AFI].[OrderComments]
    (
        [InvoiceNumber]        DECIMAL(9)  NOT NULL,
        [OrderNumber]          VARCHAR(10) NOT NULL,
        [OrderSequence]        DECIMAL(3)  NOT NULL,
        [OrderComment1]        VARCHAR(50) NULL,        ---nvarchar
        [OrderComment2]        VARCHAR(50) NULL,        ---nvarchar
        [OrderComment3]        VARCHAR(50) NULL,        ---nvarchar
        [CustomerNumber]       CHAR(8)     NOT NULL,
        [ShiptoNumber]         CHAR(4)     NOT NULL,
        [PostingMonth]         CHAR(2)     NOT NULL,
        [InvoiceDate]          DATE        NOT NULL
    );

