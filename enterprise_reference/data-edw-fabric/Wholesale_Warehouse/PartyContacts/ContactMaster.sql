CREATE TABLE [PartyContacts].[ContactMaster]
    (
        [ContactID]         INT          NULL,
        [FullName]          VARCHAR(50)  NULL,
        [FirstName]         VARCHAR(25)  NULL,
        [MiddleName]        VARCHAR(25)  NULL,
        [LastName]          VARCHAR(25)  NULL,
        [PreferredName]     VARCHAR(20)  NULL,
        [PreferredLanguage] CHAR(5)      NULL,
        [AddedByUser]              VARCHAR(30)  NULL,
        [DateAdded]              DATETIME2(6) NULL,  --Datetime2(7)
        [ChangeByUser]              VARCHAR(30)  NULL,
        [DateChange]              DATETIME2(6) NULL,   --Datetime2(7)
        [LastUserChanged]   VARCHAR(35)  NULL,
        [ShortFullName]     VARCHAR(25)  NULL
    );

-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION = N'/Wholesale/PartyContacts/ContactMaster/GBL_PartyContacts_tblPartyContactMaster.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],


