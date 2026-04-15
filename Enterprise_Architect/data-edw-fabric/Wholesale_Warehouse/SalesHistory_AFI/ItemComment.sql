CREATE TABLE [SalesHistory_AFI].[ItemComments]
    (
        [InvoiceNumber]       DECIMAL(9)   NULL,
        [OrderNumber]         VARCHAR(10)  NULL,
        [ItemSKU]             VARCHAR(15)  NULL,
        [ItemSequence]        DECIMAL(7)   NOT NULL,
        [ItemCommentsequence] DECIMAL(3)   NOT NULL,
        [ItemComments1]       VARCHAR(25)  NULL,
        [ItemComments2]       VARCHAR(25) NULL,
        [ItemComments3]       VARCHAR(25)  NULL,
        [CustomerNumber]      CHAR(8)      NULL,
        [ShiptoNumber]        CHAR(4)      NULL,
        [PostingMonth]        CHAR(2)      NULL,
        [InvoiceDate]         DATE         NULL
    );

