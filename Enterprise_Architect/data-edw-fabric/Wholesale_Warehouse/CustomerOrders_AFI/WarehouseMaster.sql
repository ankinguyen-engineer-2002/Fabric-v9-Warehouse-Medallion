CREATE TABLE [CustomerOrders_AFI].[WarehouseMaster]
    (
        [Warehouse]           CHAR(3)      NULL,
        [LocationID]          DECIMAL(10)  NULL,
        [IntransitWarehouse]  CHAR(3)      NULL,
        [SiteID]              CHAR(3)      NULL,
        [MROSiteID]           CHAR(3)      NULL,
        [WarehouseType]       CHAR(1)      NULL,
        [WarehouseOrderGroup] VARCHAR(10)  NULL,
        [WarehouseSourceID]   VARCHAR(13)  NULL,
        [RouteType]           CHAR(1)      NULL,
        [DefaultPortId]       INT          NULL,
        [Controlled]          BIT          NULL,
        [PrinterName]         VARCHAR(10)  NULL,
        [ZebraPrinter]        VARCHAR(10)  NULL,
        [SendBolsToManu]      CHAR(1)      NULL,
        [OrderReleaseMin]     INT          NULL,
        [OrderReleaseMinType] CHAR(1)      NULL,
        [DefaultShipId]       INT          NULL,
        [SortOrder]           INT      NULL,
        [AsOverhead]          INT          NULL,
        [AsFreight]           INT          NULL,
        [ContainerDirectWhse] CHAR(1)      NULL,
        [ActiveRecord]               CHAR(1)      NULL,
        [usra]                VARCHAR(30)  NULL,
        [dtea]                DATETIME2(6) NULL, --datetime2(7)
        [usrc]                VARCHAR(30)  NULL,
        [dtec]                DATETIME2(6) NULL, --datetime2(7)
        [WhereMade]           CHAR(5)      NULL,
        [ManufacturingSite]   VARCHAR(25)  NULL,
        [SellableWarehouse]   BIT          NULL
    );

--   DATA_SOURCE = [AzureStorageGen2a],
--  LOCATION = N'/Wholesale/codis_afi/AshleyWarehouseMaster/AFI_Sales_AshleyWarehouseMaster.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],

