CREATE TABLE [PartyContacts].[AddressMaster]
    (
        [AddressID]               INT           NULL,
        [Address1]                VARCHAR(35)   NULL,
        [Address2]                VARCHAR(35)   NULL,
        [Address3]                VARCHAR(35)   NULL,
        [Address4]                VARCHAR(35)   NULL,
        [Address5]                VARCHAR(35)   NULL,
        [City]                    VARCHAR(35)   NULL,
        [State]                   CHAR(2)       NULL,
        [Country]                 CHAR(3)       NULL,
        [GeocodeLatitude]         DECIMAL(8, 4) NULL,
        [GeocodeLongitude]        DECIMAL(8, 4) NULL,
        [ZipCode]                 VARCHAR(10)   NULL,
        [CountyCode]              CHAR(3)       NULL,
        [CustomsIDNumber]         VARCHAR(20)   NULL,
        [GeocodeAccuracy]         INT           NULL,
        [TranscomCityCode]        INT           NULL,
        [Directions]              VARCHAR(150)  NULL,
        [CrossStreet]             VARCHAR(35)   NULL,
        [GeocodeVerificationDate] DATETIME2(6)  NULL,   --Datetime2(7)
        [TimeZone]                CHAR(3)       NULL,
        [GeocodeType]             CHAR(1)       NULL,
        [MSA_FIPS]                CHAR(4)       NULL,
        [ShortAddress1]           VARCHAR(25)   NULL,
        [ShortAddress2]           VARCHAR(25)   NULL,
        [ShortAddress3]           VARCHAR(25)   NULL,
        [ShortAddress4]           VARCHAR(25)   NULL,
        [ShortCity]               VARCHAR(25)   NULL,
        [AddedByUser]                    VARCHAR(30)   NULL,
        [DateAdded]                    DATETIME2(6)  NULL, --Datetime2(7)
        [ChangeByUser]                    VARCHAR(30)   NULL,
        [DateChange]                    DATETIME2(6)  NULL --Datetime2(7)
    );

--- DATA_SOURCE = [AzureStorageGen2a],
--- LOCATION = N'/Wholesale/PartyContacts/AddressMaster/GBL_PartyContacts_tblPartyAddressMaster.snappy.parquet',
--- FILE_FORMAT = [ParquetFileFormatSnappy],

