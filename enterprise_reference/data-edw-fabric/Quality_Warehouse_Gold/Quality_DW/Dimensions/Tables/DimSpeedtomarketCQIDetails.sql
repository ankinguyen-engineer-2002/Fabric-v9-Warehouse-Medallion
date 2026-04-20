CREATE TABLE Quality_DW.DimSpeedtomarketCQIDetails
    (
        [Financial Division]  VARCHAR(30) NULL,
        [Item Class Code]     VARCHAR(25) NULL,
        [Item Class Name]     VARCHAR(25) NULL,
        [Item SKU]            VARCHAR(15) NOT NULL,
        [Series]              VARCHAR(16) NULL,
        [Status]              VARCHAR(1)  NULL,
        [Market Introduction] VARCHAR(30) NULL,
        [Market Date]         DATE        NULL,
        [GO Date]             DATE        NULL,
        [First ETD]           DATE        NULL,
        [Original ETD]        DATE        NULL,
        [Current ETD]         DATE        NULL,
        [First Receipt Date]  DATE        NULL,
        [Manufacture Date]    DATE        NULL,
        [Vendor Number]       CHAR(8)     NULL,
        [Vendor]              VARCHAR(30) NULL,
        [Office]              VARCHAR(15) NULL
    );

    GO

CREATE STATISTICS Stat_DimSpeedtomarketCQIDetails_Vendor_Number
    ON Quality_DW.DimSpeedtomarketCQIDetails
    (
        [Vendor Number]
    );
GO
CREATE STATISTICS Stat_DimSpeedtomarketCQIDetails_Financial_Division
    ON Quality_DW.DimSpeedtomarketCQIDetails
    (
        [Financial Division]
    );
GO
CREATE STATISTICS Stat_DimSpeedtomarketCQIDetails_Item_Class_Code
    ON Quality_DW.DimSpeedtomarketCQIDetails
    (
        [Item Class Code]
    );
GO
CREATE STATISTICS Stat_DimSpeedtomarketCQIDetails_Item_Class_Name
    ON Quality_DW.DimSpeedtomarketCQIDetails
    (
        [Item Class Name]
    );
GO
CREATE STATISTICS Stat_DimSpeedtomarketCQIDetails_Series
    ON Quality_DW.DimSpeedtomarketCQIDetails
    (
        [Series]
    );
GO
CREATE STATISTICS Stat_DimSpeedtomarketCQIDetails_Status
    ON Quality_DW.DimSpeedtomarketCQIDetails
    (
        [Status]
    );
GO
CREATE STATISTICS Stat_DimSpeedtomarketCQIDetails_Market_Introduction
    ON Quality_DW.DimSpeedtomarketCQIDetails
    (
        [Market Introduction]
    );
GO
CREATE STATISTICS Stat_DimSpeedtomarketCQIDetails_Market_Date
    ON Quality_DW.DimSpeedtomarketCQIDetails
    (
        [Market Date]
    );
GO
CREATE STATISTICS Stat_DimSpeedtomarketCQIDetails_GO_Date
    ON Quality_DW.DimSpeedtomarketCQIDetails
    (
        [GO Date]
    );
GO
CREATE STATISTICS Stat_DimSpeedtomarketCQIDetails_First_ETD
    ON Quality_DW.DimSpeedtomarketCQIDetails
    (
        [First ETD]
    );
GO
CREATE STATISTICS Stat_DimSpeedtomarketCQIDetails_Original_ETD
    ON Quality_DW.DimSpeedtomarketCQIDetails
    (
        [Original ETD]
    );
GO
CREATE STATISTICS Stat_DimSpeedtomarketCQIDetails_Current_ETD
    ON Quality_DW.DimSpeedtomarketCQIDetails
    (
        [Current ETD]
    );
GO
CREATE STATISTICS Stat_DimSpeedtomarketCQIDetails_First_Receipt_Date
    ON Quality_DW.DimSpeedtomarketCQIDetails
    (
        [First Receipt Date]
    );
GO
CREATE STATISTICS Stat_DimSpeedtomarketCQIDetails_Manufacture_Date
    ON Quality_DW.DimSpeedtomarketCQIDetails
    (
        [Manufacture Date]
    );
GO
CREATE STATISTICS Stat_DimSpeedtomarketCQIDetails_Vendor
    ON Quality_DW.DimSpeedtomarketCQIDetails
    (
        [Vendor]
    );
GO
CREATE STATISTICS Stat_DimSpeedtomarketCQIDetails_Office
    ON Quality_DW.DimSpeedtomarketCQIDetails
    (
        [Office]
    );
GO

