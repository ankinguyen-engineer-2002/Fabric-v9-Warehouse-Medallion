CREATE TABLE [Quality_DW].[DimPurchaseOrder]
    (
        [PomOrderNum]        CHAR(7)      NOT NULL,
        [PomVendorNum]       CHAR(6)      NOT NULL,
        [VName]              VARCHAR(25)  NULL,
        [VNama]              VARCHAR(10)  NULL,
        [PomCreated]         DATETIME2(6) NULL, --DATETIME2 (7) 
        [Pomwarehouse]       VARCHAR(3)   NOT NULL,
        [PomEta]             DATETIME2(6) NULL, --DATETIME2 (7) 
        [PomEtd]             DATETIME2(6) NULL, --DATETIME2 (7) 
        [PomDue]             DATETIME2(6) NULL, --DATETIME2 (7) 
        [PomOriginalEtd]     DATETIME2(6) NULL, --DATETIME2 (7) 
        [PomStatusCode]      CHAR(2)      NOT NULL,
        [Status]             VARCHAR(40)  NULL,
        [PomContainer]       VARCHAR(18)  NOT NULL,
        [PodOrderNum]        CHAR(7)      NOT NULL,
        [PodVendorNum]       CHAR(8)      NOT NULL,
        [PodItemNum]         VARCHAR(15)  NOT NULL,
        [PodItemDescription] VARCHAR(30)  NOT NULL,
        [PodWarehouse]       CHAR(3)      NOT NULL,
        [PodItemClass]       CHAR(4)      NOT NULL,
        [PomBuyerNum]        CHAR(5)      NOT NULL,
        [PomBookingNum]      VARCHAR(30)  NULL,
        [PomBookingStatusId] INT          NULL,
        [ConContainer]       VARCHAR(18)  NULL,
        [ConReceiptToStock]  DATETIME2(6) NULL, --DATETIME
        [ConReceiver]        DATETIME2(6) NULL, --DATETIME
        [ConViacode]         CHAR(3)      NULL,
        [CarName]            VARCHAR(15)  NULL
    );

GO

CREATE STATISTICS [Stat_DimPurchaseOrder_poditemnum]
    ON [Quality_DW].[DimPurchaseOrder]
    (
        [PodItemNum]
    );
GO

CREATE STATISTICS [Stat_DimPurchaseOrder_pomordernum]
    ON [Quality_DW].[DimPurchaseOrder]
    (
        [PomOrderNum]
    );
GO

CREATE STATISTICS [Stat_DimPurchaseOrder_pomvendornum]
    ON [Quality_DW].[DimPurchaseOrder]
    (
        [PomVendorNum]
    );
GO

CREATE STATISTICS [Stat_DimPurchaseOrder_pomwarehouse]
    ON [Quality_DW].[DimPurchaseOrder]
    (
        [Pomwarehouse]
    );
GO

