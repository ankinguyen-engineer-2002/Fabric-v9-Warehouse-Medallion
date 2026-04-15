CREATE VIEW AFISales_DW_Wrk.v_DimGeographicLocations
AS
    SELECT  DISTINCT
            AddressMaster.AddressID                                             AS [Address ID],
            AddressMaster.City                                                  AS City,    --trim
            AddressMaster.State                                                 AS [State Code],   --cast
            ISNULL(StateMaster.Description, 'N/A')                              AS [State],    --trim
            AddressMaster.Country                                               AS [Country Code],  --trim
            ISNULL(CountryMaster.Description, 'N/A')                            AS [Country],
            AddressMaster.GeocodeLatitude                                       AS Latitude,
            AddressMaster.GeocodeLongitude                                      AS Longitude,
            AddressMaster.ZipCode                                               AS ZipCode,   --Trim
            AddressMaster.CountyCode                                            AS [County Code],  --Trim
            ISNULL(CountyMaster.County, 'N/A') + CASE
                                                    WHEN ISNULL(CountyMaster.County, '') = ''
                                                        THEN
                                                        ''
                                                    ELSE
                                                        ', '
                                                END + AddressMaster.State       AS [County],         --Trim
            CountyMaster.CountyFips                                             AS [County Fips],    --Trim
            AddressMaster.TimeZone                                              AS [Time Zone],      --Trim

            CASE
                WHEN CountyMaster.CBSAType = 'Metro'
                    THEN
                    CountyMaster.CBSACode
                ELSE
                    NULL
            END                                                                 AS [Msa Fips Code],
            ISNULL(MSAMaster.Description, 'N/A')                                AS [Metro Statistical Area],  --Trim
            CASE
                WHEN CountyMaster.CBSAType = 'Metro'
                    THEN
                    CountyMaster.CBSAName
                ELSE
                    NULL
            END                                                                 AS [Core Based Statisticsl Area],
            COALESCE(CountyMaster.TerritoryCode, DefaultTerritory, 'N/A')       AS [Default Sales Territory],  --Cast, Trim
            ISNULL(CountyMaster.DMAName, 'N/A')                                 AS [Designated Marketing Area],    --Trim
            ISNULL(Regions.VPDesc, 'N/A')                                       AS [MSA VP],
            AddressMaster.Address1                                              AS [Address 1],
            AddressMaster.Address2                                              AS [Address 2],
            AddressMaster.Address3                                              AS [Address 3],
            AddressMaster.Address4                                              AS [Address 4],
            AddressMaster.Address5                                              AS [Address 5],
            ISNULL(FreightZones.FreightZone, 'N/A')                             AS [Freight Zone],  --cast,trim
            CountyMaster.CBSAName                                               AS [CBSA],
            CountyMaster.CBSACode                                               AS [CBSA CODE],
            CountyMaster.CBSAType                                               AS [CBSA Type],
            CAST('A' AS CHAR(1))                                                AS AddressIDType
    FROM
            [$(Wholesale_Warehouse)].PartyContacts.AddressMaster
        LEFT JOIN
            [$(MasterData_Warehouse)].[GeographicData].StateMaster
                ON AddressMaster.State = StateMaster.State
                   AND AddressMaster.Country = StateMaster.Country
        LEFT JOIN
            [$(MasterData_Warehouse)].[GeographicData].CountryMaster
                ON CountryMaster.Country = AddressMaster.Country
        LEFT JOIN
            [$(MasterData_Warehouse)].[GeographicData].MSAMaster
                ON MSAMaster.FIPS = AddressMaster.MSA_FIPS
        LEFT JOIN
            [$(MasterData_Warehouse)].[GeographicData].CountyMaster
                ON CountyMaster.CountyCode = AddressMaster.CountyCode
                   AND CountyMaster.[State] = AddressMaster.[State]
                   AND CountyMaster.Country = AddressMaster.Country
        LEFT JOIN
            (
                SELECT
                    MAX(   CASE
                               WHEN CAST([Shipto Sales Territory] AS INT) = 0
                                   THEN
                                   [Primary Sales Territory]
                               ELSE
                                   [Shipto Sales Territory]
                           END
                       )               AS DefaultTerritory,
                    [Store Address ID] AS cslBuyerAddressID
                FROM
                    AFISales_DW.DimCustomers
                GROUP BY
                    [Store Address ID]
            )                      t1
                ON AddressMaster.AddressID = cslBuyerAddressID
        LEFT JOIN
            [$(Wholesale_Warehouse)].Marketing.Regions
                ON CountyMaster.ResponsibleRegion = Regions.RegionCode
        LEFT JOIN
            [$(Wholesale_Warehouse)].Pricing_AFI.FreightZones
                ON FreightZones.Country = AddressMaster.Country
                   AND FreightZones.State = AddressMaster.State
                   AND FreightZones.ZipCode = SUBSTRING(AddressMaster.ZipCode, 1, 5)
    UNION ALL
    SELECT
            CountyMaster.CountyFips                         AS [Address ID],
            ''                                              AS [City],
            StateMaster.State                               AS [State Code],   --Cast
            ISNULL(StateMaster.Description, 'N/A')          AS [State],    --trim
            'USA'                                           AS [Country Code],
            'United States'                                 AS [Country],
            0                                               AS Latitude,
            0                                               AS Longitude,
            ''                                              AS ZipCode,
            CountyMaster.CountyCode                         AS [County Code],  -- cast, trim
            ISNULL(RTRIM(CountyMaster.County), 'N/A') + CASE
                                                          WHEN ISNULL(CountyMaster.County, '') = ''
                                                              THEN
                                                              ''
                                                          ELSE
                                                              ', '
                                                      END + StateMaster.State
                                                            AS [County],   --cast, trim
            CountyMaster.CountyFips                         AS [County Fips],   --cast
            ''                                              AS [Time Zone],
            CASE
                WHEN CountyMaster.CBSAType = 'Metro'
                    THEN
                     CountyMaster.CBSACode
                ELSE
                    NULL
            END                                             AS [Msa Fips Code],
            ISNULL(MSAMaster.Description, 'N/A')            AS [Metro Statistical Area],  --trim
            CASE
                        WHEN CountyMaster.CBSAType = 'Metro'
                            THEN
                            CountyMaster.CBSAName
                        ELSE
                            NULL
                    END                                     AS [Core Based Statisticsl Area],  --trim
            ISNULL(CountyMaster.TerritoryCode, 'N/A')       AS [Default Sales Territory],   -- cast, trim
            TRIM(CountyMaster.DMAName)                      AS [Designated Marketing Area],
            ISNULL(Regions.VPDesc, 'N/A')                   AS [MSA VP],
            ''                                              AS [Address 1],
            ''                                              AS [Address 2],
            ''                                              AS [Address 3],
            ''                                              AS [Address 4],
            ''                                              AS [Address 5],
            ISNULL(FreightZones.FreightZone, 'N/A')         AS [Freight Zone],   --cast,trim
            CountyMaster.CBSAName                           AS [CBSA],
            CountyMaster.CBSACode                           AS [CBSA CODE],
            CountyMaster.CBSAType                           AS [CBSA Type],
            CAST('C' AS CHAR(1))                            AS AddressIDType
    FROM
            [$(MasterData_Warehouse)].[GeographicData].CountyMaster
        LEFT JOIN
            [$(MasterData_Warehouse)].[GeographicData].MSAMaster
                ON MSAMaster.FIPS = CountyMaster.MSA_FIPS
        JOIN
            [$(MasterData_Warehouse)].[GeographicData].StateMaster
                ON StateMaster.State = CountyMaster.State
                   AND StateMaster.Country = CountyMaster.Country
        LEFT JOIN
            [$(Wholesale_Warehouse)].Marketing.Regions
                ON CountyMaster.ResponsibleRegion = Regions.RegionCode
        LEFT JOIN
            [$(Wholesale_Warehouse)].Pricing_AFI.FreightZones
                ON FreightZones.Country = 'USA'
                   AND FreightZones.State = StateMaster.State
                   AND FreightZones.ZipCode = ''
    WHERE
            StateMaster.Country = 'USA'
            AND StateMaster.State_FIPS > 0
    UNION ALL
    --- add in placeholder for unknown counties in Potential measure
    SELECT
        0                      AS [Address ID],
        ''                     AS [City],
        CAST('' AS CHAR(2))    AS [State Code],
        'N/A'                  AS [State],
        ''                     AS [Country Code],
        'N/A'                  AS [Country],
        0                      AS Latitude,
        0                      AS Longitude,
        ''                     AS ZipCode,
        CAST('' AS CHAR(3))    AS [County Code],
        'N/A'                  AS [County],
        CAST(NULL AS CHAR(5))  AS [County Fips],
        ''                     AS [Time Zone],
        NULL                   AS [MSA Fips Code],
        'N/A'                  AS [Metro Statistical Area],
        NULL                   AS [Core Based Statisticsl Area],
        CAST('N/A' AS CHAR(5)) AS [Default Sales Territory],
        NULL                   AS [Designated Marketing Area],
        'N/A'                  AS [MSA VP],
        ''                     AS [Address 1],
        ''                     AS [Address 2],
        ''                     AS [Address 3],
        ''                     AS [Address 4],
        ''                     AS [Address 5],
        CAST('N/A' AS CHAR(5)) AS [Freight Zone],
        NULL                   AS [CBSA],
        NULL                   AS [CBSA CODE],
        NULL                   AS [CBSA Type],
        CAST('C' AS CHAR(1))   AS AddressIDType;


