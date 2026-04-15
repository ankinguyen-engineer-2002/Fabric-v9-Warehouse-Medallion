CREATE TABLE [Marketing].[CRMAdvertisingFunds]
    (
        [ID]                                  INT            NOT NULL,
        [RegionCode]                          CHAR(3)        NOT NULL,
        [Repid]                               CHAR(5)        NULL,
        [DivisionCode]                        CHAR(1)        NOT NULL,
        [AccountNumber]                       CHAR(8)        NULL,
        [ShiptoNumber]                        CHAR(4)        NULL,  --Shipto
        [CreatedDate]                         DATETIME2(6)   NULL, --- DATETIME2(6)
        [MarketDate]                          DATETIME2(6)   NULL, --- DATETIME2(6)
        [ModifiedDate]                        DATETIME2(6)   NULL, --- DATETIME2(6)
        [ModifiedBy]                          VARCHAR(40)    NULL,
        [AdFundsSelectedDivision]             VARCHAR(50)    NULL,
        [AdFundsVelocityDriver]               VARCHAR(100)   NULL,
        [TypeOfFundName]                      VARCHAR(100)   NULL,
        [ApprovalStatusCode]                  SMALLINT       NOT NULL,
        [ApprovalStatusDescr]                 VARCHAR(100)   NULL,
        [AdFundsRequested]                    DECIMAL(18, 3) NULL,
        [AdFundsApproved]                     DECIMAL(18, 3) NULL,
        [New_Comments]                        VARCHAR(4000)  NULL,
        [New_SpecialDiscountCodeifapplicable] VARCHAR(25)    NULL,
        [New_adfundsname]                     VARCHAR(100)   NULL
    );

-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION = N'/Wholesale/Marketing/CRMAdvertisingFunds/CRMAdvertisingFunds.csv',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
