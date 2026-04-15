CREATE TABLE [Quality_DW].[DimManufacturingDetails]
    (
        [RowNumber]                  BIGINT       NOT NULL, -- IDENTITY (1, 1)
        [Invoice Date]               DATE         NULL,
        [Invoice Number]             DECIMAL(9)   NULL,
        [Serial Number]              VARCHAR(15)  NOT NULL,
        [Purchase Order Number]      VARCHAR(22)  NULL,     --VARCHAR (22)
        [Manufacturing Order Number] VARCHAR(10)  NULL,
        [Manufacturing Warehouse]    CHAR(3)      NULL,
        [Where Made]                 CHAR(5)      NULL,
        [User Group]                 VARCHAR(10)  NULL,
        [Manufactured Date]          DATE         NULL,
        [Department]                 CHAR(5)      NULL,
        [Work Center]                CHAR(5)      NULL,
        [Group]                      DECIMAL(5)   NULL,
        [Shift]                      DECIMAL(1)   NULL,
        [Supervisor Number]          DECIMAL(5)   NULL,
        [Scan Name]                  VARCHAR(10)  NULL,
        [Load Date]                  DATE         NULL,
        [Truck Number]               VARCHAR(15)  NULL,
        [Carrier]                    VARCHAR(100) NULL,
        [Manufacturing Site]         VARCHAR(25)  NULL,
        [Item Source Flag]           CHAR(3)      NOT NULL
    );

GO
CREATE STATISTICS [Stat_DimManufacturingDetails_Where_Made]
    ON [Quality_DW].[DimManufacturingDetails]
    (
        [Where Made]
    );


GO
CREATE STATISTICS [Stat_DimManufacturingDetails_Invoice_Date]
    ON [Quality_DW].[DimManufacturingDetails]
    (
        [Invoice Date]
    );


GO
CREATE STATISTICS [Stat_DimManufacturingDetails_Work_Center]
    ON [Quality_DW].[DimManufacturingDetails]
    (
        [Work Center]
    );


GO
CREATE STATISTICS [Stat_DimManufacturingDetails_User_Group]
    ON [Quality_DW].[DimManufacturingDetails]
    (
        [User Group]
    );


GO
CREATE STATISTICS [Stat_DimManufacturingDetails_Truck_Number]
    ON [Quality_DW].[DimManufacturingDetails]
    (
        [Truck Number]
    );


GO
CREATE STATISTICS [Stat_DimManufacturingDetails_Supervisor_Number]
    ON [Quality_DW].[DimManufacturingDetails]
    (
        [Supervisor Number]
    );


GO
CREATE STATISTICS [Stat_DimManufacturingDetails_Shift]
    ON [Quality_DW].[DimManufacturingDetails]
    (
        [Shift]
    );


GO
CREATE STATISTICS [Stat_DimManufacturingDetails_Serial_Number]
    ON [Quality_DW].[DimManufacturingDetails]
    (
        [Serial Number]
    );


GO
CREATE STATISTICS [Stat_DimManufacturingDetails_Scan_Name]
    ON [Quality_DW].[DimManufacturingDetails]
    (
        [Scan Name]
    );


GO
CREATE STATISTICS [Stat_DimManufacturingDetails_Purchase_Order_Number]
    ON [Quality_DW].[DimManufacturingDetails]
    (
        [Purchase Order Number]
    );


GO
CREATE STATISTICS [Stat_DimManufacturingDetails_Manufacturing_Warehouse]
    ON [Quality_DW].[DimManufacturingDetails]
    (
        [Manufacturing Warehouse]
    );


GO
CREATE STATISTICS [Stat_DimManufacturingDetails_Manufacturing_Site]
    ON [Quality_DW].[DimManufacturingDetails]
    (
        [Manufacturing Site]
    );


GO
CREATE STATISTICS [Stat_DimManufacturingDetails_Manufacturing_Order_Number]
    ON [Quality_DW].[DimManufacturingDetails]
    (
        [Manufacturing Order Number]
    );


GO
CREATE STATISTICS [Stat_DimManufacturingDetails_Manufactured_Date]
    ON [Quality_DW].[DimManufacturingDetails]
    (
        [Manufactured Date]
    );


GO
CREATE STATISTICS [Stat_DimManufacturingDetails_Load_Date]
    ON [Quality_DW].[DimManufacturingDetails]
    (
        [Load Date]
    );


GO
CREATE STATISTICS [Stat_DimManufacturingDetails_Item_Source_Flag]
    ON [Quality_DW].[DimManufacturingDetails]
    (
        [Item Source Flag]
    );


GO
CREATE STATISTICS [Stat_DimManufacturingDetails_Invoice_Number]
    ON [Quality_DW].[DimManufacturingDetails]
    (
        [Invoice Number]
    );


GO
CREATE STATISTICS [Stat_DimManufacturingDetails_Group]
    ON [Quality_DW].[DimManufacturingDetails]
    (
        [Group]
    );


GO
CREATE STATISTICS [Stat_DimManufacturingDetails_Department]
    ON [Quality_DW].[DimManufacturingDetails]
    (
        [Department]
    );


GO
CREATE STATISTICS [Stat_DimManufacturingDetails_Carrier]
    ON [Quality_DW].[DimManufacturingDetails]
    (
        [Carrier]
    );

