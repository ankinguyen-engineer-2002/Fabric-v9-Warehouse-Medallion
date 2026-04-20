CREATE TABLE [AFISales_DW].[FactDailyPlacementsSaved] (
    [RowID]                           BIGINT        NOT NULL, --IDENTITY (1, 1)
    [Item Key]                        VARCHAR (22)  NOT NULL,
    [Item SKU]                        VARCHAR (15)  NOT NULL,
    [SalesTerritoryID]                BIGINT        NULL,
    [Order Date]                      DATE          NOT NULL,
    [Shipto AddressID]                INT           NULL,
    [Account And Shipto Number]       CHAR (13)     NULL,
    [Territory]                       VARCHAR (10)  NULL,
    [Is Saved]                        DECIMAL (6,2) NULL,  --FLOAT (53) 
    [RegionCode RepID Category]       VARCHAR (13)  NULL,
	[Customer Shipto Division Number] VARCHAR (15)  NULL,
	[Customer Account Number]         VARCHAR (8)   NULL,
	[Customer Shipto Number]          CHAR (5)      NULL,
	[AFI Sales Division Code]         CHAR (1)      NULL
)

GO
CREATE STATISTICS [Stat_FactDailyPlacements_SalesTerritoryID]
    ON [AFISales_DW].[FactDailyPlacementsSaved]([SalesTerritoryID]);


GO
CREATE STATISTICS [Stat_FactDailyPlacements_Item_Key]
    ON [AFISales_DW].[FactDailyPlacementsSaved]([Item Key]);


GO
CREATE STATISTICS [Stat_FactDailyPlacements_Account_And_Shipto_Number]
    ON [AFISales_DW].[FactDailyPlacementsSaved]([Account And Shipto Number]);


GO
CREATE STATISTICS [Stat_FactDailyPlacementsSaved_Order_Date]
    ON [AFISales_DW].[FactDailyPlacementsSaved]([Order Date]);

