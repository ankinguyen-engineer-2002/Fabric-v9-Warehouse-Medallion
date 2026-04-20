CREATE TABLE [Quality_AFI].[ScrapCodes] 
(
    [ScrapCode]         CHAR (2) NULL,    --PSCRCD
    [Description]     VARCHAR (20) NULL   --PSCDSC
)
   
   
   -- DATA_SOURCE = [AzureStorageGen2a],
  --  LOCATION = N'/Wholesale/Quality_AFI/ASCRPRT/AFI_Quality_ASCRPRT.snappy.parquet',
  --  FILE_FORMAT = [ParquetFileFormatSnappy],
  