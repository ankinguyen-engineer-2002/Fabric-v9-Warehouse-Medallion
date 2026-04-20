CREATE TABLE [AFISales_DW].[FactPotential] (
    [RowID]                     BIGINT       NOT NULL,  --IDENTITY (1, 1) 
    [WeekEndingDate]            DATE         NULL,
    [AddressID]                 INT          NULL,
    [SalesTerritoryID]          BIGINT       NULL,
    [MarketPotential]           FLOAT (53)   NULL,
    [AFI Sales Category]        CHAR (3)     NULL,
    [Marketing Specialist ID]   CHAR (5)     NULL,
    [AFI Sales Region Code]     CHAR (3)     NULL,
    [AFI Sales RepID]           CHAR (5)     NULL,
    [RegionCode_RepID_Category] VARCHAR (13) NULL
)



GO
CREATE STATISTICS [Stat_FactPotential_WeekEndingDate]
    ON [AFISales_DW].[FactPotential]([WeekEndingDate]);


GO
CREATE STATISTICS [Stat_FactPotential_SalesTerritoryID]
    ON [AFISales_DW].[FactPotential]([SalesTerritoryID]);


GO
CREATE STATISTICS [Stat_FactPotential_AddressID]
    ON [AFISales_DW].[FactPotential]([AddressID]);

