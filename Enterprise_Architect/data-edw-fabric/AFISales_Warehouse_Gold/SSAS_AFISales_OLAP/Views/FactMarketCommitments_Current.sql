CREATE VIEW [SSAS_AFISALES_OLAP].[FactMarketCommitments_Current]
AS
	SELECT
		RowID,
		[Item SKU],
		[Item Key],
		Territory,
		SalesTerritoryID,
		Market, [User ID],
		[Market Commitment],
		[Market Commitment - NonHomestore],
		[Market Commitment - Homestore],
		[Monthly Estimate]
	From AFISales_DW.FactMarketCommitments_Current;