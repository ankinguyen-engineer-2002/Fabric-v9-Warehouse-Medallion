CREATE TABLE [AFISales_DW].[FactDailyPlacements] (
    [RowID]                           BIGINT         NOT NULL, --IDENTITY (1, 1)
    [Item Key]                        VARCHAR (22)   NOT NULL,
    [Item SKU]                        VARCHAR (15)   NOT NULL,
    [SalesTerritoryID]                BIGINT         NULL,
    [Daily Placement]                 DECIMAL(6,2)   NOT NULL,  -- Float (53)
    [Daily Placement for Risk Calc]   DECIMAL(6,2)   NOT NULL,  -- Float (53)
    [Placement Date]                  DATE           NOT NULL,
    [Store Address ID]                INT            NULL,
    [Shipto AddressID]                INT            NULL,
    [Account And Shipto Number]       CHAR (13)      NULL,
    [Customer Account Number]         CHAR (8)       NULL,
    [Customer Shipto Number]          CHAR (4)       NULL,
    [Customer Shipto Division Number] VARCHAR (15)   NULL,
    [Territory]                       CHAR (10)      NULL,
    [AFI Sales Region Code]           CHAR(3)        NULL,
	[AFI Sales RepID]                 CHAR (5)       NULL,
	[AFI Sales Category]              CHAR (5)       NULL,
	[RegionCode_RepID_Category]       VARCHAR (13)   NULL,
	[AFI Sales Division Code]         CHAR (1)       NULL
)

GO
CREATE STATISTICS [Stat_FactDailyPlacements_SalesTerritoryID]
    ON [AFISales_DW].[FactDailyPlacements]([SalesTerritoryID]);


GO
CREATE STATISTICS [Stat_FactDailyPlacements_Item_Key]
    ON [AFISales_DW].[FactDailyPlacements]([Item Key]);


GO
CREATE STATISTICS [Stat_FactDailyPlacements_Account_And_Shipto_Number]
    ON [AFISales_DW].[FactDailyPlacements]([Account And Shipto Number]);


GO
CREATE STATISTICS [Stat_FactDailyPlacements_Placement_Date]
    ON [AFISales_DW].[FactDailyPlacements]([Placement Date]);

