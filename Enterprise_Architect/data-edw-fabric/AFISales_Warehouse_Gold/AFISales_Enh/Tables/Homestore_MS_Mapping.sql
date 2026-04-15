CREATE TABLE [AFISales_Enh].[HomeStore_MS_Mapping]
    (
        [LocationKey]               VARCHAR(30)   NOT NULL,
        [Operation]                 VARCHAR(60)   NOT NULL,
        [StoreLocation]             VARCHAR(60)   NOT NULL,
        [AFIAccountNumber]          VARCHAR(60),
        [AFIShiptoNumber]           VARCHAR(60),
        [CloseDate]                 DATE,
        [HomestoreOwner]            VARCHAR(60),
        [Latitude]                  DECIMAL(7, 4) NOT NULL,
        [Longitude]                 DECIMAL(8, 4) NOT NULL,
        [ZipCode]                   VARCHAR(30)   NOT NULL,
        [County]                    VARCHAR(60),
        [Country]                   VARCHAR(60),
        [CountyCode]                VARCHAR(20),
        [StateCode]                 VARCHAR(20),
        [MSA_VP]                    VARCHAR(60),
        [AFIAlternateDivision]      VARCHAR(60)   NOT NULL,
        [MarketingSpecialist]       VARCHAR(60)   NOT NULL,
        [DesignatedMarketingArea]   VARCHAR(60)   NOT NULL
    );

