CREATE TABLE [Pricing_AFI].[ExpressFreightInfo]
    (
        [CustomerNumber] CHAR(8)        NULL,  ---Decimal
        [ItemNumber]     VARCHAR(15)    NULL,
        [ItemClass]      CHAR(4)        NULL,
        [Length]         DECIMAL(5)     NULL,
        [Width]          DECIMAL(5)     NULL,
        [Height]         DECIMAL(5)     NULL,
        [Charge]         DECIMAL(10, 0) NULL,
        [DateAdded]      DATETIME2(6)   NULL,
        [UserAdded]      CHAR(10)       NULL,
        [ProgramAdded]   CHAR(10)       NULL,
        [DateChanged]    DATETIME2(6)   NULL,
        [UserChanged]    VARCHAR(20)    NULL,
        [ProgramChanged] VARCHAR(10)    NULL
    );

--DATA_SOURCE = [AzureStorageGen2a],
--LOCATION = N'/Wholesale/Pricing_AFI/EXPFRTAD/AFI_CODIS_ExpFrtAd.snappy.parquet',
--FILE_FORMAT = [ParquetFileFormatSnappy],
