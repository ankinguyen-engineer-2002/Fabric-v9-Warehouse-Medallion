CREATE VIEW [SSAS_AFISALES_OLAP].[FactQualityCostData]
AS
    SELECT
            [RowID],
            [Part Number],
            [Invoice Number],
            QC.[Account And Shipto Number],
            Territory,
            [Item SKU],
            [Item Status],
            [Warehouse Code],
            [Serial Number],
            QC.[Transaction Date],
            QC.[Shipto AddressID],
            [Replacement Part Orders],
            [Replacement Part Quantity],
            [Replacement Part Cost],
            [Total Quality Quantity],
            [Quality Credit Quantity],
            [Quality Credits],
            [Replacement Part Incidents],
            [Return Quantity],
            [Short Ship Quantity],
            [Returns Amount],
            [Short Ship Amount],
            [Total Quality Costs],
            [Customer Shipto Division Number],
            QC.SalesTerritoryID
    FROM
            AFISales_DW.FactQualityCosts QC
        LEFT JOIN
            AFISales_DW.DimDateFile      D
                ON QC.[Transaction Date] = D.[Transaction Date]
    WHERE
            [Fiscal Year] >= YEAR(GETDATE()) - 4;