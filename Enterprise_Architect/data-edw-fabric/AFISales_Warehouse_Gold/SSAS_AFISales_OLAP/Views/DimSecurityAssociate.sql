CREATE VIEW [SSAS_AFISALES_OLAP].[DimSecurityAssociate]
AS
    SELECT
        [Salesman Number],
        [Account Number],
        [Shipto Number],
        [Division Code],
        [Salesman Name],
        [Customer Shipto Division Number]
    FROM
        AFISales_DW.DimAssociateSecurity;