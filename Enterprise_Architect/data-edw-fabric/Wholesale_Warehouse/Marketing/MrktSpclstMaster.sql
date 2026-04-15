CREATE TABLE [Marketing].[MrktSpclstMaster]
    (
        [MarketingSpecialist]         CHAR(5)      NULL,
        [SalesmanName]  VARCHAR(25)  NULL,
        [BusinessName]  VARCHAR(41)  NULL,
        [RepID]         CHAR(5)      NULL,
        [Mgrid]         CHAR(1)      NULL,
        [MHSCode]       VARCHAR(8)   NULL,
        [Position]      CHAR(1)      NULL,
        [FID]           VARCHAR(10)  NULL,
        [Homec]         INT      NULL,
        [AddedByUser]          VARCHAR(30)  NULL,
        [DateAdded]          DATETIME2(6) NULL, --- DATETIME2(6)
        [ChangeByUser]          VARCHAR(30)  NULL,
        [DateChange]          DATETIME2(6) NULL, --- DATETIME2(6)
        [ActiveRecord]         CHAR(1)      NULL,
        [StartDate]     DATETIME2(6) NULL, --- DATETIME2(6)
        [EndDate]       DATETIME2(6) NULL, --- DATETIME2(6)
        [Use1099]       BIT          NULL
    );


-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION =   N'/Wholesale/Marketing/MrktSpclstMaster/GBL_Sales_tblMrktSpclstMaster.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
