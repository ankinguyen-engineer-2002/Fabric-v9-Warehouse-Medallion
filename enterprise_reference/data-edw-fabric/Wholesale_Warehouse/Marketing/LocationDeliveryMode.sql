CREATE TABLE [Marketing].[LocationDeliveryMode]
    (
        [RouteAddressID]          INT          NOT NULL,
        [Warehouse]               CHAR(3)      NOT NULL, --VARCHAR (3)
        [TripType]                CHAR(1)      NOT NULL, --VARCHAR (1)
        [DeliveryMode]            CHAR(3)      NOT NULL, --VARCHAR (3)
        [AddedByUser]                    VARCHAR(30)  NULL,
        [DateAdded]                    DATETIME2(6) NULL,     --- DATETIME2(6)
        [ChangeByUser]                    VARCHAR(30)  NULL,
        [DateChange]                    DATETIME2(6) NULL,     --- DATETIME2(6)
        [ResourceRequirements]    VARCHAR(12)  NOT NULL,
        [LoadLeadTime]            INT          NOT NULL,
        [CubeMax]                 INT          NOT NULL,
        [LastUserChanged]         VARCHAR(30)  NOT NULL,
        [PackingList]             CHAR(2)      NULL,
        [RoutingLeadTimeOverride] SMALLINT     NULL
    );

-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION =   N'/Wholesale/Marketing/LocationDeliveryMode/AFI_Sales_tblLocationDeliveryMode.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
