CREATE TABLE [AFISales_DW].[DimItemWarehouse] (
    [Sequence Number]               DECIMAL (9)     NULL,
    [AFI Item Number]               VARCHAR (15)    NULL,
    [AFI Warehouse]                 CHAR (3)        NULL,
    [DRP Planner ID]                VARCHAR (10)    NULL,
    [Forecast ID]                   VARCHAR (36)    NULL,
    [Forecast Level Number]         DECIMAL (1)     NULL,
    [Alternate ABC-3 Code]          CHAR (1)        NULL,
    [IP ABC Code]                   CHAR (1)        NULL,
    [Forecast Planner ID]           VARCHAR (10)    NULL,
    [Field 1]                       CHAR (2)        NULL,
    [Product Type]                  CHAR (2)        NULL,
    [Field 17]                      VARCHAR (30)    NULL,
    [Product Watch Code]            CHAR (1)        NULL,
    [Part Flag]                     CHAR (5)        NULL,
    [Product Group ID]              VARCHAR (10)    NULL,
    [Forecast Type Code]            CHAR (1)        NULL,
    [Valid Demand]                  DECIMAL (3)     NULL,
    [Forced Sys Std Deviation]      DECIMAL (11, 2) NULL,
    [Perminent Component Quantity]  DECIMAL (11, 2) NULL,
    [Unit Price]                    DECIMAL (11, 5) NULL,
    [Derived Forecast Factor]       DECIMAL (5, 3)  NULL,
    [Derived Forecast Key]          VARCHAR (36)    NULL,
    [Derived Forecast Level Number] DECIMAL (1)     NULL,
    [Unit Cost]                     DECIMAL (11, 5) NULL,
    [Cubic Feet]                    DECIMAL (9, 4)  NULL,
    [Trend Component Quantity]      DECIMAL (11, 2) NULL,
    [Mgnmt Valid Demand]            DECIMAL (3)     NULL,
    [ABC Primary Code]              CHAR (1)        NULL,
    [Vendor Name]                   VARCHAR (20)    NULL
)


GO
CREATE STATISTICS [Stat_DimItemWarehouse_Sequence_Number]
    ON [AFISales_DW].[DimItemWarehouse]([Sequence Number]);


GO
CREATE STATISTICS [Stat_DimItemWarehouse_Vendor_Name]
    ON [AFISales_DW].[DimItemWarehouse]([Vendor Name]);


GO
CREATE STATISTICS [Stat_DimItemWarehouse_Unit_Price]
    ON [AFISales_DW].[DimItemWarehouse]([Unit Price]);


GO
CREATE STATISTICS [Stat_DimItemWarehouse_Product_Type]
    ON [AFISales_DW].[DimItemWarehouse]([Product Type]);


GO
CREATE STATISTICS [Stat_DimItemWarehouse_Product_Group_ID]
    ON [AFISales_DW].[DimItemWarehouse]([Product Group ID]);


GO
CREATE STATISTICS [Stat_DimItemWarehouse_Part_Flag]
    ON [AFISales_DW].[DimItemWarehouse]([Part Flag]);


GO
CREATE STATISTICS [Stat_DimItemWarehouse_IP_ABC_Code]
    ON [AFISales_DW].[DimItemWarehouse]([IP ABC Code]);


GO
CREATE STATISTICS [Stat_DimItemWarehouse_Forecast_Planner_ID]
    ON [AFISales_DW].[DimItemWarehouse]([Forecast Planner ID]);


GO
CREATE STATISTICS [Stat_DimItemWarehouse_DRP_Planner_ID]
    ON [AFISales_DW].[DimItemWarehouse]([DRP Planner ID]);


GO
CREATE STATISTICS [Stat_DimItemWarehouse_Cubic_Feet]
    ON [AFISales_DW].[DimItemWarehouse]([Cubic Feet]);


GO
CREATE STATISTICS [Stat_DimItemWarehouse_Alternate_ABC_3_Code]
    ON [AFISales_DW].[DimItemWarehouse]([Alternate ABC-3 Code]);


GO
CREATE STATISTICS [Stat_DimItemWarehouse_AFI_Warehouse]
    ON [AFISales_DW].[DimItemWarehouse]([AFI Warehouse]);


GO
CREATE STATISTICS [Stat_DimItemWarehouse_AFI_Item_Number]
    ON [AFISales_DW].[DimItemWarehouse]([AFI Item Number]);


GO
CREATE STATISTICS [Stat_DimItemWarehouse_ABC_Primary_Code]
    ON [AFISales_DW].[DimItemWarehouse]([ABC Primary Code]);

