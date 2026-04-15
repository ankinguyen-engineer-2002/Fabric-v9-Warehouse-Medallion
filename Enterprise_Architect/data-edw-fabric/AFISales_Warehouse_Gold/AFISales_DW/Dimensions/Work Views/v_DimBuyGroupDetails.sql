CREATE VIEW AFISales_DW_Wrk.v_DimBuyGroupDetails
AS
    SELECT
        BuyGroupMaster.BuyGroupCode AS [Buying Group Code],
        BuyGroupMaster.Description  AS [Buying Group Description]
    FROM
        [$(Wholesale_Warehouse)].Pricing_AFI.BuyGroupMaster;
