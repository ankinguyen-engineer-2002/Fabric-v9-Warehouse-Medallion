CREATE TABLE [Quality_DW].[FactPurchaseOrder] (
    [PomOrderNum]        VARCHAR (7)     NOT NULL,
    [PomCreated]         DATETIME2 (6)   NULL,
    [Pomwarehouse]       CHAR (3)        NOT NULL,
    [PomEta]             Datetime2 (6)   NULL,
    [PomEtd]             Datetime2 (6)   NULL,
    [PomDue]             Datetime2 (6)   NULL,
    [PomStatusCode]      VARCHAR (2)     NOT NULL,
    [PodItemNum]         VARCHAR (15)    NOT NULL,
    [PodWarehouse]       CHAR (3)        NOT NULL,
    [PodQtyOrdered]      DECIMAL (13, 3) NOT NULL,
    [PodStockPrice]      DECIMAL (14, 4) NOT NULL,
    [PodExtendedPrice]   DECIMAL (15, 4) NULL,
    [PodItemClass]       CHAR (4)        NOT NULL,
    [PodDueDate]         Datetime2 (6)   NULL,
    [PodCurrentPrice]    DECIMAL (15, 4) NOT NULL,
    [PodStockQty]        DECIMAL (13, 3) NOT NULL,
    [PodCubes]           DECIMAL (10, 5) NOT NULL,
    [PodWeight]          DECIMAL (10, 3) NOT NULL,
    [PodInvNature]       VARCHAR (10)    NOT NULL,
    [PomDatePaid]        Datetime2 (6)   NULL,
    [PomTotalFreight]    DECIMAL (10, 3) NULL,
    [PomBuyerNum]        CHAR (5)        NOT NULL,
    [PomBookingNum]      VARCHAR (30)    NULL,
    [PomBookingStatusId] INT             NULL,
    [ConContainer]       VARCHAR (18)    NULL,
    [ConReceiptToStock]  DATETIME2 (6)        NULL,
    [ConReceiver]        DATETIME2 (6)        NULL,
    [ConViacode]         CHAR (3)        NULL,
    [CarName]            VARCHAR (15)    NULL
)
GO


CREATE STATISTICS [Stat_FactPurchaseOrder_poditemclass]
    ON [Quality_DW].[FactPurchaseOrder]([PodItemClass]);
GO

CREATE STATISTICS [Stat_FactPurchaseOrder_poditemnum]
    ON [Quality_DW].[FactPurchaseOrder]([PodItemNum]);
GO

CREATE STATISTICS [Stat_FactPurchaseOrder_podqtyordered]
    ON [Quality_DW].[FactPurchaseOrder]([PodQtyOrdered]);
GO

CREATE STATISTICS [Stat_FactPurchaseOrder_pomwarehouse]
    ON [Quality_DW].[FactPurchaseOrder]([Pomwarehouse]);
GO

