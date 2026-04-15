CREATE TABLE [Retail].[HomestoreRetailCategoryMaster]
    (
        [RetailCategory]      CHAR(5)      NULL,
        [CategoryName]        VARCHAR(50)  NULL,
        [RetailDepartment]    INT          NULL,
        [DepartmentName]      VARCHAR(50)  NULL,
        [DepartmentStoreName] VARCHAR(50)  NULL,
        [StoreGroup]          VARCHAR(50)  NULL,
        [ChargeType]          VARCHAR(50)  NULL,
        [AddedByUser]                   VARCHAR(30)  NULL,
        [DateAdded]                   DATETIME2(6) NULL,
        [ChangeByUser]                   VARCHAR(30)  NULL,
        [DateChange]                   DATETIME2(6) NULL
    );

--DATA_SOURCE = [AzureStorageGen2a],
--LOCATION = N'/Retail/MasterData/HomestoreRetailCategoryMaster/Retail_MasterData_tblHomestoreRetailCategoryMaster.snappy.parquet',
--FILE_FORMAT = [ParquetFileFormatSnappy],

