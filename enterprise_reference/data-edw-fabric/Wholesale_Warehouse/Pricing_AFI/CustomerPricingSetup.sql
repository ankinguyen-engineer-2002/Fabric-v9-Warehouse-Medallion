CREATE TABLE [Pricing_AFI].[CustomerPricingSetup]
    (
        [CustomerNumber]  [CHAR](8)      NOT NULL,  --varchar
        [ShiptoNumber]    [CHAR](4)      NOT NULL,  --varchar
        [ID]              [CHAR](2)      NOT NULL,  --varchar
        [StartDate]       [DATE]         NOT NULL,  --DateTime
        [Code]            [CHAR](6)      NOT NULL,  --varchar
        [LastUserChanged] [VARCHAR](30)  NULL,
        [AddedByUser]            [VARCHAR](30)  NULL,
        [DateAdded]            [DATETIME2](6) NULL,
        [ChangeByUser]            [VARCHAR](30)  NULL,
        [DateChange]            [DATETIME2](6) NULL,
        [AuditFlag]       [BIT]          NULL
    );

--DATA_SOURCE = [AzureStorageGen2a],
--LOCATION = N'/Wholesale/Pricing_AFI/CustomerPricingSetup/AFI_Sales_tblCustomerPricingSetup.snappy.parquet',
--FILE_FORMAT = [ParquetFileFormatSnappy],REJECT_TYPE = VALUE,REJECT_VALUE = 0)
