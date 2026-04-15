CREATE TABLE [Quality_Enh].[InvoiceSerialNumberPurchased]
    (
        [InvoiceDate]     DATE        NOT NULL,
        [InvoiceNumber]   DECIMAL(9)  NOT NULL,
        [SerialNumber]    VARCHAR(15) NOT NULL,
        [OrderNumber]     VARCHAR(10) NOT NULL,
        [ItemSKU]         VARCHAR(15) NOT NULL,
        [ItemSeqNumber]   DECIMAL(7)  NOT NULL,
        [PONumber]        VARCHAR(25) NOT NULL,
        [CustomerNumber]  CHAR(8)     NOT NULL,
        [ShiptoNumber]    CHAR(4)     NOT NULL,
        [VendorNumber]    CHAR(8)     NOT NULL,
        [SalesOffice]     VARCHAR(10) NOT NULL,
        [CountryOfOrigin] CHAR(5)     NOT NULL,
        [DropNumber]      DECIMAL(2)  NULL,
        [ScanName]        VARCHAR(15) NULL,
        [LoadDate]        DATE        NULL,
        [TruckNumber]     VARCHAR(15) NULL,
        [Carrier]         VARCHAR(50) NULL,
        [Warehouse]       CHAR(3)     NULL,
        [AATWarehouse]    CHAR(5)     NULL
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberPurchased_Warehouse]
    ON [Quality_Enh].[InvoiceSerialNumberPurchased]
    (
        [Warehouse]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberPurchased_VendorNumber]
    ON [Quality_Enh].[InvoiceSerialNumberPurchased]
    (
        [VendorNumber]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberPurchased_TruckNumber]
    ON [Quality_Enh].[InvoiceSerialNumberPurchased]
    (
        [TruckNumber]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberPurchased_ShiptoNumber]
    ON [Quality_Enh].[InvoiceSerialNumberPurchased]
    (
        [ShiptoNumber]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberPurchased_SerialNumber]
    ON [Quality_Enh].[InvoiceSerialNumberPurchased]
    (
        [SerialNumber]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberPurchased_ScanName]
    ON [Quality_Enh].[InvoiceSerialNumberPurchased]
    (
        [ScanName]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberPurchased_SalesOffice]
    ON [Quality_Enh].[InvoiceSerialNumberPurchased]
    (
        [SalesOffice]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberPurchased_PONumber]
    ON [Quality_Enh].[InvoiceSerialNumberPurchased]
    (
        [PONumber]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberPurchased_OrderNumber]
    ON [Quality_Enh].[InvoiceSerialNumberPurchased]
    (
        [OrderNumber]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberPurchased_LoadDate]
    ON [Quality_Enh].[InvoiceSerialNumberPurchased]
    (
        [LoadDate]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberPurchased_ItemSeqNumber]
    ON [Quality_Enh].[InvoiceSerialNumberPurchased]
    (
        [ItemSeqNumber]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberPurchased_ItemSKU]
    ON [Quality_Enh].[InvoiceSerialNumberPurchased]
    (
        [ItemSKU]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberPurchased_InvoiceNumber]
    ON [Quality_Enh].[InvoiceSerialNumberPurchased]
    (
        [InvoiceNumber]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberPurchased_InvoiceDate]
    ON [Quality_Enh].[InvoiceSerialNumberPurchased]
    (
        [InvoiceDate]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberPurchased_DropNumber]
    ON [Quality_Enh].[InvoiceSerialNumberPurchased]
    (
        [DropNumber]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberPurchased_CustomerNumber]
    ON [Quality_Enh].[InvoiceSerialNumberPurchased]
    (
        [CustomerNumber]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberPurchased_CountryOfOrigin]
    ON [Quality_Enh].[InvoiceSerialNumberPurchased]
    (
        [CountryOfOrigin]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberPurchased_Carrier]
    ON [Quality_Enh].[InvoiceSerialNumberPurchased]
    (
        [Carrier]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberPurchased_AATWarehouse]
    ON [Quality_Enh].[InvoiceSerialNumberPurchased]
    (
        [AATWarehouse]
    );

