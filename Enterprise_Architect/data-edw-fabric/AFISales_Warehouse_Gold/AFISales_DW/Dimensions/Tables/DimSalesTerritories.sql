CREATE TABLE [AFISales_DW].[DimSalesTerritories] (
    [SalesTerritoryID]             BIGINT        NULL,
    [AFI Sales Division Code]      CHAR (1)      NOT NULL,
    [AFI Sales Division]           VARCHAR (25)  NOT NULL,
    [AFI Sales Region Code]        CHAR (3)      NOT NULL,
    [AFI Sales RepID]              CHAR (5)      NOT NULL,
    [AFI Sales Region]             VARCHAR (25)  NOT NULL,
    [AFI Sales Region Type]        VARCHAR (15)  NOT NULL,
    [Marketing Specialist ID]      CHAR (5)      NOT NULL,
    [Marketing Specialist]         VARCHAR (25)  NOT NULL,
    [AFI Sales Category]           CHAR (3)      NOT NULL,
    [AFI Sales Category Name]      VARCHAR (25)  NOT NULL,
    [AFI Alternate Division Code]  CHAR (3)      NOT NULL,
    [AFI Alternate Division]       VARCHAR (25)  NOT NULL,
    [Sales Regional VP]            VARCHAR (25)  NOT NULL,
    [Sales Division President]     VARCHAR (25)  NOT NULL,
    [Product Line]                 VARCHAR (25)  NOT NULL,
    [Active Record]                INT           NOT NULL,
    [Business Name]                VARCHAR (100) NULL,
    [RegionCode_RepID_Category]    VARCHAR (13)  NULL,
    [Marketing Specialist Mail ID] VARCHAR (200) NULL,
    [Activated]                    DATETIME2 (6) NULL,  --DATETIME
    [Deactivated]                  DATETIME2 (6) NULL   --DATETIME
)

GO
CREATE STATISTICS [Stat_DimSalesTerritories_SalesTerritoryID]
    ON [AFISales_DW].[DimSalesTerritories]([SalesTerritoryID]);


GO
CREATE STATISTICS [Stat_DimSalesTerritories_Sales_Regional_VP]
    ON [AFISales_DW].[DimSalesTerritories]([Sales Regional VP]);


GO
CREATE STATISTICS [Stat_DimSalesTerritories_Sales_Division_President]
    ON [AFISales_DW].[DimSalesTerritories]([Sales Division President]);


GO
CREATE STATISTICS [Stat_DimSalesTerritories_RegionCode_RepID_Category]
    ON [AFISales_DW].[DimSalesTerritories]([RegionCode_RepID_Category]);


GO
CREATE STATISTICS [Stat_DimSalesTerritories_Product_Line]
    ON [AFISales_DW].[DimSalesTerritories]([Product Line]);


GO
CREATE STATISTICS [Stat_DimSalesTerritories_Marketing_Specialist_Mail_ID]
    ON [AFISales_DW].[DimSalesTerritories]([Marketing Specialist Mail ID]);


GO
CREATE STATISTICS [Stat_DimSalesTerritories_Marketing_Specialist_ID]
    ON [AFISales_DW].[DimSalesTerritories]([Marketing Specialist ID]);


GO
CREATE STATISTICS [Stat_DimSalesTerritories_Marketing_Specialist]
    ON [AFISales_DW].[DimSalesTerritories]([Marketing Specialist]);


GO
CREATE STATISTICS [Stat_DimSalesTerritories_Deactivated]
    ON [AFISales_DW].[DimSalesTerritories]([Deactivated]);


GO
CREATE STATISTICS [Stat_DimSalesTerritories_Business_Name]
    ON [AFISales_DW].[DimSalesTerritories]([Business Name]);


GO
CREATE STATISTICS [Stat_DimSalesTerritories_AFI_Sales_RepID]
    ON [AFISales_DW].[DimSalesTerritories]([AFI Sales RepID]);


GO
CREATE STATISTICS [Stat_DimSalesTerritories_AFI_Sales_Region_Type]
    ON [AFISales_DW].[DimSalesTerritories]([AFI Sales Region Type]);


GO
CREATE STATISTICS [Stat_DimSalesTerritories_AFI_Sales_Region_Code]
    ON [AFISales_DW].[DimSalesTerritories]([AFI Sales Region Code]);


GO
CREATE STATISTICS [Stat_DimSalesTerritories_AFI_Sales_Region]
    ON [AFISales_DW].[DimSalesTerritories]([AFI Sales Region]);


GO
CREATE STATISTICS [Stat_DimSalesTerritories_AFI_Sales_Division_Code]
    ON [AFISales_DW].[DimSalesTerritories]([AFI Sales Division Code]);


GO
CREATE STATISTICS [Stat_DimSalesTerritories_AFI_Sales_Division]
    ON [AFISales_DW].[DimSalesTerritories]([AFI Sales Division]);


GO
CREATE STATISTICS [Stat_DimSalesTerritories_AFI_Sales_Category_Name]
    ON [AFISales_DW].[DimSalesTerritories]([AFI Sales Category Name]);


GO
CREATE STATISTICS [Stat_DimSalesTerritories_AFI_Sales_Category]
    ON [AFISales_DW].[DimSalesTerritories]([AFI Sales Category]);


GO
CREATE STATISTICS [Stat_DimSalesTerritories_AFI_Alternate_Division_Code]
    ON [AFISales_DW].[DimSalesTerritories]([AFI Alternate Division Code]);


GO
CREATE STATISTICS [Stat_DimSalesTerritories_AFI_Alternate_Division]
    ON [AFISales_DW].[DimSalesTerritories]([AFI Alternate Division]);


GO
CREATE STATISTICS [Stat_DimSalesTerritories_Active_Record]
    ON [AFISales_DW].[DimSalesTerritories]([Active Record]);


GO
CREATE STATISTICS [Stat_DimSalesTerritories_Activated]
    ON [AFISales_DW].[DimSalesTerritories]([Activated]);

