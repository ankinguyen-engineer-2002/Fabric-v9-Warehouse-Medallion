CREATE TABLE [Quality_DW].[FactCostHistoryAshcom] (
    [RowID]                           BIGINT           NOT NULL,
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
    [Total Quality Quantity Ashcomm]  DECIMAL (20, 8) NULL,
    [Quality Credit Quantity Ashcomm] DECIMAL (20, 8) NULL,
    [Quality Credits Ashcomm]         DECIMAL (20, 8) NULL,
    [Allocated]                       INT              NOT NULL,
    [Scrap Code with CS Control Code] CHAR (5)         NULL,
    [Ashcomm Reason Code]             VARCHAR (50)     NULL
)
;




GO
CREATE STATISTICS [Stat_FactCostHistoryAshcom_SerialNumber]
    ON [Quality_DW].[FactCostHistoryAshcom]([Serial Number]);


GO
CREATE STATISTICS [Stat_FactCostHistoryAshcom_ItemSKU]
    ON [Quality_DW].[FactCostHistoryAshcom]([Item SKU]);


GO
CREATE STATISTICS [Stat_FactCostHistoryAshcom_InvoiceNumber]
    ON [Quality_DW].[FactCostHistoryAshcom]([Invoice Number]);


GO
CREATE STATISTICS [Stat_FactCostHistoryAshcom_CreditNumber]
    ON [Quality_DW].[FactCostHistoryAshcom]([Credit Number]);


GO
CREATE STATISTICS [Stat_FactCostHistoryAshcom_CreditDate]
    ON [Quality_DW].[FactCostHistoryAshcom]([Credit Date]);


GO
CREATE STATISTICS [Stat_FactCostHistoryAshcom_AccountAndShipToNumber]
    ON [Quality_DW].[FactCostHistoryAshcom]([Account And ShipTo Number]);

