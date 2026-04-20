CREATE TABLE [AFISales_DW].[FactWeeklyPlacements]
    (
        [RowID]                             BIGINT         NOT NULL, --IDENTITY (1, 1)
        [Account And Shipto Number]         CHAR(13)       NULL,
        [SalesTerritoryID]                  BIGINT         NULL,
        [Item SKU]                          VARCHAR(15)    NOT NULL,
        [Item Key]                          VARCHAR(22)    NOT NULL,
        [Item Status]                       CHAR(1)        NULL,
        [Week Ended]                        DATE           NULL,
        [Shipto AddressID]                  INT            NULL,
        [Net Placement Gain]                DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [Weekly Quantity]                   DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [Placement Gain]                    DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [Placement Loss]                    DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [Current Placements]                DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [At Risk Placements]                DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [Velocity Rolling Average Quantity] DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [Velocity Placement Denominator]    DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [AFI Sales Category]                CHAR(3)        NULL,
        [AFI Sales Division Code]           CHAR(1)        NULL,
        [AFI Sales Region Code]             CHAR(3)        NULL,
        [AFI Sales RepID]                   CHAR(5)        NULL,
        [RegionCode_RepID_Category]         VARCHAR(13)    NULL,
        [Territory]                         VARCHAR(10)    NULL,
        [Store Address ID]                  INT            NULL,
        [Customer Shipto Division Number]   VARCHAR(13)    NULL,
        [Customer Account Number]           CHAR(8)        NULL,
        [Customer Shipto Number]            CHAR(4)        NULL
    );


GO
CREATE STATISTICS [Stat_FactWeeklyPlacements_SalesTerritoryID]
    ON [AFISales_DW].[FactWeeklyPlacements]
    (
        [SalesTerritoryID]
    );


GO
CREATE STATISTICS [Stat_FactWeeklyPlacements_Item_SKU]
    ON [AFISales_DW].[FactWeeklyPlacements]
    (
        [Item SKU]
    );


GO
CREATE STATISTICS [Stat_FactWeeklyPlacements_Item_Key]
    ON [AFISales_DW].[FactWeeklyPlacements]
    (
        [Item Key]
    );


GO
CREATE STATISTICS [Stat_FactWeeklyPlacements_Account_And_Shipto_Number]
    ON [AFISales_DW].[FactWeeklyPlacements]
    (
        [Account And Shipto Number]
    );


GO
CREATE STATISTICS [Stat_FactWeeklyPlacements_Week_Ended]
    ON [AFISales_DW].[FactWeeklyPlacements]
    (
        [Week Ended]
    );


GO
CREATE STATISTICS [Stat_FactWeeklyPlacements_Shipto_AddressID]
    ON [AFISales_DW].[FactWeeklyPlacements]
    (
        [Shipto AddressID]
    );


GO
CREATE STATISTICS [Stat_FactWeeklyPlacements_At_Risk_Placements]
    ON [AFISales_DW].[FactWeeklyPlacements]
    (
        [At Risk Placements]
    );

