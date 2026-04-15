CREATE VIEW AFISales_DW_Wrk.v_DimOrderHistoryDetails
AS
    SELECT DISTINCT
           [Order Change Date],
           [Order Number],   ----TRIM
           [Order Sequence],
           [Request Date],
           [Order Arrival Mode],
           [Primary Order Type],
           [Secondary Order Type],
           [3rd Order Type],
           [4th Order Type],
           [Reason Code]
    FROM
           AFISales_DW.FactOrderHistory
    WHERE
           [Order Change Date] >= GETDATE() - 1095;

