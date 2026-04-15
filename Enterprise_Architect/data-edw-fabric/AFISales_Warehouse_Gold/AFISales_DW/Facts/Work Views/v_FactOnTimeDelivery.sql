CREATE VIEW AFISales_DW_Wrk.v_FactOnTimeDelivery
AS
    SELECT
            [Invoice Date]                       = OnTimeDeliveryDetail.InvoiceDate,
            [AFI Warehouse]                      = OnTimeDeliveryDetail.Warehouse,
            [Trip Number]                        = OnTimeDeliveryDetail.TripNumber,
            [Account And Shipto Number],
            [SalesTerritoryID],
            [Item Key]                           = ISNULL(OnTimeDeliveryDetail.ItemSKU, ''),
            DimCustomers.[Store Address ID]                 AS [Billto AddressID],
            DimCustomers.[Shipto AddressID],
            [Item Status]                        = OnTimeDeliveryDetail.ItemStatus,
            [Route Zone]                         = OnTimeDeliveryDetail.RouteZone,
            [Route Region]                       = OnTimeDeliveryDetail.RouteRegion,
            [Order Type]                         = ISNULL(TYP2.Description2, ''),
            [Order Type3]                        = ISNULL(TYP3.Description2, ''),
            [Shipped Quantity]                   = SUM(OnTimeDeliveryDetail.ShippedQuantity * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)),
            [Order to Delivery]                  = SUM(OnTimeDeliveryDetail.OrderToDelivery * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)),
            [Originl Promise to Delivery]        = SUM(OnTimeDeliveryDetail.OrgPromToDelivery * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)),
            [Invoice To Delivery]                = SUM(OnTimeDeliveryDetail.InvoiceToDelivery * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)),
            [Current Request to Delivery]        = SUM(OnTimeDeliveryDetail.CurReqToDelivery * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)),
            [First Scan to Trip Close]           = SUM(OnTimeDeliveryDetail.FirstScanToTripClose * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)),
            [Trip Close to Delivery]             = SUM(OnTimeDeliveryDetail.TripCloseToDelivery * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)),
            [Original Request to Delivery]       = SUM(OnTimeDeliveryDetail.OrigReqtoDelivery * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)),
            [Order to First Scan]                = SUM(OnTimeDeliveryDetail.OrderToFirstScan * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)),
            [Trip Create to Trip Close]          = SUM(OnTimeDeliveryDetail.TripCreateToTripClose * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)),
            [Trip Create to First Scan]          = SUM(OnTimeDeliveryDetail.TripCreateToFirstScan * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)),
            [Order to Trip Create]               = SUM(OnTimeDeliveryDetail.OrdertoTripCreate * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)),
            [Current Promise to Delivery]        = SUM(OnTimeDeliveryDetail.CurPromisetoDelivery * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)),
            [Qty Ontime - Original Promise Day]  = SUM(OnTimeDeliveryDetail.QtyOnTimeOrigPromiseDay * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)),
            [Qty Ontime - Original Promise Week] = SUM(OnTimeDeliveryDetail.QtyOnTimeOrigPromiseWeek * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)),
            [Qty Ontime - Current Request Day]   = SUM(OnTimeDeliveryDetail.QtyOnTimeCurReqDay * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)),
            [Qty Ontime - Current Request Week]  = SUM(OnTimeDeliveryDetail.QtyOnTimeCurReqWeek * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)),
            [Qty Ontime - Original Request Day]  = SUM(OnTimeDeliveryDetail.QtyOnTimeOrigReqDay * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)),
            [Qty Ontime - Original Request Week] = SUM(OnTimeDeliveryDetail.QtyOnTimeOrigReqWeek * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)),
            [Qty Ontime - Current Promise Day]   = SUM(OnTimeDeliveryDetail.QtyOnTimeCurPromDay * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)),
            [Qty Ontime - Current Promise Week]  = SUM(OnTimeDeliveryDetail.QtyOnTimeCurPromWeek * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)),
            DimSalesTerritories.[RegionCode_RepID_Category],
            DimSalesTerritories.[AFI Sales Category],
            DimCustomers.[Customer Account Number],
            DimCustomers.[Customer Shipto Number],
            DimSalesTerritories.[AFI Sales RepID],
            DimSalesTerritories.[AFI Sales Region Code]
    FROM
            AFISales_Enh.OnTimeDeliveryDetail
        JOIN
            AFISales_DW.DimCustomers         
                ON [Customer Account Number] = OnTimeDeliveryDetail.CustomerNumber
                   AND [Customer Shipto Number] = OnTimeDeliveryDetail.ShiptoNumber
        LEFT JOIN
            AFISales_Enh.TerritoryAllocationStatic
                ON CASE
                       WHEN CAST(DimCustomers.[Shipto Sales Territory] AS INT) <> 0
                           THEN
                           DimCustomers.[Shipto Sales Territory]
                       ELSE
                           DimCustomers.[Primary Sales Territory]
                   END = TerritoryAllocationStatic.TerritoryCode
                   AND OnTimeDeliveryDetail.SalesCategory = TerritoryAllocationStatic.SalesCategory
        LEFT JOIN
            [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode          TYP2
                ON TYP2.OrderTypeCode = OnTimeDeliveryDetail.OrderType2
        LEFT JOIN
            [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode          TYP3
                ON TYP3.OrderTypeCode = OnTimeDeliveryDetail.OrderType3
        LEFT JOIN
            AFISales_DW.[DimSalesTerritories] 
                ON DimSalesTerritories.[AFI Sales Region Code] = ISNULL(TerritoryAllocationStatic.RegionCode, CAST('Z' AS CHAR(3)))
                   AND DimSalesTerritories.[AFI Sales RepID] = ISNULL(TerritoryAllocationStatic.RepID, CAST('ZZZZZ' AS CHAR(5)))
                   AND DimSalesTerritories.[AFI Sales Category] = ISNULL(OnTimeDeliveryDetail.SalesCategory, CAST('ZZ' AS CHAR(3)))
                   AND DimSalesTerritories.[Active Record] = 1
    GROUP BY
            OnTimeDeliveryDetail.Warehouse,
            OnTimeDeliveryDetail.TripNumber,
            OnTimeDeliveryDetail.InvoiceDate,
            SalesTerritoryID,
            ISNULL(OnTimeDeliveryDetail.ItemSKU, ''),
            [Store Address ID],
            [Shipto AddressID],
            OnTimeDeliveryDetail.ItemStatus,
            OnTimeDeliveryDetail.RouteZone,
            OnTimeDeliveryDetail.RouteRegion,
            ISNULL(TYP2.Description2, ''),
            ISNULL(TYP3.Description2, ''),
            [Account And Shipto Number],
            [RegionCode_RepID_Category],
            [AFI Sales Category],
            [Customer Account Number],
            [Customer Shipto Number],
            [AFI Sales RepID],
            [AFI Sales Region Code];