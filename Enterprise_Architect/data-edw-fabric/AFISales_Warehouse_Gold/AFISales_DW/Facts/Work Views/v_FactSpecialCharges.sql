CREATE VIEW [AFISales_DW_Wrk].[v_FactSpecialCharges]
AS
    SELECT
            [Invoice Date]           = SpecialCharges.[InvoiceDate],
            [Invoice Number]         = SpecialCharges.[InvoiceNumber],
            [Sequence Number]        = SpecialCharges.[SequenceNumber],
            SpecialCharges.[Warehouse]  ,
            DimCustomers.[Account And Shipto Number],
            CASE
                WHEN CAST(DimCustomers.[Shipto Sales Territory] AS INT) = 0
                    THEN
                    DimCustomers.[Primary Sales Territory]
                ELSE
                    DimCustomers.[Primary Sales Territory] + DimCustomers.[Shipto Sales Territory]
            END                      AS Territory,
            DimCustomers.[Shipto AddressID],
            DimCustomers.[Store Address ID]     AS [Billto AddressID],
            SpecialCharges.[CreditCode]        AS [Credit Code],
            SpecialCharges.[Amount]           AS [Charge Amount],
            ISNULL(CreditCodes.Description, 'Unknown') AS [Credit Code Description],
            ISNULL(CreditCodes.CreditCodeID, 'Z')      AS [Credit ID Code],
            CreditCodes.FinanceCode           AS [Finance Code],
            CreditCodes.ApplyToCommission     AS [Apply To Commission],
            CreditCodes.AccrualCredit         AS [Accrual Credit],
            CreditCodes.SpecialChargeCode     AS [Special Charge Code],
            CreditCodes.SalesTaxFlag          AS [Sales Tax Flag],
            CreditCodes.TypeCode              AS [Type Code],
            CreditCodes.AllocationCode        AS [Allocation Code],
            CreditCodes.CommissionAdjFlag     AS [Commission Adjustment Flag]
    FROM
            [$(Wholesale_Warehouse)].SalesHistory_AFI.SpecialCharges
        LEFT JOIN
            AFISales_DW.DimCustomers  
                ON DimCustomers.[Customer Account Number] = SpecialCharges.[CustomerNumber]
                   AND DimCustomers.[Customer Shipto Number] = SpecialCharges.[ShiptoNumber]
        LEFT JOIN
            [$(Wholesale_Warehouse)].CustomerOrders_AFI.CreditCodes
                ON SpecialCharges.CreditCode = CreditCodes.CreditCode;
