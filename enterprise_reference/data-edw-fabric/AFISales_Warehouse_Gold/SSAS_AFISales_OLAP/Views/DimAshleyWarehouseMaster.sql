CREATE VIEW [SSAS_AFISALES_OLAP].[DimAshleyWarehouseMaster]
AS
    SELECT
        [Warehouse Code],
        [Intransit Warehouse],
        [Container Direct Warehouse],
        [Controlled Warehouse],
        [Warehouse Location],
        [Warehouse Order Group]
    FROM
        AFISales_DW.DimWarehouseMaster;