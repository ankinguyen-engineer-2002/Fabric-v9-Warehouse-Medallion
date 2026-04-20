CREATE TABLE [Customers].[ServiceRepID]
    (
        [ServiceRepID]         CHAR(5)      NULL,
        [GroupID]              CHAR(2)      NULL,
        [ContactID]            INT          NULL,
        [Department]           CHAR(5)      NULL,
        [ContactType]          CHAR(5)      NULL,
        [AddedByUser]                 VARCHAR(30)  NULL,
        [DateAdded]                 DATETIME2(6) NULL,
        [ChangeByUser]                 VARCHAR(30)  NULL,
        [DateChange]                 DATETIME2(6) NULL,
        [ActiveRecord]                CHAR(1)      NULL
    );

--   DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/Wholesale/Customers/ServiceRepid/AFI_Sales_tblCustomerServiceRepid.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],

