CREATE TABLE [Quality_AFI].[ReplacementPartDetail]
    (
        [RPKey]                 NUMERIC(7)    NOT NULL,
        [ItemSequence]          DECIMAL(2)    NOT NULL,
        [ItemSKU]               VARCHAR(15)   NULL,
        [ComponentOverrideFlag] CHAR(1)       NULL,
        [Quantity]              DECIMAL(4)    NULL,
        [StandardCost]          DECIMAL(6, 2) NULL,
        [BasePrice]             DECIMAL(6, 2) NULL,
        [ShippedFlag]           CHAR(1)       NULL,
        [PickFlag]              CHAR(1)       NULL,
        [PickBad]               CHAR(8)       NULL,
        [PickDate]              DATE          NULL, --Decimal
        [PickTime]              DECIMAL(6)    NULL,
        [PickUser]              VARCHAR(10)   NULL,
        [ChargeType]            CHAR(1)       NULL,
        [ShippingCost]          DECIMAL(6, 2) NULL
    );

GO
CREATE STATISTICS [Stat_ReplacementPartDetails_StandardCost]
    ON [Quality_AFI].[ReplacementPartDetail]
    (
        [StandardCost]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartDetails_ShippedFlag]
    ON [Quality_AFI].[ReplacementPartDetail]
    (
        [ShippedFlag]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartDetails_RPKey]
    ON [Quality_AFI].[ReplacementPartDetail]
    (
        [RPKey]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartDetails_Quantity]
    ON [Quality_AFI].[ReplacementPartDetail]
    (
        [Quantity]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartDetails_PickUser]
    ON [Quality_AFI].[ReplacementPartDetail]
    (
        [PickUser]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartDetails_PickTime]
    ON [Quality_AFI].[ReplacementPartDetail]
    (
        [PickTime]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartDetails_PickFlag]
    ON [Quality_AFI].[ReplacementPartDetail]
    (
        [PickFlag]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartDetails_PickDate]
    ON [Quality_AFI].[ReplacementPartDetail]
    (
        [PickDate]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartDetails_PickBad]
    ON [Quality_AFI].[ReplacementPartDetail]
    (
        [PickBad]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartDetails_ItemSequence]
    ON [Quality_AFI].[ReplacementPartDetail]
    (
        [ItemSequence]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartDetails_ItemSKU]
    ON [Quality_AFI].[ReplacementPartDetail]
    (
        [ItemSKU]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartDetails_ComponentOverrideFlag]
    ON [Quality_AFI].[ReplacementPartDetail]
    (
        [ComponentOverrideFlag]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartDetails_ShippingCost]
    ON [Quality_AFI].[ReplacementPartDetail]
    (
        [ShippingCost]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartDetails_ChargeType]
    ON [Quality_AFI].[ReplacementPartDetail]
    (
        [ChargeType]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartDetails_BasePrice]
    ON [Quality_AFI].[ReplacementPartDetail]
    (
        [BasePrice]
    );

