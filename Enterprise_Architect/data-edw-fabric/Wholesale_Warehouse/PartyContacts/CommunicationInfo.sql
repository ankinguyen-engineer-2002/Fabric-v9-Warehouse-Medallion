CREATE TABLE [PartyContacts].[CommunicationInfo]
    (
        [LocationID]            INT          NULL,
        [PartyId]               INT          NULL,
        [ContactType]           CHAR(5)      NULL,
        [ContactID]             INT          NULL,
        [SequenceNumber]        INT          NULL,
        [Department]            CHAR(5)      NULL,
        [CommunicationValueExt] VARCHAR(15)  NULL,
        [CommunicationType]     CHAR(5)      NULL,
        [CommunicationValue]    VARCHAR(50)  NULL,
        [IsDefault]             BIT          NULL,
        [AddedByUser]                  VARCHAR(30)  NULL,
        [DateAdded]                  DATETIME2(6) NULL,   --Datetime2(7)
        [ChangeByUser]                  VARCHAR(30)  NULL,
        [DateChange]                  DATETIME2(6) NULL,   --Datetime2(7)
        [LastUserChanged]       VARCHAR(35)  NULL,
        [ActiveEndDate]         DATETIME2(6) NULL    --Datetime2(7)
    );

-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION = N'/Wholesale/PartyContacts/CommunicationInfo/GBL_PartyContacts_tblPartyCommunicationInfo.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],

