CREATE VIEW [SSAS_AFISALES_OLAP].[DimBuyGroupDetails]
AS
    SELECT
        [Buying Group Code]        AS bmaBgCode,
        [Buying Group Description] AS bmaBgDesc
    FROM
        AFISales_DW.DimBuyGroupDetails;