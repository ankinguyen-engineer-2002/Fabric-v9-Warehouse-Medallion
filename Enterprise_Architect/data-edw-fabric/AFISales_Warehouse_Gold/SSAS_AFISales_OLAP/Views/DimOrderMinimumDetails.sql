CREATE VIEW [SSAS_AFISALES_OLAP].[DimOrderMinimumDetails]
AS
            SELECT 'Y' AS 'Order Minimum Code',
                 'Yes' AS 'Order Minimum Met'
    UNION ALL
        SELECT 'N' AS 'Order Miminum Code',
             'No'  AS 'Order Minimum Met';