CREATE TABLE [Retail_DW_Core].[OrdersNextGen_PBI] (
    [Type]               VARCHAR (50)     NOT NULL,
    [OrderBookedStoreID] VARCHAR (50)     NULL,
    [Region]             VARCHAR (100)    NULL,
    [SalesPersonID]      VARCHAR (100)    NULL,
    [OrderDate]          DATE             NULL,
    [Def]                DECIMAL (18, 10) NULL,
    [NextGen]            DECIMAL (18, 10) NULL,
    [Total]              DECIMAL (18, 10) NULL
);
GO

