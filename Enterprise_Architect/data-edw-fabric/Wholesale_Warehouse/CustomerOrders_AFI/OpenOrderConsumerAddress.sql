CREATE TABLE [CustomerOrders_AFI].[OpenOrderConsumerAddress]
    (
        [OrderNumber]       CHAR(7)     NOT NULL,
        [SalesOrderNumber]  CHAR(30)    NOT NULL,
        [Sequence]          NUMERIC(2)  NOT NULL,
        [ConsumerLastName]  VARCHAR(30) NULL,
        [ConsumerFirstName] VARCHAR(30) NULL,
        [ConsumerAddress1]  VARCHAR(35) NULL,
        [ConsumerAddress2]  VARCHAR(35) NULL,
        [ConsumerAddress3]  VARCHAR(35) NULL,
        [ConsumerAddress4]  VARCHAR(35) NULL,
        [ConsumerAddress5]  VARCHAR(35) NULL,
        [City]              VARCHAR(35) NULL,
        [State]             CHAR(2)     NULL,
        [ZipCode]           VARCHAR(10) NULL,
        [Country]           CHAR(3)     NULL
    );

--  DATA_SOURCE = [AzureStorageGen2a],
--  LOCATION = N'/Wholesale/codis_afi/OpenOrderConsumerAddress/AFI_codis_afi_OpenOrderConsumerAddress.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],


