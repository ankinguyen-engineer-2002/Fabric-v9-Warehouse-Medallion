CREATE TABLE [Quality_DW].[DimNotRecommendedExpress]
    (
        [ItemNumber]                           VARCHAR(15)  NULL,
        [FinancialDivision]                    VARCHAR(100) NULL,
        [Office]                               VARCHAR(20)  NULL,
        [Vendor]                               VARCHAR(15)  NULL,
        [USChampion]                           VARCHAR(100) NULL,
        [GeneralDescription]                   VARCHAR(100) NULL,
        [IntroductionMarket]                   VARCHAR(100) NULL,
        [SumofShippingCharge]                  VARCHAR(30)  NULL,
        [Status]                               VARCHAR(5)   NULL,
        [ReceiptDate]                          VARCHAR(50)  NULL,
        [AfiUpsExpress]                        VARCHAR(30)  NULL,
        [AfiUpsExpressVBoard]                  VARCHAR(30)  NULL,
        [UpsExpress]                           VARCHAR(30)  NULL,
        [StandAloneItem]                       VARCHAR(50)  NULL,
        [DirectExpressRecommendation]          VARCHAR(50)  NULL,
        [AshleyExpFlag]                        VARCHAR(10)  NULL,
        [SumofLengthandGirth]                  VARCHAR(20)  NULL,
        [SumofCalcLengthvboard]                VARCHAR(20)  NULL,
        [SumofCalcWidthvboard]                 VARCHAR(20)  NULL,
        [SumofCalcHeightvboard]                VARCHAR(20)  NULL,
        [SumofLengthandGirthvboard]            VARCHAR(20)  NULL,
        [UPSShippablePackage]                  VARCHAR(20)  NULL,
        [Literal]                              VARCHAR(10)  NULL,
        [SumofQuality_FOBAmountShipped6months] VARCHAR(15)  NULL,
        [SumofQuality_ShippedQty6months]       [INT]          NULL,
        [DeliverinPackage_DelvInPkg]           VARCHAR(20)  NULL
    );


