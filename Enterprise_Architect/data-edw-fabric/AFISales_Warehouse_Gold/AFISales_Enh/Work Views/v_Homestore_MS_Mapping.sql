CREATE VIEW AFISales_Enh_Wrk.v_Homestore_MS_Mapping as

SELECT  DISTINCT
        [LocationKey],
        [Operation],
        [StoreLocation],
        [AFIAccountNumber],
        [AFIShiptoNumber],
        [CloseDate],
        [HomestoreOwner],
        [Latitude],
        [Longitude],
        [ZipCode],
        [County],
        [Country],
        [County Code],
        [State Code],
        [MSA VP],
        [AFI Alternate Division],
        [Marketing Specialist],
        [Designated Marketing Area]
FROM
        (
            SELECT  DISTINCT
                    [LocationKey],
                    [Operation],
                    [StoreLocation],
                    [AFIAccountNumber],
                    [AFIShiptoNumber],
                    [CloseDate],
                    [HomestoreOwner],
                    [Default Sales Territory],
                    d.[Latitude],
                    d.[Longitude],
                    zb.[ZipCode],
                    zb.[County],
                    zb.[Country],
                    [County Code],
                    [State Code],
                    [MSA VP],
                    [Designated Marketing Area]
            FROM
                [$(MasterData_Warehouse)].[MasterData_DW].[DimRetailLocations]              d
                LEFT JOIN
                    [AFISales_DW].[DimGeographicLocations] zb
                        ON d.[ZipCode] = zb.[ZipCode]
                           AND d.[Latitude] = zb.[Latitude]
                           AND d.[Longitude] = zb.[Longitude]
            WHERE
                    d.[Latitude] <> 0.0
                    AND [AFIAccountNumber] <> ''
                    AND [StoreLocation] IS NOT NULL
        ) abc
    LEFT JOIN
        (
            SELECT
                a.[DivisionCode],         
                a.[RegionCode],          
                a.[SalesCategory] , 
                a.[TerritoryCode] ,
                a.[RepID],
                b.Deactivated,
                a.[CommissionSplitPercent] ,
                a.[SalesSplitPercent],
                b.[SalesTerritoryID] ,
                b.[AFI Sales RepID] ,
                b.[AFI Alternate Division],
                b.[Marketing Specialist],
                b.[Activated]

            FROM
                    [AFISales_Enh].[TerritoryAllocationStatic] a
                LEFT JOIN
                    [AFISales_DW].[DimSalesTerritories]        b
                        ON RepID = [AFI Sales RepID]
        ) abd
            ON abd.TerritoryCode = abc.[Default Sales Territory]
WHERE
        abd.[Deactivated] IS NULL
        AND abd.[Marketing Specialist] <> 'N/A'
        AND abd.[AFI Alternate Division] IN (
                                            'Motion', 'Casegoods', 'Stationary'
                                        );

