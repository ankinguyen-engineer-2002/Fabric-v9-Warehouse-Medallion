CREATE TABLE [Transportation].[TripTypeCodes]
    (
        [TripType]            CHAR(1)      NULL,
        [TripTypeDescription] VARCHAR(25)  NULL,
        [SpecialHandling]     CHAR(1)      NULL,
        [UserDefined]         CHAR(1)      NULL,
        [AddTimeStamp]        DATETIME2(6) NOT NULL,  --DateTime2(7)
        [AddUser]             VARCHAR(10)  NULL,
        [ChangeTimeStamp]     DATETIME2(6) NOT NULL,  --DateTime2(7)
        [ChangeUser]          VARCHAR(10)  NULL,
        [TransportMethod]     CHAR(2)      NULL,
        [ResourceCapability]  VARCHAR(12)  NULL,
        [DeliveryModeDefault] CHAR(3)      NULL,
        [DeliveryCategory]    VARCHAR(10)  NULL
    );

--    DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/Wholesale/CODIS/TRPTYPCD/AFI_Codis_TRPTYPCD.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],


