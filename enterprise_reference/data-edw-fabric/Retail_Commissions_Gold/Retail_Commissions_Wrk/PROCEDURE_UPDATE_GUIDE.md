# Procedure Update Guide - Normalization

## Overview

The `proc_PopulateSalesOrderLineCommission` procedure needs to be updated to populate the new IncentiveProgram and normalized category columns.

## Changes Required by Commission Type

### HFS (Home Furnishings Sales)
**IncentiveProgram Logic:**
```sql
CASE 
    WHEN BeddingSales > 0 THEN 'Bedding'
    WHEN ProtectionSales > 0 THEN 'Protection'
    WHEN ClearanceSales > 0 THEN 'Clearance'
    ELSE NULL
END
```

**Normalized Column Mappings:**
- IncentiveSales = CASE WHEN BeddingSales > 0 THEN BeddingSales WHEN ProtectionSales > 0 THEN ProtectionSales WHEN ClearanceSales > 0 THEN ClearanceSales ELSE NULL END
- IncentiveCommPct = CASE WHEN BeddingSales > 0 THEN BeddingCommPct WHEN ProtectionSales > 0 THEN ProtectionCommPct WHEN ClearanceSales > 0 THEN ClearanceCommPct ELSE NULL END
- IncentiveCommAmt = CASE WHEN BeddingSales > 0 THEN BeddingCommAmt WHEN ProtectionSales > 0 THEN ProtectionCommAmt WHEN ClearanceSales > 0 THEN ClearanceCommAmt ELSE NULL END
- IncentiveGMDollars = CASE WHEN BeddingSales > 0 THEN BeddingGMDollars WHEN ProtectionSales > 0 THEN ProtectionGMDollars WHEN ClearanceSales > 0 THEN ClearanceGM ELSE NULL END
- KickerPct = CASE WHEN BeddingSales > 0 THEN LuxuryBeddingKickerPct WHEN ProtectionSales > 0 THEN ProtectionKickerPct ELSE NULL END

### ASM (Area Sales Manager)
**IncentiveProgram Logic:** Same as HFS

**Normalized Column Mappings:** Same as HFS

### Outlet
**IncentiveProgram Logic:** Same as HFS

**Normalized Column Mappings:** Same as HFS

### OutletSSM (Outlet Store Sales Manager)
**IncentiveProgram Logic:** Same as HFS

**Normalized Column Mappings:** Same as HFS

### Electronics
**IncentiveProgram Logic:**
```sql
CASE 
    WHEN SalesELECT > 0 THEN 'Electronics'
    ELSE NULL
END
```

**Normalized Column Mappings:**
- IncentiveSales = SalesELECT
- IncentiveCommPct = ElectCommPct
- IncentiveCommAmt = ElectCommAmt
- IncentiveGMDollars = NULL
- KickerPct = NULL

### MonthlyBonus_ASM & MonthlyBonus_Mng
**IncentiveProgram Logic:**
```sql
CASE 
    WHEN BeddingSales > 0 THEN 'Bedding'
    WHEN ProtectionSales > 0 THEN 'Protection'
    ELSE NULL
END
```

**Normalized Column Mappings:**
- IncentiveSales = CASE WHEN BeddingSales > 0 THEN BeddingSales WHEN ProtectionSales > 0 THEN ProtectionSales ELSE NULL END
- CategoryGMFactor = CASE WHEN BeddingSales > 0 THEN BeddingGMFactor WHEN ProtectionSales > 0 THEN ProtectionGMFactor ELSE NULL END
- CategoryGMBonus = CASE WHEN BeddingSales > 0 THEN BeddingGMBonus WHEN ProtectionSales > 0 THEN ProtectionGMBonus ELSE NULL END

### MonthlyBonus_Outlet
**IncentiveProgram Logic:**
```sql
CASE 
    WHEN DeliveredClearanceUnits > 0 THEN 'Clearance'
    ELSE NULL
END
```

**Normalized Column Mappings:**
- IncentiveUnitsPerformance = ClearanceUnitsPerformanceBonus

### MonthlyBonus_OutletSSM
**IncentiveProgram Logic:**
```sql
CASE 
    WHEN DeliveredClearanceUnits > 0 THEN 'Clearance'
    ELSE NULL
END
```

**Normalized Column Mappings:**
- IncentiveUnitsPerformance = ClearanceUnitsPerformanceBonus

### TeleSales
**IncentiveProgram Logic:** NULL (no category-specific data)

**Normalized Column Mappings:** All NULL

## Implementation Steps

1. **Add IncentiveProgram to INSERT column list**
   - Location: After CategoryID in the column list

2. **Add normalized columns to INSERT column list**
   - IncentiveSales, IncentiveCommPct, IncentiveCommAmt, IncentiveGMDollars
   - IncentiveGMPct, IncentiveGMCommPct, IncentiveGMCommAmt, IncentiveUnitsPerformance
   - KickerPct, CategoryGMFactor, CategoryGMBonus

3. **Add IncentiveProgram to SELECT statement**
   - Use CASE logic based on commission type

4. **Add normalized column mappings to SELECT statement**
   - Use CASE logic to map category-specific columns

5. **Keep legacy columns in both INSERT and SELECT**
   - Ensure backward compatibility

## Testing Checklist

- [ ] IncentiveProgram populated correctly for each type
- [ ] Normalized columns populated correctly
- [ ] Legacy columns still populated
- [ ] No NULL values where data should exist
- [ ] Data matches source tables
- [ ] Performance acceptable

## Rollback Plan

If issues occur:
1. Keep legacy columns populated
2. Revert IncentiveProgram to NULL
3. Revert normalized columns to NULL
4. All existing queries continue to work

---

**Status:** Ready for implementation
**Estimated Effort:** 2-3 hours
**Risk Level:** Low (backward compatible)

