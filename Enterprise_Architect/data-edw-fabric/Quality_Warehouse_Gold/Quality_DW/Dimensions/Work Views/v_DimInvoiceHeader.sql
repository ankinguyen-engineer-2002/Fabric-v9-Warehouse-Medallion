Create view Quality_DW_Wrk.v_DimInvoiceHeader
as 
SELECT [Invoice Date] = CAST([InvoiceDate] AS DATE),
       [Invoice Number] = [InvoiceNumber],
       [Order Number] = [OrderNumber],
       [Trip Number] = [TripNumber],
       [Purchase Order] = TRIM([PurchaseOrder]),
       [Order Arrival Mode] = TRIM(oacOadesc),
       [Primary Order Type] = t1.OTDES1,
       [Secondary Order Type] = t1.OTDES1,
       [Order Arrival Group] = oagDescription,
       [Order Arrival Electronic] = CAST(oagElectronic AS INT),
       [3rd Order Type] = t1.OTDES1,
       [4th Order Type] = t1.OTDES1,
       [Invoice Credit Code] = TRIM([CreditCode])
FROM [$(Wholesale_Warehouse)].SalesHistory_AFI.[InvoiceHeader]
    LEFT JOIN [$(Source_Data)].[Wholesale_Codis_AFI].[OrderArrivalCode]
        ON [OrderArrivalCode] = oacOacode
    LEFT JOIN [$(Source_Data)].[Wholesale_Codis_AFI].[OrderArrivalGroup]
        ON oacModeGroup = oagGroup
    LEFT JOIN [$(Source_Data)].[Wholesale_Codis_AFI].[AAORDTYP] t1
        ON t1.OTCODE = [OrderTypePrimary]
        and t1.OTCODE = [OrderTypeSecondary]
        and t1.OTCODE = [OrderTypeUsrDefine3]
        and t1.OTCODE = [OrderTypeUsrDefine4]
WHERE [InvoiceDate]
BETWEEN GETDATE() - 3560 AND GETDATE() - 1

