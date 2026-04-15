CREATE TABLE [Security].[Customer]
    (
        [CustomerNumber]  CHAR(8)      NULL,
        [ShiptoNumber]    CHAR(4)      NULL,
        [MHS_Name]        CHAR(8)      NULL,
        [CustomerRank]    DECIMAL(5)   NULL,
        [AddedByUser]            VARCHAR(30)  NULL,
        [DateAdded]            DATETIME2(6) NULL, --DATETIME2 (7)
        [ChangeByUser]            VARCHAR(30)  NULL,
        [DateChange]            DATETIME2(6) NULL  --DATETIME2 (7)
    );
--   DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/MasterData/urity/Customer/AFI_Sales_tblurityCustomer.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],
