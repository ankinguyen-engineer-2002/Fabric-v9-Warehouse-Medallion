CREATE TABLE [Customers].[DeliveryWindow]
    (
        [CustomerNumber]     CHAR(8)       NULL,
        [ShiptoNumber]       CHAR(4)       NULL,
        [RC]                 CHAR(1)       NULL,
        [Window_ID]          CHAR(2)       NULL,
        [Open]               CHAR(8)       NULL,
        [Close]              CHAR(8)       NULL,
        [Days]               CHAR(7)       NULL,
        [Prim_Sec]           CHAR(1)       NULL,
        [Before]             CHAR(5)       NULL,
        [After]              CHAR(5)       NULL,
        [LastVerDate]        DATE          NULL, --DATETIME2 (7) 
        [Type]               CHAR(1)       NULL,
        [ExceptionSDate]     DATE          NULL, --DATETIME2 (7) 
        [ExceptionEDate]     DATE          NULL, --DATETIME2 (7) 
        [CompanyNum]         INT           NULL,
        [LastDeliveryDate]   DATE          NULL, --DATETIME 
        [AddedByUser]        VARCHAR(30)   NULL,
        [DateAdded]          DATETIME2(6)  NULL,
        [ChangeByUser]       VARCHAR(30)   NULL,
        [DateChange]         DATETIME2(6)  NULL,
        [ActiveRecord]       CHAR(1)       NULL,
        [WindowProfitFactor] DECIMAL(3, 2) NULL,
        [UserId]             VARCHAR(35)   NULL,
        [RecordID]           BIGINT        NULL,
        [RowVer]             varbinary(20) NULL,  --  VARBINARY(20)
        [RecordVersion]      BIGINT        NULL
    );


-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION = = N'/Wholesale/Customers/DeliveryWindow/AFI_Sales_tblCustomerDeliveryWindow.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
