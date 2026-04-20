CREATE TABLE [AFISales_DW].[FactAdNoticeData] (
    [key]                             INT           NOT NULL,
    [Customer Account Number]         CHAR (8)      NULL,
    [Ship Number]                     CHAR (4)      NOT NULL,
    [Territory]                       VARCHAR (10)  NULL,
    [Delivery Date for AD]            DATETIME2 (6) NULL, --datetime
    [Start Date for AD]               DATETIME2 (6) NULL, --datetime
    [End Date for AD]                 DATETIME2 (6) NULL, --datetime
    [Warehouse]                       CHAR (3)      NOT NULL,
    [AD Date Entered]                 DATETIME2 (6) NULL,   --datetime
    [SalesTerritoryID]                BIGINT        NULL,
    [Item Number]                     VARCHAR (15)  NOT NULL,
    [AD Goal Quantity]                INT           NOT NULL,
    [Ad Actual Qty]                   INT           NOT NULL,
    [Notice Time Lead]                INT           NULL,
    [Promotion Duration]              INT           NULL,
    [Division Code]                   CHAR (1)      NULL,
    [Customer Shipto Division Number] VARCHAR (10)  NULL
)


GO
CREATE STATISTICS [Stat_FactAdNoticeData_CustomerAccountNumber]
    ON [AFISales_DW].[FactAdNoticeData]([Customer Account Number]);

