
CREATE TABLE [Quality_DW].[FactCalculatedColumns] (
    [ItemNo]                 VARCHAR (15)    NOT NULL,
    [SeriesNo]               VARCHAR (16)    NOT NULL,
    [MerchandisingGroup]     VARCHAR (35)    NULL,
    [AS400Description]       VARCHAR (100)   NULL,
    [DescriptionCode]        DECIMAL (4)     NULL,
    [GeneralDescription]     VARCHAR (40)    NULL,
    [IntroductionMarket]     VARCHAR (30)    NULL,
    [Status]                 CHAR (1)        NULL,
    [FinancialDivision]      VARCHAR (30)    NULL,
    [ImportDomestic]         CHAR (1)        NULL,
    [QtyinBox]               DECIMAL (4)     NULL,
    [UnitofMeasure]          CHAR (2)        NULL,
    [Color]                  VARCHAR (25)    NULL,
    [SeriesExclusiveComment] VARCHAR (60)    NULL,
    [ItemExclusiveComment]   VARCHAR (60)    NULL,
    [UPCCode]                DECIMAL (10)    NULL,
    [UPCCheckDigit]          DECIMAL (1)     NULL,
    [StandAloneItem]         CHAR (3)        NOT NULL,
    [ExpressFlag]            CHAR (1)        NULL,
    [VBoardFlag]             CHAR (7)        NULL,
    [CertifiedPack]          CHAR (7)        NULL,
    [PKProductWidth]         DECIMAL (7, 2)  NULL,
    [PKProductDepth]         DECIMAL (7, 2)  NULL,
    [PkProductHeight]        DECIMAL (7, 2)  NULL,
    [PKWidth]                DECIMAL (7, 2)  NULL,
    [PKDepth]                DECIMAL (7, 2)  NULL,
    [PkHeight]               DECIMAL (7, 2)  NULL,
    [PKDimensionsConfirmed]  VARCHAR (10)    NULL,
    [Weight]                 DECIMAL (18)    NULL,
    [CalcLength]             DECIMAL (18)    NULL,
    [CalcWidth]              DECIMAL (18)    NULL,
    [CalcHeight]             DECIMAL (18)    NULL,
    [CalcGirth]              DECIMAL (18)    NULL,
    [LengthGirth]            DECIMAL (18)    NULL,
    [CalcLengthvboard]       DECIMAL (18)    NULL,
    [CalcWidthvboard]        DECIMAL (18)    NULL,
    [CalcHeightvboard]       DECIMAL (18)    NULL,
    [LengthGirthvboard]      DECIMAL (18)    NULL,
    [WeightinLbs]            INT             NULL,
    [Zone2]                  DECIMAL (4, 2)  NULL,
    [Zone3]                  DECIMAL (4, 2)  NULL,
    [Zone4]                  DECIMAL (4, 2)  NULL,
    [Zone5]                  DECIMAL (4, 2)  NULL,
    [Zone6]                  DECIMAL (4, 2)  NULL,
    [Zone7]                  DECIMAL (4, 2)  NULL,
    [Zone8]                  DECIMAL (4, 2)  NULL,
    [Description]            VARCHAR (100)   NULL,
    [VendorStatus]           CHAR (5)        NULL,
    [FinanceDivision]        VARCHAR (100)   NULL,
    [VendorNumber]           CHAR (8)        NULL,
    [VendorName]             VARCHAR (100)   NULL,
    [VendorOffice]           VARCHAR (30)    NULL,
    [VendorSplit]            INT             NULL,
    [DelvInPkg]              CHAR (7)        NULL,
    [AshleyExpFlag]          CHAR (1)        NULL,
    [ExpressItemNo]          VARCHAR (15)    NULL,
    [ReceiptDate]            VARCHAR (50)    NULL,
    [UPSShippablePackage]    VARCHAR (10)    NULL,
    [SkuCode]                VARCHAR (20)    NOT NULL,
    [UPSExpress]             VARCHAR (19)    NOT NULL,
    [AFIUPSExpress]          VARCHAR (19)    NOT NULL,
    [AFIUPSExpressWVBoard]   VARCHAR (19)    NOT NULL,
    [ShippingCharge]         DECIMAL (14, 2) NULL,
    [DNR]                    VARCHAR (50)    NULL,
    [ProductCategory]        VARCHAR (50)    NULL,
    [USChampion]             VARCHAR (64)    NULL,
    [Receipt_Manu_Date]      VARCHAR (30)    NULL
)
;



GO


  

GO
CREATE STATISTICS Stat_FactCalculatedColumns_ItemNo		 ON Quality_DW.FactCalculatedColumns([ItemNo])

GO
CREATE STATISTICS Stat_FactCalculatedColumns_SeriesNo	 ON Quality_DW.FactCalculatedColumns([SeriesNo])