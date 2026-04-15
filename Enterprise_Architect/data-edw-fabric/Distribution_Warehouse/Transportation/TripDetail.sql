CREATE TABLE [Transportation].[TripDetail]        
    (
        [TripNumber]      NUMERIC(5)     NOT NULL,
        [DropNumber]      NUMERIC(2)     NOT NULL,
        [OrderNumber]     CHAR(7)        NOT NULL,
        [ItemSequence]    NUMERIC(7)     NOT NULL,
        [ItemSKU]         CHAR(15)       NOT NULL,
        [ItemDescription] CHAR(20)       NOT NULL,
        [CommanItemSKU]   CHAR(15)       NOT NULL,
        [InvoiceNumber]   NUMERIC(9)     NOT NULL,
        [ReferenceNumber] NUMERIC(6)     NOT NULL,
        [CustomerNumber]  NUMERIC(8)     NOT NULL,
        [ControlNumber]   NUMERIC(7)     NOT NULL,
        [ItemClass]       CHAR(4)        NOT NULL,
        [CommodityClass]  CHAR(5)        NOT NULL,
        [TotalQuantity]   NUMERIC(5)     NOT NULL,
        [TotalCubes]      NUMERIC(10, 2) NOT NULL,
        [TotalWeight]     NUMERIC(10, 2) NOT NULL,
        [AddbyUser]       CHAR(10)       NOT NULL,
        [AddedDate]       DATE           NULL, -- NUMERIC(8)     NOT NULL,
        [AddedTime]       NUMERIC(6)     NOT NULL,
        [AddedByProgram]  CHAR(10)       NOT NULL
    );

GO
CREATE STATISTICS [Stat_TripDetail_TripNumber]
    ON [Transportation].[TripDetail]
    (
        [TripNumber]
    );


GO
CREATE STATISTICS [Stat_TripDetail_OrderNumber]
    ON [Transportation].[TripDetail]
    (
        [OrderNumber]
    );


GO
CREATE STATISTICS [Stat_TripDetail_ItemSKU]
    ON [Transportation].[TripDetail]
    (
        [ItemSKU]
    );


GO
CREATE STATISTICS [Stat_TripDetail_ItemSequence]
    ON [Transportation].[TripDetail]
    (
        [ItemSequence]
    );


GO
CREATE STATISTICS [Stat_TripDetail_InvoiceNumber]
    ON [Transportation].[TripDetail]
    (
        [InvoiceNumber]
    );


GO
CREATE STATISTICS [Stat_TripDetail_DropNumber]
    ON [Transportation].[TripDetail]
    (
        [DropNumber]
    );

