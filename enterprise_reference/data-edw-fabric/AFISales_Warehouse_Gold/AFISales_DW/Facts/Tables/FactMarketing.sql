CREATE TABLE [AFISales_DW].[FactMarketing] (
    [Velocity Driver Key]             BIGINT         NOT NULL, -- IDENTITY (1, 1)
    [Ad Funds Key]                    INT            NULL,
    [SalesTerritoryID]                BIGINT         NULL,
    [Territory]                       CHAR (10)      NULL,
    [Account And Shipto Number]       CHAR (13)      NULL,
    [MarketDate]                      DATE           NULL,
    [VelocityDriverCount]             INT            NULL,
    [AdFundsRequested]                DECIMAL (8, 2) NULL,
    [AdFundsApproved]                 DECIMAL (8, 2) NULL,
    [Account Number]                  CHAR (8)       NULL,
    [Shipto Number]                   CHAR (4)       NULL,
    [Division Code]                   VARCHAR (50)   NULL,
    [Customer Shipto Division Number] VARCHAR (15)   NULL,
    [RegionCode_RepID_Category]       VARCHAR (13)   NULL
)

GO
CREATE STATISTICS [Stat_FactMarketing_Territory]
    ON [AFISales_DW].[FactMarketing]([Territory]);


GO
CREATE STATISTICS [Stat_FactMarketing_SalesTerritoryID]
    ON [AFISales_DW].[FactMarketing]([SalesTerritoryID]);


GO
CREATE STATISTICS [Stat_FactMarketing_Division_Code]
    ON [AFISales_DW].[FactMarketing]([Division Code]);


GO
CREATE STATISTICS [Stat_FactMarketing_AdFundsKey]
    ON [AFISales_DW].[FactMarketing]([Ad Funds Key]);


GO
CREATE STATISTICS [Stat_FactMarketing_MarketDate]
    ON [AFISales_DW].[FactMarketing]([MarketDate]);

