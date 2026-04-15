CREATE TABLE [CostAccounting_DW].[DimMarginDetails]
([MarginDetailsKey]                  INT          NOT NULL,--IDENTITY
    [Fiscal Year Period]             VARCHAR (7)  NULL,
    [Item Number]                    VARCHAR (15) NOT NULL,
    [Margin Warehouse]               CHAR    (3)  NOT NULL,
    [Item Series]                    VARCHAR (10) NOT NULL,
    [Series Description]             VARCHAR (40) NULL,
    [Item Class]                     CHAR    (4)  NOT NULL,
    [Item Class Description]         VARCHAR (25) NULL,
    [Item Description]               VARCHAR (30) NOT NULL,
    [Manufacturing Status Code]      CHAR    (1)  NOT NULL,
    [Import Office]                  VARCHAR (5)  NOT NULL,
    [Financial Division]             CHAR    (1)  NOT NULL,
    [Financial Division Description] VARCHAR (30) NOT NULL
);

GO
CREATE STATISTICS [Stat_DimMarginDetails_MarginDetailsKey]
    ON [CostAccounting_DW].[DimMarginDetails]([MarginDetailsKey]);


GO
CREATE STATISTICS [Stat_DimMarginDetails_Margin_Warehouse]
    ON [CostAccounting_DW].[DimMarginDetails]([Margin Warehouse]);


GO
CREATE STATISTICS [Stat_DimMarginDetails_Fiscal_Year_Period]
    ON [CostAccounting_DW].[DimMarginDetails]([Fiscal Year Period]);



