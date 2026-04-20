CREATE TABLE [Marketing].[FinancialDivision]
    (
        [FinancialDivision]    CHAR(1)      NULL,
        [Description]          VARCHAR(30)  NULL,
        [AddedByUser]                 VARCHAR(30)  NULL,
        [DateAdded]                 DATETIME2(6) NULL, --- DATETIME2(6)
        [ChangeByUser]                 VARCHAR(30)  NULL,
        [DateChange]                 DATETIME2(6) NULL, --- DATETIME2(6)
        [FinancialDivCodeLong] VARCHAR(50)  NULL
    );

-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION =   N'/Wholesale/Marketing/FinancialDivision/GBL_Sales_tblFinancialDivision.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
