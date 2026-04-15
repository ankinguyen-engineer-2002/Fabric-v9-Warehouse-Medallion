CREATE TABLE [SalesHistory_AFI].[OrderHistory] (
    [OrderNumber]          VARCHAR (10)   NOT NULL,
    [CustomerNumber]       CHAR (8)       NOT NULL,
    [ShiptoNumber]         CHAR (4)       NOT NULL,
    [Warehouse]            CHAR (3)       NOT NULL,
    [OrderDate]            DATE           NOT NULL,  --INT
    [ItemSKU]              VARCHAR (15)   NULL,
    [ItemSequence]         INT            NOT NULL,
    [Quantity]             INT            NULL,
    [NetAmount]            DECIMAL (10,2) NOT NULL,  --DECIMAL(12,2)
    [ItemClass]            CHAR (4)       NULL,
    [RequestDate]          DATE           NULL,  --INT
    [OrderChangeTime]      INT            NOT NULL,
    [OrderChangeDate]      DATE           NOT NULL,   --INT
    [ReasonCode]           CHAR (2)       NULL,
    [Freight]              DECIMAL (10,2) NOT NULL, --MONEY
    [HiddenFreight]        DECIMAL (10,2) NOT NULL, --MONEY
    [Discount]             DECIMAL (10,2) NOT NULL, --MONEY
    [OrderArrivalMode]     CHAR (2)       NULL,
    [ChangedByUser]        VARCHAR (10)   NOT NULL,
    [PackageID]            VARCHAR (15)   NULL,
    [CurrencyCode]         CHAR (3)       NULL,
    [ItemStatus]           CHAR (1)       NULL,
    [OrderTypePrimary]     CHAR (1)       NULL,
    [OrderType2]           CHAR (1)       NULL,
    [OrderType3]           CHAR (1)       NULL,
    [OrderType4]           CHAR (1)       NULL
)
