CREATE VIEW [AFISales_Enh].[TerritoryAllocation]
AS
    SELECT  DISTINCT
            SalesCategory.Division                                                 AS DivisionCode,
            COALESCE(MrktSpclstRegion.Region, Others.RegionCode, CAST('Z' AS CHAR(3)))     AS RegionCode,
            SalesCategory.SalesCategory                                  AS SalesCategory,
            TerritoryAssignment.TerritoryCode                         AS TerritoryCode,
            ISNULL(MrktSpclstRegion.RepID, TerritoryAssignment.MarketingSpecialist) AS RepID,
            1                                                         AS CommissionSplitPercent,
            1                                                         AS SalesSplitPercent
    FROM
            [$(Wholesale_Warehouse)].Marketing.SalesCategory
        LEFT JOIN
            [$(Wholesale_Warehouse)].Marketing.TerritoryAssignment
                ON TerritoryAssignment.CommissionClass = SalesCategory.CommissionClass
        LEFT JOIN
            [$(Wholesale_Warehouse)].Marketing.MrktSpclstRegion
                ON MrktSpclstRegion.MarketingSpecialist = TerritoryAssignment.MarketingSpecialist
                   AND MrktSpclstRegion.Division = SalesCategory.Division
        LEFT JOIN
            (
                SELECT
                    MAX(Regions.RegionCode) AS RegionCode,
                    Regions.Division
                FROM
                    [$(Wholesale_Warehouse)].Marketing.Regions
                WHERE
                    Regions.RegionType = 'Other'
                GROUP BY
                    Regions.Division
            ) Others
                ON Others.Division =  SalesCategory.Division
    WHERE
            TerritoryAssignment.MarketingSpecialist NOT IN
                (
                    SELECT
                        SalesTeamMembers.Team
                    FROM
                        [$(Wholesale_Warehouse)].Marketing.SalesTeamMembers
                    GROUP BY
                        SalesTeamMembers.Team
                )
    UNION
    SELECT  DISTINCT
            CAST('Z' AS CHAR(1)),
            CAST('ZZ' AS CHAR(3)),
            CAST('ZZ' AS CHAR(3)),
            TerritoryAssignment.TerritoryCode,
            TerritoryAssignment.MarketingSpecialist,
            1,
            1
    FROM
            [$(Wholesale_Warehouse)].Marketing.TerritoryAssignment
        JOIN
            [$(Wholesale_Warehouse)].Pricing_AFI.CommissionClass
                ON TerritoryAssignment.CommissionClass = CommissionClass.CommissionClass
    WHERE
            CommissionClass.SalesCategory = 'ZZ'
    UNION
    SELECT  DISTINCT
            SalesCategory.Division,
            COALESCE(MrktSpclstRegion.Region, Others.RegionCode, CAST('Z' AS CHAR(3))) AS RegionCode,
            SalesCategory.SalesCategory,
            TerritoryAssignment.TerritoryCode,
            ISNULL(MrktSpclstRegion.RepID, Teams.MarketingSpecialist)                         AS RepID,
            SalesSplitPercent AS CommissionSplitPercent,
            SalesSplitPercent                                             
    FROM
            [$(Wholesale_Warehouse)].Marketing.SalesCategory
        LEFT JOIN
            [$(Wholesale_Warehouse)].Marketing.TerritoryAssignment
                ON TerritoryAssignment.CommissionClass = SalesCategory.CommissionClass
        JOIN
            (
                SELECT
                        SlTeamt.Team                                                    AS Team,
                        SlTeam.MarketingSpecialist                                                    AS MarketingSpecialist,
                        ROUND(CONVERT(FLOAT, StoreCount) / CONVERT(FLOAT, Totcount), 7) AS SalesSplitPercent
                FROM
                        [$(Wholesale_Warehouse)].Marketing.SalesTeamMembers SlTeam
                    JOIN
                        (
                            SELECT
                                SlTeam.Team,
                                SUM(StoreCount) AS Totcount
                            FROM
                                [$(Wholesale_Warehouse)].Marketing.SalesTeamMembers SlTeam
                            GROUP BY
                                SlTeam.Team
                        )                                         SlTeamt
                            ON SlTeamt.Team = SlTeam.Team
                               AND SlTeam.StoreCount <> 0
            )             Teams
                ON TerritoryAssignment.MarketingSpecialist = Teams.Team
        LEFT JOIN
            [$(Wholesale_Warehouse)].Marketing.MrktSpclstRegion
                ON MrktSpclstRegion.MarketingSpecialist = Teams.MarketingSpecialist
                   AND MrktSpclstRegion.Division = SalesCategory.Division
        LEFT JOIN
            (
                SELECT
                    MAX(Regions.RegionCode) AS RegionCode,
                    Regions.Division
                FROM
                    [$(Wholesale_Warehouse)].Marketing.Regions
                WHERE
                    Regions.RegionType = 'Other'
                GROUP BY
                    Regions.Division
            )             Others
                ON Others.Division = SalesCategory.Division;