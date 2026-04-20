CREATE PROC [AFISales_DW].[usp_Refresh_DimSalesTerritories]
AS

    /* Change Control -----------------------------------------------------------------------------------------------------------
* Procedure: [AFISales_DW].[usp_Refresh_DimSalesTerritories]
* Description: Process updates DimDimSalesTerritories adding any new combinations of Region, RepID, Division
*   that don't already exist and adds a surrogate key to them.  There is an Active flag used to 
*   indicate which rows are part of the current territory settings.  Inactive rows are only needed
*   until all the fact tables get reallocated to the current settings... this may take up to a week
* 
*   SalesTerritoryID is a unique surrogate key that gets associated with all the fact table records
*   There is legacy code in the AFISales_OLAP cube that links back to the fact tables using a combination 
*   of RepID-SalesCategory-Region
* 
* Bob Horton (Jan 2018): Migrated from PDW Cube load view to Azure Data Warehouse
* Gabe De Mayo (3/1/18): Modified to use usp_CreateReplicateWorkTable/updated object existence check/updated error handling
* Bob Horton 1/29/2019 added a check for a change in email address   (OR T1.[Marketing Specialist Mail ID] <> T2.[Marketing Specialist Mail ID])
* Bob Horton 3/12/2019  added snapshot to the history table
* 02/28/2020 Changed insert to "Values" syntax to avoid exclusive locks
* 03/16/2020 Changed script Update to insert tpkmodified column in Table Dictionary
---------------------------------------------------------------------------------------------------------------------------*/

    BEGIN

        DECLARE
            @String    VARCHAR(5000),
            @DateValue DATETIME,
            @User      VARCHAR(500);
       
        SET @String =  'AFISales_DW.AFISales_DW.usp_Refresh_DimSalesTerritories';
        SET @User = SYSTEM_USER;
        SET @DateValue = GETDATE();
        SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)

                     
        INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
        VALUES
            (
                @String, @DateValue, @User, 'Process Start'
            );

        BEGIN TRY

            -- First, snapshot the current territory settings into an Enh table to be used to allocate transactions 


            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                'AFISales_Enh.TerritoryAllocationStatic_LOAD';

            CREATE TABLE [AFISales_Enh].[TerritoryAllocationStatic_Load]
                (
                    [DivisionCode]           CHAR(1)       NULL,   
                    [RegionCode]             CHAR(3)       NULL,   
                    [SalesCategory]          CHAR(3)       NULL,   
                    [TerritoryCode]          CHAR(5)       NULL,   
                    [RepID]                  CHAR(5)       NULL,
                    [CommissionSplitPercent] DECIMAL(8, 4) NULL,    
                    [SalesSplitPercent]      DECIMAL(8, 4) NULL    
                );

            INSERT INTO  [AFISales_Enh].[TerritoryAllocationStatic_Load]
                (DivisionCode,
                RegionCode,
                SalesCategory,
                TerritoryCode,
                RepID,
                CommissionSplitPercent,
                SalesSplitPercent)
            SELECT 
                DivisionCode,
                RegionCode,
                SalesCategory,
                TerritoryCode,
                RepID,
                CommissionSplitPercent,
                SalesSplitPercent
            FROM
                AFISales_Enh.TerritoryAllocation;


            CREATE STATISTICS [Stat_TerritoryAllocationStatic_RepID]
                ON AFISales_Enh.TerritoryAllocationStatic_LOAD
                (
                    [RepID]
                );
            CREATE STATISTICS [Stat_TerritoryAllocationStatic_SalesCategory]
                ON AFISales_Enh.TerritoryAllocationStatic_LOAD
                (
                    [SalesCategory]
                );
            CREATE STATISTICS [Stat_TerritoryAllocationStatic_RegionCode]
                ON AFISales_Enh.TerritoryAllocationStatic_LOAD
                (
                    [RegionCode]
                );
            CREATE STATISTICS [Stat_TerritoryAllocationStatic_DivisionCode]
                ON AFISales_Enh.TerritoryAllocationStatic_LOAD
                (
                    [DivisionCode]
                );
            CREATE STATISTICS [Stat_TerritoryAllocationStatic_TerritoryCode]
                ON AFISales_Enh.TerritoryAllocationStatic_LOAD
                (
                    [TerritoryCode]
                );


            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                'AFISales_Enh.TerritoryAllocationStatic';


            EXECUTE sp_rename 'AFISales_DW.TerritoryAllocationStatic_LOAD','TerritoryAllocationStatic'
            
            -- Capture a snapshot of the allocation table 
            INSERT INTO [AFISales_Enh].[TerritoryAllocationStatic_History]
                        SELECT
                            @DateValue,  *
                        FROM
                            [AFISales_Enh].[TerritoryAllocationStatic];

            SET @DateValue = Getdate()
            SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)

            INSERT INTO [$(ETL_Framework)].DW_Developer.TableDictionary_UpdateLog
                        SELECT 
                            'AFISales_DW',
                            'AFISales_Enh',
                            'TerritoryAllocationStatic',
                            @DateValue
                        UNION
                        SELECT
                            'AFISales_DW',
                            'AFISales_Enh',
                            'TerritoryAllocationStatic_History',
                            @DateValue;



            /*---------------------------------------------------------------------------------------------

This view includes several cominations of key columns for identifying a specific row 
depending on what type of fact table joins to it. 

There are 5 types of values included....

1.)  Combination of Region-RepID-SalesCat from TerritoryAllocationStatic.

Measures (Facts) where all 3 values are known can be used to build keys to connect to this Dimension 
allowing for access to all attributes within the dimension

2.)  Value of 'Z-ZZZZZ-ZZ'. 

Measures (Facts) where none of these values are known should pass this value so to avoid 
itegrety errors during the load process and to pick up the default values for all the attributes

3.)  Combination of 'Z-ZZZZZ'-SalesCat from SalesCategory

Measures (Facts) where only the Sales Category is know.  This allows for additional attributes like
Division and product line to be assocated with the facts whereas any region (including alternate divsion)
or RepID based atributes come in as unknown.

4.)  Combination of Region-RepID-ProductLine from TerritoryAllocationStatic

Measures (Facts) where the Sales Category is unknown but the product line is should use this method
in order to expose all attributes in the Sales Territory dimension except Sales Category and Sales
Category Name.

5.  Combination of Region-RepID--DivisionCode from TerritoryAllocationStatic

Measures (Facts) where the Sales Category is unknown, product line is unknown but division is should use this method
in order to expose all attributes in the Sales Territory dimension except Sales Category,Sales
Category Name and product line.

----------------------------------------------------------------------------------------------*/



            SELECT
                RegionCode_RepID_Category,
                [AFI Sales Division Code],
                [AFI Sales Division],
                [AFI Sales Region Code],
                [AFI Sales RepID],
                [AFI Sales Region],
                [AFI Sales Region Type],
                MAX([Marketing Specialist ID]) AS [Marketing Specialist ID],
                MAX([Marketing Specialist])    AS [Marketing Specialist],
                [AFI Sales Category],
                [AFI Sales Category Name],
                [AFI Alternate Division Code],
                [AFI Alternate Division],
                [Sales Regional VP],
                [Sales Division President],
                [Product Line],
                [Business Name],
                1                              AS [Active Record],
                CAST('' AS VARCHAR(500))       AS [Marketing Specialist Mail ID]
            INTO
                #CURRENT
            FROM
                (
                    SELECT
                            RTRIM(ISNULL(RegionTerritories.RegionCode, 'Z')) + '-'
                                  + RTRIM(ISNULL(RegionTerritories.RepID, 'ZZZZZ')) + '-'
                                  + ISNULL(RegionTerritories.SalesCategory, 'ZZ')     AS RegionCode_RepID_Category,
                            [AFI Sales Division Code]     = RegionTerritories.DivisionCode,
                            [AFI Sales Division]          = ISNULL(def.Description, 'N/A'),
                            [AFI Sales Region Code]       = ISNULL(RegionTerritories.RegionCode, CAST('Z' AS CHAR(3))),
                            [AFI Sales RepID]             = ISNULL(RegionTerritories.RepID, CAST('ZZZZZ' AS CHAR(5))),
                            [AFI Sales Region]            = ISNULL(Regions.Description, 'N/A'),
                            [AFI Sales Region Type]       = ISNULL(Regions.RegionType, 'N/A'),
                            [Marketing Specialist ID]     = ISNULL(MrktSpclstMaster.MarketingSpecialist, 'N/A'),
                            [Marketing Specialist]        = ISNULL(MrktSpclstMaster.SalesmanName, 'N/A'),
                            [AFI Sales Category]          = ISNULL(RegionTerritories.SalesCategory, CAST('ZZ' AS CHAR(3))),
                            [AFI Sales Category Name]     = ISNULL(SalesCategory.Description, 'N/A'),
                            [AFI Alternate Division Code] = ISNULL(Regions.AlternateDivision, 'N/A'),
                            [AFI Alternate Division]      = ISNULL(alt.Description, 'N/A'),
                            [Sales Regional VP]           = ISNULL(Regions.VPDesc, 'N/A'),
                            [Sales Division President]    = ISNULL(def.President, 'N/A'),
                            [Product Line]                = ISNULL(ProductLineMaster.Description, 'N/A'),
                            [Business Name]               = CASE
                                                                WHEN MrktSpclstMaster.BusinessName IS NULL
                                                                     OR MrktSpclstMaster.BusinessName = ''
                                                                    THEN
                                                                    ISNULL(MrktSpclstMaster.SalesmanName, 'N/A')
                                                                WHEN MrktSpclstMaster.SalesmanName IS NULL
                                                                     OR MrktSpclstMaster.SalesmanName = ''
                                                                    THEN
                                                                    ISNULL(MrktSpclstMaster.BusinessName, 'N/A')
                                                                ELSE
                                                                    RTRIM(MrktSpclstMaster.SalesmanName) + ', ' + MrktSpclstMaster.BusinessName
                                                            END,
                            [Region Type]                 = Regions.RegionType
                    FROM
                            (
                                SELECT DISTINCT
                                       DivisionCode,
                                       SalesCategory,
                                       RegionCode,
                                       RepID
                                FROM
                                       AFISales_Enh.TerritoryAllocationStatic
                            )                                      RegionTerritories
                        LEFT JOIN
                            [$(Wholesale_Warehouse)].Marketing.Regions
                                ON Regions.RegionCode = RegionTerritories.RegionCode
                        LEFT JOIN
                            [$(Wholesale_Warehouse)].Marketing.Divisions def
                                ON def.DivisionCode = RegionTerritories.DivisionCode
                        LEFT JOIN
                            [$(Wholesale_Warehouse)].Marketing.MrktSpclstMaster
                                ON MrktSpclstMaster.RepID = RegionTerritories.RepID
                        LEFT JOIN
                            [$(Wholesale_Warehouse)].Marketing.SalesCategory
                                ON SalesCategory.SalesCategory = RegionTerritories.SalesCategory
                        LEFT JOIN
                            [$(Wholesale_Warehouse)].Marketing.Divisions alt
                                ON alt.DivisionCode = Regions.AlternateDivision
                        LEFT JOIN
                            [$(Wholesale_Warehouse)].Marketing.ProductLineMaster
                                ON ProductLineMaster.ProductLineCode = SalesCategory.ProductLine


                    --union select

                    --'Z-ZZZZZ-ZZ','Z','N/A','Z','ZZZZZ','N/A','N/A','N/A','N/A','ZZ','N/A','N/A','N/A','N/A','N/A','N/A','N/A','N/A'


                    UNION
                    SELECT
                            'Z-ZZZZZ-' + SalesCategory.SalesCategory,
                            SalesCategory.Division,
                            ISNULL(Divisions.Description, 'N/A'),
                            CAST('Z' AS CHAR(3)),
                            CAST('ZZZZZ' AS CHAR(5)),
                            'N/A',
                            'N/A',
                            'N/A',
                            'N/A',
                            SalesCategory.SalesCategory,
                            SalesCategory.Description,
                            'N/A',
                            'N/A',
                            'N/A',
                            ISNULL(Divisions.President, 'N/A'),
                            ISNULL(ProductLineMaster.Description, 'N/A'),
                            'N/A',
                            'N/A'
                    FROM
                            [$(Wholesale_Warehouse)].Marketing.SalesCategory
                        LEFT JOIN
                            [$(Wholesale_Warehouse)].Marketing.ProductLineMaster
                                ON ProductLineMaster.ProductLineCode = SalesCategory.ProductLine
                        LEFT JOIN
                            [$(Wholesale_Warehouse)].Marketing.Divisions
                                ON Divisions.DivisionCode = SalesCategory.Division
                    UNION
                    SELECT  DISTINCT
                            RTRIM(ISNULL(RegionTerritories.RegionCode, 'Z')) + '-' + RTRIM(ISNULL(RegionTerritories.RepID, 'ZZZZZ')) + '-'
                            + ISNULL(SalesCategory.ProductLine, 'Z') AS RegionCode_RepID_Category,
                            [AFI Sales Division Code]     = RegionTerritories.DivisionCode,
                            [AFI Sales Division]          = ISNULL(def.Description, 'N/A'),
                            [AFI Sales Region Code]       = ISNULL(RegionTerritories.RegionCode, CAST('Z' AS CHAR(3))),
                            [AFI Sales RepID]             = ISNULL(RegionTerritories.RepID, CAST('ZZZZZ' AS CHAR(5))),
                            [AFI Sales Region]            = ISNULL(Regions.Description, 'N/A'),
                            [AFI Sales Region Type]       = ISNULL(Regions.RegionType, 'N/A'),
                            [Marketing Specialist ID]     = ISNULL(MrktSpclstMaster.MarketingSpecialist, 'N/A'),
                            [Marketing Specialist]        = ISNULL(MrktSpclstMaster.SalesmanName, 'N/A'),
                            [AFI Sales Category]          = CAST('N/A' AS CHAR(3)),
                            [AFI Sales Category Name]     = 'N/A',
                            [AFI Alternate Division Code] = ISNULL(Regions.AlternateDivision, 'N/A'),
                            [AFI Alternate Division]      = ISNULL(alt.Description, 'N/A'),
                            [Sales Regional VP]           = ISNULL(Regions.VPDesc, 'N/A'),
                            [Sales Division President]    = ISNULL(def.President, 'N/A'),
                            [Product Line]                = ISNULL(ProductLineMaster.Description, 'N/A'),
                            [Business Name]               = CASE
                                                                WHEN MrktSpclstMaster.BusinessName IS NULL
                                                                     OR MrktSpclstMaster.BusinessName = ''
                                                                    THEN
                                                                    ISNULL(MrktSpclstMaster.SalesmanName, 'N/A')
                                                                WHEN MrktSpclstMaster.SalesmanName IS NULL
                                                                     OR MrktSpclstMaster.SalesmanName = ''
                                                                    THEN
                                                                    ISNULL(MrktSpclstMaster.BusinessName, 'N/A')
                                                                ELSE
                                                                    RTRIM(MrktSpclstMaster.SalesmanName) + ', ' + MrktSpclstMaster.BusinessName
                                                            END,
                            [Region Type]                 = Regions.RegionType
                    FROM
                            (
                                SELECT DISTINCT
                                       DivisionCode,
                                       SalesCategory,
                                       RegionCode,
                                       RepID
                                FROM
                                       AFISales_Enh.TerritoryAllocationStatic
                            )                                      RegionTerritories
                        LEFT JOIN
                            [$(Wholesale_Warehouse)].Marketing.Regions
                                ON Regions.RegionCode = RegionTerritories.RegionCode
                        LEFT JOIN
                            [$(Wholesale_Warehouse)].Marketing.Divisions def
                                ON def.DivisionCode = RegionTerritories.DivisionCode
                        LEFT JOIN
                            [$(Wholesale_Warehouse)].Marketing.MrktSpclstMaster
                                ON MrktSpclstMaster.RepID = RegionTerritories.RepID
                        LEFT JOIN
                            [$(Wholesale_Warehouse)].Marketing.SalesCategory
                                ON SalesCategory.SalesCategory = RegionTerritories.SalesCategory
                        LEFT JOIN
                            [$(Wholesale_Warehouse)].Marketing.Divisions alt
                                ON alt.DivisionCode = Regions.AlternateDivision
                        LEFT JOIN
                            [$(Wholesale_Warehouse)].Marketing.ProductLineMaster
                                ON ProductLineMaster.ProductLineCode = SalesCategory.ProductLine
                    UNION
                    SELECT  DISTINCT
                            RTRIM(ISNULL(RegionTerritories.RegionCode, 'Z')) + '-' 
                                 + RTRIM(ISNULL(RegionTerritories.RepID, 'ZZZZZ')) + '--'
                                  + RegionTerritories.DivisionCode AS RegionCode_RepID_Category,
                            [AFI Sales Division Code]                                                                    = RegionTerritories.DivisionCode,
                            [AFI Sales Division]                                                                         = ISNULL(def.Description, 'N/A'),
                            [AFI Sales Region Code]                                                                      = ISNULL(RegionTerritories.RegionCode, CAST('Z' AS CHAR(3))),
                            [AFI Sales RepID]                                                                            = ISNULL(RegionTerritories.RepID, CAST('ZZZZZ' AS CHAR(5))),
                            [AFI Sales Region]                                                                           = ISNULL(Regions.Description, 'N/A'),
                            [AFI Sales Region Type]                                                                      = ISNULL(Regions.RegionType, 'N/A'),
                            [Marketing Specialist ID]                                                                    = ISNULL(MrktSpclstMaster.MarketingSpecialist, 'N/A'),
                            [Marketing Specialist]                                                                       = ISNULL(MrktSpclstMaster.SalesmanName, 'N/A'),
                            [AFI Sales Category]                                                                         = CAST('N/A' AS CHAR(3)),
                            [AFI Sales Category Name]                                                                    = 'N/A',
                            [AFI Alternate Division Code]                                                                = ISNULL(Regions.AlternateDivision, 'N/A'),
                            [AFI Alternate Division]                                                                     = ISNULL(alt.Description, 'N/A'),
                            [Sales Regional VP]                                                                          = ISNULL(Regions.VPDesc, 'N/A'),
                            [Sales Division President]                                                                   = ISNULL(def.President, 'N/A'),
                            [Product Line]                                                                               = 'N/A',
                            [Business Name]                                                                              = CASE
                                                                                                                               WHEN MrktSpclstMaster.BusinessName IS NULL
                                                                                                                                    OR MrktSpclstMaster.BusinessName = ''
                                                                                                                                   THEN
                                                                                                                                   ISNULL(MrktSpclstMaster.SalesmanName, 'N/A')
                                                                                                                               WHEN MrktSpclstMaster.SalesmanName IS NULL
                                                                                                                                    OR MrktSpclstMaster.SalesmanName = ''
                                                                                                                                   THEN
                                                                                                                                   ISNULL(MrktSpclstMaster.BusinessName, 'N/A')
                                                                                                                               ELSE
                                                                                                                                   RTRIM(MrktSpclstMaster.SalesmanName) + ', ' + MrktSpclstMaster.BusinessName
                                                                                                                           END,
                            [Region Type]                                                                                = Regions.RegionType
                    FROM
                            (
                                SELECT DISTINCT
                                       DivisionCode,
                                       SalesCategory,
                                       RegionCode,
                                       RepID
                                FROM
                                       AFISales_Enh.TerritoryAllocationStatic
                            )                                      RegionTerritories
                        LEFT JOIN
                            [$(Wholesale_Warehouse)].Marketing.Regions
                                ON Regions.RegionCode = RegionTerritories.RegionCode
                        LEFT JOIN
                            [$(Wholesale_Warehouse)].Marketing.Divisions def
                                ON def.DivisionCode = RegionTerritories.DivisionCode
                        LEFT JOIN
                            [$(Wholesale_Warehouse)].Marketing.MrktSpclstMaster
                                ON MrktSpclstMaster.RepID = RegionTerritories.RepID
                        LEFT JOIN
                            [$(Wholesale_Warehouse)].Marketing.Divisions alt
                                ON alt.DivisionCode = Regions.AlternateDivision
                ) Alldata
            GROUP BY
                RegionCode_RepID_Category,
                [AFI Sales Division Code],
                [AFI Sales Division],
                [AFI Sales Region Code],
                [AFI Sales RepID],
                [AFI Sales Region],
                [AFI Sales Region Type],
                [AFI Sales Category],
                [AFI Sales Category Name],
                [AFI Alternate Division Code],
                [AFI Alternate Division],
                [Sales Regional VP],
                [Sales Division President],
                [Product Line],
                [Business Name];


            ----------------------------------------------------------------------------
            /*Marketing Specialist Email id on 2017-Dec-04, Start */
            ----------------------------------------------------------------------------

            SELECT
                RepID,
                Salesno,
                COALESCE(MIN(   CASE
                                    WHEN t1.rnk = 1
                                        THEN
                                        t1.Email
                                END
                            ), ''
                        ) + COALESCE(MIN(   CASE
                                                WHEN t1.rnk = 2
                                                    THEN
                                                    ', ' + t1.Email
                                            END
                                        ), ''
                                    ) + COALESCE(MIN(   CASE
                                                            WHEN t1.rnk = 3
                                                                THEN
                                                                ', ' + t1.Email
                                                        END
                                                    ), ''
                                                ) + COALESCE(MIN(   CASE
                                                                        WHEN t1.rnk = 4
                                                                            THEN
                                                                            ', ' + t1.Email
                                                                    END
                                                                ), ''
                                                            ) + COALESCE(MIN(   CASE
                                                                                    WHEN t1.rnk = 5
                                                                                        THEN
                                                                                        ', ' + t1.Email
                                                                                END
                                                                            ), ''
                                                                        ) AS Email
            INTO
                #CURRENT_MAILID
            FROM
                (
                    SELECT
                        RepID,
                        SalesNo,
                        Email,
                        DENSE_RANK() OVER (PARTITION BY
                                               SalesNo
                                           ORDER BY
                                               Email
                                          ) rnk
                    FROM
                        (
                            SELECT  DISTINCT
                                    RepID,
                                    SalesNo,
                                    Email
                            FROM
                                    [$(Wholesale_Warehouse)].Marketing.MrktSpclstInfo AS msi
                                JOIN
                                    #CURRENT                                    AS cu
                                        ON cu.[Marketing Specialist ID] = msi.SalesNo
                                           AND cu.[AFI Sales RepID] = msi.RepID
                            WHERE
                                    ISNULL(Email, '') <> ''
                        ) tbl
                ) t1
            GROUP BY
                RepID,
                SalesNo;

            -- Code is Added For Geting Email ID Based On Marketing Specialist's First Name, Last Name And Afi Sales RepID.
            INSERT INTO #CURRENT_MAILID
                        SELECT
                            RepID,
                            SalesNo,
                            COALESCE(MIN(   CASE
                                                WHEN t1.rnk = 1
                                                    THEN
                                                    t1.Email
                                            END
                                        ), ''
                                    ) + COALESCE(MIN(   CASE
                                                            WHEN t1.rnk = 2
                                                                THEN
                                                                ', ' + t1.Email
                                                        END
                                                    ), ''
                                                ) + COALESCE(MIN(   CASE
                                                                        WHEN t1.rnk = 3
                                                                            THEN
                                                                            ', ' + t1.Email
                                                                    END
                                                                ), ''
                                                            ) + COALESCE(MIN(   CASE
                                                                                    WHEN t1.rnk = 4
                                                                                        THEN
                                                                                        ', ' + t1.Email
                                                                                END
                                                                            ), ''
                                                                        ) + COALESCE(MIN(   CASE
                                                                                                WHEN t1.rnk = 5
                                                                                                    THEN
                                                                                                    ', ' + t1.Email
                                                                                            END
                                                                                        ), ''
                                                                                    ) AS Email
                        FROM
                            (
                                SELECT
                                    RepID,
                                    SalesNo,
                                    Email,
                                    DENSE_RANK() OVER (PARTITION BY
                                                           SalesNo
                                                       ORDER BY
                                                           Email
                                                      ) rnk
                                FROM
                                    (
                                        SELECT  DISTINCT
                                                RepID,
                                                SalesNo,
                                                Email,
                                                msilastname,
                                                msifirstname
                                        FROM
                                                [$(Wholesale_Warehouse)].Marketing.MrktSpclstInfo AS msi
                                            JOIN
                                                #CURRENT                                    AS cu
                                                    ON SUBSTRING(
                                                                    [Marketing Specialist], 0,
                                                                    CHARINDEX(',', [Marketing Specialist])
                                                                ) = REPLACE(msi.msilastname, '-NA', '')
                                                       AND LTRIM(RTRIM(SUBSTRING(
                                                                                    [Marketing Specialist],
                                                                                    CHARINDEX(
                                                                                                 ',',
                                                                                                 [Marketing Specialist]
                                                                                             ) + 1,
                                                                                    LEN([Marketing Specialist])
                                                                                )
                                                                      )
                                                                ) = REPLACE(
                                                                               msi.msifirstname,
                                                                               '-NA', ''
                                                                           )
                                                       AND cu.[AFI Sales RepID] = msi.RepID
                                        WHERE
                                                ISNULL(Email, '') <> ''
                                                AND NOT EXISTS
                                            (
                                                SELECT
                                                    1
                                                FROM
                                                    #CURRENT_MAILID cm
                                                WHERE
                                                    msi.SalesNo = cm.SalesNo
                                                    AND msi.RepID = cm.RepID
                                            )
                                    ) tbl
                            ) t1
                        GROUP BY
                            RepID,
                            SalesNo;


            UPDATE
                #CURRENT
            SET
                #CURRENT.[Marketing Specialist Mail ID] =
                    (
                        SELECT
                            #CURRENT_MAILID.Email
                        FROM
                            #CURRENT_MAILID
                        WHERE
                            #CURRENT_MAILID.SalesNo = #CURRENT.[Marketing Specialist ID]
                            AND #CURRENT_MAILID.RepID = #CURRENT.[AFI Sales RepID]
                    );
            ----------------------------- Marketing Specialist Email id End -------------------



            -- Deactivate missing /changed rows

            SELECT
                    SalesTerritoryID
            INTO
                    #TEMPOLD
            FROM
                    AFISales_DW.DimSalesTerritories t1
                LEFT JOIN
                    #CURRENT                        t2
                        ON t1.[AFI Sales Category] = t2.[AFI Sales Category]
                           AND t1.[AFI Sales Region Code] = t2.[AFI Sales Region Code]
                           AND t1.[AFI Sales RepID] = t2.[AFI Sales RepID]
                           AND t1.[AFI Sales Division Code] = t2.[AFI Sales Division Code]
                           AND t1.[Product Line] = t2.[Product Line]
            WHERE
                    t1.[Active Record] = 1
                    AND
                        (
                            t2.[AFI Sales Region Code] IS NULL
                            OR t1.[AFI Sales Division] <> t2.[AFI Sales Division]
                            OR t1.[AFI Sales Category Name] <> t2.[AFI Sales Category Name]
                            OR t1.[AFI Sales Region] <> t2.[AFI Sales Region]
                            OR t1.[AFI Sales Region Type] <> t2.[AFI Sales Region Type]
                            OR t1.[Marketing Specialist ID] <> t2.[Marketing Specialist ID]
                            OR t1.[Marketing Specialist] <> t2.[Marketing Specialist]
                            OR t1.[AFI Alternate Division Code] <> t2.[AFI Alternate Division Code]
                            OR t1.[AFI Alternate Division] <> t2.[AFI Alternate Division]
                            OR t1.[Sales Regional VP] <> t2.[Sales Regional VP]
                            OR t1.[Sales Division President] <> t2.[Sales Division President]
                            OR ISNULL(t1.[Business Name], '') <> ISNULL(t2.[Business Name], '')
                            OR ISNULL(t1.[Marketing Specialist Mail ID], '') <> ISNULL(
                                                                                          t2.[Marketing Specialist Mail ID],
                                                                                          ''
                                                                                      )
                            OR ISNULL(t1.RegionCode_RepID_Category, '') <> ISNULL(t2.RegionCode_RepID_Category, '')
                        );


            -- Deactivate changed records

            UPDATE
                AFISales_DW.DimSalesTerritories
            SET
                [Active Record] = 0,
                Deactivated = @DateValue
            WHERE
                SalesTerritoryID IN
                    (
                        SELECT
                            SalesTerritoryID
                        FROM
                            #TEMPOLD
                    );

            --- Add new rows 
            DECLARE @MaxRow BIGINT;
            SET @MaxRow = ISNULL(
                              (
                                  SELECT
                                      MAX([SalesTerritoryID])
                                  FROM
                                      AFISales_DW.DimSalesTerritories
                              ), 0
                                );

            INSERT INTO AFISales_DW.DimSalesTerritories
                (
                    [SalesTerritoryID],
                    RegionCode_RepID_Category,
                    [AFI Sales Division Code],
                    [AFI Sales Division],
                    [AFI Sales Region Code],
                    [AFI Sales RepID],
                    [AFI Sales Region],
                    [AFI Sales Region Type],
                    [Marketing Specialist ID],
                    [Marketing Specialist],
                    [AFI Sales Category],
                    [AFI Sales Category Name],
                    [AFI Alternate Division Code],
                    [AFI Alternate Division],
                    [Sales Regional VP],
                    [Sales Division President],
                    [Product Line],
                    [Business Name],
                    [Active Record],
                    [Marketing Specialist Mail ID],
                    Activated
                )
                        SELECT
                            [NewID] + @MaxRow                                               AS [SalesTerritoryID],
                            RegionCode_RepID_Category,
                            [AFI Sales Division Code],
                            [AFI Sales Division],
                            TRIM([AFI Sales Region Code])                                   AS [AFI Sales Region Code],
                            TRIM([AFI Sales RepID])                                         AS [AFI Sales RepID],
                            [AFI Sales Region],
                            TRIM([AFI Sales Region Type])                                   AS [AFI Sales Region Type],
                            [Marketing Specialist ID],
                            TRIM([Marketing Specialist])                                    AS [Marketing Specialist],
                            [AFI Sales Category],
                            [AFI Sales Category Name],
                            [AFI Alternate Division Code],
                            TRIM([AFI Alternate Division])                                  AS [AFI Alternate Division],
                            TRIM([Sales Regional VP])                                       AS [Sales Regional VP],
                            --[Sales Regional VP],
                            [Sales Division President],
                            [Product Line],
                            [Business Name],
                            1                                                               AS [Active Record],
                            [Marketing Specialist Mail ID],
                             @DateValue AS Activated
                        FROM
                            (
                                SELECT
                                        ROW_NUMBER() OVER (ORDER BY
                                                               t1.[AFI Sales Category]
                                                          ) AS [NewID],
                                        t1.*
                                FROM
                                        #CURRENT                        t1
                                    LEFT JOIN
                                        AFISales_DW.DimSalesTerritories t2
                                            ON t1.[AFI Sales Category] = t2.[AFI Sales Category]
                                               AND t1.[AFI Sales Region Code] = t2.[AFI Sales Region Code]
                                               AND t1.[AFI Sales RepID] = t2.[AFI Sales RepID]
                                               AND t1.[AFI Sales Division Code] = t2.[AFI Sales Division Code]
                                               AND t1.[Product Line] = t2.[Product Line]
                                               AND t2.[Active Record] = 1
                                WHERE
                                        t2.[AFI Sales Region Code] IS NULL
                            ) NewRecords;



            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                'Temdb..#TEMPOLD';
            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                'Temdb..#CURRENT';

        END TRY
        BEGIN CATCH
            DECLARE
                @ErrorMessage  VARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState    INT;
            SET @ErrorMessage = ERROR_MESSAGE();
            SET @ErrorSeverity = ISNULL(ERROR_SEVERITY(), 16);
            SET @ErrorState = ISNULL(ERROR_STATE(), 0);
            SET @DateValue = GETDATE();
            SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)

            INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
            VALUES
                (
                    @String, @DateValue, @User, @ErrorMessage
                );

            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        END CATCH;

        SET @DateValue = GETDATE();
        SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)


        -- Update last modified in Table Dictionary 
        INSERT INTO [$(ETL_Framework)].DW_Developer.TableDictionary_UpdateLog
        VALUES
            (
               'AFISales_DW', 'AFISales_DW', 'DimSalesTerritories', @DateValue
            );


    END;
GO