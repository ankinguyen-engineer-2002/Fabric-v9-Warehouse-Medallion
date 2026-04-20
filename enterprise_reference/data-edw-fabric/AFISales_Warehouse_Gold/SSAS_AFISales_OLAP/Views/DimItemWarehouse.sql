CREATE VIEW [SSAS_AFISALES_OLAP].[DimItemWarehouse]
AS
    SELECT
        [Sequence Number],
        [AFI Item Number],
        [AFI Warehouse],
        [DRP Planner ID],
        [Alternate ABC-3 Code],
        [IP ABC Code],
        [Forecast Planner ID],
        [Field 1],
        [Product Type],
        [Field 17],
        [Product Watch Code],
        [Part Flag],
        [Product Group ID],
        [Unit Price],
        [Unit Cost],
        [Cubic Feet],
        [ABC Primary Code],
        [Vendor Name]
    FROM
        AFISales_DW.DimItemWarehouse
    UNION ALL
    SELECT
                   NULL             AS [Sequence Number],
                   [ItemSKU]        AS [AFI Item Number],
                   [Warehouse Code] AS [AFI Warehouse],
                   NULL             AS [DRP Planner ID],
                   NULL             AS [Alternate ABC-3 Code],
                   NULL             AS [IP ABC Code],
                   NULL             AS [Forecast Planner ID],
                   NULL             AS [Field 1],
                   NULL             AS [Product Type],
                   NULL             AS [Field 17],
                   NULL             AS [Product Watch Code],
                   NULL             AS [Part Flag],
                   NULL             AS [Product Group ID],
                   NULL             AS [Unit Price],
                   NULL             AS [Unit Cost],
                   NULL             AS [Cubic Feet],
                   NULL             AS [ABC Primary Code],
                   NULL             AS [Vendor Name]
    FROM
                   AFISales_DW.DimItemMaster --- was MasterData_DW
        CROSS JOIN AFISales_DW.DimWarehouseMaster
        LEFT JOIN
                   AFISales_DW.DimItemWarehouse
                       ON ItemSKU = [AFI Item Number]
                          AND [AFI Warehouse] = [Warehouse Code]
    WHERE
                   [AFI Item Number] IS NULL;