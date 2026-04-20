CREATE VIEW [AFISales_DW_Wrk].[v_FactQualityCosts_AcctOwnership]
AS
    WITH ReplacementPartHistory
    AS (
           SELECT
                   [RPKey]                                 = ReplacementPartHeader.RPKey,
                   [Item Sequence]                         = ReplacementPartDetail.ItemSequence,
                   [Part Number]                           = ReplacementPartDetail.ItemSKU,
                   [Scrap Code]                            = ReplacementPartHeader.DefectCode + ReplacementPartHeader.LocationCode,
                   [Item SKU]                              = ReplacementPartHeader.ItemSKU,
                   [Warehouse]                             = ReplacementPartHeader.Warehouse,
                   [Account And Shipto Number]             = CASE
                                                                 WHEN ISNULL(ReplacementPartHeader.ShiptoNumber, '') = ''
                                                                     THEN
                                                                     ReplacementPartHeader.CustomerNumber
                                                                 ELSE
                                                                     RTRIM(ReplacementPartHeader.CustomerNumber) + '-' + LTRIM(ReplacementPartHeader.ShiptoNumber)
                                                             END,
                   [Ship Date]                             = ReplacementPartHeader.ShipDate,
                   [Replacement Part Order Count]          = CASE
                                                                 WHEN ReplacementPartDetail.ItemSequence = 1
                                                                     THEN
                                                                     1
                                                                 ELSE
                                                                     NULL
                                                             END,
                   [Replacement Part Incidents]            = 1,
                   [Parts Shipped Quantity - No Charge]    = CASE
                                                                 WHEN ReplacementPartHeader.ChargeType IN (
                                                                                    'N', 'F'
                                                                                )
                                                                     THEN
                                                                     ReplacementPartDetail.Quantity
                                                                 ELSE
                                                                     NULL
                                                             END,
                   [Parts Shipped Quantity - Charged Back] = CASE
                                                                 WHEN ReplacementPartHeader.ChargeType IN (
                                                                                    'B'
                                                                                )
                                                                     THEN
                                                                     ReplacementPartDetail.Quantity
                                                                 ELSE
                                                                     NULL
                                                             END,
                   [Parts Cost - No Charge]                = CASE
                                                                 WHEN ReplacementPartHeader.ChargeType IN (
                                                                                    'N', 'F'
                                                                                )
                                                                     THEN
                   (CASE
                        WHEN ISNULL(stduc, 0) = 0
                            THEN
                            BZANVA / 2
                        ELSE
                            stduc
                    END
                   ) * ReplacementPartDetail.Quantity
                                                                 ELSE
                                                                     NULL
                                                             END,
                   [Parts Cost - Charged Back]             = CASE
                                                                 WHEN ReplacementPartHeader.ChargeType IN (
                                                                                    'B'
                                                                                )
                                                                     THEN
                   (CASE
                        WHEN ISNULL(stduc, 0) = 0
                            THEN
                            BZANVA / 2
                        ELSE
                            stduc
                    END
                   ) * ReplacementPartDetail.Quantity
                                                                 ELSE
                                                                     NULL
                                                             END,
                   [Shipping Cost - No Charge]             = CASE
                                                                 WHEN ReplacementPartHeader.ChargeType IN (
                                                                                    'N'
                                                                                )
                                                                     THEN
                                                                     ReplacementPartHeader.ShippingCost * ReplacementPartDetail.Quantity * (CASE
                                                                                         WHEN ReplacementPartHeader.ShipVia IN (
                                                                                                            'FDX', 'UPS'
                                                                                                        )
                                                                                             THEN
                                                                                             .55
                                                                                         ELSE
                                                                                             1
                                                                                     END
                                                                                    )
                                                                 ELSE
                                                                     NULL
                                                             END,
                   [Shipping Cost - Charged Back]          = CASE
                                                                 WHEN ReplacementPartHeader.ChargeType IN (
                                                                                    'F', 'B'
                                                                                )
                                                                     THEN
                                                                     ReplacementPartHeader.ShippingCost * ReplacementPartDetail.Quantity * (CASE
                                                                                         WHEN ReplacementPartHeader.ShipVia IN (
                                                                                                            'FDX', 'UPS'
                                                                                                        )
                                                                                             THEN
                                                                                             .55
                                                                                         ELSE
                                                                                             1
                                                                                     END
                                                                                    )
                                                                 ELSE
                                                                     NULL
                                                             END
           FROM
                   [$(Wholesale_Warehouse)].Quality_AFI.ReplacementPartHeader
               JOIN
                   AFISales_DW.DimDateFile
                       ON DimDateFile.[Transaction Date] = ReplacementPartHeader.ShipDate
               JOIN
                   [$(Wholesale_Warehouse)].Quality_AFI.ReplacementPartDetail
                       ON ReplacementPartHeader.RPKey = ReplacementPartDetail.RPKey
               LEFT JOIN
                   AFISales_DW.DimItemMaster
                       ON ReplacementPartHeader.ItemSKU = DimItemMaster.[ItemSKU]
               LEFT JOIN
                   (
                       SELECT
                               x.ITNBR,
                               b.STDUC AS stduc
                       FROM
                               [$(Source_Data)]. [MasterData_ItemMaster_AFI].[ITMEXT] x
                           JOIN
                               [$(Source_Data)].[MasterData_ItemMaster_AFI].[ITMRVA] a
                                   ON x.CEX = a.STID
                                      AND x.ITNBR = a.ITNBR
                                      AND '1    ' = a.UUCA
                           JOIN
                               [$(Source_Data)].[MasterData_ItemMaster_AFI].[ITMRVB] b
                                   ON x.CEX = b.STID
                                      AND x.ITNBR = b.ITNBR
                                      AND a.ITRV = b.ITRV
                   ) ItmCst
                       ON ReplacementPartDetail.ItemSKU = ItmCst.ITNBR
               LEFT JOIN
                   (
                       SELECT
                               BP.BZAITX,
                               BP.BZANVA
                       FROM
                               [$(Databricks)].[masterdata_itemmaster_afi].mbbzrep BP
                           JOIN
                               (
                                   SELECT
                                       BZAITX,
                                       MAX(BZBLDT) AS BZBLDT
                                   FROM
                                       [$(Databricks)].[masterdata_itemmaster_afi].mbbzrep
                                   WHERE
                                       CAST(CASE
                                                WHEN SUBSTRING(
                                                                  REPLACE(CONVERT(VARCHAR(10), GETDATE(), 120), '-', ''),
                                                                  1, 2
                                                              ) = '19'
                                                    THEN
                                                    '0'
                                                ELSE
                                                    '1'
                                            END
                                            + SUBSTRING(REPLACE(CONVERT(VARCHAR(10), GETDATE(), 120), '-', ''), 3, 6) AS DECIMAL(7, 0)) >= BZBLDT
                                   GROUP BY
                                       BZAITX
                               )                                          MBP
                                   ON BP.BZAITX = MBP.BZAITX
                                      AND BP.BZBLDT = MBP.BZBLDT
                   ) BasePrice
                       ON ReplacementPartDetail.ItemSKU = BasePrice.BZAITX
           WHERE
                   ISNULL(OrderType, '') = ' ')
    SELECT
        ROW_NUMBER() OVER (ORDER BY
                               QualityData.[Invoice Number]
                          ) AS RowID,
        [Part Number],
        [Defect Type],
        [Purchase Order],
        [Invoice Number],
        [Order Number],
        [Item Sequence Number],
        [Item SKU],
        [Item Key],
        [Defect Code],
        [Location Code],
        [Credit Code],
        [Quality Code],
        [Damage Type],
        [Damaged Location],
        [Percent Allowed],
        [Serial Number],
        [Trip Number],
        [Drop Number],
        [Original Invoice],
        [Original Order],
        [Order Date],
        [Order Mode],
        [Add User],
        [Carrier],
        [Truck Number],
        [Delivery Date],
        [Scan Name],
        [Load Date],
        [Order Type],
        [Transaction Date],
        [Vendor Number],
        [Where Made],
        [Manufacture Date],
        [User Group],
        [Sales Number],
        [Item Type],
        [Scrap Code],
        [Quality Category],
        [SalesTerritoryID],
        [Account And Shipto Number],
        [Territory],
        [Item Status],
        [Warehouse Code],
        [Shipto AddressID],
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
        [Customer Shipto Division Number]
    FROM
        (
            SELECT
                    'N/A'                                                                                               AS [Part Number],
                    QualityCostsDetail.Type                                                                             AS [Defect Type],
                    QualityCostsDetail.PONumber                                                                         AS [Purchase Order],
                    QualityCostsDetail.InvoiceNumber                                                                    AS [Invoice Number],
                    QualityCostsDetail.OrderNumber                                                                      AS [Order Number],
                    QualityCostsDetail.ItemSequence                                                                     AS [Item Sequence Number],
                    TRIM(QualityCostsDetail.ItemSKU)                                                                    AS [Item SKU],
                    'ASHLEY_' + QualityCostsDetail.ItemSKU                                                              AS [Item Key],
                    ISNULL(QualityCostsDetail.DefectCode, 'N/A')                                                        AS [Defect Code],
                    ISNULL(QualityCostsDetail.LocationCode, 'N/A')                                                      AS [Location Code],
                    QualityCostsDetail.CreditCode                                                                       AS [Credit Code],
                    QualityCostsDetail.QualityCode                                                                      AS [Quality Code],
                    ISNULL(DamageCodes.Description, 'N/A')                                                              AS [Damage Type],
                    ISNULL(ScrapCodes.Description, 'N/A')                                                               AS [Damaged Location],
                    QualityCostsDetail.[Percent]                                                                        AS [Percent Allowed],
                    QualityCostsDetail.SerialNumber                                                                     AS [Serial Number],
                    QualityCostsDetail.TripNumber                                                                       AS [Trip Number],
                    QualityCostsDetail.DropNumber                                                                       AS [Drop Number],
                    QualityCostsDetail.OrgInvoiceNumber                                                                 AS [Original Invoice],
                    QualityCostsDetail.OrgOrderNumber                                                                   AS [Original Order],
                    QualityCostsDetail.OrderDate                                                                        AS [Order Date],
                    QualityCostsDetail.OrderMode                                                                        AS [Order Mode],
                    QualityCostsDetail.AddUser                                                                          AS [Add User],
                    QualityCostsDetail.Carrier                                                                          AS [Carrier],
                    QualityCostsDetail.TruckNumber                                                                      AS [Truck Number],
                    QualityCostsDetail.DeliveryDate                                                                     AS [Delivery Date],
                    QualityCostsDetail.ScanName                                                                         AS [Scan Name],
                    QualityCostsDetail.LoadDate                                                                         AS [Load Date],
                    QualityCostsDetail.OrderType                                                                        AS [Order Type],
                    QualityCostsDetail.TransactionDate                                                                  AS [Transaction Date],
                    QualityCostsDetail.VendorNumber                                                                     AS [Vendor Number],
                    QualityCostsDetail.WhereMade                                                                        AS [Where Made],
                    QualityCostsDetail.ManufactureDate                                                                  AS [Manufacture Date],
                    QualityCostsDetail.UserGroup                                                                        AS [User Group],
                    QualityCostsDetail.SalesNumber                                                                      AS [Sales Number],
                    QualityCostsDetail.ItemType                                                                         AS [Item Type],
                    QualityCostsDetail.Scrap                                                                            AS [Scrap Code],
                    QualityCostsDetail.QualityCategory                                                                  AS [Quality Category],
                    [SalesTerritoryID],
                    DimCustomers.[Account And Shipto Number],
                    CASE
                        WHEN CAST(DimCustomers.[Shipto Sales Territory] AS INT) = 0
                            THEN
                            DimCustomers.[Primary Sales Territory]
                        ELSE
                            DimCustomers.[Primary Sales Territory] + DimCustomers.[Shipto Sales Territory]
                    END                                                                                                 AS Territory,
                    QualityCostsDetail.ItemStatus                                                                       AS [Item Status],
                    QualityCostsDetail.Warehouse                                                                        AS [Warehouse Code],
                    DimCustomers.[Shipto AddressID],
                    00000.00                                                                                            AS [Replacement Part Orders],
                    0                                                                                                   AS [Replacement Part Quantity],
                    000000.000                                                                                          AS [Replacement Part Cost],
                    CAST(QualityCostsDetail.Quantity * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1) AS DECIMAL(9, 3)) AS [Total Quality Quantity],
                    00000.00                                                                                            AS [Quality Credit Quantity],
                    000000.000                                                                                          AS [Quality Credits],
                    00000.00                                                                                            AS [Replacement Part Incidents],
                    CAST((CASE
                              WHEN QualityCostsDetail.CreditCode = 'R'
                                  THEN
                                  QualityCostsDetail.Quantity
                              ELSE
                                  0
                          END
                         ) * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1) AS DECIMAL(9, 3))                           [Return Quantity],
                    CAST((CASE
                              WHEN QualityCostsDetail.CreditCode = 'R'
                                  THEN
                                  0
                              ELSE
                                  QualityCostsDetail.Quantity
                          END
                         ) * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1) AS DECIMAL(9, 3))                           AS [Short Ship Quantity],
                    CAST((CASE
                              WHEN QualityCostsDetail.CreditCode = 'R'
                                  THEN
                    (QualityCostsDetail.Quantity)
                    * (QualityCostsDetail.Price - QualityCostsDetail.Freight - QualityCostsDetail.Adjust
                       + QualityCostsDetail.Discount
                      )
                              ELSE
                                  0
                          END
                         ) * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1) AS DECIMAL(9, 3))                           AS [Returns Amount],
                    CAST((CASE
                              WHEN QualityCostsDetail.CreditCode = 'R'
                                  THEN
                                  0
                              ELSE
                    (QualityCostsDetail.Quantity)
                    * (QualityCostsDetail.Price - QualityCostsDetail.Freight - QualityCostsDetail.Adjust
                       + QualityCostsDetail.Discount
                      )
                          END
                         ) * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1) AS DECIMAL(9, 3))                           AS [Short Ship Amount],
                    CAST((CASE
                              WHEN QualityCostsDetail.CreditCode = 'R'
                                  THEN
                    (QualityCostsDetail.Quantity)
                    * (QualityCostsDetail.Price - QualityCostsDetail.Freight - QualityCostsDetail.Adjust
                       + QualityCostsDetail.Discount
                      )
                              ELSE
                                  0
                          END
                         ) * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1)
                         + (CASE
                                WHEN QualityCostsDetail.CreditCode = 'R'
                                    THEN
                                    0
                                ELSE
                    (QualityCostsDetail.Quantity)
                    * (QualityCostsDetail.Price - QualityCostsDetail.Freight - QualityCostsDetail.Adjust
                       + QualityCostsDetail.Discount
                      )
                            END
                           ) * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1) AS DECIMAL(9, 3))                         AS [Total Quality Costs],
                    RTRIM(DimCustomers.[Customer Account Number]) + '-' + RTRIM(DimCustomers.[Customer Shipto Number])
                    + '-' + DimSalesTerritories.[AFI Sales Division Code]                                               AS [Customer Shipto Division Number]
            FROM
                    [$(Wholesale_Warehouse)].Quality_AFI.QualityCostsDetail
                JOIN
                    AFISales_DW.DimCustomers
                        ON DimCustomers.[Customer Account Number] = QualityCostsDetail.CustomerNumber
                           AND DimCustomers.[Customer Shipto Number] = QualityCostsDetail.ShiptoNumber
                LEFT JOIN
                    AFISales_DW.DimItemMaster
                        ON DimItemMaster.ItemSKU = QualityCostsDetail.ItemSKU
                LEFT JOIN
                    [$(Wholesale_Warehouse)].[Quality_AFI].[DamageCodes]
                        ON QualityCostsDetail.DefectCode = DamageCodes.DamageCode
                LEFT JOIN
                    [$(Wholesale_Warehouse)].[Quality_AFI].[ScrapCodes]
                        ON QualityCostsDetail.LocationCode = ScrapCodes.ScrapCode
                LEFT JOIN
                    AFISales_Enh.MrktSpclstAcctOwnershipSlsCat
                        ON AFISalesDivisionCode = MrktSpclstAcctOwnershipSlsCat.Division
                           AND MrktSpclstAcctOwnershipSlsCat.CustomerNumber = QualityCostsDetail.CustomerNumber
                           AND CASE
                                   WHEN DimCustomers.[Account Exception Flag] = 0
                                       THEN
                                       ''
                                   WHEN DimCustomers.[Account Exception Flag] = 1
                                       THEN
                                       MrktSpclstAcctOwnershipSlsCat.ShiptoNumber
                                   ELSE
                                       ''
                               END = MrktSpclstAcctOwnershipSlsCat.ShiptoNumber
                           AND AFISalesCategoryCode = MrktSpclstAcctOwnershipSlsCat.SalesCategory
                LEFT JOIN
                    AFISales_DW.DimSalesTerritories
                        ON DimSalesTerritories.[AFI Sales Region Code] = ISNULL(
                                                                                   MrktSpclstAcctOwnershipSlsCat.Region,
                                                                                   CAST('Z' AS CHAR(3))
                                                                               )
                           AND DimSalesTerritories.[AFI Sales RepID] = ISNULL(
                                                                                 MrktSpclstAcctOwnershipSlsCat.RepID,
                                                                                 CAST('ZZZZZ' AS CHAR(5))
                                                                             )
                           AND DimSalesTerritories.[AFI Sales Category] = CASE
                                                                              WHEN ISNULL(AFISalesCategoryCode, '') = ''
                                                                                   OR ISNULL(
                                                                                                MrktSpclstAcctOwnershipSlsCat.Region,
                                                                                                ''
                                                                                            ) = ''
                                                                                  THEN
                                                                                  CAST('ZZ' AS CHAR(3))
                                                                              ELSE
                                                                                  DimItemMaster.AFISalesCategoryCode
                                                                          END
                           AND DimSalesTerritories.[Active Record] = 1
            WHERE
                    (
                        QualityCostsDetail.QualityCode IN (
                                                              'RQ', 'RC', 'SS'
                                                          )
                        OR
                            (
                                ISNULL(QualityCostsDetail.Scrap, '') LIKE 'XX%'
                                OR ISNULL(QualityCostsDetail.Scrap, '') LIKE 'XP%'
                            )
                    )
                    AND QualityCostsDetail.InvoiceNumber2 <> '0'
            UNION ALL
            SELECT
                    'N/A'                                                 AS [Part Number],
                    QualityCostsDetail.Type,
                    QualityCostsDetail.PONumber,
                    QualityCostsDetail.InvoiceNumber,
                    QualityCostsDetail.OrderNumber,
                    QualityCostsDetail.ItemSequence,
                    QualityCostsDetail.ItemSKU,
                    'ASHLEY_' + QualityCostsDetail.ItemSKU                AS [item Key],
                    ISNULL(QualityCostsDetail.DefectCode, 'N/A')          AS [Defect Code],
                    ISNULL(QualityCostsDetail.LocationCode, 'N/A')        AS [Location Code],
                    QualityCostsDetail.CreditCode,
                    QualityCostsDetail.QualityCode,
                    ISNULL(DamageCodes.Description, 'N/A')                AS [Damage Type],
                    ISNULL(ScrapCodes.Description, 'N/A')                 AS [Damaged Location],
                    QualityCostsDetail.[Percent],
                    QualityCostsDetail.SerialNumber,
                    QualityCostsDetail.TripNumber,
                    QualityCostsDetail.DropNumber,
                    QualityCostsDetail.OrgInvoiceNumber,
                    QualityCostsDetail.OrgOrderNumber,
                    QualityCostsDetail.OrderDate,
                    QualityCostsDetail.OrderMode,
                    QualityCostsDetail.AddUser,
                    QualityCostsDetail.Carrier,
                    QualityCostsDetail.TruckNumber,
                    QualityCostsDetail.DeliveryDate,
                    QualityCostsDetail.ScanName,
                    QualityCostsDetail.LoadDate,
                    QualityCostsDetail.OrderType,
                    QualityCostsDetail.TransactionDate,
                    QualityCostsDetail.VendorNumber,
                    QualityCostsDetail.WhereMade,
                    QualityCostsDetail.ManufactureDate,
                    QualityCostsDetail.UserGroup,
                    QualityCostsDetail.SalesNumber,
                    QualityCostsDetail.ItemType,
                    QualityCostsDetail.Scrap,
                    QualityCostsDetail.QualityCategory,
                    [SalesTerritoryID],
                    DimCustomers.[Account And Shipto Number],
                    CASE
                        WHEN CAST(DimCustomers.[Shipto Sales Territory] AS INT) = 0
                            THEN
                            DimCustomers.[Primary Sales Territory]
                        ELSE
                            DimCustomers.[Primary Sales Territory] + DimCustomers.[Shipto Sales Territory]
                    END                                                   AS Territory,
                    QualityCostsDetail.ItemStatus,
                    QualityCostsDetail.Warehouse,
                    DimCustomers.[Shipto AddressID],
                    0                                                     AS [Replacement Part Orders],
                    0                                                     AS [Replacement Part Quantity],
                    0                                                     AS [Replacement Part Cost],
                    QualityCostsDetail.Quantity * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1),
                    (QualityCostsDetail.QualityCredQnty * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1)) * -1,
                    (CASE
                         WHEN QualityCostsDetail.QualityCode = 'QC'
                             THEN
                             -1.000 * QualityCostsDetail.QualityCredits
                         ELSE
                             QualityCostsDetail.Quantity
                             * (QualityCostsDetail.Price + QualityCostsDetail.Discount - QualityCostsDetail.Freight
                                - QualityCostsDetail.Adjust
                               )
                     END
                    ) * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1)    AS QualityCredits,
                    0                                                     AS [Replacement Part Incidents],
                    0                                                     AS ReturnQnty,
                    0                                                     AS [Returns],
                    0                                                     AS ShortShipQnty,
                    0                                                     AS ShortShips,
                    (CASE
                         WHEN QualityCostsDetail.QualityCode = 'QC'
                             THEN
                             -1.000 * QualityCostsDetail.QualityCredits
                         ELSE
                             QualityCostsDetail.Quantity
                             * (QualityCostsDetail.Price + QualityCostsDetail.Discount - QualityCostsDetail.Freight
                                - QualityCostsDetail.Adjust
                               )
                     END
                    ) * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1)    AS [ToTerritoryAllocationStatic. Quality Costs],
                    RTRIM(DimCustomers.[Customer Account Number]) + '-' + RTRIM(DimCustomers.[Customer Shipto Number])
                    + '-' + DimSalesTerritories.[AFI Sales Division Code] AS [Customer Shipto Division Number]
            FROM
                    [$(Wholesale_Warehouse)].Quality_AFI.QualityCostsDetail
                JOIN
                    AFISales_DW.DimCustomers
                        ON DimCustomers.[Customer Account Number] = QualityCostsDetail.CustomerNumber
                           AND DimCustomers.[Customer Shipto Number] = QualityCostsDetail.ShiptoNumber
                LEFT JOIN
                    AFISales_DW.DimItemMaster
                        ON DimItemMaster.ItemSKU = QualityCostsDetail.ItemSKU
                LEFT JOIN
                    [$(Wholesale_Warehouse)].[Quality_AFI].[DamageCodes]
                        ON QualityCostsDetail.DefectCode = DamageCodes.DamageCode
                LEFT JOIN
                    [$(Wholesale_Warehouse)].[Quality_AFI].[ScrapCodes]
                        ON QualityCostsDetail.LocationCode = ScrapCodes.ScrapCode
                LEFT JOIN
                    AFISales_Enh.MrktSpclstAcctOwnershipSlsCat
                        ON DimItemMaster.AFISalesDivisionCode = MrktSpclstAcctOwnershipSlsCat.Division
                           AND QualityCostsDetail.CustomerNumber = MrktSpclstAcctOwnershipSlsCat.CustomerNumber
                           AND CASE
                                   WHEN DimCustomers.[Account Exception Flag] = 0
                                       THEN
                                       ''
                                   WHEN DimCustomers.[Account Exception Flag] = 1
                                       THEN
                                       QualityCostsDetail.ShiptoNumber
                                   ELSE
                                       ''
                               END = MrktSpclstAcctOwnershipSlsCat.ShiptoNumber
                           AND DimItemMaster.AFISalesCategoryCode = MrktSpclstAcctOwnershipSlsCat.SalesCategory
                LEFT JOIN
                    AFISales_DW.DimSalesTerritories
                        ON DimSalesTerritories.[AFI Sales Region Code] = ISNULL(
                                                                                   MrktSpclstAcctOwnershipSlsCat.Region,
                                                                                   CAST('Z' AS CHAR(3))
                                                                               )
                           AND DimSalesTerritories.[AFI Sales RepID] = ISNULL(
                                                                                 MrktSpclstAcctOwnershipSlsCat.RepID,
                                                                                 CAST('ZZZZZ' AS CHAR(5))
                                                                             )
                           AND DimSalesTerritories.[AFI Sales Category] = CASE
                                                                              WHEN ISNULL(
                                                                                             DimItemMaster.AFISalesCategoryCode,
                                                                                             ''
                                                                                         ) = ''
                                                                                   OR ISNULL(
                                                                                                MrktSpclstAcctOwnershipSlsCat.Region,
                                                                                                ''
                                                                                            ) = ''
                                                                                  THEN
                                                                                  CAST('ZZ' AS CHAR(3))
                                                                              ELSE
                                                                                  DimItemMaster.AFISalesCategoryCode
                                                                          END
                           AND DimSalesTerritories.[Active Record] = 1
            WHERE
                    ISNULL(QualityCostsDetail.Scrap, '') NOT LIKE 'XX%'
                    AND ISNULL(QualityCostsDetail.Scrap, '') NOT LIKE 'XP%'
                    AND QualityCostsDetail.QualityCode IN (
                                                              'AL'
                                                          )
                    AND QualityCostsDetail.InvoiceNumber2 <> '0'
            UNION ALL
            SELECT
                    TRIM(ReplacementPartHistory.[Part Number]),
                    'RP'                                                  AS rpqDefectType,
                    '0',
                    '0',
                    CAST(ReplacementPartHistory.RPKey AS VARCHAR(10)),
                    CAST(ReplacementPartHistory.[Item Sequence] AS VARCHAR(7)),
                    TRIM(ReplacementPartHistory.[Item SKU]),
                    'ASHLEY_' + [DimItemMaster].[ItemSKU]                 AS [item Key],
                    'N/A',
                    'N/A',
                    '',
                    'RP',
                    ISNULL(DamageCodes.Description, 'N/A')                AS [Damage Type],
                    ISNULL(ScrapCodes.Description, 'N/A')                 AS [Damaged Location],
                    0,
                    'N/A',
                    0,
                    0,
                    0,
                    ' ',
                    ' ',
                    ' ',
                    ' ',
                    'N/A',
                    'N/A',
                    NULL,
                    'N/A',
                    NULL,
                    ' ',
                    CAST(ReplacementPartHistory.[Ship Date] AS DATE)      AS [Transaction date],
                    ' ',
                    ' ',
                    NULL,
                    ' ',
                    ' ',
                    ' ',
                    ' ',
                    ScrapCategoryCodes.Category,
                    DimSalesTerritories.[SalesTerritoryID],
                    DimCustomers.[Account And Shipto Number],
                    CASE
                        WHEN CAST(DimCustomers.[Shipto Sales Territory] AS INT) = 0
                            THEN
                            DimCustomers.[Primary Sales Territory]
                        ELSE
                            DimCustomers.[Primary Sales Territory] + DimCustomers.[Shipto Sales Territory]
                    END                                                   AS Territory,
                    DimItemMaster.AFIItemStatus,
                    ReplacementPartHistory.[Warehouse],
                    DimCustomers.[Shipto AddressID],
                    ISNULL(ReplacementPartHistory.[Replacement Part Order Count], 0)
                    * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1)      AS [Replacement Part Orders],
                    (ISNULL(ReplacementPartHistory.[Parts Shipped Quantity - No Charge], 0)
                     + ISNULL(ReplacementPartHistory.[Parts Shipped Quantity - Charged Back], 0)
                    )
                    * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1)      AS [Replacement Part Quantity],
                    (ISNULL(ReplacementPartHistory.[Parts Cost - No Charge], 0)
                     + ISNULL(ReplacementPartHistory.[Parts Cost - Charged Back], 0)
                     + ISNULL(ReplacementPartHistory.[Shipping Cost - No Charge], 0)
                     + ISNULL(ReplacementPartHistory.[Shipping Cost - Charged Back], 0)
                    )
                    * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1)      AS [Replacement Part Cost],
                    (ISNULL(ReplacementPartHistory.[Parts Shipped Quantity - No Charge], 0)
                     + ISNULL(ReplacementPartHistory.[Parts Shipped Quantity - Charged Back], 0)
                    )
                    * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1)      AS [ToTerritoryAllocationStatic. Quality Quantity],
                    0,
                    0,
                    ISNULL(ReplacementPartHistory.[Replacement Part Incidents], 0)
                    * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1)      AS [Replacement Part Incidents],
                    0,
                    0,
                    0,
                    0,
                    (ISNULL(ReplacementPartHistory.[Parts Cost - No Charge], 0)
                     + ISNULL(ReplacementPartHistory.[Parts Cost - Charged Back], 0)
                     + ISNULL(ReplacementPartHistory.[Shipping Cost - No Charge], 0)
                     + ISNULL(ReplacementPartHistory.[Shipping Cost - Charged Back], 0)
                    )
                    * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1)      AS [ToTerritoryAllocationStatic. Quality Cost],
                    RTRIM(DimCustomers.[Customer Account Number]) + '-' + RTRIM(DimCustomers.[Customer Shipto Number])
                    + '-' + DimSalesTerritories.[AFI Sales Division Code] AS [Customer Shipto Division Number]
            FROM
                    [$(Quality_Warehouse)].Quality_Enh.ReplacementPartHistory
                JOIN
                    AFISales_DW.DimCustomers
                        ON DimCustomers.[Account And Shipto Number] = ReplacementPartHistory.[Account And Shipto Number]
                LEFT JOIN
                    AFISales_DW.DimItemMaster
                        ON DimItemMaster.ItemSKU = ReplacementPartHistory.[Item SKU]
                LEFT JOIN
                    [$(Wholesale_Warehouse)].[Quality_AFI].[DamageCodes]
                        ON DamageCodes.DamageCode = LEFT(ReplacementPartHistory.[Scrap Code], 2)
                LEFT JOIN
                    [$(Wholesale_Warehouse)].[Quality_AFI].[ScrapCodes]
                        ON ScrapCodes.ScrapCode = RIGHT(ReplacementPartHistory.[Scrap Code], 2)
                LEFT JOIN
                    [$(Wholesale_Warehouse)].Quality_AFI.ScrapCategoryCodes
                        ON ScrapCategoryCodes.ScrapCode = LEFT(ReplacementPartHistory.[Scrap Code], 2)
                LEFT JOIN
                    AFISales_Enh.MrktSpclstAcctOwnershipSlsCat
                        ON AFISalesDivisionCode = MrktSpclstAcctOwnershipSlsCat.Division
                           AND DimCustomers.[Customer Account Number] = MrktSpclstAcctOwnershipSlsCat.CustomerNumber
                           AND CASE
                                   WHEN DimCustomers.[Account Exception Flag] = 0
                                       THEN
                                       ''
                                   WHEN DimCustomers.[Account Exception Flag] = 1
                                       THEN
                                       DimCustomers.[Customer Shipto Number]
                                   ELSE
                                       ''
                               END = MrktSpclstAcctOwnershipSlsCat.ShiptoNumber
                           AND AFISalesCategoryCode = MrktSpclstAcctOwnershipSlsCat.SalesCategory
                LEFT JOIN
                    AFISales_DW.DimSalesTerritories
                        ON DimSalesTerritories.[AFI Sales Region Code] = ISNULL(
                                                                                   MrktSpclstAcctOwnershipSlsCat.Region,
                                                                                   CAST('Z' AS CHAR(3))
                                                                               )
                           AND DimSalesTerritories.[AFI Sales RepID] = ISNULL(
                                                                                 MrktSpclstAcctOwnershipSlsCat.RepID,
                                                                                 CAST('ZZZZZ' AS CHAR(5))
                                                                             )
                           AND DimSalesTerritories.[AFI Sales Category] = CASE
                                                                              WHEN ISNULL(
                                                                                             DimItemMaster.AFISalesCategoryCode,
                                                                                             ''
                                                                                         ) = ''
                                                                                   OR ISNULL(
                                                                                                MrktSpclstAcctOwnershipSlsCat.Region,
                                                                                                ''
                                                                                            ) = ''
                                                                                  THEN
                                                                                  CAST('ZZ' AS CHAR(3))
                                                                              ELSE
                                                                                  DimItemMaster.AFISalesCategoryCode
                                                                          END
                           AND DimSalesTerritories.[Active Record] = 1
        ) QualityData;