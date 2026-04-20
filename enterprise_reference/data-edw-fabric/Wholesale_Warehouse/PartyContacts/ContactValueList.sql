CREATE TABLE [PartyContacts].[ContactValueList]
    (
        [ValueType]    VARCHAR(20)  NULL,
        [KeyValue]     CHAR(5)      NULL,
        [Description]  VARCHAR(35)  NULL,
        [ListType]     VARCHAR(25)  NULL,
        [SortSequence] INT          NULL,
        [SecurityTag]  VARCHAR(20)  NULL,
        [KeyDateValue] DATETIME2(6) NULL,  --Datetime2(7)
        [AddedByUser]         VARCHAR(30)  NULL,
        [DateAdded]         DATETIME2(6) NULL,  --Datetime2(7)
        [ChangeByUser]         VARCHAR(30)  NULL,
        [DateChange]         DATETIME2(6) NULL   --Datetime2(7)
    );

--DATA_SOURCE = [AzureStorageGen2a],
--LOCATION = N'/Wholesale/PartyContacts/ContactValueList/GBL_PartyContacts_tblPartyContactValueList.snappy.parquet',
--FILE_FORMAT = [ParquetFileFormatSnappy],


