CREATE TABLE [MasterData_DW].[DimRetailLocations] (
    [LocationKey]                 VARCHAR (10)   NOT NULL,
    [OperationId]                 DECIMAL (10)   NULL,
    [ProfitCenter]                DECIMAL (4)    NULL,
    [Operation]                   VARCHAR (20)   NULL,
    [EnterpriseOperation]         INT        NULL,
    [CompLocation]                VARCHAR (3)    NULL,
    [EnterpriseLocation]          VARCHAR (50)   NULL,
    [StoreLocation]               VARCHAR (50)   NULL,
    [EnterpriseStore]             VARCHAR (3)    NULL,
    [InternationalStore]          VARCHAR (3)    NULL,
    [ProfitCenterType]            VARCHAR (20)   NULL,
    [CorporateMarket]             VARCHAR (25)   NULL,
    [CorporateRegion]             VARCHAR (25)   NULL,
    [CorporateFinanceGrouping]    VARCHAR (3)    NULL,
    [AFIAccountNumber]            CHAR (8)    NULL,
    [AFIShiptoNumber]             VARCHAR (4)    NULL,
    [AFIAccountName]              VARCHAR (35)   NULL,
    [AFIShiptoName]               VARCHAR (35)   NULL,
    [AddressID]                   INT            NULL,
    [City]                        VARCHAR (39)   NULL,
    [StateCode]                   VARCHAR (2)    NULL,
    [State]                       VARCHAR (25)   NULL,
    [CountryCode]                 VARCHAR (3)    NULL,
    [Country]                     VARCHAR (30)   NULL,
    [Latitude]                    DECIMAL (8, 4) NULL,
    [Longitude]                   DECIMAL (8, 4) NULL,
    [ZipCode]                     VARCHAR (10)   NULL,
    [CountyCode]                  VARCHAR (3)    NULL,
    [Address]                     VARCHAR (130)  NULL,
    [Address1]                    VARCHAR (250)  NULL,
    [Address2]                    VARCHAR (250)  NULL,
    [Address3]                    VARCHAR (250)  NULL,
    [County]                      VARCHAR (30)   NULL,
    [IncludeInHomestoreReporting] VARCHAR (3)    NULL,
    [SoftOpenDate]                DATE           NULL,
    [GrandOpenDate]               DATE           NULL,
    [CloseDate]                   DATE           NULL,
    [HomestoreType]               VARCHAR (20)   NULL,
    [TaxRate]                     DECIMAL (5, 4) NULL,
    [ConvertCogs]                 BIT            NULL,
    [CurrencyType]                VARCHAR (5)    NULL,
    [ShopperTrakLocID]            VARCHAR (9)    NULL,
    [HomesSystem]                 VARCHAR (3)    NULL,
    [DistrictID]                  INT            NULL,
    [RegionType]                  VARCHAR (50)   NULL,
    [DistrictRegionID]            INT            NULL,
    [DistrictNickName]            VARCHAR (50)   NULL,
    [SquareFootage]               INT            NULL,
    [ResponsibleRegion]           VARCHAR (25)   NULL,
    [MetroStatisticalArea]        VARCHAR (50)   NULL,
    [HomestoreOwner]              VARCHAR (100)  NULL,
    [Segment]                     VARCHAR (25)   NULL
)


