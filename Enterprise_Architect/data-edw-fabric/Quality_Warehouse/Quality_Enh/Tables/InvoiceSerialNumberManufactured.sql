CREATE TABLE [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [InvoiceDate]      DATE         NOT NULL,
        [InvoiceNumber]    DECIMAL(9)   NOT NULL,
        [SerialNumber]     VARCHAR(15)  NULL,
        [OrderNumber]      VARCHAR(10)  NULL,
        [ItemSKU]          VARCHAR(15)  NULL,
        [ItemSeqNumber]    DECIMAL(7)   NOT NULL,
        [MfgOrderNumber]   VARCHAR(10)  NULL,
        [CustomerNumber]   CHAR(8)      NULL,
        [ShiptoNumber]     CHAR(4)      NULL,
        [DropNumber]       DECIMAL(2)   NOT NULL,
        [WhereMade]        CHAR(5)      NOT NULL,
        [UserGroup]        VARCHAR(10)  NULL,
        [MfgDate]          DATE         NULL,
        [ScanName]         VARCHAR(15)  NULL,
        [LoadDate]         DATE         NOT NULL,
        [TruckNumber]      VARCHAR(15)  NULL,
        [Carrier]          VARCHAR(100) NULL,
        [Warehouse]        CHAR(3)      NULL,
        [Department]       CHAR(5)      NULL,
        [WorkCenter]       CHAR(5)      NULL,
        [Group]            DECIMAL(5)   NOT NULL,
        [Shift]            DECIMAL(1)   NOT NULL,
        [SupervisorNumber] DECIMAL(5)   NOT NULL,
        [AATWarehouse]     CHAR(3)      NULL
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_WorkCenter]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [WorkCenter]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_WhereMade]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [WhereMade]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_Warehouse]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [Warehouse]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_UserGroup]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [UserGroup]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_TruckNumber]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [TruckNumber]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_SupervisorNumber]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [SupervisorNumber]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_ShiptoNumber]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [ShiptoNumber]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_Shift]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [Shift]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_SerialNumber]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [SerialNumber]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_ScanName]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [ScanName]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_OrderNumber]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [OrderNumber]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_MfgOrderNumber]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [MfgOrderNumber]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_MfgDate]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [MfgDate]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_LoadDate]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [LoadDate]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_ItemSeqNumber]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [ItemSeqNumber]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_ItemSKU]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [ItemSKU]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_InvoiceNumber]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [InvoiceNumber]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_InvoiceDate]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [InvoiceDate]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_Group]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [Group]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_DropNumber]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [DropNumber]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_Department]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [Department]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_CustomerNumber]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [CustomerNumber]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_Carrier]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [Carrier]
    );


GO
CREATE STATISTICS [Stat_InvoiceSerialNumberManufactured_AATWarehouse]
    ON [Quality_Enh].[InvoiceSerialNumberManufactured]
    (
        [AATWarehouse]
    );

