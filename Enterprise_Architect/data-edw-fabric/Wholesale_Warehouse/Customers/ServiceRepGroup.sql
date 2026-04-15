CREATE TABLE [Customers].[ServiceRepGroup]
    (
        [GroupID]          CHAR(2)      NULL,
        [UserID]           VARCHAR(10)  NULL,
        [AddedByUser]             VARCHAR(30)  NULL,
        [DateAdded]             DATETIME2(6) NULL,
        [ChangeByUser]             VARCHAR(30)  NULL,
        [DateChange]             DATETIME2(6) NULL,
        [GroupDescription] VARCHAR(30)  NULL
    );

--   DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/Wholesale/Customers/ServiceRepGroup/AFI_Sales_tblCustomerServiceRepGroup.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],

