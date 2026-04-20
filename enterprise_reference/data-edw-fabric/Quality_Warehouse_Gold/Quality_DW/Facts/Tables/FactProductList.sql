CREATE TABLE [Quality_DW].[FactProductList] (
    [ItemNo]                VARCHAR (15)   NOT NULL,
    [SeriesNo]              VARCHAR (16)   NOT NULL,
    [QtyinBox]              DECIMAL (4)    NULL,
    [PKProductWidth]        DECIMAL (7, 2) NULL,
    [PKProductDepth]        DECIMAL (7, 2) NULL,
    [PkProductHeight]       DECIMAL (7, 2) NULL,
    [PKWidth]               DECIMAL (7, 2) NULL,
    [PKDepth]               DECIMAL (7, 2) NULL,
    [PkHeight]              DECIMAL (7, 2) NULL,
    [PKDimensionsConfirmed] BIT            NOT NULL,
    [Weight]                DECIMAL (18)   NULL,
    [CalcLength]            DECIMAL (18)   NULL,
    [CalcWidth]             DECIMAL (18)   NULL,
    [CalcHeight]            DECIMAL (18)   NULL,
    [LengthGirth]           DECIMAL (18)   NULL,
    [CalcLengthvboard]      DECIMAL (18)   NULL,
    [CalcWidthvboard]       DECIMAL (18)   NULL,
    [CalcHeightvboard]      DECIMAL (18)   NULL,
    [LengthGirthvboard]     DECIMAL (18)   NULL,
    [ItemExclusiveComment]  VARCHAR (60)   NULL,
    [UPCCode]               DECIMAL (10)   NULL,
    [UPCCheckDigit]         DECIMAL (1)    NULL,
    [StandAloneItem]        CHAR (3)       NOT NULL,
    [ExpressFlag]           CHAR (1)       NULL,
    [VBoardFlag]            CHAR (7)       NULL,
    [UPSShippablePackage]   CHAR (3)       NOT NULL,
    [IntroductionMarket]    VARCHAR (50)   NULL
)
GO


CREATE STATISTICS [Stat_FactProductList_ItemNo]
    ON [Quality_DW].[FactProductList]([ItemNo]);
GO

CREATE STATISTICS [Stat_FactProductList_QtyinBox]
    ON [Quality_DW].[FactProductList]([QtyinBox]);
GO

CREATE STATISTICS [Stat_FactProductList_SeriesNo]
    ON [Quality_DW].[FactProductList]([SeriesNo]);
GO

