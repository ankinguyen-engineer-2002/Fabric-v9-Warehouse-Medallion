CREATE TABLE [SalesHistory_AFI].[OpenInvoices]
    (
        [CustomerNumber]   CHAR(8)        NULL,
        [PurchaseOrder]    VARCHAR(30)    NULL,
        [InvoiceNumber]    VARCHAR(15)    NULL,
        [InvoiceAmount]    DECIMAL(12, 2) NULL,
        [OpenAmount]       DECIMAL(12, 2) NULL,
        [DateLastPayment]  DATE           NULL,
        [InvoiceDate]      DATE           NULL,
        [CategoryCode]     CHAR(6)        NULL,
        [CurrencyCode]     CHAR(3)        NULL,
        [InvoiceType]      INT            NULL,
        [CreditMemoNumber] VARCHAR(15)   NULL,
        [TotalCredit]      DECIMAL(12, 2) NULL
    );


-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION = N'/Wholesale/SalesHistory_AFI/OpenInvoices/AFI_SalesHistory_OpenInvoices.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],

