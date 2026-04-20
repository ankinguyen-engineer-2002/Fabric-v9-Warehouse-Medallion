CREATE TABLE [Marketing].[ItemMaster]
    (
        [ItemSKU]              VARCHAR(15)    NOT NULL,
        [Description]          VARCHAR(30)    NULL,
        [Class]                CHAR(4)        NULL,
        [Style]                CHAR(3)        NULL,
        [StandardCost]         DECIMAL(9, 3)  NULL,
        [StandardPrice]        DECIMAL(8, 2)  NULL,
        [Status]               CHAR(1)        NULL,
        [Weight]               DECIMAL(7, 3)  NULL,
        [Cubes]                DECIMAL(5, 2)  NULL,
        [SalesClass]           CHAR(2)        NULL,
        [Seats]                DECIMAL(5, 2)  NULL,
        [ATP_ItemSKU]          VARCHAR(15)    NULL,
        [CommissionClass]      CHAR(2)        NULL,
        [DiscountClass]        CHAR(2)        NULL,
        [FreightClass]         CHAR(2)        NULL,
        [CEX]                  CHAR(3)        NULL,
        [CEX2]                 CHAR(3)        NULL,
        [Width1]               DECIMAL(7, 2)  NULL,
        [Width2]               DECIMAL(7, 2)  NULL,
        [Height1]              DECIMAL(7, 2)  NULL,
        [Height2]              DECIMAL(7, 2)  NULL,
        [Depth1]               DECIMAL(7, 2)  NULL,
        [Depth2]               DECIMAL(7, 2)  NULL,
        [StatusLastChanged]    DATE           NULL, --- DATETIME2(6)
        [PreviousStatus]       CHAR(1)        NULL,
        [GroupingCode]         VARCHAR(10)    NULL,
        [Gendescd]             INT            NULL,
        [Leafin]               DECIMAL(6, 2)  NULL,
        [DivisionCode]         CHAR(1)        NULL,
        [QuantityPerContainer] INT            NULL,
        [GroupingCodeLength]   INT            NULL,
        [AuditFlag]            BIT            NULL,
        [AddedByUser]                 VARCHAR(30)    NULL,
        [DateAdded]                 DATETIME2(6)   NULL, --- DATETIME2(6)
        [ChangeByUser]                 VARCHAR(30)    NULL,
        [DateChange]                 DATETIME2(6)   NULL, --- DATETIME2(6)
        [ActiveRecord]                CHAR(1)        NULL,
        [SalesCategory]        VARCHAR(3)     NULL,
        [BlockingCode]         VARCHAR(5)     NULL,
        [UnitOfMeasure]        VARCHAR(2)     NULL,
        [UPCPrefix]            DECIMAL(1, 0)  NULL,
        [UPCCode]              DECIMAL(10, 0) NULL,
        [UPCCheckDigit]        DECIMAL(1, 0)  NULL,
        [HTSNumber]            VARCHAR(10)    NULL,
        [ItemTypeCode]         CHAR(1)        NULL,
        [ImportDomesticCode]   CHAR(1)        NULL,
        [CountryOfOrigin]      CHAR(5)        NULL,
        [LastChangedDate]      DATETIME2(6)   NULL, --- DATETIME
        [GTINCode]             VARCHAR(14)    NULL,
        [GoodBetterBest]       VARCHAR(6)     NULL
 
    );


-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION = N'/Wholesale/Marketing/ItemMaster/AFI_Sales_tblItemMaster.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
