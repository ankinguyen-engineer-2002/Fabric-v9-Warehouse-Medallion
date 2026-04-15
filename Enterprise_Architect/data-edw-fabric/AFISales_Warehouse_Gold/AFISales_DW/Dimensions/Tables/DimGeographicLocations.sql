CREATE TABLE [AFISales_DW].[DimGeographicLocations] (
    [Address ID]                  INT            NULL,
    [City]                        VARCHAR (35)   NULL,
    [State Code]                  CHAR (2)       NULL,
    [State]                       VARCHAR (25)   NULL,
    [Country Code]                VARCHAR (3)    NULL,
    [Country]                     VARCHAR (30)   NULL,
    [Latitude]                    DECIMAL (8, 4) NULL,
    [Longitude]                   DECIMAL (8, 4) NULL,
    [ZipCode]                     VARCHAR (10)   NULL,
    [County Code]                 CHAR (3)       NULL,
    [County]                      VARCHAR (29)   NULL,
    [County Fips]                 CHAR (5)       NULL,
    [Time Zone]                   VARCHAR (3)    NULL,
    [Msa Fips Code]               CHAR (5)       NULL,
    [Metro Statistical Area]      VARCHAR (50)   NULL,
    [Core Based Statisticsl Area] VARCHAR (50)   NULL,
    [Default Sales Territory]     CHAR (5)       NULL,
    [Designated Marketing Area]   VARCHAR (40)   NULL,
    [MSA VP]                      VARCHAR (25)   NOT NULL,
    [Address 1]                   VARCHAR (35)   NULL,
    [Address 2]                   VARCHAR (35)   NULL,
    [Address 3]                   VARCHAR (35)   NULL,
    [Address 4]                   VARCHAR (35)   NULL,
    [Address 5]                   VARCHAR (35)   NULL,
    [Freight Zone]                CHAR (5)       NULL,
    [CBSA]                        VARCHAR (50)   NULL,
    [CBSA CODE]                   CHAR (5)       NULL,
    [CBSA Type]                   CHAR (5)       NULL,
    [AddressIDType]               CHAR (1)       NULL
)

GO
CREATE STATISTICS [Stat_DimGeographicLocations_ZipCode]
    ON [AFISales_DW].[DimGeographicLocations]([ZipCode]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_State_Code]
    ON [AFISales_DW].[DimGeographicLocations]([State Code]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_County_Code]
    ON [AFISales_DW].[DimGeographicLocations]([County Code]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_Country_Code]
    ON [AFISales_DW].[DimGeographicLocations]([Country Code]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_Address_ID]
    ON [AFISales_DW].[DimGeographicLocations]([Address ID]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_Time_Zone]
    ON [AFISales_DW].[DimGeographicLocations]([Time Zone]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_State]
    ON [AFISales_DW].[DimGeographicLocations]([State]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_MSA_VP]
    ON [AFISales_DW].[DimGeographicLocations]([MSA VP]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_Msa_Fips_Code]
    ON [AFISales_DW].[DimGeographicLocations]([Msa Fips Code]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_Longitude]
    ON [AFISales_DW].[DimGeographicLocations]([Longitude]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_Latitude]
    ON [AFISales_DW].[DimGeographicLocations]([Latitude]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_Freight_Zone]
    ON [AFISales_DW].[DimGeographicLocations]([Freight Zone]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_Designated_Marketing_Area]
    ON [AFISales_DW].[DimGeographicLocations]([Designated Marketing Area]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_Default_Sales_Territory]
    ON [AFISales_DW].[DimGeographicLocations]([Default Sales Territory]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_County]
    ON [AFISales_DW].[DimGeographicLocations]([County]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_Country]
    ON [AFISales_DW].[DimGeographicLocations]([Country]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_Core_Based_Statisticsl_Area]
    ON [AFISales_DW].[DimGeographicLocations]([Core Based Statisticsl Area]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_City]
    ON [AFISales_DW].[DimGeographicLocations]([City]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_CBSA_Type]
    ON [AFISales_DW].[DimGeographicLocations]([CBSA Type]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_CBSA_CODE]
    ON [AFISales_DW].[DimGeographicLocations]([CBSA CODE]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_CBSA]
    ON [AFISales_DW].[DimGeographicLocations]([CBSA]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_AddressIDType]
    ON [AFISales_DW].[DimGeographicLocations]([AddressIDType]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_Address_5]
    ON [AFISales_DW].[DimGeographicLocations]([Address 5]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_Address_4]
    ON [AFISales_DW].[DimGeographicLocations]([Address 4]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_Address_3]
    ON [AFISales_DW].[DimGeographicLocations]([Address 3]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_Address_2]
    ON [AFISales_DW].[DimGeographicLocations]([Address 2]);


GO
CREATE STATISTICS [Stat_DimGeographicLocations_Address_1]
    ON [AFISales_DW].[DimGeographicLocations]([Address 1]);


