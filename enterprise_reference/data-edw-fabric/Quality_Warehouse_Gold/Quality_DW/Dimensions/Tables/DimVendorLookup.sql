CREATE TABLE [Quality_DW].[DimVendorLookup]
    (
        [RowNumber]   BIGINT         NOT NULL,  --IDENTITY(1, 1)
        [Item]        VARCHAR(15)    NULL,
        [InvoiceDate] DATE           NOT NULL,
        [Vendor]      CHAR(8)        NULL,
        [VendorCount] DECIMAL(38, 3) NULL,
        [warehouse]   CHAR(3)        NULL
    );



GO
CREATE STATISTICS [Stat_DimVendorLookup_Vendor]
    ON [Quality_DW].[DimVendorLookup]
    (
        [Vendor]
    );


GO
CREATE STATISTICS [Stat_DimVendorLookup_Item]
    ON [Quality_DW].[DimVendorLookup]
    (
        [Item]
    );


GO
CREATE STATISTICS [Stat_DimVendorLookup_State_Code]
    ON [Quality_DW].[DimVendorLookup]
    (
        [InvoiceDate]
    );

-- removed vlu prefix