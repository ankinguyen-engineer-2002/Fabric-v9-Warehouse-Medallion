CREATE TABLE [PartyContacts].[ProfileDetail]
    (
        [CompanyNo]             INT      NULL,
        [PartnerNo]             CHAR(8)      NULL,
        [PartnerShipto]         CHAR(4)      NULL,
        [TransactionCode]       CHAR(3)      NULL,
        [TransactionDirection]  CHAR(1)      NULL,
        [AllShiptos]            BIT          NULL,
        [TransactionType]       CHAR(1)      NULL,
        [TransactionStyle]      CHAR(1)      NULL,
        [EDITradingPartner]     CHAR(8)      NULL,
        [EDIVersion]            VARCHAR(12)  NULL,
        [EDISend997]            CHAR(1)      NULL,
        [EDITransactionProgram] VARCHAR(10)  NULL,
        [TransactionFormatID]   CHAR(4)      NULL,
        [UseDeliveryTable]      BIT          NULL,
        [DeliveryTypeID]        CHAR(4)      NULL,
        [SourceAddress]         VARCHAR(100) NULL,
        [SendFunctionalAck]     CHAR(1)      NULL,
        [PartnerTypeID]         CHAR(3)      NULL,
        [LanguageCode]          CHAR(3)      NULL,
        [XRefType]              VARCHAR(50)  NULL,
        [DestinationAddress]    VARCHAR(100) NULL,
        [EffectiveFrom]         DATETIME2(6) NULL, --Datetime2(7)
        [EffectiveTo]           DATETIME2(6) NULL, --Datetime2(7)
        [ActiveRecord]                 CHAR(1)      NULL,
        [AddedByUser]                  VARCHAR(30)  NULL,
        [DateAdded]                  DATETIME2(6) NULL, --Datetime2(7)
        [ChangeByUser]                  VARCHAR(30)  NULL,
        [DateChange]                  DATETIME2(6) NULL, --Datetime2(7)
        [AuthorizedBy]          VARCHAR(25)  NULL,
        [ChangedBy]             VARCHAR(25)  NULL,
        [ChangedDate]           DATETIME2(6) NULL, --Datetime2(7)
        [PartyID]               INT          NULL,
        [LocationID]            INT          NULL,
        [LastUserChanged]       VARCHAR(35)  NULL
    );

--  DATA_SOURCE = [AzureStorageGen2a],
--  LOCATION = N'/Wholesale/PartyContacts/ProfileDetail/AFI_DemandPlanning_tblPartnerProfileDetail.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],

