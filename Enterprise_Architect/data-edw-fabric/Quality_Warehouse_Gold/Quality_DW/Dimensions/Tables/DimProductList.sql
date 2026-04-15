CREATE TABLE [Quality_DW].[DimProductList]
    (
        [ItemNo]                 [VARCHAR](15)    NOT NULL,
        [SeriesNo]               [VARCHAR](16)    NOT NULL,
        [MerchandisingGroup]     [VARCHAR](35)    NULL,
        [AS400Description]       [VARCHAR](100)   NULL,
        [DescriptionCode]        DECIMAL(4, 0)  NULL,
        [GeneralDescription]     [VARCHAR](40)    NULL,
        [IntroductionMarket]     [VARCHAR](30)    NULL,
        [Status]                 [CHAR](1)        NULL,
        [FinancialDivision]      [VARCHAR](30)    NULL,
        [ImportDomestic]         [CHAR](1)        NULL,
        [QtyinBox]               DECIMAL(4, 0)  NULL,
        [UnitofMeasure]          [CHAR](2)        NULL,
        [Color]                  [VARCHAR](25)    NULL,
        [SeriesExclusiveComment] [VARCHAR](60)    NULL,
        [ItemExclusiveComment]   [VARCHAR](60)    NULL,
        [UPCCode]                DECIMAL(10, 0) NULL,
        [UPCCheckDigit]          DECIMAL(1, 0)  NULL,
        [StandAloneItem]         [CHAR](3)        NOT NULL,
        [ExpressFlag]            [CHAR](1)        NULL,
        [VBoardFlag]             CHAR(7)          NULL,
        [UPSShippablePackage]    [CHAR](3)        NOT NULL,
        [PKProductWidth]         DECIMAL(7, 2)  NULL,
        [PKProductDepth]         DECIMAL(7, 2)  NULL,
        [PkProductHeight]        DECIMAL(7, 2)  NULL,
        [PKWidth]                DECIMAL(7, 2)  NULL,
        [PKDepth]                DECIMAL(7, 2)  NULL,
        [PkHeight]               DECIMAL(7, 2)  NULL,
        [PKDimensionsConfirmed]  [BIT]            NOT NULL,
        [Weight]                 DECIMAL(18, 0) NULL,
        [CalcLength]             DECIMAL(18, 0) NULL,
        [CalcWidth]              DECIMAL(18, 0) NULL,
        [CalcHeight]             DECIMAL(18, 0) NULL,
        [LengthGirth]            DECIMAL(18, 0) NULL,
        [CalcLengthvboard]       DECIMAL(18, 0) NULL,
        [CalcWidthvboard]        DECIMAL(18, 0) NULL,
        [CalcHeightvboard]       DECIMAL(18, 0) NULL,
        [LengthGirthvboard]      DECIMAL(18, 0) NULL
    )

GO

CREATE STATISTICS [Stat_DimProductList_ItemNo]
    ON Quality_DW.[DimProductList]
    (
        [ItemNo]
    );
GO

CREATE STATISTICS [Stat_DimProductList_SeriesNo]
    ON Quality_DW.[DimProductList]
    (
        [SeriesNo]
    );

GO
CREATE STATISTICS [Stat_DimProductList_Status]
    ON Quality_DW.[DimProductList]
    (
        [Status]
    );
GO
CREATE STATISTICS [Stat_DimProductList_FinancialDivision]
    ON Quality_DW.[DimProductList]
    (
        [FinancialDivision]
    );
GO
