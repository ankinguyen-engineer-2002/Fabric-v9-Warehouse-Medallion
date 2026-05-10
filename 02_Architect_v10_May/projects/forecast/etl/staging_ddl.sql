-- ============================================================
-- Staging_Wrk Views — Raw EDW Projection
-- ============================================================
-- Layer: Staging. Pattern: TRIM strings, TRY_CONVERT dates, PascalCase aliases. No JOIN.
-- Source: SupplyChain_Processing_Warehouse
-- Generated from live workspace scan (2026-05-06)
-- ============================================================

-- ---- Staging_Wrk.v_Codatan ----
CREATE VIEW Staging_Wrk.v_Codatan AS
SELECT
    TRIM(ORDNO) AS OrderID, TRIM(ITNBR) AS ItemSKU, TRIM(HOUSE) AS WarehouseCode,
    CAST(ITMSQ AS INT) AS ItemSequenceNum,
    CAST(COQTY AS DECIMAL(12,3)) AS QtyOrdered, CAST(QTYSH AS DECIMAL(12,3)) AS QtyShipped,
    CAST(QTYBO AS DECIMAL(12,3)) AS QtyBackordered,
    CAST(INSAM AS DECIMAL(12,2)) AS AmtExtendedSelling,
    CAST(PRICE AS DECIMAL(12,4)) AS AmtSellingPrice,
    TRY_CONVERT(DATE, CAST(CAST(RQIDT AS BIGINT) AS VARCHAR(20))) AS RequestedDate,
    TRY_CONVERT(DATE, CAST(CAST(MFIDT AS BIGINT) AS VARCHAR(20))) AS ManufacturedDate,
    TRIM(CCUSNO) AS Customer, TRIM(CSHPNO) AS ShipToCode,
    TRIM(ITDSC) AS ItemDescriptionName, TRIM(ITDSI) AS ItemDescriptionShortName,
    CAST(IAFLG AS VARCHAR(200)) AS AllocationFlagCode,
    CAST(NUMLDDTCHG AS INT) AS LoadDateChanges
FROM Enterprise_Lakehouse.Wholesale_Codis_AFI.codatan WHERE ORDNO IS NOT NULL

GO

-- ---- Staging_Wrk.v_Comast ----
CREATE VIEW Staging_Wrk.v_Comast AS
SELECT TRIM(ORDNO) AS OrderID,
    TRY_CONVERT(DATE, CAST(CAST(ORDTE AS BIGINT) AS VARCHAR(20))) AS OrderDate,
    CAST(SHLTC AS INT) AS LeadTimeDays, TRIM(SHINS) AS ShippingInstructionsName,
    TRIM(ACREC) AS RecordTypeCode
FROM Enterprise_Lakehouse.Wholesale_Codis_AFI.COMAST

GO

-- ---- Staging_Wrk.v_Extord ----
CREATE VIEW Staging_Wrk.v_Extord AS
SELECT TRIM(XORDNO) AS OrderID,
    TRY_CONVERT(DATE, CAST(CAST(FRZDAT AS BIGINT) AS VARCHAR(20))) AS FreezeDate,
    TRY_CONVERT(DATE, CAST(CAST(RQSDAT AS BIGINT) AS VARCHAR(20))) AS RequestedShipDate,
    TRIM(ORDARR) AS OrderArrangementCode,
    TRIM(OTTYP1) AS OrderType1Code, TRIM(OTTYP2) AS OrderType2Code,
    TRIM(OTTYP3) AS OrderType3Code, TRIM(OTTYP4) AS OrderType4Code
FROM Enterprise_Lakehouse.Wholesale_Codis_AFI.EXTORD

GO

-- ---- Staging_Wrk.v_Extorit ----
CREATE VIEW Staging_Wrk.v_Extorit AS
SELECT TRIM(IORD) AS OrderID, CAST(ISEQ AS INT) AS ItemSequenceNum,
    CAST(IFRGHT AS DECIMAL(12,2)) AS AmtFreight,
    TRY_CONVERT(DATE, CAST(CAST(IPRMDT AS BIGINT) AS VARCHAR(20))) AS PromiseDate
FROM Enterprise_Lakehouse.Wholesale_Codis_AFI.EXTORIT

GO
