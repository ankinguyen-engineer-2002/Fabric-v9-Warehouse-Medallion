CREATE VIEW [SSAS_AFISALES_OLAP].[FactOrderMinimum]
AS
    SELECT
        [Invoice Date],
        [Account And Shipto Number],
        [Invoice Number],
        [Order Minimum $],
        [Order Minimum],
        [Order Minimum Met],
        [OM Base Calc],
        [Warehouse],
        [Store Address ID],
        [Shipto AddressID],
        [Territory],
        [State] as [inhshpst]
    FROM
        AFISales_DW.FactOrderMinimum;