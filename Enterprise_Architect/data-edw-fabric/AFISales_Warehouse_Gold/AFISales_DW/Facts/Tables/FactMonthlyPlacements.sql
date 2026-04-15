CREATE TABLE [AFISales_DW].[FactMonthlyPlacements]
    (
        [RowID]                             BIGINT        NOT NULL, --IDENTITY (1, 1) 
        [Account And Shipto Number]         CHAR(13)      NULL,
        [SalesTerritoryID]                  BIGINT        NULL,
        [Item SKU]                          VARCHAR(15)   NOT NULL,
        [Item Key]                          VARCHAR(22)   NOT NULL,
        [Item Status]                       CHAR(1)       NULL,
        [Month Ended]                       DATE          NULL,
        [Shipto AddressID]                  INT           NULL,
        [Net Placement Gain]                DECIMAL(6, 2) NULL,     -- FLOAT (53)
        [Monthly Quantity]                  DECIMAL(6, 2) NULL,     -- FLOAT (53)
        [Placement Gain]                    DECIMAL(6, 2) NULL,     -- FLOAT (53)
        [Placement Loss]                    DECIMAL(6, 2) NULL,     -- FLOAT (53)
        [Current Placements]                DECIMAL(6, 2) NULL,     -- FLOAT (53)
        [At Risk Placements]                DECIMAL(6, 2) NULL,     -- FLOAT (53)
        [MTD Quantity]                      DECIMAL(6, 2) NULL,     -- FLOAT (53)
        [MTD Placements]                    DECIMAL(6, 2) NULL,     -- FLOAT (53)
        [Velocity Rolling Average Quantity] DECIMAL(6, 2) NULL,     -- FLOAT (53)
        [Velocity Placement Denominator]    DECIMAL(6, 2) NULL,     -- FLOAT (53)
        [RegionCode_RepID_Category]         VARCHAR(13)   NULL,
        [Customer Shipto Division Number]   VARCHAR(15)   NULL,
        [Territory]                         VARCHAR(10)   NULL,
        [AFI Sales Category]                CHAR(3)       NULL,
        [AFI Sales Division Code]           CHAR(3)       NULL,
        [AFI Sales Region Code]             CHAR(3)       NULL,
        [AFI Sales RepID]                   CHAR(5)       NULL,
        [Customer Account Number]           VARCHAR(10)   NULL,
        [Customer Shipto Number]            CHAR(5)       NULL,
        [Store Address ID]                  INT           NULL
    );

GO
CREATE STATISTICS [Stat_FactMonthlyPlacements_SalesTerritoryID]
    ON [AFISales_DW].[FactMonthlyPlacements]
    (
        [SalesTerritoryID]
    );


GO
CREATE STATISTICS [Stat_FactMonthlyPlacements_Month_Ended]
    ON [AFISales_DW].[FactMonthlyPlacements]
    (
        [Month Ended]
    );


GO
CREATE STATISTICS [Stat_FactMonthlyPlacements_Item_SKU]
    ON [AFISales_DW].[FactMonthlyPlacements]
    (
        [Item SKU]
    );


GO
CREATE STATISTICS [Stat_FactMonthlyPlacements_Item_Key]
    ON [AFISales_DW].[FactMonthlyPlacements]
    (
        [Item Key]
    );


GO
CREATE STATISTICS [Stat_FactMonthlyPlacements_Account_And_Shipto_Number]
    ON [AFISales_DW].[FactMonthlyPlacements]
    (
        [Account And Shipto Number]
    );


GO
CREATE STATISTICS [Stat_FactMonthlyPlacements_Shipto_AddressID]
    ON [AFISales_DW].[FactMonthlyPlacements]
    (
        [Shipto AddressID]
    );


GO
CREATE STATISTICS [Stat_FactMonthlyPlacements_Net_Placement_Gain]
    ON [AFISales_DW].[FactMonthlyPlacements]
    (
        [Net Placement Gain]
    );


GO
CREATE STATISTICS [Stat_FactMonthlyPlacements_Monthly_Quantity]
    ON [AFISales_DW].[FactMonthlyPlacements]
    (
        [Monthly Quantity]
    );


GO
CREATE STATISTICS [Stat_FactMonthlyPlacements_Current_Placements]
    ON [AFISales_DW].[FactMonthlyPlacements]
    (
        [Current Placements]
    );


GO
CREATE STATISTICS [Stat_FactMonthlyPlacements_At_Risk_Placements]
    ON [AFISales_DW].[FactMonthlyPlacements]
    (
        [At Risk Placements]
    );

