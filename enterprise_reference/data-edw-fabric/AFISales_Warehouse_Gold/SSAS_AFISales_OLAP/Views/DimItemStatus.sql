CREATE VIEW [SSAS_AFISALES_OLAP].[DimItemStatus]
AS
    SELECT
        ' '      AS [Status Code],
        'Active' AS [Item Status]
    UNION
    SELECT
        'R',
        'Replaced'
    UNION
    SELECT
        'D',
        'Discontinued'
    UNION
    SELECT
        'I',
        'Introduced'
    UNION
    SELECT
        'T',
        'Tentative'
    UNION
    SELECT
        'N',
        'New'
    UNION
    SELECT
        'Z',
        'Unknown';