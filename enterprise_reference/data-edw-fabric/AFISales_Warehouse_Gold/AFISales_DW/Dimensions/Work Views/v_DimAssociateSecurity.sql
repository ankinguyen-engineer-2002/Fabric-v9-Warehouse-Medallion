CREATE VIEW AFISales_DW_Wrk.v_DimAssociateSecurity
AS
    WITH UserProfileDivisionAccess
    AS (
           SELECT DISTINCT
                  UserProfile.FirstName,
                  UserProfile.LastName,
                  UserProfile.Email,
                  UserProfile.UserLogin,
                  'A' AS Division
           FROM
                  [$(MasterData_Warehouse)].[Security].UserProfile
           WHERE
                  UserProfile.Security_Casegoods = 1
           UNION
           SELECT DISTINCT
                  UserProfile.FirstName,
                  UserProfile.LastName,
                  UserProfile.Email,
                  UserProfile.UserLogin,
                  'U'
           FROM
                  [$(MasterData_Warehouse)].[Security].UserProfile
           WHERE
                  UserProfile.Security_Upholstery = 1
           UNION
           SELECT DISTINCT
                  UserProfile.FirstName,
                  UserProfile.LastName,
                  UserProfile.Email,
                  UserProfile.UserLogin,
                  'B'
           FROM
                  [$(MasterData_Warehouse)].[Security].UserProfile
           WHERE
                  UserProfile.Security_Bedding = 1
           UNION
           SELECT DISTINCT
                  UserProfile.FirstName,
                  UserProfile.LastName,
                  UserProfile.Email,
                  UserProfile.UserLogin,
                  'V'
           FROM
                  [$(MasterData_Warehouse)].[Security].UserProfile
           WHERE
                  UserProfile.Security_UphSigDesign = 1
           UNION
           SELECT DISTINCT
                  UserProfile.FirstName,
                  UserProfile.LastName,
                  UserProfile.Email,
                  UserProfile.UserLogin,
                  'D'
           FROM
                  [$(MasterData_Warehouse)].[Security].UserProfile
           WHERE
                  UserProfile.Security_CaseSigDesign = 1
           UNION
           SELECT DISTINCT
                  UserProfile.FirstName,
                  UserProfile.LastName,
                  UserProfile.Email,
                  UserProfile.UserLogin,
                  'L'
           FROM
                  [$(MasterData_Warehouse)].[Security].UserProfile
           WHERE
                  UserProfile.Security_Motion = 1
           UNION
           SELECT DISTINCT
                  UserProfile.FirstName,
                  UserProfile.LastName,
                  UserProfile.Email,
                  UserProfile.UserLogin,
                  'K'
           FROM
                  [$(MasterData_Warehouse)].[Security].UserProfile
           WHERE
                  UserProfile.Security_MotionSigDesign = 1
           UNION
           SELECT DISTINCT
                  UserProfile.FirstName,
                  UserProfile.LastName,
                  UserProfile.Email,
                  UserProfile.UserLogin,
                  'C'
           FROM
                  [$(MasterData_Warehouse)].[Security].UserProfile
           WHERE
                  UserProfile.Security_BedSigDesign = 1
           UNION
           SELECT DISTINCT
                  UserProfile.FirstName,
                  UserProfile.LastName,
                  UserProfile.Email,
                  UserProfile.UserLogin,
                  'E'
           FROM
                  [$(MasterData_Warehouse)].[Security].UserProfile
           WHERE
                  UserProfile.Security_AccSigDesign = 1)
    SELECT
        CAST(ROW_NUMBER() OVER (ORDER BY
                                    [Salesman Number]
                               ) AS BIGINT)             RowNumber,
        CAST(SecurityData.[Salesman Number] AS CHAR(5)) AS [Salesman Number],
        CAST(SecurityData.[Account Number] AS CHAR(8))  AS [Account Number],
        CAST(SecurityData.[Shipto Number] AS CHAR(4))   AS [Shipto Number],
        CAST(SecurityData.[Division Code] AS CHAR(1))   AS [Division Code],
        SecurityData.[Salesman Name],
        SecurityData.[Customer Shipto Division Number]
    FROM
        (
            SELECT
                    TRIM(SCU.SalesCode)                                                            AS [Salesman Number],
                    CAST(TRIM(SEC.CustomerNumber) AS INT)                                          AS [Account Number],
                    TRIM(SEC.ShiptoNumber)                                                         AS [Shipto Number],
                    MSR.Division                                                                   AS  [Division Code],
                    MrktSpclstMaster.SalesmanName                                                  AS [Salesman Name],
                    RTRIM(SEC.CustomerNumber) + '-' + RTRIM(SEC.ShiptoNumber) + '-' + ISNULL(MSR.Division, '') AS [Customer Shipto Division Number]
            FROM
                    [$(MasterData_Warehouse)].[Security].Customer          SEC
                INNER JOIN
                    [$(Wholesale_Warehouse)].Customers.ShippingLocations CSM
                        ON SEC.CustomerNumber = CSM.CustomerNumber
                           AND SEC.ShiptoNumber = CSM.ShiptoNumber --and CSM.ActiveRecord <> 'S' 
                LEFT JOIN
                    [$(Wholesale_Warehouse)].Marketing.RepCustomerFilter RCF
                        ON SEC.CustomerNumber = RCF.CustomerNumber
                           AND SEC.ShiptoNumber = RCF.ShiptoNumber
                           AND RCF.MHS_Name = 'MASTERXX'
                LEFT OUTER JOIN
                    [$(MasterData_Warehouse)].[Security].CustomerList      SCU
                        ON SEC.CustomerNumber = SCU.CustomerNumber
                           AND SEC.ShiptoNumber = SCU.ShiptoNumber
                           AND SCU.SalesCode IN
                                   (
                                       SELECT DISTINCT
                                              Territory.SalesCode
                                       FROM
                                              [$(MasterData_Warehouse)].[Security].Territory
                                       WHERE
                                              Territory.RepID IN
                                                  (
                                                      SELECT
                                                          MrktSpclstMaster.RepID
                                                      FROM
                                                          [$(Wholesale_Warehouse)].Marketing.MrktSpclstMaster
                                                      WHERE
                                                          RTRIM(MrktSpclstMaster.RepID) <> ''
                                                  )
                                   )
                LEFT JOIN
                    [$(Wholesale_Warehouse)].Marketing.MrktSpclstRegion  MSR
                        ON SCU.SalesCode = MSR.MarketingSpecialist
                LEFT JOIN
                    [$(Wholesale_Warehouse)].Marketing.MrktSpclstMaster
                        ON MrktSpclstMaster.MarketingSpecialist = SCU.SalesCode
                           AND MrktSpclstMaster.MarketingSpecialist LIKE 'A%'
            WHERE
                    SEC.MHS_Name IN
                        (
                            SELECT
                                SalesProfile.MHS_Name
                            FROM
                                [$(MasterData_Warehouse)].[Security].SalesProfile
                            WHERE
                                SalesProfile.SalesCode IN
                                    (
                                        SELECT
                                            MrktSpclstMaster.MarketingSpecialist
                                        FROM
                                            [$(Wholesale_Warehouse)].Marketing.MrktSpclstMaster
                                    )
                        )
                    AND (SCU.SalesCode LIKE 'A%')
            --Added by Shobana on Dec 21, 2015 Starts
            UNION
            SELECT  DISTINCT
                    TRIM(SCU.SalesCode)                                                                       AS [Salesman Number],
                    CAST(TRIM(SEC.CustomerNumber) AS INT)                                                     AS [Account Number],
                    TRIM(SEC.ShiptoNumber)                                                                    AS [Shipto Number],
                    UP.Division                                                                               AS [Division Code],
                    MrktSpclstMaster.SalesmanName                                                             AS [Salesman Name],
                    RTRIM(SEC.CustomerNumber) + '-' + RTRIM(SEC.ShiptoNumber) + '-' + ISNULL(UP.Division, '') AS [Customer Shipto Division Number]
            FROM
                    [$(MasterData_Warehouse)].[Security].Customer          SEC
                --Modified by Ram Dhilip on 11/13/2015
                --INNER JOIN AFISales_Enh.CustomerShipMaster CSM  ON seCustomerNumber=csmCusno AND seShiptoNumber=csmshpno 
                INNER JOIN
                    [$(Wholesale_Warehouse)].Customers.ShippingLocations          CSM
                        ON SEC.CustomerNumber = CSM.CustomerNumber
                           AND SEC.ShiptoNumber = CSM.ShiptoNumber --and CSM.ActiveRecord <> 'S' 
                LEFT JOIN
                    [$(Wholesale_Warehouse)].Marketing.RepCustomerFilter RCF
                        ON SEC.CustomerNumber = RCF.CustomerNumber
                           AND SEC.ShiptoNumber = RCF.ShiptoNumber
                           AND RCF.MHS_Name = 'MASTERXX'
                LEFT OUTER JOIN
                    [$(MasterData_Warehouse)].[Security].CustomerList      SCU
                        ON SEC.CustomerNumber = SCU.CustomerNumber
                           AND SEC.ShiptoNumber = SCU.ShiptoNumber
                           AND SCU.SalesCode IN
                                   (
                                       SELECT DISTINCT
                                              Territory.SalesCode
                                       FROM
                                              [$(MasterData_Warehouse)].[Security].Territory
                                       WHERE
                                              Territory.RepID IN
                                                  (
                                                      SELECT
                                                          MrktSpclstMaster.RepID
                                                      FROM
                                                          [$(Wholesale_Warehouse)].Marketing.MrktSpclstMaster
                                                      WHERE
                                                          RTRIM(MrktSpclstMaster.RepID) <> ''
                                                  )
                                   )

                LEFT JOIN
                    [$(Wholesale_Warehouse)].Marketing.MrktSpclstMaster
                        ON MrktSpclstMaster.MarketingSpecialist = SCU.SalesCode
                           AND MrktSpclstMaster.MarketingSpecialist LIKE 'A%'
                INNER JOIN
                    [$(Wholesale_Warehouse)].Marketing.MrktSpclstInfo    b
                        ON LTRIM(RTRIM(MrktSpclstMaster.SalesmanName)) = LTRIM(RTRIM(b.LastName)) + ', ' + LTRIM(RTRIM(b.FirstName))
                LEFT JOIN
                    UserProfileDivisionAccess                      AS UP
                        ON (
                               LTRIM(RTRIM(b.Email)) = LTRIM(RTRIM(UP.Email))
                               AND
                                   (
                                       LTRIM(RTRIM(b.LastName)) = LTRIM(RTRIM(UP.LastName))
                                       OR LTRIM(RTRIM(b.FirstName)) = LTRIM(RTRIM(UP.FirstName))
                                   )
                           )
            WHERE
                    SEC.MHS_Name IN
                        (
                            SELECT
                                SalesProfile.MHS_Name
                            FROM
                                [$(MasterData_Warehouse)].[Security].SalesProfile
                            WHERE
                                SalesProfile.SalesCode IN
                                    (
                                        SELECT
                                            MrktSpclstMaster.MarketingSpecialist
                                        FROM
                                            [$(Wholesale_Warehouse)].Marketing.MrktSpclstMaster
                                    )
                        )
                    AND (SCU.SalesCode LIKE 'A%')
                    AND UP.Division IS NOT NULL
   
            UNION
            SELECT
                           'XXXX'                                                                                             AS [Salesman Number],
                           TRIM(ShippingLocations.CustomerNumber)                                                             AS [Account Number],
                           TRIM(ShippingLocations.ShiptoNumber)                                                               AS [Shipto Number],
                           Divisions.DivisionCode                                                                             AS [Division Code],
                           'N/A'                                                                                              AS [Salesman Name],
                            RTRIM(ISNULL(ShippingLocations.CustomerNumber, '')) + '-'
                             + RTRIM(ISNULL(ShippingLocations.ShiptoNumber, '')) + '-'
                             + Divisions.DivisionCode                                    AS [Customer Shipto Division Number]
            FROM
                           [$(Wholesale_Warehouse)].Customers.ShippingLocations
                --added by Bob Horton jan, 2018 to add rows for each division to each cust-ship combo
                CROSS JOIN [$(Wholesale_Warehouse)].Marketing.Divisions
        ) SecurityData;
