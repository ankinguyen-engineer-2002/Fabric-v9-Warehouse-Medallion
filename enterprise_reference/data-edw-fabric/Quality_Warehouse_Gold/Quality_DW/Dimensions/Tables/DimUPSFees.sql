CREATE TABLE [Quality_DW].[DimUPSFees]
    (
        [Category]               VARCHAR(200)  NULL,
        [UPSPublishedParameters] VARCHAR(100)  NULL,
        [Ups]                    DECIMAL(6, 2) NULL,
        [UpsDiscounts]           DECIMAL(6, 2) NULL,
        [Net]                    DECIMAL(6, 2) NULL
    );