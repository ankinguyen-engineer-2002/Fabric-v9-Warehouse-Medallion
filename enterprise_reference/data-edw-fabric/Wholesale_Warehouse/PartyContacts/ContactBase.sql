CREATE TABLE [PartyContacts].[ContactBase]
    (
        [LocationID]        INT          NULL,
        [PartyID]           INT          NULL,
        [ContactType]       CHAR(5)      NULL,
        [ContactID]         INT          NULL,
        [JobTitle]          VARCHAR(30)  NULL,
        [Department]        CHAR(5)      NULL,
        [IsDefault]         BIT          NULL,
        [NetworkUserID]     VARCHAR(25)  NULL,
        [AS400UserID]       VARCHAR(10)  NULL,
        [ProgramAdded]      VARCHAR(30)  NULL,
        [ActiveEndDate]     DATETIME2(6) NULL,  --Datetime2(7)
        [AdGuid]            VARCHAR(40)  NULL,
        [AddedByUser]              VARCHAR(30)  NULL,
        [DateAdded]              DATETIME2(6) NULL,  --Datetime2(7)
        [ChangeByUser]              VARCHAR(30)  NULL,
        [DateChange]              DATETIME2(6) NULL,  --Datetime2(7)
        [LastUserChanged]   VARCHAR(35)  NULL,
        [DefaultLanguage]   CHAR(8)      NULL,
        [ForecastPlannerID] VARCHAR(40)  NULL
    );

--  DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION = N'/Wholesale/PartyContacts/ContactBase/GBL_PartyContacts_tblPartyContactBase.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],

