
  CREATE TABLE [Quality_Enh].[InvoiceSerialNumberNone] (
    [RowID]           BIGINT       NOT NULL,   --- IDENTITY (1, 1) NOT NULL,
    [InvoiceDate]     DATE         NOT NULL,
    [InvoiceNumber]   DECIMAL (9)  NOT NULL,
    [ItemSKU]         VARCHAR (15) NOT NULL,
    [ItemSeqNumber]   VARCHAR (7)  NOT NULL,
    [OrderNumber]     VARCHAR (10) NOT NULL,
    [CustomerNumber]  CHAR (8)     NOT NULL,
    [ShiptoNumber]    CHAR (4)     NOT NULL,
    [DropNumber]      DECIMAL (2)  NULL,
    [Carrier]         VARCHAR (50) NOT NULL,
    [ShippedQuantity] DECIMAL (7)  NOT NULL,
    [Warehouse]       CHAR (3)     NULL
)

GO
CREATE STATISTICS [Stat_InvoiceSerialNumberNone_Warehouse]
    ON [Quality_Enh].[InvoiceSerialNumberNone]([Warehouse]);


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberNone_ShiptoNumber]
    ON [Quality_Enh].[InvoiceSerialNumberNone]([ShiptoNumber]);


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberNone_ShippedQuantity]
    ON [Quality_Enh].[InvoiceSerialNumberNone]([ShippedQuantity]);


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberNone_RowID]
    ON [Quality_Enh].[InvoiceSerialNumberNone]([RowID]);


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberNone_OrderNumber]
    ON [Quality_Enh].[InvoiceSerialNumberNone]([OrderNumber]);


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberNone_ItemSeqNumber]
    ON [Quality_Enh].[InvoiceSerialNumberNone]([ItemSeqNumber]);


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberNone_ItemSKU]
    ON [Quality_Enh].[InvoiceSerialNumberNone]([ItemSKU]);


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberNone_InvoiceNumber]
    ON [Quality_Enh].[InvoiceSerialNumberNone]([InvoiceNumber]);


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberNone_InvoiceDate]
    ON [Quality_Enh].[InvoiceSerialNumberNone]([InvoiceDate]);


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberNone_DropNumber]
    ON [Quality_Enh].[InvoiceSerialNumberNone]([DropNumber]);


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberNone_CustomerNumber]
    ON [Quality_Enh].[InvoiceSerialNumberNone]([CustomerNumber]);


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberNone_Carrier]
    ON [Quality_Enh].[InvoiceSerialNumberNone]([Carrier]);



