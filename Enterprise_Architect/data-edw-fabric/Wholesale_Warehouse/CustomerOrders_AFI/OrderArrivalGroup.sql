CREATE TABLE [CustomerOrders_AFI].[OrderArrivalGroup]
    (
        [Group]       INT          NULL,
        [Description] VARCHAR(25)  NULL,
        [Electronic]  BIT          NULL,
        [usra]        VARCHAR(30)  NULL,
        [dtea]        DATETIME2(6) NULL, --Dateteime2(7)
        [usrc]        VARCHAR(30)  NULL,
        [dtec]        DATETIME2(6) NULL  --Dateteime2(7)
    );

--   DATA_SOURCE = [AzureStorageGen2a],
--    LOCATION = N'/Wholesale/codis_afi/OrderArrivalGroup/AFI_Sales_tblOrderArrivalGroup.snappy.parquet',
--    FILE_FORMAT = [ParquetFileFormatSnappy],

