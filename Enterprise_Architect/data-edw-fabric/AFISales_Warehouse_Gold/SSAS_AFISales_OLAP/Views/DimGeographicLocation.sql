CREATE VIEW [SSAS_AFISALES_OLAP].[DimGeographicLocation]
AS
    SELECT
        [Address ID],
        City,
        [State Code],
        [State],
        [Country Code],
        Country,
        Latitude,
        Longitude,
        ZipCode,
        [County Code],
        County,
        [County Fips],
        [Time Zone],
        [Msa Fips Code],
        [Metro Statistical Area],
        [Core Based Statisticsl Area],
        [Default Sales Territory],
        [Designated Marketing Area],
        [MSA VP],
        [Address 1],
        [Address 2],
        [Address 3],
        [Address 4],
        [Address 5],
        [Freight Zone],
        CBSA,
        [CBSA CODE],
        [CBSA Type],
        AddressIDType
    FROM
        AFISales_DW.[DimGeographicLocations];