CREATE TABLE [Quality_DW].[DimUsChampion]
    (
        [USChampion]  VARCHAR(64)  NULL,
        [Userid]      INT          NULL,
        [vendorNo]    VARCHAR(50)  NULL,
        [VendorName]  VARCHAR(100) NULL,
        [ProductType] VARCHAR(50)  NULL
    );

GO

CREATE STATISTICS [Stat_DimUsChampion_USChampion]
    ON Quality_DW.DimUsChampion
    (
        [USChampion]
    );
GO

CREATE STATISTICS [Stat_DimUsChampion_vendorNo]
    ON Quality_DW.DimUsChampion
    (
        vendorNo
    );

GO
CREATE STATISTICS [Stat_DimUsChampion_VendorName]
    ON Quality_DW.DimUsChampion
    (
        VendorName
    );
GO