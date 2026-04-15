CREATE TABLE [Quality_DW].[DimVendor]
    (
        [RowNumber]                   BIGINT      NOT NULL, --IDENTITY (1, 1) 
        [Vendor Number]               CHAR(8)     NOT NULL,
        [Vendor Code]                 CHAR(2)     NULL,
        [Vendor Name]                 VARCHAR(25) NULL,
        [Vendor Country]              CHAR(3)     NULL,
        [Vendor FOB Country]          CHAR(3)     NULL,
        [Vendor Office]               VARCHAR(10) NULL,
        [Vendor Office Location]      VARCHAR(25) NULL,
        [Vendor Active]               CHAR(3)     NULL,
        [Vendor Import Domestic Flag] CHAR(8)     NULL
    );


GO
CREATE STATISTICS [Stat_DimVendor_Vendor_Office]
    ON [Quality_DW].[DimVendor]
    (
        [Vendor Office]
    );


GO
CREATE STATISTICS [Stat_DimVendor_Vendor_Number]
    ON [Quality_DW].[DimVendor]
    (
        [Vendor Number]
    );


GO
CREATE STATISTICS [Stat_DimVendor_Vendor_Name]
    ON [Quality_DW].[DimVendor]
    (
        [Vendor Name]
    );


GO
CREATE STATISTICS [Stat_DimVendor_Vendor_Import_Domestic_Flag]
    ON [Quality_DW].[DimVendor]
    (
        [Vendor Import Domestic Flag]
    );


GO
CREATE STATISTICS [Stat_DimVendor_Vendor_Country]
    ON [Quality_DW].[DimVendor]
    (
        [Vendor Country]
    );

