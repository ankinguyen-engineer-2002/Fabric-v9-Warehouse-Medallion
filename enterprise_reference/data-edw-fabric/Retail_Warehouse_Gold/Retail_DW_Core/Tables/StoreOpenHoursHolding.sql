CREATE TABLE [Retail_DW_Core].[StoreOpenHoursHolding] (
    [StoreID]         INT             NOT NULL,
    [TransDate]       DATE            NOT NULL,
    [Store_OpenTime]  DECIMAL (18, 2) NULL,
    [Store_CloseTime] DECIMAL (18, 2) NULL
);
GO

