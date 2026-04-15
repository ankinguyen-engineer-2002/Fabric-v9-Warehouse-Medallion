CREATE TABLE [Marketing].[TerritoryAssignment]
    (
        [TerritoryCode]   CHAR(5)      NULL,
        [CommissionClass] CHAR(2)      NULL,
        [MarketingSpecialist]           CHAR(5)      NULL,
        [StartDate]       DATE         NULL, --DateTime
        [EndDdate]        DATE         NULL, --DateTime
        [AuditFlag]       BIT          NULL,
        [AddedByUser]            VARCHAR(30)  NULL,
        [DateAdded]            DATETIME2(6) NULL, --DATETIME2 (7) NULL,
        [ChangeByUser]            VARCHAR(30)  NULL,
        [DateChange]            DATETIME2(6) NULL, --DATETIME2 (7) NULL,
        [ActiveRecord]           CHAR(1)      NULL
    );


-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION = N'/Wholesale/Marketing/TerritoryAssignment/AFI_Sales_tblTerritoryAssignment.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
