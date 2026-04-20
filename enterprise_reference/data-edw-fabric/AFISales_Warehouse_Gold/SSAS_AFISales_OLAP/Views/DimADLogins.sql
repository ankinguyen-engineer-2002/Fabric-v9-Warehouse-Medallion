CREATE VIEW [SSAS_AFISALES_OLAP].[DimADLogins]
AS
    SELECT
        ADLogins,
        [Customer Profile]
    FROM
        AFISales_DW.DimADLogins;