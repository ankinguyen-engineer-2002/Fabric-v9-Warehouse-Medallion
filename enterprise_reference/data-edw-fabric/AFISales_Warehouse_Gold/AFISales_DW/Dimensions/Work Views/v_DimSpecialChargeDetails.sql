CREATE VIEW AFISales_DW_Wrk.v_DimSpecialChargeDetails
AS
    SELECT
        [Credit Code]                = CreditCode,
        [Credit Code Description]    = [Description],
        [Credit ID Code]             = CreditCodeID,
        [Finance Code]               = FinanceCode,
        [Apply To Commission]        = ApplyToCommission,
        [Accrual Credit]             = AccrualCredit,
        [Special Charge Code]        = SpecialChargeCode,
        [Sales Tax Flag]             = SalesTaxFlag,
        [Type Code]                  = TypeCode,
        [Allocation Code]            = AllocationCode,
        [Commission Adjustment Flag] = CommissionAdjFlag
    FROM
        [$(Wholesale_Warehouse)].CustomerOrders_AFI.CreditCodes;