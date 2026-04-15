CREATE TABLE [Retail_DW_Core].[DimDMLocationCalendar] (
    [StoreID]        INT          NOT NULL,
    [LocationKey]    BIGINT       NOT NULL,
    [TransDate]      DATE         NULL,
    [OpenTime]       VARCHAR (20) NOT NULL,
    [CloseTime]      VARCHAR (20) NOT NULL,
    [TYIsOpen]       INT          NOT NULL,
    [LYIsOpen]       INT          NOT NULL,
    [NYIsOpen]       INT          NOT NULL,
    [TYComp]         INT          NULL,
    [LYComp]         INT          NULL,
    [TransDateKey]   BIGINT       NOT NULL,
    [DateKey]        BIGINT       NOT NULL,
    [NYDateKey]      INT          NULL,
    [IsDelivery]     INT          NOT NULL,
    [TransDelivDate] DATE         NULL
);
GO

