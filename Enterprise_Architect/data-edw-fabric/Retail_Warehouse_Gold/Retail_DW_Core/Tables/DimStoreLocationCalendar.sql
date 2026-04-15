CREATE TABLE [Retail_DW_Core].[DimStoreLocationCalendar] (
    [StoreID]      INT           NOT NULL,
    [LocationKey]  INT           NOT NULL,
    [TransDate]    DATE          NULL,
    [TransDateKey] INT           NOT NULL,
    [YearMonthKey] INT           NULL,
    [YearKey]      INT           NULL,
    [OpenTime]     VARCHAR (20)  NOT NULL,
    [CloseTime]    VARCHAR (20)  NOT NULL,
    [IsOpen]       INT           NOT NULL,
    [IsDelivery]   INT           NOT NULL,
    [DateChanged]  DATETIME2 (3) NULL,
    [ChangedBy]    VARCHAR (50)  NULL
);