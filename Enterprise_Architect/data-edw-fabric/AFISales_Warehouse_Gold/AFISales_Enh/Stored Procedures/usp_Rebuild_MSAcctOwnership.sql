CREATE PROC [AFISales_Enh].[usp_Rebuild_MSAcctOwnership]
AS

    /* Change Control -----------------------------------------------------------------------------------------------------------
* Procedure: [AFISales_Enh].[usp_Rebuild_MSAcctOwnership]
* Description: Build Account Ownership by territory
* Author: Matt Carter          Date: 07/27/04
* bh 10/2006 added MrktSpclstAcctOwnershipSlsCat, sales category logic
* TB 02/08/2013 Changed Truncate to Delete FROM datawhse.dbo.MrktSpclstAcctOwnership (because its now IN replication)
* BH, converted to run IN PDW jan, 2017. converted to run IN ADW Jan, 2018
* Gabe De Mayo (2/27/18): Modified to use usp_CreateReplicateWorkTable/updated object existence check/updated error handling
* Amy Morina 04/26/2018 changed all references to GETDATE() to DW_Developer.fn_GetCSTDate(GETDATE())
* 02/26/2020 Changed insert to "Values" syntax to avoid exclusive locks
---------------------------------------------------------------------------------------------------------------------------*/

    BEGIN

        DECLARE
            @String    VARCHAR(5000),
            @DateValue DATETIME2(6),
            @User      VARCHAR(500);

        SET @String = 'AFISales_DW.AFISales_Enh.usp_Rebuild_MSAcctOwnership';
        SET @User = SYSTEM_USER;

        SET @DateValue = Getdate()
         SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)

        INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
        VALUES
            (
                @String, @DateValue, @User, 'Process Start'
            );

        BEGIN TRY

            /*** Get Bill-to ownership ***/

            CREATE TABLE #tb_repCustomers
                (
                    AccountNum    CHAR(8),
                    ShipNum       CHAR(4),
                    RepID         CHAR(5),
                    Division      CHAR(1),
                    Region        CHAR(5),
                    SalesCategory CHAR(3),
                    Ratio         FLOAT
                );


            INSERT INTO #tb_repCustomers
                        SELECT
                                AccountNum    = AccountMaster.CustomerNumber,
                                ShipNum       = CAST('' AS VARCHAR(4)),
                                RepID         = TerritoryAllocationStatic.RepID,
                                Division      = TerritoryAllocationStatic.DivisionCode,
                                Region        = TerritoryAllocationStatic.RegionCode,
                                SalesCategory = TerritoryAllocationStatic.SalesCategory,
                                Ratio         = 1
                        FROM
                                [$(Wholesale_Warehouse)].Customers.AccountMaster 
                            JOIN
                                AFISales_Enh.TerritoryAllocationStatic
                                    ON AccountMaster.PrimaryTerritory = TerritoryCode
                            JOIN
                                [$(Wholesale_Warehouse)].Customers.ShippingLocations
                                    ON AccountMaster.CustomerNumber = ShippingLocations.CustomerNumber
                                       AND ShippingLocations.ShiptoNumber = ''
                            LEFT JOIN
                                (
                                    SELECT DISTINCT
                                           CustomerOwnershipExceptions.Division,
                                           CustomerOwnershipExceptions.CustomerNumber,
                                           CustomerOwnershipExceptions.ShiptoNumber
                                    FROM
                                           [$(Wholesale_Warehouse)].Marketing.CustomerOwnershipExceptions
                                    WHERE
                                           CustomerOwnershipExceptions.RepID IS NOT NULL
                                )                                 t1
                                    ON t1.Division = TerritoryAllocationStatic.DivisionCode
                                       AND t1.CustomerNumber = ShippingLocations.CustomerNumber
                                       AND t1.ShiptoNumber = ShippingLocations.ShiptoNumber
                        WHERE
                                t1.CustomerNumber IS NULL
                                AND TerritoryAllocationStatic.SalesSplitPercent = 1
                                AND AccountMaster.CustomerNumber NOT IN
                                        (
                                            SELECT
                                                PresBillToExceptions.CustomerNumber
                                            FROM
                                                [$(Wholesale_Warehouse)].Marketing.PresBillToExceptions
                                        )
                        GROUP BY
                                AccountMaster.CustomerNumber,
                                TerritoryAllocationStatic.RepID,
                                TerritoryAllocationStatic.DivisionCode,
                                TerritoryAllocationStatic.RegionCode,
                                TerritoryAllocationStatic.SalesCategory;


            -- Add Ownership Exceptions
            INSERT INTO #tb_repCustomers
                        SELECT
                                ShippingLocations.CustomerNumber,
                                '',
                                a.RepID,
                                a.Division,
                                a.RegionCode,
                                a.SalesCategory,
                                Ratio = 1
                        FROM
                                [$(Wholesale_Warehouse)].Customers.ShippingLocations
                            JOIN
                                (
                                    SELECT
                                            CustomerOwnershipExceptions.CustomerNumber,
                                            CustomerOwnershipExceptions.ShiptoNumber,
                                            CustomerOwnershipExceptions.Division,
                                            TerritoryAllocationStatic.RegionCode ,
                                            TerritoryAllocationStatic.SalesCategory ,
                                            TerritoryAllocationStatic.RepID 
                                        FROM
                                            [$(Wholesale_Warehouse)].Marketing.CustomerOwnershipExceptions
                                        JOIN
                                            AFISales_Enh.TerritoryAllocationStatic
                                                ON CustomerOwnershipExceptions.Division = TerritoryAllocationStatic.DivisionCode
                                                   AND CustomerOwnershipExceptions.RepID = TerritoryAllocationStatic.RepID
                                    WHERE
                                            CustomerOwnershipExceptions.CustomerNumber NOT IN
                                                (
                                                    SELECT
                                                        PresBillToExceptions.CustomerNumber
                                                    FROM
                                                        [$(Wholesale_Warehouse)].Marketing.PresBillToExceptions
                                                )
                                    GROUP BY
                                            CustomerOwnershipExceptions.CustomerNumber,
                                            CustomerOwnershipExceptions.ShiptoNumber,
                                            CustomerOwnershipExceptions.Division,
                                            TerritoryAllocationStatic.RegionCode,
                                            TerritoryAllocationStatic.SalesCategory,
                                            TerritoryAllocationStatic.RepID
                                ) a
                                    ON a.CustomerNumber = ShippingLocations.CustomerNumber
                                       AND a.ShiptoNumber = ShippingLocations.ShiptoNumber;

            /*** Get Ship-to Ownership for those accounts that we split by ship-to instead of bill-to ***/
            -- Get base accounts

            CREATE TABLE #tb_splitList
                (
                    csmCusno CHAR(8),
                    csmShpno CHAR(4),
                    csmTerr2 CHAR(5)
                );


            INSERT INTO #tb_splitList
                        SELECT
                            ShippingLocations.CustomerNumber,
                            ShippingLocations.ShiptoNumber,
                            ShippingLocations.ShippingTerritory
                        FROM
                            [$(Wholesale_Warehouse)].Customers.ShippingLocations
                        WHERE
                            ShippingLocations.CustomerNumber IN
                                (
                                    SELECT
                                        PresBillToExceptions.CustomerNumber
                                    FROM
                                        [$(Wholesale_Warehouse)].Marketing.PresBillToExceptions
                                );

            -- Update base with parent information WHERE it was missing IN detail.
            UPDATE
                #tb_splitList
            SET
                csmTerr2 = AccountMaster.PrimaryTerritory
            FROM
                [$(Wholesale_Warehouse)].Customers.AccountMaster
            WHERE
                csmCusno = AccountMaster.CustomerNumber
                AND csmTerr2 IN (
                                    '00000', '0000', '    0', ''
                                );

            -- Add Ship-to list of accounts to the bill-to list.
            INSERT INTO #tb_repCustomers
                        SELECT
                                AccountNum    = CustomerList.csmCusno,
                                ShipNum       = CustomerList.csmShpno,
                                RepID         = TerritoryAllocationStatic.RepID,
                                Division      = TerritoryAllocationStatic.DivisionCode,
                                Region        = TerritoryAllocationStatic.RegionCode,
                                SalesCategory = TerritoryAllocationStatic.SalesCategory,
                                Ratio         = TerritoryAllocationStatic.SalesSplitPercent
                        FROM
                                AFISales_Enh.TerritoryAllocationStatic
                            JOIN
                                #tb_splitList  CustomerList
                                    ON CustomerList.csmTerr2 = TerritoryAllocationStatic.TerritoryCode
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Marketing.CustomerOwnershipExceptions
                                    ON CustomerOwnershipExceptions.Division = TerritoryAllocationStatic.DivisionCode
                                       AND CustomerOwnershipExceptions.CustomerNumber = CustomerList.csmCusno
                                       AND CustomerOwnershipExceptions.ShiptoNumber = CustomerList.csmShpno
                        WHERE
                                CustomerOwnershipExceptions.RepID IS NULL
                        GROUP BY
                                CustomerList.csmCusno,
                                CustomerList.csmShpno,
                                TerritoryAllocationStatic.SalesSplitPercentRepID,
                                TerritoryAllocationStatic.DivisionCode,
                                TerritoryAllocationStatic.RegionCode,
                                TerritoryAllocationStatic.SalesCategory,
                                TerritoryAllocationStatic.SalesSplitPercent;

            -- Add Ownership Exceptions for ship-to level
            INSERT INTO #tb_repCustomers
                        SELECT
                                ShippingLocations.CustomerNumber,
                                ShippingLocations.ShiptoNumber,
                                a.RepID,
                                a.Division,
                                a.RegionCode,
                                a.SalesCategory,
                                Ratio = 1
                        FROM
                                [$(Wholesale_Warehouse)].Customers.ShippingLocations
                            JOIN
                                (
                                    SELECT
                                            CustomerOwnershipExceptions.CustomerNumber,
                                            CustomerOwnershipExceptions.ShiptoNumber,
                                            CustomerOwnershipExceptions.Division,
                                            TerritoryAllocationStatic.RegionCode,
                                            TerritoryAllocationStatic.SalesCategory,
                                            CustomerOwnershipExceptions.RepID
                                    FROM
                                            [$(Wholesale_Warehouse)].Marketing.CustomerOwnershipExceptions
                                        JOIN
                                            AFISales_Enh.TerritoryAllocationStatic
                                                ON CustomerOwnershipExceptions.Division = TerritoryAllocationStatic.DivisionCode
                                                   AND CustomerOwnershipExceptions.RepID = TerritoryAllocationStatic.RepID
                                    WHERE
                                            CustomerOwnershipExceptions.CustomerNumber IN
                                                (
                                                    SELECT
                                                        PresBillToExceptions.CustomerNumber
                                                    FROM
                                                        [$(Wholesale_Warehouse)].Marketing.PresBillToExceptions
                                                )
                                    GROUP BY
                                            CustomerOwnershipExceptions.CustomerNumber,
                                            CustomerOwnershipExceptions.ShiptoNumber,
                                            CustomerOwnershipExceptions.Division,
                                            TerritoryAllocationStatic.RegionCode,
                                            CustomerOwnershipExceptions.RepID,
                                            TerritoryAllocationStatic.SalesCategory
                                ) a
                                    ON a.CustomerNumber = ShippingLocations.CustomerNumber
                                       AND a.ShiptoNumber = ShippingLocations.ShiptoNumber;

            /*** Replace tables with copies of new data ***/


            DROP TABLE IF EXISTS
                AFISales_Enh.MrktSpclstAcctOwnership_LOAD;

            CREATE TABLE AFISales_Enh.[MrktSpclstAcctOwnership_LOAD]
                (
                    [Division]       CHAR(1) NOT NULL,
                    [Region]         CHAR(3) NOT NULL,
                    [RepID]          CHAR(5) NOT NULL,
                    [CustomerNumber] CHAR(8) NOT NULL,
                    [ShiptoNumber]   CHAR(4) NOT NULL,
                    [Ratio]          FLOAT   NOT NULL
                );



            INSERT INTO AFISales_Enh.MrktSpclstAcctOwnership_LOAD
                (
                    Division,
                    Region,
                    RepID,
                    CustomerNumber,
                    ShiptoNumber,
                    Ratio
                )
                        SELECT DISTINCT
                               Division,
                               Region,
                               RepID,
                               AccountNum,
                               ShipNum,
                               Ratio
                        FROM
                               #tb_repCustomers;

            CREATE STATISTICS [Stat_MrktSpclstAcctOwnership_Division]
                ON AFISales_Enh.[MrktSpclstAcctOwnership_LOAD]
                (
                    [Division]
                );
            CREATE STATISTICS [Stat_MrktSpclstAcctOwnership_Region]
                ON AFISales_Enh.[MrktSpclstAcctOwnership_LOAD]
                (
                    [Region]
                );
            CREATE STATISTICS [Stat_MrktSpclstAcctOwnership_RepID]
                ON AFISales_Enh.[MrktSpclstAcctOwnership_LOAD]
                (
                    [RepID]
                );
            CREATE STATISTICS [Stat_MrktSpclstAcctOwnership_CustomerNumber]
                ON AFISales_Enh.[MrktSpclstAcctOwnership_LOAD]
                (
                    [CustomerNumber]
                );
            CREATE STATISTICS [Stat_MrktSpclstAcctOwnership_ShiptoNumber]
                ON AFISales_Enh.[MrktSpclstAcctOwnership_LOAD]
                (
                    [ShiptoNumber]
                );



            DROP TABLE IF EXISTS AFISales_Enh.MrktSpclstAcctOwnership;

            EXECUTE sp_rename 'AFISales_Enh.MrktSpclstAcctOwnership_LOAD','MrktSpclstAcctOwnership'

            SET @DateValue = Getdate()
            SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)

                     
            INSERT INTO [$(ETL_Framework)].DW_Developer.TableDictionary_UpdateLog
                    VALUES
                        (
                           'AFISales_DW', 'AFISales_Enh', 'MrktSpclstAcctOwnershipSlsCat', @DateValue
                        );

            DROP TABLE IF EXISTS AFISales_Enh.MrktSpclstAcctOwnershipSlsCat_LOAD;


            CREATE TABLE AFISales_Enh.[MrktSpclstAcctOwnershipSlsCat_LOAD]
                (
                    [Division]       CHAR(1) NOT NULL,
                    [Region]         CHAR(3) NOT NULL,
                    [RepID]          CHAR(5) NOT NULL,
                    [CustomerNumber] CHAR(8) NOT NULL,
                    [ShiptoNumber]   CHAR(4) NOT NULL,
                    [SalesCategory]  CHAR(3) NOT NULL,
                    [Ratio]          FLOAT   NOT NULL
                );



            INSERT INTO AFISales_Enh.MrktSpclstAcctOwnershipSlsCat_LOAD
                (
                    Division,
                    Region,
                    RepID,
                    CustomerNumber,
                    ShiptoNumber,
                    SalesCategory,
                    Ratio
                )
                        SELECT DISTINCT
                               Division,
                               Region,
                               RepID,
                               AccountNum,
                               ShipNum,
                               SalesCategory,
                               Ratio
                        FROM
                               #tb_repCustomers;

            CREATE STATISTICS [Stat_MrktSpclstAcctOwnershipSlsCat_Division]
                ON AFISales_Enh.[MrktSpclstAcctOwnershipSlsCat_LOAD]
                (
                    [Division]
                );
            CREATE STATISTICS [Stat_MrktSpclstAcctOwnershipSlsCat_Region]
                ON AFISales_Enh.[MrktSpclstAcctOwnershipSlsCat_LOAD]
                (
                    [Region]
                );
            CREATE STATISTICS [Stat_MrktSpclstAcctOwnershipSlsCat_RepID]
                ON AFISales_Enh.[MrktSpclstAcctOwnershipSlsCat_LOAD]
                (
                    [RepID]
                );
            CREATE STATISTICS [Stat_MrktSpclstAcctOwnershipSlsCat_CustomerNumber]
                ON AFISales_Enh.[MrktSpclstAcctOwnershipSlsCat_LOAD]
                (
                    [CustomerNumber]
                );
            CREATE STATISTICS [Stat_MrktSpclstAcctOwnershipSlsCat_ShiptoNumber]
                ON AFISales_Enh.[MrktSpclstAcctOwnershipSlsCat_LOAD]
                (
                    [ShiptoNumber]
                );
            CREATE STATISTICS [Stat_MrktSpclstAcctOwnershipSlsCat_SalesCategory]
                ON AFISales_Enh.[MrktSpclstAcctOwnershipSlsCat_LOAD]
                (
                    [SalesCategory]
                );


            DROP TABLE IF EXISTS AFISales_Enh.MrktSpclstAcctOwnershipSlsCat;

        
            EXECUTE sp_rename 'AFISales_Enh.MrktSpclstAcctOwnershipSlsCat_LOAD','MrktSpclstAcctOwnershipSlsCat'

            DROP TABLE #tb_repCustomers;
            DROP TABLE #tb_splitList;

        END TRY
        BEGIN CATCH
            DECLARE
                @ErrorMessage  VARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState    INT;
            SET @ErrorMessage = ERROR_MESSAGE();
            SET @ErrorSeverity = ISNULL(ERROR_SEVERITY(), 16);
            SET @ErrorState = ISNULL(ERROR_STATE(), 0);
            
            SET @DateValue = Getdate()
            SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)


            INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
            VALUES
                (
                    @String, @DateValue, @User, @ErrorMessage
                );

            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        END CATCH;

        SET @DateValue = Getdate()
         SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)

        EXEC [$(ETL_Framework)].DW_Developer.usp_UpdateTableDictionary_ModifiedDate 
            'AFISales_DW', 'AFISales_Enh', 'MrktSpclstAcctOwnershipSlsCat', @String, @DateValue;


    END;