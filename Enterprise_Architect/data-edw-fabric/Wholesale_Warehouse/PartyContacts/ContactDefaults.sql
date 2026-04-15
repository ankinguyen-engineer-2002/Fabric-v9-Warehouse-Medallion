CREATE TABLE [PartyContacts].[ContactDefaults]
    (
        [PartyID]                  INT          NULL,
        [LocationID]               INT          NULL,
        [Department]               CHAR(5)      NULL,
        [ContactType]              CHAR(5)      NULL,
        [ContactID]                INT          NULL,
        [IsBuyerDefault]           BIT          NULL,
        [IsReceivingDefault]       BIT          NULL,
        [AddedByUser]                     VARCHAR(30)  NULL,
        [DateAdded]                     DATETIME2(6) NULL,   --Datetime2(7)
        [ChangeByUser]                     VARCHAR(30)  NULL,
        [DateChange]                     DATETIME2(6) NULL,   --Datetime2(7)
        [IsStoreDefault]           BIT          NULL,
        [IsCustomerServiceDefault] BIT          NULL,
        [IsPrimaryOwnerDefault]    BIT          NULL,
        [IsWarrantyDefault]        BIT          NULL
    );

-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION = N'/Wholesale/PartyContacts/ContactDefaults/GBL_PartyContacts_tblPartyContactDefaults.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
