CREATE TABLE [CustomerOrders_AFI].[DashboardValueList]
    (
        [ValueListType]   VARCHAR(20)  NOT NULL,
        [ValueListValue]  VARCHAR(50)  NOT NULL,
        [ValueListValue2] VARCHAR(50)  NOT NULL,
        [Description]     VARCHAR(50)  NULL,
        [SecurityTag]     VARCHAR(20)  NULL,
        [Sequence]        INT          NULL,
        [Program]         VARCHAR(100) NULL,
        [usra]            VARCHAR(30)  NULL,
        [dtea]            DATETIME2(6) NULL, --Datetime2(7)
        [usrc]            VARCHAR(30)  NULL,
        [dtec]            DATETIME2(6) NULL  --Datetime2(7)
    );

-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION = N'/Wholesale/codis_afi/DashboardValuelist/AFI_Sales_DashboardValuelist.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],

