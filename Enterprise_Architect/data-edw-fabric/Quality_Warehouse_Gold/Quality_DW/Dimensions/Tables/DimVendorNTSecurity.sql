CREATE TABLE [Quality_DW].[DimVendorNTSecurity]
    (
        [RowNumber]       BIGINT      NOT NULL, -- IDENTITY (1, 1)
        [Vendor NTLogins] VARCHAR(25) NULL,
        [Vendor Profile]  VARCHAR(16) NULL
    );


GO
CREATE STATISTICS [Stat_DimVendorNTSecurity_Vendor_Profile]
    ON [Quality_DW].[DimVendorNTSecurity]
    (
        [Vendor Profile]
    );


GO
CREATE STATISTICS [Stat_DimVendorNTSecurity_Vendor_NTLogins]
    ON [Quality_DW].[DimVendorNTSecurity]
    (
        [Vendor NTLogins]
    );

