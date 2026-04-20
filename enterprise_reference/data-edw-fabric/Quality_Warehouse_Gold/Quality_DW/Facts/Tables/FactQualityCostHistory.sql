CREATE TABLE [Quality_DW].[FactQualityCostHistory] (
    [RowID]                           BIGINT            NOT NULL,
    [Credit Number]                   DECIMAL (9)      NOT NULL,
    [Credit Date]                     DATE             NOT NULL,
    [Invoice Number]                  DECIMAL (9)      NULL,
    [Invoice Date]                    DATE             NULL,
    [Scrap Code]                      CHAR (4)         NULL,
    [Item SKU]                        VARCHAR (15)     NOT NULL,
    [Item Status]                     CHAR (1)         NULL,
    [Serial Number]                   VARCHAR (15)     NULL,
    [Shipto AddressID]                INT              NULL,
    [Warehouse]                       CHAR (3)         NULL,
    [Location Code]                   CHAR (5)         NOT NULL,
    [Mfg Warehouse Code]              CHAR (3)         NULL,
    [Vendor Number]                   CHAR (8)         NULL,
    [Account And ShipTo Number]       VARCHAR (13)     NULL,
    [Total Quality Quantity]          DECIMAL (4, 2) NULL,
    [Quality Credit Quantity]         DECIMAL (4, 2) NULL,
    [Quality Credits]                 DECIMAL (6,2) NULL,
    [Non-Quality Credit Quantity]     DECIMAL (6,2) NULL,
    [Non-Quality Credits]             DECIMAL (6,2) NULL,
    [Quality Return Quantity]         DECIMAL (4, 2) NULL,
    [Quality Returns Amount]          DECIMAL (4, 2)  NULL,
    [Non-Quality Return Quantity]     DECIMAL (4, 2) NULL,
    [Non-Quality Returns Amount]      DECIMAL (10, 4)  NULL,
    [Short Ship Quantity]             DECIMAL (4, 2) NULL,
    [Short Ship Amount]               DECIMAL (10, 4) NULL,
    [Allocated]                       INT              NOT NULL,
    [Scrap Code with CS Control Code] CHAR (5)         NULL
)






GO
CREATE STATISTICS [Stat_FactQualityCostHistory_SerialNumber]
    ON [Quality_DW].[FactQualityCostHistory]([Serial Number]);


GO
CREATE STATISTICS [Stat_FactQualityCostHistory_ItemSKU]
    ON [Quality_DW].[FactQualityCostHistory]([Item SKU]);


GO
CREATE STATISTICS [Stat_FactQualityCostHistory_InvoiceNumber]
    ON [Quality_DW].[FactQualityCostHistory]([Invoice Number]);


GO
CREATE STATISTICS [Stat_FactQualityCostHistory_CreditNumber]
    ON [Quality_DW].[FactQualityCostHistory]([Credit Number]);


GO
CREATE STATISTICS [Stat_FactQualityCostHistory_CreditDate]
    ON [Quality_DW].[FactQualityCostHistory]([Credit Date]);


GO
CREATE STATISTICS [Stat_FactQualityCostHistory_AccountAndShipToNumber]
    ON [Quality_DW].[FactQualityCostHistory]([Account And ShipTo Number]);

