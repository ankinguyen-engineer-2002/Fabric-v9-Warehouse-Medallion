CREATE TABLE [CustomerOrders_AFI].[OrderTypeCode]
    (
        [OrderTypeCode]             CHAR(1)     NULL,
        [Description]               VARCHAR(30) NULL,
        [Description2]              VARCHAR(10) NULL,
        [UserMaintained]            VARCHAR(10) NULL,
        [DateMaintained]            DATE        NULL, --Decimal (8)
        [OrderClass]                CHAR(3)     NULL,
        [RouteThroughMRS]           CHAR(1)     NULL,
        [OrderTypeCategory]         CHAR(1)     NULL,
        [AllowAddressChange]        CHAR(1)     NULL,
        [AutoReleaseFlag]           CHAR(1)     NULL,
        [WindowExplosion]           CHAR(1)     NULL,
        [MinimumDollarsRequirement] CHAR(1)     NULL,
        [OrderTypeRequirement]      VARCHAR(12) NULL,
        [FeedEschedulerFlag]        CHAR(1)     NULL,
        [FeedRimmsFlag]             CHAR(1)     NULL,
        [TripType]                  CHAR(1)     NULL,
        [ZoneLoadLeadTimeFlag]      CHAR(1)     NULL,
        [SpecialHandlingFlag]       CHAR(1)     NULL,
        [AutoReschedule]            CHAR(1)     NULL,
        [UserDefinedFlag]           CHAR(1)     NULL
    );

--   DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/Wholesale/CODIS/OrderTypeCode/AFI_Codis_AAORDTYP.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],   
