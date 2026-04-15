CREATE VIEW [SSAS_AFISALES_OLAP].[DimSpecialChargeDetails]
AS
    SELECT
        [Credit Code],
        [Credit Code Description],
        [Credit ID Code],
        [Finance Code],
        [Apply To Commission],
        [Accrual Credit],
        [Special Charge Code],
        [Sales Tax Flag],
        [Type Code],
        [Allocation Code],
        [Commission Adjustment Flag]
    FROM
        AFISales_DW.DimSpecialChargeDetails;