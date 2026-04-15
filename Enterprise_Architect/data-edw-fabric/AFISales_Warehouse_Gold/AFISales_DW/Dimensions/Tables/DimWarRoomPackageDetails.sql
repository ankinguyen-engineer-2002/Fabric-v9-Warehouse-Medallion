CREATE TABLE [AFISales_DW].[DimWarRoomPackageDetails] (
    [War Room Package ID]            VARCHAR (15)    NULL,
    [Item Number]                    VARCHAR (15)    NULL,
    [Package Description]            VARCHAR (60)    NULL,
    [Template ID]                    VARCHAR (15)    NULL,
    [Package Detail]                 VARCHAR (60)    NULL,
    [Package Series Number]          VARCHAR (16)    NULL,
    [Item Merch Grid Override Photo] VARCHAR (8000)  NULL,
    [Package Image]                  VARCHAR (8000)  NULL,
    [FOB Arcadia]                    DECIMAL (9, 2)  NULL,
    [ABC Code]                       CHAR (1)        NULL,
    [Logility Status]                CHAR (1)        NULL,
    [Trend Arrow]                    VARCHAR (20)    NULL,
    [Series Margin FOB]              DECIMAL (9, 2)  NULL,
    [Series Margin Current]          DECIMAL (9, 2)  NULL,
    [Series Margin Actual]           DECIMAL (9, 2)  NULL,
    [Monthly Totals for]             VARCHAR (30)    NULL,
    [GMROI]                          DECIMAL (8, 1)  NULL,
    [Profit Cnt His]                 DECIMAL (12, 4) NULL,
    [Profit Cnt Pro]                 NUMERIC (10)    NULL,
    [Profit Cnt His Std]             DECIMAL (12, 4) NULL,
    [Profit Cnt Pro Std]             NUMERIC (10)    NULL,
    [Profit Cnt His Act]             DECIMAL (21, 4) NULL,
    [Profit Cnt Pro Act]             NUMERIC (10)    NULL,
    [Logility Month Ave His]         DECIMAL (12, 4) NULL,
    [Logility Month Ave Pro]         DECIMAL (12, 4) NULL,
    [Logility Month Ave His Dol]     DECIMAL (12, 4) NULL,
    [Logility Month Ave Pro Dol]     DECIMAL (12, 4) NULL,
    [Item AVG]                       NUMERIC (5)     NULL,
    [Item STD]                       NUMERIC (8, 2)  NULL,
    [Item ACT]                       NUMERIC (8, 2)  NULL,
    [Rental Acct]                    VARCHAR (3)     NULL,
    [Rental]                         INT         NULL,
    [Source]                         VARCHAR (1)     NULL,
    [Ret Pr Pt]                      INT             NULL,
    [Min MU]                         INT             NULL,
    [Ret MU]                         INT             NULL,
    [package Type]                   CHAR (2)        NULL,
    [War Room Key Item]              INT             NULL,
    [Amount Returned]                NUMERIC (4, 1)  NULL,
    [Forecast Result1]               DECIMAL (9)     NULL,
    [Forecast Result2]               DECIMAL (9)     NULL,
    [Forecast Result3]               DECIMAL (9)     NULL,
    [Forecast Result4]               DECIMAL (9)     NULL,
    [Forecast Result5]               DECIMAL (9)     NULL,
    [Forecast Result6]               DECIMAL (9)     NULL,
    [Forecast Result7]               DECIMAL (9)     NULL,
    [Forecast Result8]               DECIMAL (9)     NULL,
    [Forecast Result9]               DECIMAL (9)     NULL,
    [Forecast Result10]              DECIMAL (9)     NULL,
    [Forecast Result11]              DECIMAL (9)     NULL,
    [Forecast Result12]              DECIMAL (9)     NULL,
    [Dollars]                        DECIMAL (12, 2) NULL,
    [FOB price]                      NUMERIC (5)     NULL,
    [Quantity Returned]              NUMERIC (4, 1)  NULL,
    [Discounted]                     NUMERIC (4, 1)  NULL,
    [FOB]                            NUMERIC (3)     NULL,
    [ACT]                            NUMERIC (3)     NULL,
    [Package Item Flag]              VARCHAR (1)     NULL,
    [Package FOB Arcadia Price]      DECIMAL (12, 3) NULL,
    [Package Series Name]            VARCHAR (100)   NULL,
    [Series Item Flag]               INT             NULL
)

GO
CREATE STATISTICS [Stat_DimmWarRoomPackageDetails_PackageID]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([War Room Package ID]);


GO
CREATE STATISTICS [Stat_DimmWarRoomPackageDetails_ItemNumber]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Item Number]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_War_Room_Key_Item]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([War Room Key Item]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Trend_Arrow]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Trend Arrow]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Template_ID]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Template ID]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Source]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Source]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Series_Margin_FOB]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Series Margin FOB]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Series_Margin_Current]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Series Margin Current]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Series_Margin_Actual]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Series Margin Actual]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Series_Item_Flag]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Series Item Flag]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Ret_Pr_Pt]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Ret Pr Pt]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Ret_MU]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Ret MU]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Rental_Acct]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Rental Acct]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Rental]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Rental]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Quantity_Returned]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Quantity Returned]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Profit_Cnt_Pro_Std]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Profit Cnt Pro Std]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Profit_Cnt_Pro_Act]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Profit Cnt Pro Act]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Profit_Cnt_Pro]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Profit Cnt Pro]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Profit_Cnt_His_Std]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Profit Cnt His Std]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Profit_Cnt_His_Act]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Profit Cnt His Act]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Profit_Cnt_His]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Profit Cnt His]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_package_Type]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([package Type]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Package_Series_Number]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Package Series Number]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Package_Series_Name]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Package Series Name]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Package_Item_Flag]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Package Item Flag]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Package_Image]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Package Image]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Package_FOB_Arcadia_Price]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Package FOB Arcadia Price]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Package_Detail]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Package Detail]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Package_Description]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Package Description]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Monthly_Totals_for]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Monthly Totals for]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Min_MU]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Min MU]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Logility_Status]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Logility Status]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Logility_Month_Ave_Pro_Dol]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Logility Month Ave Pro Dol]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Logility_Month_Ave_Pro]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Logility Month Ave Pro]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Logility_Month_Ave_His_Dol]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Logility Month Ave His Dol]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Logility_Month_Ave_His]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Logility Month Ave His]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Item_STD]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Item STD]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Item_Number]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Item Number]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Item_Merch_Grid_Override_Photo]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Item Merch Grid Override Photo]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Item_AVG]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Item AVG]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Item_ACT]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Item ACT]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_GMROI]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([GMROI]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Forecast_Result9]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Forecast Result9]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Forecast_Result8]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Forecast Result8]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Forecast_Result7]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Forecast Result7]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Forecast_Result6]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Forecast Result6]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Forecast_Result5]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Forecast Result5]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Forecast_Result4]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Forecast Result4]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Forecast_Result3]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Forecast Result3]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Forecast_Result2]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Forecast Result2]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Forecast_Result12]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Forecast Result12]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Forecast_Result11]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Forecast Result11]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Forecast_Result10]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Forecast Result10]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Forecast_Result1]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Forecast Result1]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_FOB_price]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([FOB price]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_FOB_Arcadia]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([FOB Arcadia]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_FOB]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([FOB]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Dollars]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Dollars]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Discounted]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Discounted]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_Amount_Returned]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([Amount Returned]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_ACT]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([ACT]);


GO
CREATE STATISTICS [Stat_DimWarRoomPackageDetails_ABC_Code]
    ON [AFISales_DW].[DimWarRoomPackageDetails]([ABC Code]);

