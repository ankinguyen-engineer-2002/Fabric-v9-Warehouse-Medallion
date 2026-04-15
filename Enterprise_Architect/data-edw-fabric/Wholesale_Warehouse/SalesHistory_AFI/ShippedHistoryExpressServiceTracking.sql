CREATE TABLE [SalesHistory_AFI].[ShippedHistoryExpressServiceTracking] (
    [InvoiceNumber]              DECIMAL (9)    NOT NULL,
    [OrderNumber]                VARCHAR (10)   NOT NULL,
    [ItemSequence]               DECIMAL (7)    NOT NULL,
    [ItemNumber]                 VARCHAR (15)   NOT NULL,
    [InvoiceDate]                DATE           NOT NULL,
    [CustomerNumber]             CHAR (8)       NULL,
    [ShiptoNumber]               CHAR (4)       NULL,
    [TrackingSequenceNumber]     INT            NULL,
    [TrackingNumber]             VARCHAR (40)   NULL,
    [Carrier]                    VARCHAR (15)   NULL,
    [DeliveryMethodServiceLevel] VARCHAR (10)   NULL,
    [SerialNumber]               VARCHAR (15)   NULL,
    [FreightCharge]              DECIMAL (7, 2) NULL
)



