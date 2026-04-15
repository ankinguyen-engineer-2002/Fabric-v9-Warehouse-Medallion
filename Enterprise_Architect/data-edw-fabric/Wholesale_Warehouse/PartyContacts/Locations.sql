CREATE TABLE [PartyContacts].[Locations]
    (
        [LocationID]              INT          NULL,
        [PartyID]                 INT          NULL,
        [AddressID]               INT          NULL,
        [Description]             VARCHAR(50)  NULL,
        [LocationType]            CHAR(5)      NULL,
        [AddressVerificationDate] DATETIME2(6) NULL,  --Datetime2(7)
        [OutsideSourceType]       CHAR(5)      NULL,
        [OutsideSourceLocation]   VARCHAR(20)  NULL,
        [AddedByUser]                    VARCHAR(30)  NULL,
        [DateAdded]                    DATETIME2(6) NULL,  --Datetime2(7)
        [ChangeByUser]                    VARCHAR(30)  NULL,
        [DateChange]                    DATETIME2(6) NULL,  --Datetime2(7)
        [ActiveEndDate]           DATETIME2(6) NULL,  --Datetime2(7)
        [ShortDescription]        VARCHAR(25)  NULL
    );

--DATA_SOURCE = [AzureStorageGen2a],
--LOCATION = N'/Wholesale/PartyContacts/Locations/GBL_PartyContacts_tblPartyLocations.snappy.parquet',
--FILE_FORMAT = [ParquetFileFormatSnappy],


