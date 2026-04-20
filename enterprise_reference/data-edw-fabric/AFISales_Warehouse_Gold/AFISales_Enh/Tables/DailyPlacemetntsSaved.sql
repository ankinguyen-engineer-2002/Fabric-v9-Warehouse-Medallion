CREATE TABLE [AFISales_Enh].[DailyPlacementsSaved] (
    [CustomerNumber]         CHAR (8)       NOT NULL,
    [ShiptoNumber]           CHAR (4)       NOT NULL,
    [ItemSKU]                VARCHAR (15)   NOT NULL,
    [OrderDate]              DATE           NULL,
    [ChangeDate]             DATE           NULL,
    [YearPeriod]             INT            NOT NULL,
    [Quantity]               DECIMAL (7, 2) NOT NULL,
    [ShiptoAddressID]        INT            NULL,
    [AccountAndShiptoNumber] VARCHAR (13)   NULL,
    [Territory]              VARCHAR (10)   NULL,
    [SalesCategory]          CHAR (2)       NULL
)

GO
CREATE STATISTICS [Stat_DailyPlacementsSaved_Territory]
    ON [AFISales_Enh].[DailyPlacementsSaved]([Territory]);


GO
CREATE STATISTICS [Stat_DailyPlacementsSaved_SalesCategory]
    ON [AFISales_Enh].[DailyPlacementsSaved]([SalesCategory]);


GO
CREATE STATISTICS [Stat_DailyPlacementsSaved_Quantity]
    ON [AFISales_Enh].[DailyPlacementsSaved]([Quantity]);


GO
CREATE STATISTICS [Stat_DailyPlacementData_YearPeriod]
    ON [AFISales_Enh].[DailyPlacementsSaved]([YearPeriod]);


GO
CREATE STATISTICS [Stat_DailyPlacementData_ShiptoAddressID]
    ON [AFISales_Enh].[DailyPlacementsSaved]([ShiptoAddressID]);


GO
CREATE STATISTICS [Stat_DailyPlacementData_ShiptoNumber]
    ON [AFISales_Enh].[DailyPlacementsSaved]([ShiptoNumber]);


GO
CREATE STATISTICS [Stat_DailyPlacementData_OrderDate]
    ON [AFISales_Enh].[DailyPlacementsSaved]([OrderDate]);


GO
CREATE STATISTICS [Stat_DailyPlacementData_ItemSKU]
    ON [AFISales_Enh].[DailyPlacementsSaved]([ItemSKU]);


GO
CREATE STATISTICS [Stat_DailyPlacementData_CustomerNumber]
    ON [AFISales_Enh].[DailyPlacementsSaved]([CustomerNumber]);


GO
CREATE STATISTICS [Stat_DailyPlacementData_ChangeDate]
    ON [AFISales_Enh].[DailyPlacementsSaved]([ChangeDate]);


GO
CREATE STATISTICS [Stat_DailyPlacementData_AccountAndShiptoNumber]
    ON [AFISales_Enh].[DailyPlacementsSaved]([AccountAndShiptoNumber]);

