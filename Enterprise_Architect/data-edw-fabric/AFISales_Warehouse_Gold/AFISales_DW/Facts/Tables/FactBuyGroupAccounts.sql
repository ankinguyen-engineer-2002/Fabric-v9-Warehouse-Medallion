CREATE TABLE [AFISales_DW].[FactBuyGroupAccounts] (
    [RowID]            BIGINT    NOT NULL, -- IDENTITY (1, 1)
    [AccountAndShipto] CHAR (13) NOT NULL,
    [bmebgcode]        CHAR (3)  NOT NULL
)


GO
CREATE STATISTICS [Stat_FactBuyGroupAccounts_AccountAndShipto]
    ON [AFISales_DW].[FactBuyGroupAccounts]([AccountAndShipto]);

