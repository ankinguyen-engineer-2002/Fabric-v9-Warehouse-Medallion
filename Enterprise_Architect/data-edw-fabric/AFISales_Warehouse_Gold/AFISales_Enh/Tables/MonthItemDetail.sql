CREATE TABLE [AFISales_Enh].[MonthItemDetail] (
    [ItemSKU]         VARCHAR (15)    NOT NULL,
    [QuantityShippedipped]      NUMERIC (10)    NOT NULL,
    [QtyOrdered]      NUMERIC (10)    NOT NULL,
    [AmtShipped]      NUMERIC (10)    NOT NULL,
    [AmtOrdered]      NUMERIC (10)    NOT NULL,
    [FOBPrice]        NUMERIC (5)     NOT NULL,
    [AvgPrice]        NUMERIC (5)     NOT NULL,
    [Returned]        NUMERIC (4, 1)  NOT NULL,
    [Allowed]         NUMERIC (4, 1)  NOT NULL,
    [Discount]        NUMERIC (4, 1)  NOT NULL,
    [StdCost]         NUMERIC (8, 2)  NOT NULL,
    [ActCost]         NUMERIC (8, 2)  NOT NULL,
    [FOBMargin]       NUMERIC (3)     NOT NULL,
    [ActMargin]       NUMERIC (3)     NOT NULL,
    [Rental]          BIT             NOT NULL,
    [TotalAmtShipped] NUMERIC (10)    NOT NULL,
    [TotalAmtOrdered] NUMERIC (10)    NOT NULL,
    [Period]          NUMERIC (2)     NOT NULL,
    [Year]            NUMERIC (4)     NOT NULL,
    [Landed]          NUMERIC (10, 2) NOT NULL,
    [MoQty3]          NUMERIC (10)    NOT NULL,
    [MoQty6]          NUMERIC (10)    NOT NULL,
    [MoQty12]         NUMERIC (10)    NOT NULL,
    [FutStatus]       CHAR (1)        NOT NULL,
    [CountryCode]     CHAR (3)        NOT NULL,
    [RentalAcct]      CHAR (3)        NOT NULL
)


GO
CREATE STATISTICS [Stat_MonthItemDetail_Year]
    ON [AFISales_Enh].[MonthItemDetail]([Year]);


GO
CREATE STATISTICS [Stat_MonthItemDetail_Period]
    ON [AFISales_Enh].[MonthItemDetail]([Period]);


GO
CREATE STATISTICS [Stat_MonthItemDetail_Landed]
    ON [AFISales_Enh].[MonthItemDetail]([Landed]);


GO
CREATE STATISTICS [Stat_MonthItemDetail_ItemSKU]
    ON [AFISales_Enh].[MonthItemDetail]([ItemSKU]);


GO
CREATE STATISTICS [Stat_MonthItemDetail_FutStatus]
    ON [AFISales_Enh].[MonthItemDetail]([FutStatus]);


GO
CREATE STATISTICS [Stat_MonthItemDetail_CountryCode]
    ON [AFISales_Enh].[MonthItemDetail]([CountryCode]);

