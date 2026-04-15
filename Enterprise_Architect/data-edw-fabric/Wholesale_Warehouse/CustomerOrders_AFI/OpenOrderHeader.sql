CREATE TABLE [CustomerOrders_AFI].[OpenOrderHeader]
    (
        [ActiveRecord]         CHAR(1)        NULL,
        [OrderNumber]          CHAR(7)        NULL,
        [CustomerNumber]       CHAR(8)        NULL,
        [PurchaseOrder]        VARCHAR(22)    NULL,
        [OrderDate]            DATE           NULL, --DECIMAL(8) 
        [PriorityOverride]     CHAR(1)        NULL,
        [CreditMemoCode]       CHAR(1)        NULL,
        [Warehouse]            CHAR(3)        NULL,
        [Slsno]                DECIMAL(5)     NULL,
        [OrderValue]           DECIMAL(13, 2) NULL,
        [ShiptoNumber]         CHAR(4)        NULL,
        [RequestDate]          DATE           NULL, -- DECIMAL(8) 
        [ShippingLeadTime]     DECIMAL(2)     NULL,
        [ShippingInstructions] VARCHAR(30)    NULL,
        [PurchaseOrderDate]    DATE           NULL  --DECIMAL(8) 
    );

--   DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/Wholesale/codis_afi/COMAST/AFI_Codis_COMAST.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],




