CREATE TABLE [Pricing_AFI].[CommissionRates]
    (
        [CommissionCode]       CHAR(3)        NOT NULL,
        [CommissionClass]      CHAR(2)        NOT NULL,
        [CommissionPercent]    DECIMAL(6, 4)  NOT NULL,
        [OrderStartDate]       DATE           NULL,   --DateTime
        [OrderEndDate]         DATE           NULL,   --DateTime
        [CommissionBaseAdjust] DECIMAL(10, 3) NOT NULL,
        [AuditFlag]            BIT            NOT NULL,
        [AddedByUser]                 VARCHAR(30)    NULL,
        [DateAdded]                 DATETIME2(6)   NULL,
        [ChangeByUser]                 VARCHAR(30)    NULL,
        [DateChange]                 DATETIME2(6)   NULL,
        [ActiveRecord]                CHAR(1)        NOT NULL
    );


-- DATA_SOURCE = [AzureStorageGen2a],
--LOCATION = N'/Wholesale/Pricing_AFI/CommissionRates/AFI_Sales_tblCommissionRates.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],

