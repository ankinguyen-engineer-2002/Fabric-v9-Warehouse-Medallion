CREATE TABLE [Retail].[HomestoreRetailCategories]
    (
        [Database]         VARCHAR(20) NULL,
        [SalesCategory]    CHAR(5)     NULL,
        [RetailCategory]   CHAR(5)     NULL,
        [RetailDepartment] INT         NULL,
        [CategoryName]     VARCHAR(50) NULL
    );

--DATA_SOURCE = [AzureStorageGen2a],
--LOCATION = N'/Retail/MasterData/HomestoreRetailCategories/Retail_MasterData_tblHomestoreRetailCategories.snappy.parquet',
--FILE_FORMAT = [ParquetFileFormatSnappy],

