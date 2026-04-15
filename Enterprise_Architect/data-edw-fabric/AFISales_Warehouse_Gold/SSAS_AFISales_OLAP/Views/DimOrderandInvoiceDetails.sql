CREATE VIEW [SSAS_AFISALES_OLAP].[DimOrderandInvoiceDetails]
AS
    SELECT
            OH.[Order Number],
            OH.[Order Date],
            OH.[Order Change Date],
            SH.[Invoice Date],
            SH.[Invoice Number],
            SH.[Trip Number],
            SH.[Purchase Order],
            SH.[Order Arrival Mode],
            SH.[Primary Order Type],
            SH.[Secondary Order Type],
            SH.[Order Arrival Group],
            SH.[Order Arrival Electronic],
            SH.[3rd Order Type],
            SH.[4th Order Type],
            SH.[Invoice Credit Code],
            SH.[Order Sequence],
            SH.[Request Date]  AS [Request Date],
            SH.[Promise Date]  AS [Promise Date],
            SH.[Delivery Date] AS [Delivery Date]
    FROM
            AFISales_DW.FactOrderHistory   OH
        LEFT JOIN
            AFISales_DW.FactShippedHistory SH
                ON OH.[Order Number] = SH.[Order Number]
                   AND OH.[Order Number] = SH.[Order Date]
                   AND OH.[Item Key] = SH.[Item Key]
                   AND OH.[Order Sequence] = SH.[Invoice Sequence];