CREATE VIEW [AFISales_DW_Wrk].[v_FactADLoginsAndTerrigory]
AS
    SELECT  DISTINCT
            UserProfile.UserLogin AS [ADLogins],
            Territory.RepID       AS Territory
    FROM
            [$(MasterData_Warehouse)].[Security].Territory
        JOIN
            [$(MasterData_Warehouse)].[Security].UserProfile
                ON Territory.MHS_Name = UserProfile.MHS
        JOIN
            AFISales_DW.DimTerritory
                ON DimTerritory.Territory = Territory.RepID --- Inner join will remove invalid territories
    WHERE
            Territory.MHS_Name <> 'MASTERXX'
            AND Territory.RepID <> ''
            AND UserProfile.MHS <> ''
    UNION ALL

    -- Get Primary+Shipto territories associated with AD Logins

    SELECT  DISTINCT
            Terr.UserLogin                                                   AS ADLogins,
            combo.[Primary Sales Territory] + combo.[Shipto Sales Territory] AS Territory
    FROM
            (
                SELECT  DISTINCT
                        UserProfile.UserLogin,
                        TerritoryAssignment.TerritoryCode
                FROM
                        [$(MasterData_Warehouse)].[Security].UserProfile
                    JOIN
                        [$(MasterData_Warehouse)].[Security].MarketingSpecialist
                            ON UserProfile.MHS = MarketingSpecialist.MHS_Name
                               AND UserProfile.MHS <> 'MASTERXX'
                    JOIN
                        [$(Wholesale_Warehouse)].Marketing.SalesTeamMembers
                            ON MarketingSpecialist.SalesCode = SalesTeamMembers.MarketingSpecialist
                    JOIN
                        [$(Wholesale_Warehouse)].Marketing.TerritoryAssignment
                            ON TerritoryAssignment.MarketingSpecialist = SalesTeamMembers.Team
                    JOIN
                        AFISales_DW.DimTerritory
                            ON Territory = TerritoryAssignment.TerritoryCode --- Inner join will remove invalid territories
                WHERE
                        TerritoryAssignment.MarketingSpecialist <> '99999'
                        AND UserProfile.MHS <> ''
                UNION
                SELECT
                        UserProfile.UserLogin,
                        TerritoryAssignment.TerritoryCode
                FROM
                        [$(MasterData_Warehouse)].[Security].UserProfile
                    JOIN
                        [$(MasterData_Warehouse)].[Security].MarketingSpecialist
                            ON UserProfile.MHS = MarketingSpecialist.MHS_Name
                               AND UserProfile.MHS <> 'MASTERXX'
                    JOIN
                        [$(Wholesale_Warehouse)].Marketing.TerritoryAssignment
                            ON MarketingSpecialist.SalesCode = TerritoryAssignment.MarketingSpecialist
                    JOIN
                        AFISales_DW.DimTerritory
                            ON Territory = TerritoryAssignment.TerritoryCode --- Inner join will remove invalid territories
                WHERE
                        TerritoryAssignment.MarketingSpecialist <> '99999'
                        AND UserProfile.MHS <> ''
            ) Terr
        JOIN
            (
                SELECT DISTINCT
                       [Primary Sales Territory],
                       [Shipto Sales Territory]
                FROM
                       AFISales_DW.DimCustomers
                WHERE
                       CAST([Shipto Sales Territory] AS INT) <> 0
            ) combo
                ON Terr.TerritoryCode = combo.[Primary Sales Territory]
                    OR Terr.TerritoryCode = combo.[Shipto Sales Territory]
    UNION ALL


    -- Get Primary territories associated with AD Logins

    SELECT  DISTINCT
            Terr.UserLogin           AS ADLogins,
            combo.[Primary Sales Territory] AS Territory
    FROM
            (
                SELECT  DISTINCT
                        UserProfile.UserLogin,
                        TerritoryAssignment.TerritoryCode
                FROM
                        [$(MasterData_Warehouse)].[Security].UserProfile
                    JOIN
                        [$(MasterData_Warehouse)].[Security].MarketingSpecialist
                            ON UserProfile.MHS = MarketingSpecialist.MHS_Name
                               AND UserProfile.MHS <> 'MASTERXX'
                    JOIN
                        [$(Wholesale_Warehouse)].Marketing.SalesTeamMembers
                            ON MarketingSpecialist.SalesCode = SalesTeamMembers.MarketingSpecialist
                    JOIN
                        [$(Wholesale_Warehouse)].Marketing.TerritoryAssignment
                            ON TerritoryAssignment.MarketingSpecialist = SalesTeamMembers.Team
                    JOIN
                        AFISales_DW.DimTerritory
                            ON DimTerritory.Territory = TerritoryAssignment.TerritoryCode --- Inner join will remove invalid territories
                WHERE
                        TerritoryAssignment.MarketingSpecialist <> '99999'
                        AND UserProfile.MHS <> ''
                UNION
                SELECT
                        UserProfile.UserLogin,
                        TerritoryAssignment.TerritoryCode
                FROM
                        [$(MasterData_Warehouse)].[Security].UserProfile
                    JOIN
                        [$(MasterData_Warehouse)].[Security].MarketingSpecialist
                            ON UserProfile.MHS = MarketingSpecialist.MHS_Name
                               AND UserProfile.MHS <> 'MASTERXX'
                    JOIN
                        [$(Wholesale_Warehouse)].Marketing.TerritoryAssignment
                            ON MarketingSpecialist.SalesCode = TerritoryAssignment.MarketingSpecialist
                    JOIN
                        AFISales_DW.DimTerritory
                            ON Territory = TerritoryAssignment.TerritoryCode --- Inner join will remove invalid territories
                WHERE
                        TerritoryAssignment.MarketingSpecialist <> '99999'
                        AND UserProfile.MHS <> ''
            ) Terr
        JOIN
            (
                SELECT DISTINCT
                       DimCustomers.[Primary Sales Territory]
                FROM
                       AFISales_DW.DimCustomers
            ) combo
                ON Terr.TerritoryCode = combo.[Primary Sales Territory];