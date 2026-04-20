CREATE VIEW [AFISales_DW_Wrk].[v_DimTerritory]
AS
    SELECT
        CAST(Territory AS CHAR(10)) AS Territory
    FROM
        (
            SELECT
                CASE
                    WHEN CAST([Shipto Sales Territory] AS INT) = 0
                        THEN
                        [Primary Sales Territory]
                    ELSE
                        [Primary Sales Territory] + [Shipto Sales Territory]
                END AS Territory
            FROM
                AFISales_DW.DimCustomers


            /*
 * Get the list of Reps.This will be used to link to measure groups that do not
 * have the foreign key(Primary+Shipto territory)
 */
            UNION
            SELECT DISTINCT
                   MrktSpclstMaster.RepID
            FROM
                   [$(Wholesale_Warehouse)].Marketing.MrktSpclstMaster
            WHERE
                   MrktSpclstMaster.RepID <> ''
            UNION

            --SELECT DISTINCT [Primary Sales Territory] as Territory FROM AFISales_DW.DimCustomers

            SELECT DISTINCT
                   TerritoryAssignment.TerritoryCode AS Territory
            FROM
                   [$(Wholesale_Warehouse)].Marketing.TerritoryAssignment

            -- added by Bob Horton Jan, 2018 to eliminate Unknown values in Market Commitment, ta and Potential measures

        ) terr;


