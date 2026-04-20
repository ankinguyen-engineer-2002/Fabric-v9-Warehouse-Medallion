CREATE TABLE [CustomerOrders_AFI].[OrderCancellationReasonCode]
    (
        [ActiveCode]          CHAR(1)     NULL,
        [ReasonCode]          CHAR(2)     NULL,
        [ReasonDescription]   VARCHAR(25) NULL,
        [MaintainDate]        DECIMAL(8)  NULL,
        [MaintainTime]        DECIMAL(6)  NULL,
        [MaintainUser]        VARCHAR(10) NULL,
        [TrueCancel]          CHAR(1)     NULL,
        [CancelCategory]      VARCHAR(20) NULL,
        [AvailToAshleyDirect] CHAR(1)     NULL,
        [AshleyDirectDesc]    VARCHAR(25) NULL
    );

--  DATA_SOURCE = [AzureStorageGen2a],
--  LOCATION = N'/Wholesale/codis_afi/OrderCancellationReasonCode/AFI_codis_afi_OrderCancellationReasonCode.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],

