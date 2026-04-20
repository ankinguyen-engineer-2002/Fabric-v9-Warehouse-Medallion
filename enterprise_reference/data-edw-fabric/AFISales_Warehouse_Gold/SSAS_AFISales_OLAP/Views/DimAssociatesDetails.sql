CREATE VIEW [SSAS_AFISALES_OLAP].[DimAssociatesDetails]
AS
    SELECT
        [Salesman Number],
        [Salesman Name]
    FROM
        AFISales_DW.DimAssociateDetails;