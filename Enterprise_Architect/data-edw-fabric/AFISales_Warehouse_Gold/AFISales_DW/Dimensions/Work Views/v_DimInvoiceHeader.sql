
CREATE VIEW AFISales_DW_Wrk.v_DimInvoiceHeader
AS
SELECT 
       [Invoice Date],
       [Invoice Number] ,
       [Order Number],
       [Trip Number],
       CAST([Purchase Order] AS VARCHAR(25)) AS [Purchase Order],
       [Order Arrival Mode],
       [Primary Order Type],
       [Secondary Order Type],
       [Order Arrival Group],
       [Order Arrival Electronic],
       [3rd Order Type],
       [4th Order Type],
       [Invoice Credit Code],
       [Order Sequence],
       [Request Date],
       [Promise Date],
       [Delivery Date],
       [Original Invoice Number] ,
       [Original Invoice Date],
       [Original Order Number],
       [Original Order Date],
       [Original Sequence Number],
       [Original Delivery Method],
       [TruckLoad Trip Type]
FROM
(
    SELECT T1.[Invoice Date],
           T1.[Invoice Number],
           T1.[Order Number],
           T1.[Trip Number],
           LEFT(TRIM(T1.[Purchase Order]), 22) AS [Purchase Order],
           T1.[Order Arrival Mode],
           T1.[Primary Order Type],
           T1.[Secondary Order Type],
           T1.[Order Arrival Group],
           CAST(T1.[Order Arrival Electronic] AS INT) AS [Order Arrival Electronic],
           T1.[3rd Order Type],
           T1.[4th Order Type],
           T1.[Invoice Credit Code],
           T1.[Order Sequence],
           MAX(T1.[Request Date]) AS [Request Date],
           MAX(T1.[Promise Date]) AS [Promise Date],
           MAX(T1.[Delivery Date]) AS [Delivery Date],
           MAX(T2.[OriginalInvoiceNumber]) AS [Original Invoice Number],
           MAX(T2.[OriginalInvoiceDate]) AS [Original Invoice Date],
           MAX(T2.[OriginalOrderNumber]) AS [Original Order Number],
           MAX(T2.[OriginalOrderDate]) AS [Original Order Date],
           MAX(T2.[OriginalSequenceNumber]) AS [Original Sequence Number],
           ISNULL(MAX(t3.Description), T1.[Secondary Order Type]) AS [Original Delivery Method],
           T1.[TruckLoad Trip Type]
    FROM AFISales_DW.FactShippedHistory T1
        LEFT JOIN [$(Wholesale_Warehouse)].SalesHistory_AFI.InvoiceDetail T2
            ON T1.[Invoice Number] = [InvoiceNumber]
               AND T1.[Invoice Date] = [InvoiceDate]
               AND T1.[Invoice Sequence] = ItemSequence
        LEFT JOIN [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode t3
            ON t3.OrderTypeCode = T2.[OriginalDeliveryMethod]
    GROUP BY T1.[Invoice Date],
             T1.[Invoice Number],
             T1.[Order Number],
             T1.[Trip Number],
             T1.[Purchase Order],
             T1.[Order Arrival Mode],
             T1.[Primary Order Type],
             T1.[Secondary Order Type],
             T1.[Order Arrival Group],
             T1.[Order Arrival Electronic],
             T1.[3rd Order Type],
             T1.[4th Order Type],
             T1.[Invoice Credit Code],
             T1.[Order Sequence],
             T1.[TruckLoad Trip Type]
    UNION ALL

    --- add in generic 'zero' invoice numbers for quality credits without original invoice numbers
    SELECT [Invoice Date] = CAST(d.CalendarDate AS Date),
           [Invoice Number] = 0,
           [Order Number] = 'N/A',
           [Trip Number] = 0,
           [Purchase Order] = 'N/A',
           [Order Arrival Mode] = NULL,
           [Primary Order Type] = NULL,
           [Secondary Order Type] = NULL,
           [Order Arrival Group] = NULL,
           [Order Arrival Electronic] = NULL,
           [3rd Order Type] = NULL,
           [4th Order Type] = NULL,
           [Invoice Credit Code] = NULL,
           [Order Sequence] = NULL,
           [Request Date] = NULL,
           [Promise Date] = NULL,
           [Delivery Date] = NULL,
           [Original Invoice Number] = NULL,
           [Original Invoice Date] = NULL,
           [Original Order Number] = NULL,
           [Original Order Date] = NULL,
           [Original Sequence Number] = NULL,
           [Original Delivery Method] = NULL,
           [Trip Type] = NULL
    FROM [$(MasterData_Warehouse)].MasterData_DW.DimDate d
    WHERE d.CalendarDate
    BETWEEN DateADD(dd, DateDIFF(dd, 0, GETDate()), -2567) AND DateADD(dd, DateDIFF(dd, 0, GETDate()), 7)
    UNION ALL

    ---- add in credit memos that were not run through the shipped history process
    SELECT FactOpenInvoices.[Invoice Date] ,
           FactOpenInvoices.[Invoice Number],
           [Order Number] = 'N/A',
           [Trip Number] = 0,
           [Purchase Order] = 'N/A',
           [Order Arrival Mode] = NULL,
           [Primary Order Type] = NULL,
           [Secondary Order Type] = NULL,
           [Order Arrival Group] = NULL,
           [Order Arrival Electronic] = NULL,
           [3rd Order Type] = NULL,
           [4th Order Type] = NULL,
           [Invoice Credit Code] = NULL,
           [Order Sequence] = NULL,
           [Request Date] = NULL,
           [Promise Date] = NULL,
           [Delivery Date] = NULL,
           [Original Invoice Number] = NULL,
           [Original Invoice Date] = NULL,
           [Original Order Number] = NULL,
           [Original Order Date] = NULL,
           [Original Sequence Number] = NULL,
           [Original Delivery Method] = NULL,
           [TruckLoad Trip Type] AS [Trip Type]
    FROM AFISales_DW.FactOpenInvoices
        LEFT JOIN AFISales_DW.DimInvoiceHeader
            ON AFISales_DW.DimInvoiceHeader.[Invoice Date] = AFISales_DW.FactOpenInvoices.[Invoice Date]
               AND AFISales_DW.DimInvoiceHeader.[Invoice Number] = AFISales_DW.FactOpenInvoices.[Invoice Number]
    WHERE AFISales_DW.DimInvoiceHeader.[Invoice Number] IS NULL
) InvoiceHistory;
