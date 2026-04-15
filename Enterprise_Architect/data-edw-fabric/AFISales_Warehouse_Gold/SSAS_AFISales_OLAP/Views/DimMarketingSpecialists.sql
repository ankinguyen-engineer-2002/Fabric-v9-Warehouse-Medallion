CREATE VIEW [SSAS_AFISALES_OLAP].[DimMarketingSpecialists]
AS
    SELECT
        [Salesman Number],
        [Salesman Name],
        [Saleman Business Name],
        [Sales Position]
    FROM
        AFISales_DW.DimMarketingSpecialists;