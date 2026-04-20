CREATE TABLE [Quality_AFI].[ReplacementPartHeader]
    (
        [ActiveRecord]         CHAR(1)       NULL,
        [DateEntered]          DATE          NULL, --- Decimal
        [EnteredBy]            VARCHAR(10)   NULL,
        [RPKey]                NUMERIC(7)    NULL,
        [CustomerNumber]       NUMERIC(8)    NULL,
        [PurchaseOrder]        VARCHAR(22)   NULL,
        [Status]               CHAR(1)       NULL,
        [InvoiceStatus]        CHAR(1)       NULL,
        [ItemSKU]              VARCHAR(15)   NULL,
        [ItemOverrideFlag]     CHAR(1)       NULL,
        [DefectCode]           CHAR(2)       NULL,
        [LocationCode]         CHAR(2)       NULL,
        [OrderPriority]        CHAR(1)       NULL,
        [ChargeType]           CHAR(1)       NULL,
        [SerialNumber]         VARCHAR(15)   NULL,
        [ShiptoNumber]         CHAR(4)       NULL,
        [ShipDate]             DATE          NULL, --Decimal
        [ShipVia]              CHAR(3)       NULL,
        [ShippingCost]         DECIMAL(6, 2) NULL,
        [ShiptoName]           VARCHAR(25)   NULL,
        [ShiptoAddress1]       VARCHAR(25)   NULL,
        [ShiptoAddress2]       VARCHAR(25)   NULL,
        [ShiptoAddress3]       VARCHAR(25)   NULL,
        [ShiptoState]          CHAR(2)       NULL,
        [ShiptoZipCode]        CHAR(5)       NULL,
        [ShiptoZipExtension]   CHAR(4)       NULL,
        [ShippedFlag]          CHAR(1)       NULL,
        [PickedDate]           DATE          NULL, --DECIMAL (8) 
        [TrackingNumber]       VARCHAR(30)   NULL,
        [TripNumber]           DECIMAL(5)    NULL,
        [TrailerNumber]        VARCHAR(10)   NULL,
        [ReferenceNumber]      VARCHAR(30)   NULL,
        [Warehouse]            CHAR(3)       NULL,
        [InventoryFlag]        CHAR(1)       NULL,
        [PieceCount]           DECIMAL(3)    NULL,
        [ShippingZone]         CHAR(4)       NULL,
        [CartonID]             CHAR(10)      NULL,
        [ProcessedFlag]        CHAR(1)       NULL,
        [DropNumber]           DECIMAL(2)    NULL,
        [PackageCount]         DECIMAL(3)    NULL,
        [LeftPart]             DECIMAL(2)    NULL,
        [RightPart]            DECIMAL(2)    NULL,
        [CenterPart]           DECIMAL(2)    NULL,
        [TopPart]              DECIMAL(2)    NULL,
        [BottomPart]           DECIMAL(2)    NULL,
        [FrontPart]            DECIMAL(2)    NULL,
        [BackPart]             DECIMAL(2)    NULL,
        [ShiptoCountry]        VARCHAR(25)   NULL,
        [EmailAddress]         VARCHAR(75)   NULL,
        [ShiptoPhone]          VARCHAR(16)   NULL,
        [ShiptoFax]            VARCHAR(16)   NULL,
        [ShiptoAddress4]       VARCHAR(25)   NULL,
        [ShippingMethod]       CHAR(1)       NULL,
        [ContactName]          VARCHAR(25)   NULL,
        [ImportPONumber]       VARCHAR(10)   NULL,
        [ServiceType]          VARCHAR(22)   NULL,
        [OrderType]            CHAR(1)       NULL,
        [Site]                 CHAR(3)       NULL,
        [UpholsteryWarehouse]  CHAR(3)       NULL,
        [UpholsteryLineNumber] CHAR(5)       NULL
    );

GO
CREATE STATISTICS [Stat_ReplacementPartOrders_Warehouse]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [Warehouse]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_TrackingNumber]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [TrackingNumber]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_UpholsteryWarehouse]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [UpholsteryWarehouse]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_UpholsteryLineNumber]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [UpholsteryLineNumber]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_TrailerNumber]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [TrailerNumber]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_TripNumber]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [TripNumber]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_TopPart]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [TopPart]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ServiceType]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ServiceType]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ShippedFlag]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ShippedFlag]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_Status]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [Status]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_Site]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [Site]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ShiptoZipExtension]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ShiptoZipExtension]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ShiptoZipCode]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ShiptoZipCode]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ShipVia]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ShipVia]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ShiptoState]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ShiptoState]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ShiptoPhone]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ShiptoPhone]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ShiptoNumber]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ShiptoNumber]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ShiptoName]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ShiptoName]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ShippingMethod]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ShippingMethod]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ShiptoFax]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ShiptoFax]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ShipDate]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ShipDate]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ShiptoCountry]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ShiptoCountry]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ShippingCost]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ShippingCost]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ShiptoAddress4]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ShiptoAddress4]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ShiptoAddress3]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ShiptoAddress3]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ShiptoAddress2]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ShiptoAddress2]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ShiptoAddress1]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ShiptoAddress1]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_SerialNumber]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [SerialNumber]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_RZONE]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ShippingZone]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_RightPart]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [RightPart]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_LocationCode]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [LocationCode]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_RPKey]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [RPKey]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_DefectCode]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [DefectCode]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ProcessedFlag]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ProcessedFlag]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_PurchaseOrder]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [PurchaseOrder]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_PackageCount]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [PackageCount]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_OrderType]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [OrderType]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_OrderPriority]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [OrderPriority]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_PickedDate]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [PickedDate]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_PieceCount]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [PieceCount]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ItemOverrideFlag]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ItemOverrideFlag]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ItemSKU]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ItemSKU]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_LeftTPart]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [LeftPart]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_InvoiceStatus]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [InvoiceStatus]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_InventoryFlag]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [InventoryFlag]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ImportPONumber]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ImportPONumber]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_FrontPart]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [FrontPart]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_EnteredBy]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [EnteredBy]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_DateEntered]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [DateEntered]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_EmailAddress]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [EmailAddress]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_DropNumber]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [DropNumber]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_CustomerNumber]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [CustomerNumber]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_CenterPart]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [CenterPart]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ChargeType]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ChargeType]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ContactName]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ContactName]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_CartonID]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [CartonID]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_BottomPart]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [BottomPart]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_BacKPart]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [BackPart]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ReferenceNumber]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ReferenceNumber]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartOrders_ActiveRecord]
    ON [Quality_AFI].[ReplacementPartHeader]
    (
        [ActiveRecord]
    );

