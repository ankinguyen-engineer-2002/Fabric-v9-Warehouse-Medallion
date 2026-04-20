CREATE TABLE [Marketing].[RepCustomerFilter]
    (
        [MHS_Name]       CHAR(8)      NULL,
        [UserId]         VARCHAR(25)  NULL,
        [CustomerNumber] CHAR(8)      NULL,
        [ShiptoNumber]   CHAR(4)      NULL,
        [SalesmanNumber] CHAR(5)      NULL,
        [FilterA]        CHAR(2)      NULL,
        [FilterB]        VARCHAR(5)   NULL,
        [FilterC]        VARCHAR(25)  NULL,
        [FilterD]        BIT          NULL,
        [ActiveRecord]          CHAR(1)      NULL,
        [AddedByUser]           VARCHAR(30)  NULL,
        [DateAdded]           DATETIME2(6) NULL, --DATETIME2 (7) NULL,
        [ChangeByUser]           VARCHAR(30)  NULL,
        [DateChange]           DATETIME2(6) NULL  --DATETIME2 (7) NULL,
    );


-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION =   N'/Wholesale/Marketing/RepCustomerFilter/AFI_Sales_tblRepCustomerFilter.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
