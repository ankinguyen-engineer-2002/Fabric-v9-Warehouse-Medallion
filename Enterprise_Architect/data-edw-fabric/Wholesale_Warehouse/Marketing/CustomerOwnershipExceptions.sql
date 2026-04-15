CREATE TABLE [Marketing].[CustomerOwnershipExceptions]
    (
        [CustomerNumber] CHAR(8)      NULL,
        [ShiptoNumber]   CHAR(4)      NULL,
        [Division]       CHAR(1)      NULL,
        [RepID]          VARCHAR(5)   NULL,
        [UserId]         VARCHAR(30)  NULL,
        [DateChanged]    DATETIME2(6) NULL, --- DATETIME2(6)
        [AddedByUser]           VARCHAR(30)  NULL,
        [DateAdded]           DATETIME2(6) NULL,
        [ChangeByUser]           VARCHAR(30)  NULL,
        [DateChange]           DATETIME2(6) NULL  --- DATETIME2(6)
    );

-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION =  N'/Wholesale/Marketing/CustomerOwnershipExceptions/AFI_Sales_tblCustomerOwnershipExceptions.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
