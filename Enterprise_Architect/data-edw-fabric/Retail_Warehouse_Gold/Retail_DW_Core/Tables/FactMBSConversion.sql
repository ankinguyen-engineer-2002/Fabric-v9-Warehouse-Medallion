CREATE TABLE [Retail_DW_Core].[FactMBSConversion] (
    [StoreID]      INT             NOT NULL,
    [StoreBrandID] VARCHAR (20)    NULL,
    [CustomerKey]  BIGINT          NULL,
    [TransDateKey] INT             NOT NULL,
    [GroupID]      VARCHAR (50)    NULL,
    [WrittenSales] NUMERIC (38, 2) NULL
);
GO

