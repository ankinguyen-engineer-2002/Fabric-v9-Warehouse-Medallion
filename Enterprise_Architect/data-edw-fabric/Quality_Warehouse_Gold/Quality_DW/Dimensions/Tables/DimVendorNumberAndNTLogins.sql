CREATE TABLE [Quality_DW].[DimVendorNumberAndNTLogins]
    (
        [RowNumber]       BIGINT      NOT NULL, -- IDENTITY (1, 1) 
        [Vendor NTLogins] VARCHAR(25) NOT NULL,
        [Vendor Number]   CHAR(8)     NOT NULL
    );

GO
CREATE STATISTICS [Stat_DimVendorNumberAndNTLogins_Vendor_NTLogins]
    ON [Quality_DW].[DimVendorNumberAndNTLogins]
    (
        [Vendor NTLogins]
    );


GO
CREATE STATISTICS [Stat_DimVendorNumberAndNTLogins_Vendor_Number]
    ON [Quality_DW].[DimVendorNumberAndNTLogins]
    (
        [Vendor Number]
    );

