CREATE VIEW [SSAS_AFISALES_OLAP].[FactSpecialChargeData]
AS
    SELECT
            [Invoice Date],
            [Invoice Number],
            [Warehouse],
            [Account And Shipto Number],
            [Territory],
            [Shipto AddressID],
            [Billto AddressID],
            [Credit Code],
            [Charge Amount]
    FROM
            AFISales_DW.FactSpecialCharges SC
        LEFT JOIN
            AFISales_DW.DimDateFile        D
                ON SC.[Invoice Date] = D.[Transaction Date]
    WHERE
            [Fiscal Year] >= YEAR(GETDATE()) - 4;
GO