GO
CREATE STATISTICS [Stat_DimRetailLocations_ZipCode]
    ON [MasterData_DW].[DimRetailLocations]([ZipCode]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_TaxRate]
    ON [MasterData_DW].[DimRetailLocations]([TaxRate]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_StoreLocation]
    ON [MasterData_DW].[DimRetailLocations]([StoreLocation]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_StateCode]
    ON [MasterData_DW].[DimRetailLocations]([StateCode]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_State]
    ON [MasterData_DW].[DimRetailLocations]([State]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_SquareFootage]
    ON [MasterData_DW].[DimRetailLocations]([SquareFootage]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_SoftOpenDate]
    ON [MasterData_DW].[DimRetailLocations]([SoftOpenDate]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_ShopperTrakLocID]
    ON [MasterData_DW].[DimRetailLocations]([ShopperTrakLocID]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_Segment]
    ON [MasterData_DW].[DimRetailLocations]([Segment]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_ResponsibleRegion]
    ON [MasterData_DW].[DimRetailLocations]([ResponsibleRegion]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_RegionType]
    ON [MasterData_DW].[DimRetailLocations]([RegionType]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_ProfitCenterType]
    ON [MasterData_DW].[DimRetailLocations]([ProfitCenterType]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_ProfitCenter]
    ON [MasterData_DW].[DimRetailLocations]([ProfitCenter]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_OperationId]
    ON [MasterData_DW].[DimRetailLocations]([OperationId]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_Operation]
    ON [MasterData_DW].[DimRetailLocations]([Operation]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_MetroStatisticalArea]
    ON [MasterData_DW].[DimRetailLocations]([MetroStatisticalArea]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_Longitude]
    ON [MasterData_DW].[DimRetailLocations]([Longitude]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_LocationKey]
    ON [MasterData_DW].[DimRetailLocations]([LocationKey]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_Latitude]
    ON [MasterData_DW].[DimRetailLocations]([Latitude]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_InternationalStore]
    ON [MasterData_DW].[DimRetailLocations]([InternationalStore]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_IncludeInHomestoreReporting]
    ON [MasterData_DW].[DimRetailLocations]([IncludeInHomestoreReporting]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_HomestoreType]
    ON [MasterData_DW].[DimRetailLocations]([HomestoreType]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_HomestoreOwner]
    ON [MasterData_DW].[DimRetailLocations]([HomestoreOwner]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_HomesSystem]
    ON [MasterData_DW].[DimRetailLocations]([HomesSystem]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_GrandOpenDate]
    ON [MasterData_DW].[DimRetailLocations]([GrandOpenDate]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_EnterpriseStore]
    ON [MasterData_DW].[DimRetailLocations]([EnterpriseStore]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_EnterpriseOperation]
    ON [MasterData_DW].[DimRetailLocations]([EnterpriseOperation]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_EnterpriseLocation]
    ON [MasterData_DW].[DimRetailLocations]([EnterpriseLocation]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_DistrictRegionID]
    ON [MasterData_DW].[DimRetailLocations]([DistrictRegionID]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_DistrictNickName]
    ON [MasterData_DW].[DimRetailLocations]([DistrictNickName]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_DistrictID]
    ON [MasterData_DW].[DimRetailLocations]([DistrictID]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_CurrencyType]
    ON [MasterData_DW].[DimRetailLocations]([CurrencyType]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_CountyCode]
    ON [MasterData_DW].[DimRetailLocations]([CountyCode]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_County]
    ON [MasterData_DW].[DimRetailLocations]([County]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_CountryCode]
    ON [MasterData_DW].[DimRetailLocations]([CountryCode]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_Country]
    ON [MasterData_DW].[DimRetailLocations]([Country]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_CorporateRegion]
    ON [MasterData_DW].[DimRetailLocations]([CorporateRegion]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_CorporateMarket]
    ON [MasterData_DW].[DimRetailLocations]([CorporateMarket]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_CorporateFinanceGrouping]
    ON [MasterData_DW].[DimRetailLocations]([CorporateFinanceGrouping]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_ConvertCogs]
    ON [MasterData_DW].[DimRetailLocations]([ConvertCogs]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_CompLocation]
    ON [MasterData_DW].[DimRetailLocations]([CompLocation]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_CloseDate]
    ON [MasterData_DW].[DimRetailLocations]([CloseDate]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_City]
    ON [MasterData_DW].[DimRetailLocations]([City]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_AFIShiptoNumber]
    ON [MasterData_DW].[DimRetailLocations]([AFIShiptoNumber]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_AFIShiptoName]
    ON [MasterData_DW].[DimRetailLocations]([AFIShiptoName]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_AFIAccountNumber]
    ON [MasterData_DW].[DimRetailLocations]([AFIAccountNumber]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_AFIAccountName]
    ON [MasterData_DW].[DimRetailLocations]([AFIAccountName]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_AddressID]
    ON [MasterData_DW].[DimRetailLocations]([AddressID]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_Address3]
    ON [MasterData_DW].[DimRetailLocations]([Address3]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_Address2]
    ON [MasterData_DW].[DimRetailLocations]([Address2]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_Address1]
    ON [MasterData_DW].[DimRetailLocations]([Address1]);


GO
CREATE STATISTICS [Stat_DimRetailLocations_Address]
    ON [MasterData_DW].[DimRetailLocations]([Address]);

