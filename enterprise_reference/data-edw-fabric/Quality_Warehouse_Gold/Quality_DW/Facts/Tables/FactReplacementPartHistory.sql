CREATE TABLE [Quality_DW].[FactReplacementPartHistory] (
    [RowID]                                 BIGINT           NOT NULL,
    [RPKey]                                 INT              NOT NULL,
    [Item Sequence]                         DECIMAL (2)      NOT NULL,
    [Part Number]                           VARCHAR (15)     NULL,
    [Serial Number]                         VARCHAR (15)     NULL,
    [Scrap Code]                            CHAR (4)         NULL,
    [Item SKU]                              VARCHAR (15)     NULL,
    [Warehouse]                             CHAR (3)         NULL,
    [Location Code]                         CHAR (5)         NOT NULL,
    [Mfg Warehouse Code]                    CHAR (3)         NULL,
    [Invoice Number]                        DECIMAL (9)      NULL,
    [Invoice Date]                          DATE             NULL,
    [Vendor Number]                         CHAR (8)         NULL,
    [Account And ShipTo Number]             VARCHAR (13)     NULL,
    [Ship Date]                             DATE             NULL,
    [Shipto AddressID]                      INT              NULL,
    [Replacement Part Order Count]          Decimal (15, 8) NULL,
    [Replacement Part Incidents]            Decimal (15, 8) NULL,
    [Parts Shipped Quantity - No Charge]    DECIMAL (15, 8) NULL,
    [Parts Shipped Quantity - Charged Back] DECIMAL (15, 8) NULL,
    [Parts Cost - No Charge]                DECIMAL (15, 8)  NULL,
    [Parts Cost - Charged Back]             DECIMAL (15, 8)  NULL,
    [Shipping Cost - No Charge]             NUMERIC (15, 6)  NULL,
    [Shipping Cost - Charged Back]          NUMERIC (15, 6)  NULL,
    [Allocated]                             INT              NOT NULL,
    [Scrap Code with CS Control Code]       CHAR (5)         NULL,
    [Days - Entered to Shipped]             INT              NULL,
    [Primary Site ID]                       CHAR (3)         NOT NULL,
    [Shipping Charges]                      DECIMAL (6, 2)   NULL,
    [Parts Charges]                         DECIMAL (6, 2)   NULL
)







GO
CREATE STATISTICS [Stat_FactReplacementPartHistory_ShiptoAddressID]
    ON [Quality_DW].[FactReplacementPartHistory]([Shipto AddressID]);


GO
CREATE STATISTICS [Stat_FactReplacementPartHistory_SerialNumber]
    ON [Quality_DW].[FactReplacementPartHistory]([Serial Number]);


GO
CREATE STATISTICS [Stat_FactReplacementPartHistory_RPKey]
    ON [Quality_DW].[FactReplacementPartHistory]([RPKey]);


GO
CREATE STATISTICS [Stat_FactReplacementPartHistory_ItemSKU]
    ON [Quality_DW].[FactReplacementPartHistory]([Item SKU]);

