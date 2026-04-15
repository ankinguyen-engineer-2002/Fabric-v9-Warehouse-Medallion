CREATE TABLE [PartyContacts].[PartyMaster]
    (
        [PartyID]        INT          NULL,
        [PartyName]      VARCHAR(35)  NULL,
        [CustomerNumber] CHAR(8)      NULL,
        [VendorID]       CHAR(8)      NULL,
        [ExportID]       CHAR(8)      NULL,
        [AddedByUser]           VARCHAR(30)  NULL,
        [DateAdded]           DATETIME2(6) NULL, -- Datetime2(7)
        [ChangeByUser]           VARCHAR(30)  NULL,
        [DateChange]           DATETIME2(6) NULL, -- Datetime2(7)
        [ActiveEndDate]  DATETIME2(6) NULL, -- Datetime2(7)
        [PartyType]      CHAR(5)      NULL,
        [ShortName]      VARCHAR(25)  NULL
    );

--DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION = N'/Wholesale/PartyContacts/PartyMaster/GBL_PartyContacts_tblPartyMaster.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],


