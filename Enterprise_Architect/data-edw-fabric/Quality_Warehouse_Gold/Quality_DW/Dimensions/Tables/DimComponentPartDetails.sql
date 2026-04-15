CREATE TABLE [Quality_DW].[DimComponentPartDetails]
    (
        [RowNumber]                        BIGINT      NOT NULL, --IDENTITY (1, 1) 
        [Part SKU]                         VARCHAR(15) NOT NULL,
        [Item Class Code]                  CHAR(4)     NOT NULL,
        [Responsible Office]               VARCHAR(10) NOT NULL,
        [Item Class Name]                  VARCHAR(25) NOT NULL,
        [Item Class]                       VARCHAR(32) NOT NULL,
        [Part Description]                 VARCHAR(30) NULL,     --VARCHAR (30)
        [AFI Item Status]                  CHAR(3)     NULL,
        [AFI Item Status Description]      VARCHAR(25) NOT NULL,
        [Import/Domestic Code]             CHAR(3)     NOT NULL,
        [Country of Origin]                VARCHAR(30) NOT NULL,
        [Primary Site ID]                  CHAR(3)     NULL,
        [Primary Vendor]                   CHAR(8)     NOT NULL,
        [Manufacturing Status Change Date] DATE        NULL,
        [Site ID]                          CHAR(3)     NOT NULL
    );


GO
CREATE STATISTICS [Stat_DimComponentPartDetails_Site_ID]
    ON [Quality_DW].[DimComponentPartDetails]
    (
        [Site ID]
    );


GO
CREATE STATISTICS [Stat_DimComponentPartDetails_Primary_Vendor]
    ON [Quality_DW].[DimComponentPartDetails]
    (
        [Primary Vendor]
    );


GO
CREATE STATISTICS [Stat_DimComponentPartDetails_Part_SKU]
    ON [Quality_DW].[DimComponentPartDetails]
    (
        [Part SKU]
    );


GO
CREATE STATISTICS [Stat_DimComponentPartDetails_Item_Class_Code]
    ON [Quality_DW].[DimComponentPartDetails]
    (
        [Item Class Code]
    );


GO
CREATE STATISTICS [Stat_DimComponentPartDetails_AFI_Item_Status]
    ON [Quality_DW].[DimComponentPartDetails]
    (
        [AFI Item Status]
    );


GO
CREATE STATISTICS [Stat_DimComponentPartDetails_Responsible_Office]
    ON [Quality_DW].[DimComponentPartDetails]
    (
        [Responsible Office]
    );


GO
CREATE STATISTICS [Stat_DimComponentPartDetails_Item_Class_Name]
    ON [Quality_DW].[DimComponentPartDetails]
    (
        [Item Class Name]
    );


GO
CREATE STATISTICS [Stat_DimComponentPartDetails_Item_Class]
    ON [Quality_DW].[DimComponentPartDetails]
    (
        [Item Class]
    );


GO
CREATE STATISTICS [Stat_DimComponentPartDetails_AFI_Item_Status_Description]
    ON [Quality_DW].[DimComponentPartDetails]
    (
        [AFI Item Status Description]
    );

