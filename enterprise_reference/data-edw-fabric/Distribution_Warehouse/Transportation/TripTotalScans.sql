CREATE TABLE [Transportation].[TripTotalScans]
    (
        [ReasonCode]               CHAR(1)    NOT NULL,
        [TripNumber]               NUMERIC(5) NOT NULL,
        [DropNumber]               NUMERIC(2) NOT NULL,
        [OrderNumber]              CHAR(7)    NOT NULL,
        [ItemSequence]             NUMERIC(7) NOT NULL,
        [ItemSKU]                  CHAR(15)   NOT NULL,
        [ReferenceNumber]          NUMERIC(6) NOT NULL,
        [QuanityScannedWithTag]    NUMERIC(5) NOT NULL,
        [QuanityScannedWithoutTag] NUMERIC(5) NOT NULL
    );

