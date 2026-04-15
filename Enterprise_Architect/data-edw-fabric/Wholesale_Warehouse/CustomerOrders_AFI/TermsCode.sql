CREATE TABLE [CustomerOrders_AFI].[TermsCode]
    (
        [TermsCode]            CHAR(3)        NULL,
        [Description]          VARCHAR(25)    NULL,
        [DaysDue]              DECIMAL(3)     NULL,
        [CommisionDaysDue]     DECIMAL(3)     NULL,
        [InvoiceDaysDue]       DECIMAL(3)     NULL,
        [ShortDescription]     VARCHAR(14)    NULL,
        [PrincePriceFlag]      CHAR(1)        NULL,
        [DisplayMessageFlag]   CHAR(1)        NULL,
        [TermsDiscountPercent] DECIMAL(10, 3) NULL,
        [TermsDiscountDays]    DECIMAL(5)     NULL,
        [MapicsTermsCode]      CHAR(2)        NULL
    );

--   DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/Wholesale/CODIS/TermsCode/AFI_Codis_STDTRM.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],


