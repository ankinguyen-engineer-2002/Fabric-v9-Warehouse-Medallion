CREATE TABLE [Marketing].[CRMVelocityDriver]
    (
        [ID]                        INT            NULL,
        [RegionCode]                CHAR(3)        NULL,
        [RepID]                     CHAR(5)        NULL,
        [DivisionCode]              CHAR(1)        NULL,
        [AccountNumber]             CHAR(8)        NULL,
        [ShiptoNumber]              CHAR(4)        NULL,
        [CreatedDate]               DATETIME2(6)   NULL, --- DATETIME2(6)
        [MarketHook1]               VARCHAR(100)   NULL,
        [MarketHook2]               VARCHAR(100)   NULL,
        [MarketHook3]               VARCHAR(100)   NULL,
        [MarketHook4]               VARCHAR(100)   NULL,
        [MarketHook5]               VARCHAR(100)   NULL,
        [MarketHook6]               VARCHAR(100)   NULL,
        [CustomHook]                VARCHAR(50)    NULL,
        [EventName]                 VARCHAR(100)   NULL,
        [VelocityDriverName]        VARCHAR(100)   NULL,
        [MarketDate]                DATETIME2(6)   NULL, --- DATETIME2(6)
        [EventEndDate]              DATETIME2(6)   NULL, --- DATETIME2(6)
        [MediaCircularFlag]         BIT            NULL,
        [MediaDirectMailFlag]       BIT            NULL,
        [MediaInternetFlag]         BIT            NULL,
        [MediaSocialMediaFlag]      BIT            NULL,
        [MediaNewspaperFlag]        BIT            NULL,
        [MediaOtherFlag]            VARCHAR(100)   NULL,
        [MediaRadioFlag]            BIT            NULL,
        [MediaTVFlag]               BIT            NULL,
        [WillTheyRunThisAgainFlag]  BIT            NULL,
        [VelocityDriverStatusCode]  SMALLINT       NULL,
        [VelocityDriverStatusDescr] VARCHAR(100)   NULL,
        [VelocityDriverCount]       DECIMAL(18, 3) NULL
    );


-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION = N'/Wholesale/Marketing/CRMVelocityDriver/CRMVelocityDriver.csv',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
