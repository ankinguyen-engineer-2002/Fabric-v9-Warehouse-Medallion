CREATE TABLE [Quality_DW].[FactShippedHistoryByPartNumber] (
    [RowID]                       BIGINT          NOT NULL,
    [Invoice Week Ended Date]     DATE            NULL,
    [Vendor]                      CHAR (8)        NULL,
    [Account And ShipTo Number]   VARCHAR (13)    NULL,
    [ShipTo AddressID]            INT             NULL,
    [Warehouse]                   CHAR (3)        NULL,
    [Location Code]               CHAR (5)        NULL,
    [End Item Number]             VARCHAR (15)    NULL,
    [Part Number]                 VARCHAR (15)    NULL,
    [End Item Shipped Quantity]   DECIMAL (16, 3) NULL,
    [End Item FOB Amount Shipped] DECIMAL (16, 3) NULL,
    [RP Quantity Used]            INT             NULL,
    [Allocated]                   INT             NULL,
    [Part Primary Site ID]        CHAR (3)        NULL,
    [RP Shipped Quantity Used]    DECIMAL (27, 3) NULL
)



GO
CREATE STATISTICS [Stat_FactShippedHistoryByPartNumber_PartNumber]
    ON [Quality_DW].[FactShippedHistoryByPartNumber]([Part Number]);


GO
CREATE STATISTICS [Stat_FactShippedHistoryByPartNumber_InvoiceWeekEndedDate]
    ON [Quality_DW].[FactShippedHistoryByPartNumber]([Invoice Week Ended Date]);

