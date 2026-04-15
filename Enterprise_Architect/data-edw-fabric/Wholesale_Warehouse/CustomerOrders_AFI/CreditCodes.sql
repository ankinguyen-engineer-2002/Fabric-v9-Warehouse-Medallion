CREATE TABLE [CustomerOrders_AFI].[CreditCodes]
    (
        [CreditCode]         CHAR(3)      NULL,
        [Description]        VARCHAR(30)  NULL,
        [CreditCodeID]       CHAR(1)      NULL,
        [FinanceCode]        CHAR(3)      NULL,
        [ApplyToCommission]  CHAR(1)      NULL,
        [AccrualCredit]      CHAR(1)      NULL,
        [DateEntered]        DATETIME2(6) NULL,
        [UserEntered]        VARCHAR(10)  NULL,
        [SpecialChargeCode]  CHAR(1)      NULL,
        [ActiveRecord]       CHAR(1)      NULL,
        [SalesTaxFlag]       CHAR(1)      NULL,
        [TypeCode]           VARCHAR(10)  NULL,
        [AllocationCode]     VARCHAR(10)  NULL,
        [CommissionAdjFlag]  CHAR(1)      NULL,
        [VolumeDiscountFlag] CHAR(1)      NULL,
        [NoShowDiscountFlag] CHAR(1)      NULL,
        [SurchargeFlag]      CHAR(1)      NULL,
        [COAAllowanceFlag]   CHAR(1)      NULL,
        [OpenField2Flag]     CHAR(1)      NULL,
        [DFIDiscountFlag]    CHAR(1)      NULL
    );

--   DATA_SOURCE = [AzureStorageGen2a],
--  LOCATION = N'/Wholesale/codis_afi/ACRDMAS/AFI_codis_afi_ACRDMAS.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],


