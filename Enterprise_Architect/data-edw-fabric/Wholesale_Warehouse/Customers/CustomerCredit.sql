CREATE TABLE [Customers].[CustomerCredit]
    (
        [CustomerNumber]      CHAR(8)       NULL,
        [CreditLimit]         DECIMAL(8)    NULL,
        [BeyondTerms_90Days]  DECIMAL(4)    NULL,
        [BeyondTerms_6Months] DECIMAL(4)    NULL,
        [BeyondTerms_365Days] DECIMAL(4)    NULL,
        [BeyondTerms_Life]    DECIMAL(4)    NULL,
        [BeyondTerms_Custom]  DECIMAL(4)    NULL,
        [HighestCredit]       DECIMAL(10, 2) NULL,
        [OutstandingBalance]  DECIMAL(10, 2) NULL,
        [ACI_Amount]          DECIMAL(12, 4) NULL
    )

--    DATA_SOURCE = [AzureStorageGen2a],
--    LOCATION = N'/Wholesale/CustomerOrders/MC2CUEPF/AFI_CODIS_MC2CUEPF.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],

