CREATE VIEW [AFISales_DW_Wrk].[v_FactPotential]
AS
    SELECT  DISTINCT
            ROW_NUMBER() OVER (ORDER BY
                                   DimDateFile.[Transaction Date]
                              )                                               AS RowID,
            DimDateFile.[Transaction Date]                                    AS [WeekEndingDate],
            DimGeographicLocations.[Address ID]                               AS [AddressID],
            DimSalesTerritories.[SalesTerritoryID],
            SQ.Amount / DFI.maxWeek * SalesCategory.MktPotFactor              AS [MarketPotential],
            DimSalesTerritories.[AFI Sales Category],
            DimSalesTerritories.[Marketing Specialist ID],
            DimSalesTerritories.[AFI Sales Region Code],
            DimSalesTerritories.[AFI Sales RepID],
            DimSalesTerritories.RegionCode_RepID_Category
    FROM
            (
                SELECT
                    Year,
                    State,
                    CountyFips,
                    ProductLine,
                    SUM(Amount) AS Amount
                FROM
                    [$(Wholesale_Warehouse)].Marketing.[MarketPotential]
                GROUP BY
                    Year,
                    State,
                    CountyFips,
                    ProductLine
                UNION
                SELECT
                    Year              AS Year,
                    StateAbbreviation AS State,
                    ID                AS CountyFips,
                    ProductLineCode   AS ProductLine,
                    SUM(Amount)       AS Amount
                FROM
                    [$(Wholesale_Warehouse)].Marketing.[MarketPotential2]
                GROUP BY
                    Year,
                    StateAbbreviation,
                    ID,
                    ProductLineCode
            )                  AS SQ
        JOIN
            AFISales_DW.DimDateFile
                ON DimDateFile.[Fiscal Year] = SQ.Year
                   AND DATEPART(dw, DimDateFile.[Transaction Date]) = 7
        LEFT JOIN
            [$(MasterData_Warehouse)].[GeographicData].CountyMaster
                ON CountyMaster.CountyCode = SQ.CountyFips
                   AND CountyMaster.State = SQ.State
                   AND CountyMaster.Country = 'USA'
        LEFT JOIN
            [$(MasterData_Warehouse)].[GeographicData].StateMaster
                ON StateMaster.State = CountyMaster.State
                   AND StateMaster.Country = 'USA'
        LEFT JOIN
            AFISales_DW.DimGeographicLocations
                ON ISNULL(CountyMaster.CountyCode, '') = [County Code]
                   AND ISNULL(StateMaster.State, '') = [State Code]
                   AND ISNULL(StateMaster.Country, '') = [Country Code]
                   AND [AddressIDType] = 'C'
        JOIN
            [$(Wholesale_Warehouse)].Marketing.SalesCategory
                ON SalesCategory.ProductLine = SQ.ProductLine
        LEFT JOIN
            AFISales_Enh.TerritoryAllocationStatic
                ON SalesCategory.SalesCategory = TerritoryAllocationStatic.SalesCategory
                   AND TerritoryAllocationStatic.TerritoryCode = CountyMaster.TerritoryCode
        JOIN
            (
                SELECT
                    CAST(MAX([Fiscal Week]) AS DECIMAL(6, 2)) maxWeek,
                    DimDateFile.[Fiscal Year]
                FROM
                    AFISales_DW.DimDateFile
                GROUP BY
                    [Fiscal Year]
            )                  DFI
                ON DFI.[Fiscal Year] = DimDateFile.[Fiscal Year]
        LEFT JOIN
            AFISales_DW.[DimSalesTerritories]
                ON DimSalesTerritories.[AFI Sales Region Code] = ISNULL(
                                                                           TerritoryAllocationStatic.RegionCode,
                                                                           CAST('Z' AS CHAR(3))
                                                                       )
                   AND DimSalesTerritories.[AFI Sales RepID] = ISNULL(
                                                                         TerritoryAllocationStatic.RepID,
                                                                         CAST('ZZZZZ' AS CHAR(5))
                                                                     )
                   AND DimSalesTerritories.[AFI Sales Category] = ISNULL(
                                                                            SalesCategory.SalesCategory,
                                                                            SQ.ProductLine
                                                                        )
                   AND DimSalesTerritories.[Active Record] = 1
    WHERE
            DimDateFile.[Transaction Date] > GETDATE() - 2560;
