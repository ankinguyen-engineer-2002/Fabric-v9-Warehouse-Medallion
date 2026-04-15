CREATE VIEW [SSAS_AFISALES_OLAP].[FactMarketCommitments]
AS
    SELECT
        [AFI Sales RepID]       AS [Marketing Specialist ID],
        [AFI Sales Category]    AS [Sales Category],
        [AFI Sales Region Code] AS [Region Code],
        [AFI Sales RepID]       AS Territory,
        RegionCode_RepID_Category,
        [Item SKU],
        [Item Key],
        SalesTerritoryID,
        [Committed],
        [Committed - NonHomestore],
        [Committed - Homestore],
        [Actual Placements],
        [Original Commitment],
        [Original Commitment - NonHomestore],
        [Original Commitment - Homestore],
        [Remaining Goal]
    FROM
        AFISales_DW.[FactMarketCommitments];