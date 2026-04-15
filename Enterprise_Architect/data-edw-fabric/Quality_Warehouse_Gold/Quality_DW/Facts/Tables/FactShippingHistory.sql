CREATE TABLE [Quality_DW].[FactShippingHistory] (
    [RowID]                     BIGINT           NOT NULL,
    [Invoice Date]              DATE            NOT NULL,
    [Invoice Number]            DECIMAL (9)     NOT NULL,
    [Serial Number]             VARCHAR (15)    NOT NULL,
    [Vendor]                    CHAR (8)        NULL,
    [Account And ShipTo Number] VARCHAR (15)    NULL,
    [Shipto AddressID]          INT             NULL,
    [Warehouse]                 CHAR (3)        NOT NULL,
    [Location Code]             CHAR (5)        NULL,
    [Mfg Warehouse Code]        CHAR (3)        NULL,
    [Item Number]               VARCHAR (15)    NOT NULL,
    [Shipped Quantity]          DECIMAL (13, 2) NULL,
    [FOB Amount Shipped]        DECIMAL (15, 6) NULL,
    [Allocated]                 INT             NOT NULL
)




GO
CREATE STATISTICS [Stat_FactShippingHistory_InvoiceNumber]
    ON [Quality_DW].[FactShippingHistory]([Invoice Number]);


GO
CREATE STATISTICS [Stat_FactShippingHistory_InvoiceDate]
    ON [Quality_DW].[FactShippingHistory]([Invoice Date]);

