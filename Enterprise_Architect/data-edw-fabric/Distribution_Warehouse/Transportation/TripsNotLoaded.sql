CREATE TABLE [Transportation].[TripsNotLoaded]
    (
        [TripNumber]           NUMERIC(5)  NOT NULL,
        [DropNumber]           NUMERIC(2)  NOT NULL,
        [OrderNumber]          VARCHAR(7)  NOT NULL,
        [ItemSequence]         NUMERIC(7)  NOT NULL,
        [CustomerNumber]       NUMERIC(8)  NULL,
        [CustomerServiceRepID] NUMERIC(5)  NULL,
        [ShiptoNumber]         CHAR(4)     NULL,
        [Call]                 CHAR(1)     NULL,
        [ItemSKU]              VARCHAR(15) NULL,
        [QuantityNotLoaded]    NUMERIC(5)  NULL,
        [ReasonCode]           CHAR(2)     NULL,
        [Time]                 NUMERIC(6)  NULL,
        [Date]                 DATE        NULL, -- NUMERIC(8)  NULL,
        [user]                 VARCHAR(10) NULL,
        [Promgram]             VARCHAR(10) NULL,
        [OrderType1]           CHAR(1)     NULL,
        [OrderType2]           CHAR(1)     NULL,
        [OrderType3]           CHAR(1)     NULL,
        [OrderType4]           CHAR(1)     NULL,
        [CustomerName]         VARCHAR(25) NULL
    );
--  DATA_SOURCE = [AzureStorageGen2a],
--  LOCATION = N'/Wholesale/CODIS/BTRSNCDE/AFI_Codis_BTRSNCDE.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],

