CREATE TABLE [Security].[CustomerList]
    (
        [SalesCode]       CHAR(5)      NULL,
        [CustomerNumber]  CHAR(8)      NULL,
        [ShiptoNumber]    CHAR(4)      NULL,
        [AddedByUser]            VARCHAR(30)  NULL,
        [DateAdded]            DATETIME2(6) NULL,  --DATETIME2 (7)
        [ChangeByUser]            VARCHAR(30)  NULL,
        [DateChange]            DATETIME2(6) NULL,  --DATETIME2 (7)
        [RowGuid]         VARCHAR(40)  NULL
    );

--   DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/MasterData/Security/CustomerList/AFI_Sales_tblSecurityCustomerList.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],


