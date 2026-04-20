CREATE TABLE [AFISales_DW].[FactSpecials] (
    [RowID]                           BIGINT          NOT NULL,  --IDENTITY (1, 1)
    [SalesTerritoryID]                BIGINT          NULL,
    [Account And Shipto Number]       CHAR (13)       NULL,
    [Territory]                       CHAR (10)       NULL,
    [Order Number]                    VARCHAR (10)    NULL,
    [Sequence Number]                 DECIMAL (3)     NULL,
    [Invoice Number]                  DECIMAL (9)     NULL,
    [Invoice Date]                    DATE           NULL,
    [Billto Address ID]               INT             NULL,
    [Shipto AddressID]                INT             NULL,
    [Purchase Order]                  VARCHAR (25)    NULL,
    [Item Key]                        VARCHAR (22)    NULL,
    [Warehouse]                       CHAR (3)        NOT NULL,
    [Specials Discount Code]          VARCHAR (100)   NULL,
    [Specials Discount Adj Code]      CHAR (3)        NULL,
    [Specials Quantity]               DECIMAL (13, 3) NULL,
    [Order Date]                      DATE            NULL,
    [Specials Gross Price]            DECIMAL (12, 4) NULL,
    [Specials Discount]               DECIMAL (12, 4) NULL,
    [New Discount Percentage]         DECIMAL (12, 4) NULL,
    [Customer Number]                 INT             NULL,
    [Shipto Number]                   CHAR (4)        NULL,
    [RegionCode_RepID_Category]       VARCHAR (13)    NULL,
    [Customer Shipto Division Number] VARCHAR (15)    NULL,
    [Store Address ID]                INT             NULL
)

GO
CREATE STATISTICS [Stat_FactSpecials_Warehouse]
    ON [AFISales_DW].[FactSpecials]([Warehouse]);


GO
CREATE STATISTICS [Stat_FactSpecials_Special_Discount_Code]
    ON [AFISales_DW].[FactSpecials]([Specials Discount Code]);


GO
CREATE STATISTICS [Stat_FactSpecials_SalesTerritoryID]
    ON [AFISales_DW].[FactSpecials]([SalesTerritoryID]);


GO
CREATE STATISTICS [Stat_FactSpecials_Order_Date]
    ON [AFISales_DW].[FactSpecials]([Order Date]);


GO
CREATE STATISTICS [Stat_FactSpecials_Item_Key]
    ON [AFISales_DW].[FactSpecials]([Item Key]);


GO
CREATE STATISTICS [Stat_FactSpecials_Order_Number]
    ON [AFISales_DW].[FactSpecials]([Order Number]);

