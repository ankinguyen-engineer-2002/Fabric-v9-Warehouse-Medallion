CREATE PROC [AFISales_DW].[usp_Refresh_DimCustomers]
AS

    /* Change Control -----------------------------------------------------------------------------------------------------------
* Procedure: [AFISales_DW].[usp_Refresh_DimCustomers]
* Description: Process rebuilds DimADNoticeDetails using a "Create, Drop and Rename" method
*   Account And Shipto Numbers are being concatinated resulting in a unique key for the dimension
* Bob Horton (Jan 2018): Migrated from PDW Cube load view to Azure Data Warehouse
* Gabe De Mayo (2/27/18): Modified to use usp_CreateReplicateWorkTable/updated object existence check/updated error handling
* Gabe De Mayo (3/1/18): Added drop statements for work tables
* Gabe De Mayo (3/23/18): Modified to prevent dups
* Amy Morina 04/26/2018 changed all references to GETDATE() to DW_Developer.fn_GetCSTDate(GETDATE())
* Amy Morina 10/24/2018 changed reference from [$(Wholesale_Warehouse)].Marketing.CustomerAccountRating to AFISales_Enh.CustomerAccountRating
* Amy Morina 06/19/2019 added logic that calculated Account Rating at different granularites based on Account Exception Flag
* 2/28/2020 Changed inserts to "Values" syntax to avoid exclusive locks
* 03/16/2020 Changed script Update to insert tpkmodified column in Table Dictionary
* 11/23/2020 Karthick Surendran added logic for HSOwner attribute 
* 1/6/2021 Karthick Surendran changed logic for HSOwner attribute 
* Srinath 7/2/2021 changed [$(Wholesale_Warehouse)].Pricing schema to [$(Wholesale_Warehouse)].Pricing_AFI
* Karthick Surendran 4/18/2022 Changed zero to E for the fields [ABC Account-Current Year], [ABC Account-Previous Year] and [ABC Account-2 Years Ago] when there is no matching records in the system
* Ramya (6/20/2022): Added CAST and TRIM functions from view to curation SP
* Bob Horton 11/9/2023 converted to Fabric
---------------------------------------------------------------------------------------------------------------------------*/

    BEGIN

        DECLARE
            @String    VARCHAR(5000),
            @DateValue DATETIME,
            @User      VARCHAR(500);
        SET @String = 'AFISales_DW.AFISales_DW.usp_Refresh_DimCustomers';
        SET @User = SYSTEM_USER;

        SET @DateValue = GETDATE();
        SELECT
            @DateValue = CSTDateValue
        FROM
            [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue);

        INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
        VALUES
            (
                @String, @DateValue, @User, 'Process Start'
            );


        BEGIN TRY


            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                '#ActiveLocationDetails';

            SELECT
                    Location.Osllicenseeid,
                    Location.Osllocationid,
                    Location.Oslaccountno,
                    Location.Oslshipto
            INTO
                    #ActiveLocationDetails
            FROM
                    [$(Source_Data)].[MasterData_OneSource].[OSLocation] Location
                INNER JOIN
                    (
                        SELECT
                            Location.Oslaccountno,
                            Location.Oslshipto,
                            MAX(Location.Dtea) max_dtea
                        FROM
                            [$(Source_Data)].[MasterData_OneSource].[OSLocation]  Location
                        WHERE
                            Location.Osllocationstatusnotes NOT IN (
                                                            'Closed', 'Inactive', 'Denied'
                                                        )
                        GROUP BY
                            Location.Oslaccountno,
                            Location.Oslshipto
                    ) AL
                        ON Location.Oslaccountno = AL.Oslaccountno
                           AND Location.Oslshipto = AL.Oslshipto
                           AND Location.Dtea = AL.max_dtea;


            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                '#hopProspect';

            SELECT
                    ContactJoin.Oscjcontactid,
                    ContactJoin.Oscjlocationid,
                    ContactJoin.Oscjcontacttype
            INTO
                    #hopProspect
            FROM
                    [$(Source_Data)].[MasterData_OneSource].[OSContactjoin] ContactJoin
                INNER JOIN
                    (
                        SELECT
                                OSL.Oslaccountno + '-' + OSL.Oslshipto AS oslAccountNo,
                                ContactJoin.Oscjlocationid,
                                MAX(ContactJoin.Dtea)            max_dtea
                        FROM
                                [$(Source_Data)].[MasterData_OneSource].[OSContactjoin] ContactJoin
                            INNER JOIN
                                #ActiveLocationDetails OSL
                                    ON ContactJoin.Oscjlocationid = OSL.Osllocationid
                        WHERE
                                ContactJoin.Oscjcontacttype = 'hopProspect'
                        GROUP BY
                                OSL.Oslaccountno + '-' + OSL.Oslshipto,
                                ContactJoin.Oscjlocationid
                    ) b
                        ON ContactJoin.Oscjlocationid = b.Oscjlocationid
                           AND ContactJoin.Dtea = b.max_dtea
                           AND ContactJoin.Oscjcontacttype = 'hopProspect';


            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                '#ActiveHSOwnerDetails_Initial';

            SELECT DISTINCT
                   *
            INTO
                   #ActiveHSOwnerDetails_Initial
            FROM
                   (
                       SELECT  DISTINCT
                               Location.Oslaccountno,
                               Location.Oslshipto,
                               CASE
                                   WHEN Location.Oslshipto <> ''
                                       THEN
                                       Location.Oslaccountno + '-' + Location.Oslshipto
                                   ELSE
                                       Location.Oslaccountno
                               END        AS AccNo,
                               ContactJoin.Oscjcontactid,
                               CASE
                                   WHEN Contact.Oscfirstname <> ''
                                       THEN
                                       Contact.Osclastname + ', ' + Contact.Oscfirstname
                                   ELSE
                                       Contact.Osclastname
                               END        AS HSOwner
                       FROM
                               [$(Source_Data)].[MasterData_OneSource].[OSLocation] Location
                           INNER JOIN
                               [$(Source_Data)].[MasterData_OneSource].[OSContactjoin] ContactJoin
                                   ON Location.Osllicenseeid = ContactJoin.Oscjlicenseeid
                           INNER JOIN
                               [$(Source_Data)].[MasterData_OneSource].[OSContact] Contact
                                   ON ContactJoin.Oscjcontactid = Contact.Osccontactid
                       WHERE
                               Contact.Osclastname + ', ' + Contact.Oscfirstname IS NOT NULL
                               AND Location.Osllocationstatusnotes NOT IN (
                                                                   'Closed', 'Inactive', 'Denied'
                                                               )
                   ) a
            WHERE
                   a.[HSOwner] <> 'Corporate';

            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                '#ActiveHSOwnerDetails_Final';

            SELECT DISTINCT
                   *
            INTO
                   #ActiveHSOwnerDetails_Final
            FROM
                   (
                       SELECT
                               OSL.Oslaccountno,
                               OSL.Oslshipto,
                               CASE
                                   WHEN OSL.Oslshipto <> ''
                                       THEN
                                       OSL.Oslaccountno + '-' + OSL.Oslshipto
                                   ELSE
                                       OSL.Oslaccountno
                               END AS AccNo,
                               oscjJ.Oscjcontactid,
                               CASE
                                   WHEN Contact.Oscfirstname <> ''
                                       THEN
                                       Contact.Osclastname + ', ' + Contact.Oscfirstname
                                   ELSE
                                       Contact.Osclastname
                               END AS HSOwner
                       FROM
                               [$(Source_Data)].[MasterData_OneSource].[OSContact] Contact
                           INNER JOIN
                               #hopProspect           oscjJ
                                   ON Contact.Osccontactid = oscjJ.Oscjcontactid
                           INNER JOIN
                               #ActiveLocationDetails OSL
                                   ON OSL.Osllocationid = oscjJ.Oscjlocationid
                       WHERE
                               Contact.Osclastname IS NOT NULL
                               AND Contact.Oscfirstname IS NOT NULL
                   ) a
            WHERE
                   a.[HSOwner] <> 'Corporate';

            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                '#InactiveLocationDetails';

            SELECT
                    Location.Osllicenseeid,
                    Location.Osllocationid,
                    Location.Oslaccountno,
                    Location.Oslshipto
            INTO
                    #InactiveLocationDetails
            FROM
                    [$(Source_Data)].[MasterData_OneSource].[OSLocation] Location
                INNER JOIN
                    (
                        SELECT
                            Location.Oslaccountno,
                            Location.Oslshipto,
                            MAX(Location.Dtea) max_dtea
                        FROM
                            [$(Source_Data)].[MasterData_OneSource].[OSLocation] Location
                        WHERE
                            Location.Osllocationstatusnotes NOT IN (
                                                            'Denied', 'Operational'
                                                        )
                        GROUP BY
                            Location.Oslaccountno,
                            Location.Oslshipto
                    ) AL
                        ON Location.Oslaccountno = AL.Oslaccountno
                           AND Location.Oslshipto = AL.Oslshipto
                           AND Location.Dtea = AL.max_dtea;

            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                '#InactivehopProspect';

            SELECT
                    ContactJoin.Oscjcontactid,
                    ContactJoin.Oscjlocationid,
                    ContactJoin.Oscjcontacttype
            INTO
                    #InactivehopProspect
            FROM
                     [$(Source_Data)].[MasterData_OneSource].[OSContactjoin] ContactJoin
                INNER JOIN
                    (
                        SELECT
                                OSL.Oslaccountno + '-' + OSL.Oslshipto AS CustomerNumber,
                                ContactJoin.Oscjlocationid,
                                MAX(ContactJoin.Dtea)            max_dtea
                        FROM
                                 [$(Source_Data)].[MasterData_OneSource].[OSContactjoin] ContactJoin
                            INNER JOIN
                                #InactiveLocationDetails OSL
                                    ON ContactJoin.Oscjlocationid = OSL.Osllocationid
                        WHERE
                                ContactJoin.Oscjcontacttype = 'hopProspect'
                        GROUP BY
                                OSL.Oslaccountno + '-' + OSL.Oslshipto,
                                ContactJoin.Oscjlocationid
                    ) b
                        ON ContactJoin.Oscjlocationid = b.Oscjlocationid
                           AND ContactJoin.Dtea = b.max_dtea
                           AND ContactJoin.Oscjcontacttype = 'hopProspect';

            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                '#InactiveHSOwnerDetails_Initial';

            SELECT DISTINCT
                   *
            INTO
                   #InactiveHSOwnerDetails_Initial
            FROM
                   (
                       SELECT  DISTINCT
                               Location.Oslaccountno,
                               Location.Oslshipto,
                               CASE
                                   WHEN Location.Oslshipto <> ''
                                       THEN
                                       Location.Oslaccountno + '-' + Location.Oslshipto
                                   ELSE
                                       Location.Oslaccountno
                               END        AS AccNo,
                               ContactJoin.Oscjcontactid,
                               CASE
                                   WHEN Contact.Oscfirstname <> ''
                                       THEN
                                       Contact.Osclastname + ', ' + Contact.Oscfirstname
                                   ELSE
                                       Contact.Osclastname
                               END        AS HSOwner
                       FROM
                                [$(Source_Data)].[MasterData_OneSource].[OSLocation] Location
                           INNER JOIN
                                [$(Source_Data)].[MasterData_OneSource].[OSContactjoin] ContactJoin
                                   ON Location.Osllicenseeid = ContactJoin.Oscjlicenseeid
                           INNER JOIN
                                [$(Source_Data)].[MasterData_OneSource].[OSContact] Contact
                                   ON ContactJoin.Oscjcontactid = Contact.Osccontactid
                       WHERE
                               Contact.Osclastname + ', ' + Contact.Oscfirstname IS NOT NULL
                               AND Location.Osllocationstatusnotes NOT IN (
                                                                   'Operational', 'Denied'
                                                               )
                   ) a
            WHERE
                   a.[HSOwner] <> 'Corporate';

            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                '#InactiveHSOwnerDetails_Final';

            SELECT DISTINCT
                   *
            INTO
                   #InactiveHSOwnerDetails_Final
            FROM
                   (
                       SELECT
                               OSL.Oslaccountno,
                               OSL.Oslshipto,
                               CASE
                                   WHEN OSL.Oslshipto <> ''
                                       THEN
                                       OSL.Oslaccountno + '-' + OSL.Oslshipto
                                   ELSE
                                       OSL.Oslaccountno
                               END AS AccNo,
                               oscjJ.Oscjcontactid,
                               CASE
                                   WHEN Contact.Oscfirstname <> ''
                                       THEN
                                       Contact.Osclastname + ', ' + Contact.Oscfirstname
                                   ELSE
                                       Contact.Osclastname
                               END AS HSOwner
                       FROM
                                [$(Source_Data)].[MasterData_OneSource].[OSContact] Contact
                           INNER JOIN
                               #InactivehopProspect     oscjJ
                                   ON Contact.Osccontactid = oscjJ.Oscjcontactid
                           INNER JOIN
                               #InactiveLocationDetails OSL
                                   ON OSL.Osllocationid = oscjJ.Oscjlocationid
                       WHERE
                               Contact.Osclastname IS NOT NULL
                               AND Contact.Oscfirstname IS NOT NULL
                   ) a
            WHERE
                   a.[HSOwner] <> 'Corporate';




            EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                'AFISales_DW.DimCustomers_LOAD';

            CREATE TABLE AFISales_DW.DimCustomers_LOAD
                (
            [Account And Shipto Number]     [CHAR](13)       NULL,
            [Customer Name]                 [VARCHAR](25)    NULL,
            [Customer Account Number]       [CHAR](8)        NULL,
            [Customer Shipto Number]        [CHAR](4)        NULL,
            [Account Exception Flag]        [INT]            NULL,
            [Discount Code]                 [CHAR](3)        NULL,
            [Discount Code Description]     [VARCHAR](30)    NULL,
            [AFI Discount Description]      [VARCHAR](35)    NULL,
            [Price Code]                    [CHAR](6)        NULL,
            [Price Code Description]        [VARCHAR](30)    NULL,
            [AFI Price Description]         [VARCHAR](38)    NULL,
            [Freight Code]                  [CHAR](3)        NULL,
            [Freight Code Description]      [VARCHAR](30)    NULL,
            [AFI Freight Description]       [VARCHAR](35)    NULL,
            [Commission Code]               [CHAR](3)        NULL,
            [Commission Code Description]   [VARCHAR](30)    NULL,
            [AFI Commission Code]           [VARCHAR](35)    NULL,
            [Customer Shipto Name]          [VARCHAR](35)    NULL,
            [Customer Segment]              [INT]        NULL,
            [Business Type Code]            [CHAR](2)        NULL,
            [Business Type]                 [VARCHAR](30)    NOT NULL,
            [Reporting Business Type]       [VARCHAR](50)    NULL,
            [Customer Service Repid]        [CHAR](5)        NOT NULL,
            [Customer Service Agent Name]   [VARCHAR](50)    NOT NULL,
            [Customer Service Group ID]     [CHAR](2)        NOT NULL,
            [Customer Service Group Leader] [VARCHAR](10)    NOT NULL,
            [Store Address ID]              [INT]            NULL,
            [Shipto AddressID]              [INT]            NULL,
            [Primary Sales Territory]       [CHAR](5)        NULL,
            [Shipto Sales Territory]        [CHAR](5)        NULL,
            [Customer Account Status]       [CHAR](1)        NULL,
            [DFI Account Flag]              [CHAR](1)        NOT NULL,
            [AFI Credit Terms]              [VARCHAR](30)    NULL,
            [Terms Code]                    [CHAR](3)        NULL,
            [Credit Territory Code]         [INT]        NULL,
            [Default Warehouse]             [CHAR](3)        NULL,
            [Terms Description]             [VARCHAR](25)    NULL,
            [Route Zone]                    [CHAR](3)        NOT NULL,
            [Route Region]                  [CHAR](3)        NOT NULL,
            [Bill To Address 1]             [VARCHAR](35)    NULL,
            [Bill To Address 2]             [VARCHAR](35)    NULL,
            [Bill To Address 3]             [VARCHAR](35)    NULL,
            [Bill To Address 4]             [VARCHAR](35)    NULL,
            [Bill To Address 5]             [VARCHAR](35)    NULL,
            [Bill To City]                  [VARCHAR](35)    NULL,
            [Bill To State]                 [CHAR](2)        NULL,
            [Bill To Zip Code]              [VARCHAR](10)    NULL,
            [Bill To Country]               [CHAR](3)        NULL,
            [Bill To-Buyer Name]            [VARCHAR](50)    NULL,
            [Bill To-Buyer Phone]           [VARCHAR](50)    NULL,
            [Bill To-Buyer Fax]             [VARCHAR](50)    NULL,
            [Bill To-Buyer Email]           [VARCHAR](50)    NULL,
            [Bill To-Receiving Name]        [VARCHAR](50)    NULL,
            [Bill To-Receiving Phone]       [VARCHAR](50)    NULL,
            [Bill To-Receiving Fax]         [VARCHAR](50)    NULL,
            [Bill To-Receiving Email]       [VARCHAR](50)    NULL,
            [Ship To-Buyer Name]            [VARCHAR](50)    NULL,
            [Ship To-Buyer Phone]           [VARCHAR](50)    NULL,
            [Ship To-Buyer Fax]             [VARCHAR](50)    NULL,
            [Ship To-Buyer Email]           [VARCHAR](50)    NULL,
            [Ship To-Receiving Name]        [VARCHAR](50)    NULL,
            [Ship To-Receiving Phone]       [VARCHAR](50)    NULL,
            [Ship To-Receiving Fax]         [VARCHAR](50)    NULL,
            [Ship To-Receiving Email]       [VARCHAR](50)    NULL,
            [Shipto Details]                [VARCHAR](80)    NULL,
            [ACI Amount]                    [DECIMAL](15, 2) NULL,
            [Outstanding Balance]           [DECIMAL](14, 2) NOT NULL,
            [Days Beyond Terms - 90]        [DECIMAL](14, 0) NOT NULL,
            [Days Beyond Terms - 365]       [DECIMAL](14, 0) NOT NULL,
            [Credit Limit]                  [DECIMAL](14, 0) NOT NULL,
            [Invoice Type]                  [CHAR](1)        NULL,
            [EPay Flag]                     [CHAR](1)        NULL,
            [Currency Type]                 [CHAR](3)        NULL,
            [Highest Credit]                [DECIMAL](28, 2) NOT NULL,
            [ABC Account-Current Year]      [CHAR](1)        NOT NULL,
            [ABC Account-Previous Year]     [CHAR](1)        NOT NULL,
            [ABC Account-2 Years Ago]       [CHAR](1)        NOT NULL,
            [HS Owner]                      [VARCHAR](50)    NULL,
            [District Manager]              [VARCHAR](50)    NULL,
            [CustomerandAccountNumber]      [VARCHAR](50)    NULL
                );


            INSERT INTO AFISales_DW.DimCustomers_LOAD
                        SELECT  DISTINCT
                                TRIM(   CASE
                                            WHEN ShippingLocations.ShiptoNumber IS NULL
                                                 OR ShippingLocations.ShiptoNumber = ''
                                                THEN
                                                ShippingLocations.CustomerNumber
                                            ELSE
                                                RTRIM(ShippingLocations.CustomerNumber) + '-'
                                                + LTRIM(ShippingLocations.ShiptoNumber)
                                        END
                                    )                                                                              AS [Account And Shipto Number],
                                TRIM(AccountMaster.CustomerName)                                                   AS [Customer Name],
                                TRIM(ShippingLocations.CustomerNumber)                                             AS [Customer Account Number],
                                TRIM(ShippingLocations.ShiptoNumber)                                               AS [Customer Shipto Number],
                                CASE
                                    WHEN PresBillToExceptions.CustomerNumber IS NULL
                                        THEN
                                        CAST(0 AS INT)
                                    ELSE
                                        CAST(1 AS INT)
                                END                                                                                [Account Exception Flag],
                                TRIM(ShippingLocations.DiscountCode)                                               AS [Discount Code],
                                TRIM(DiscountCodes.Description)                                                    AS [Discount Code Description],
                                TRIM(RTRIM(ShippingLocations.DiscountCode) + ', ' + DiscountCodes.Description)     AS [AFI Discount Code],
                                TRIM(ShippingLocations.PriceCode)                                                  AS [Price Code],
                                TRIM(PriceCode.Description)                                                        AS [Price Code Description],
                                TRIM(RTRIM(ShippingLocations.PriceCode) + ', ' + PriceCode.Description)            AS [AFI Price Code],
                                TRIM(ShippingLocations.FreightCode)                                                AS [Freight Code],
                                TRIM(FreightCodes.Description)                                                     AS [Freight Code Description],
                                TRIM(RTRIM(ShippingLocations.FreightCode) + ', ' + FreightCodes.Description)       AS [AFI Freight Code],
                                TRIM(ShippingLocations.CommissionCode)                                             AS [Commission Code],
                                TRIM(CommissionCodes.Description)                                                  AS [Commission Code Description],
                                TRIM(RTRIM(ShippingLocations.CommissionCode) + ', ' + CommissionCodes.Description) AS [AFI Commission Code],
                                TRIM(ShippingLocations.Name)                                                       AS [Customer Shipto Name],
                                ShippingLocations.CustomerSegment                                                  AS [Customer Segment],
                                TRIM(ShippingLocations.BusinessType)                                               AS [Business Type Code],
                                TRIM(ISNULL(BusinessType.Description, ''))                                         AS [Business Type],
                                BusinessType.RptBusType                                                            AS [Reporting Business Type],
                                TRIM(ISNULL(ServiceRepID.ServiceRepID, ''))                                        AS [Customer Service RepID],
                                TRIM(ISNULL(CRM.ShortFullName, ''))                                                AS [Customer Service Agent Name],
                                TRIM(ISNULL(ServiceRepID.GroupID, ''))                                             AS [Customer Service Group ID],
                                ISNULL(ServiceRepGroup.UserID, 'N/A')                                              AS [Customer Service Group Leader],
                                ShippingLocations.BuyerAddressID                                                   AS [Store Address ID],
                                ShippingLocations.RouteAddressID                                                   AS [Shipto AddressID],
                                TRIM(AccountMaster.PrimaryTerritory)                                               AS [Primary Sales Territory],
                                TRIM(ShippingLocations.ShippingTerritory)                                          AS [Shipto Sales Territory],
                                AccountMaster.ActiveRecord                                                                AS [Customer Account Status],
                                CASE
                                    WHEN dfi.CustomerNumber IS NULL
                                        THEN
                                        'N'
                                    ELSE
                                        'Y'
                                END                                                                                AS [DFI Account Flag],
                                TRIM(RTRIM(AccountMaster.TermsCode) + ', ' + TermsCode.Description)                         AS [AFI Credit Terms],
                                TRIM(AccountMaster.TermsCode)                                                      AS [Terms Code],
                                AccountMaster.CreditTerritoryID                                                    AS [Credit Territory Code],
                                TRIM(ShippingLocations.DefaultWarehouse)                                           AS [Default Warehouse],
                                TRIM(TermsCode.Description)                                                                 AS [Terms Description],
                                TRIM(ISNULL(ExtendedCustomerProfile.RouteZone, 'N/A'))                             AS [Route Zone],
                                TRIM(ISNULL(ExtendedCustomerProfile.RouteRegion, 'N/A'))                           AS [Route Region],
                                TRIM(BillTo.Address1)                                                              AS [Bill To Address 1],
                                TRIM(BillTo.Address2)                                                              AS [Bill To Address 2],
                                TRIM(BillTo.Address3)                                                              AS [Bill To Address 3],
                                TRIM(BillTo.Address4)                                                              AS [Bill To Address 4],
                                TRIM(BillTo.Address5)                                                              AS [Bill To Address 5],
                                TRIM(BillTo.City)                                                                  AS [Bill To City],
                                TRIM(BillTo.State)                                                                 AS [Bill To State],
                                TRIM(BillTo.ZipCode)                                                               AS [Bill To Zip Code],
                                TRIM(BillTo.Country)                                                               AS [Bill To Country],
                                TRIM(BTBuy.FullName)                                                               AS [Bill To-Buyer Name],
                                TRIM(BTBuy.PhoneNumber)                                                            AS [Bill To-Buyer Phone],
                                TRIM(BTBuy.FaxNumber)                                                              AS [Bill To-Buyer Fax],
                                TRIM(BTBuy.Email)                                                                  AS [Bill To-Buyer Email],
                                TRIM(BTRec.FullName)                                                               AS [Bill To-Receiving Name],
                                TRIM(BTRec.PhoneNumber)                                                            AS [Bill To-Receiving Phone],
                                TRIM(BTRec.FaxNumber)                                                              AS [Bill To-Receiving Fax],
                                TRIM(BTRec.Email)                                                                  AS [Bill To-Receiving Email],
                                TRIM(STBuy.FullName)                                                               AS [Ship To-Buyer Name],
                                TRIM(STBuy.PhoneNumber)                                                            AS [Ship To-Buyer Phone],
                                TRIM(STBuy.FaxNumber)                                                              AS [Ship To-Buyer Fax],
                                TRIM(STBuy.Email)                                                                  AS [Ship To-Buyer Email],
                                TRIM(STRec.FullName)                                                               AS [Ship To-Receiving Name],
                                TRIM(STRec.PhoneNumber)                                                            AS [Ship To-Receiving Phone],
                                TRIM(STRec.FaxNumber)                                                              AS [Ship To-Receiving Fax],
                                TRIM(STRec.Email)                                                                  AS [Ship To-Receiving Email],
                                TRIM(RTRIM(ShippingLocations.CustomerNumber) + '-' + RTRIM(ShippingLocations.ShiptoNumber)
                                     + '-' + RTRIM(ShippingLocations.Name) + ', ' + RTRIM(ShippingLocations.Address3)
                                     + ', ' + RTRIM(LTRIM(ShippingLocations.State))
                                    )                                                                              AS [Shipto Details],
                                ISNULL(CustomerCredit.ACI_Amount, 0)                                               AS [ACI Amount],
                                ISNULL(CustomerCredit.OutstandingBalance, 0)                                       AS [Outstanding Balance],
                                ISNULL(CustomerCredit.BeyondTerms_90Days, 0)                                       AS [Days Beyond Terms - 90],
                                ISNULL(CustomerCredit.BeyondTerms_365Days, 0)                                      AS [Days Beyond Terms - 365],
                                ISNULL(CustomerCredit.CreditLimit, 0)                                              AS [Credit Limit],
                                InvType                                                                            AS [Invoice Type],
                                EPayAccts.EPayAccount                                                              AS [EPay Flag],
                                AccountMaster.CurrencyCode                                                         AS [Currency Type],
                                ISNULL(CustomerCredit.HighestCredit, 0)                                                               AS [Highest Credit],
                                ISNULL(CustomerAccountRating.CurrentYearRating, 'E')                               AS [ABC Account-Current Year],
                                ISNULL(CustomerAccountRating.PreviousYearRating, 'E')                              AS [ABC Account-Previous Year],
                                ISNULL(CustomerAccountRating.SecondYearRating, 'E')                                AS [ABC Account-2 Years Ago],
                                NULL                                                                               AS HSOwner,
                                NULL                                                                               AS [District Manager],
                                RTRIM(AccountMaster.CustomerName) + '-' + LTRIM(ShippingLocations.CustomerNumber)  AS [CustomerandAccountNumber]
                        FROM
                                [$(Wholesale_Warehouse)].Customers.ShippingLocations
                            JOIN
                                [$(Wholesale_Warehouse)].Customers.AccountMaster
                                    ON AccountMaster.CustomerNumber = ShippingLocations.CustomerNumber
                            LEFT JOIN
                                AFISales_Enh.CustomerAccountRating
                                    ON CustomerAccountRating.CustomerNumber = AccountMaster.CustomerNumber
                                       AND [Account Exception Flag] = 0
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Marketing.BusinessType
                                    ON BusinessType.BusinessTypeCode = ShippingLocations.BusinessType
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Customers.ServiceRepID
                                    ON ServiceRepID.ServiceRepID = ShippingLocations.ServiceRepID
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].PartyContacts.ContactMaster CRM
                                    ON ServiceRepID.ContactID = CRM.ContactID
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Customers.ServiceRepGroup
                                    ON ServiceRepID.GroupID = ServiceRepGroup.GroupID
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Pricing_AFI.CommissionCodes
                                    ON CommissionCodes.CommissionCode = ShippingLocations.CommissionCode
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Pricing_AFI.DiscountCodes
                                    ON DiscountCodes.DiscountCode = ShippingLocations.DiscountCode
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Pricing_AFI.FreightCodes
                                    ON FreightCodes.FreightCode = ShippingLocations.FreightCode
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Pricing_AFI.PriceCode
                                    ON PriceCode.PriceCode = ShippingLocations.PriceCode
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].CustomerOrders_AFI.TermsCode
                                    ON AccountMaster.TermsCode = TermsCode.MapicsTermsCode
                            LEFT JOIN
                                (
                                    SELECT DISTINCT
                                           ShippingLocations.CustomerNumber,
                                           ShippingLocations.ShiptoNumber  
                                    FROM
                                           [$(Wholesale_Warehouse)].Customers.ShippingLocations
                                    WHERE
                                           ShippingLocations.DiscountCode IN
                                               (
                                                   SELECT DISTINCT
                                                          DiscountRates.DiscountCode
                                                   FROM
                                                          [$(Wholesale_Warehouse)].Pricing_AFI.DiscountRates
                                                   WHERE
                                                          DiscountRates.Discount6 <> 0
                                               )
                                )                 dfi
                                    ON ShippingLocations.CustomerNumber = dfi.CustomerNumber
                                       AND ShippingLocations.ShiptoNumber = dfi.ShiptoNumber
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Marketing.PresBillToExceptions
                                    ON PresBillToExceptions.CustomerNumber = ShippingLocations.CustomerNumber
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Customers.ExtendedCustomerProfile
                                    ON ShippingLocations.CustomerNumber = ExtendedCustomerProfile.CustomerNumber
                                       AND ShippingLocations.ShiptoNumber = ExtendedCustomerProfile.ShiptoNumber
                            LEFT JOIN
                                (
                                    SELECT
                                            AccountMaster.CustomerNumber,
                                            AddressMaster.Address1,
                                            AddressMaster.Address2,
                                            AddressMaster.Address3,
                                            AddressMaster.Address4,
                                            AddressMaster.Address5,
                                            AddressMaster.City,
                                            AddressMaster.State,
                                            AddressMaster.ZipCode,
                                            AddressMaster.Country,
                                            ROW_NUMBER() OVER (PARTITION BY
                                                                   AccountMaster.CustomerNumber
                                                               ORDER BY
                                                                   PartyMaster.PartyID DESC
                                                              ) AS RowNumber
                                    FROM
                                            [$(Wholesale_Warehouse)].Customers.AccountMaster
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.PartyMaster
                                                ON AccountMaster.CustomerNumber = PartyMaster.CustomerNumber
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.Locations
                                                ON PartyMaster.PartyID = Locations.PartyID
                                                   AND 'CMA' = Locations.LocationType
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.AddressMaster
                                                ON Locations.AddressID = AddressMaster.AddressID
                                )                 BillTo
                                    ON AccountMaster.CustomerNumber = BillTo.CustomerNumber
                                       AND BillTo.RowNumber = 1
                            LEFT JOIN
                                (
                                    SELECT
                                            AccountMaster.CustomerNumber  AS CustomerNumber,
                                            MAX(ContactMaster.FullName)   AS FullName,
                                            MAX(Phone.CommunicationValue) AS PhoneNumber,
                                            MAX(Fax.CommunicationValue)   AS FaxNumber,
                                            MAX(Email.CommunicationValue) AS Email
                                    FROM
                                            [$(Wholesale_Warehouse)].Customers.AccountMaster
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.PartyMaster
                                                ON AccountMaster.CustomerNumber = PartyMaster.CustomerNumber
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.Locations
                                                ON PartyMaster.PartyID = Locations.PartyID
                                                   AND 'CMA' = Locations.LocationType
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactDefaults
                                                ON Locations.LocationID = ContactDefaults.LocationID
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactBase
                                                ON ContactDefaults.LocationID = ContactBase.LocationID
                                                   AND ContactDefaults.Department = ContactBase.Department
                                                   AND ContactDefaults.ContactType = ContactBase.ContactType
                                                   AND ContactDefaults.ContactID = ContactBase.ContactID
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactMaster
                                                ON ContactDefaults.ContactID = ContactMaster.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Phone'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Phone
                                                ON ContactDefaults.LocationID = Phone.LocationID
                                                   AND ContactDefaults.Department = Phone.Department
                                                   AND ContactDefaults.ContactType = Phone.ContactType
                                                   AND ContactDefaults.ContactID = Phone.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Fax'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Fax
                                                ON ContactDefaults.LocationID = Fax.LocationID
                                                   AND ContactDefaults.Department = Fax.Department
                                                   AND ContactDefaults.ContactType = Fax.ContactType
                                                   AND ContactDefaults.ContactID = Fax.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Email'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Email
                                                ON ContactDefaults.LocationID = Email.LocationID
                                                   AND ContactDefaults.Department = Email.Department
                                                   AND ContactDefaults.ContactType = Email.ContactType
                                                   AND ContactDefaults.ContactID = Email.ContactID
                                    WHERE
                                            ContactDefaults.IsBuyerDefault = 1
                                    GROUP BY
                                            AccountMaster.CustomerNumber
                                )                 BTBuy
                                    ON AccountMaster.CustomerNumber = BTBuy.CustomerNumber
                            LEFT JOIN
                                (
                                    SELECT
                                            AccountMaster.CustomerNumber  AS CustomerNumber,
                                            MAX(ContactMaster.FullName)   AS FullName,
                                            MAX(Phone.CommunicationValue) AS PhoneNumber,
                                            MAX(Fax.CommunicationValue)   AS FaxNumber,
                                            MAX(Email.CommunicationValue) AS Email
                                    FROM
                                            [$(Wholesale_Warehouse)].Customers.AccountMaster
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.PartyMaster
                                                ON AccountMaster.CustomerNumber = PartyMaster.CustomerNumber
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.Locations
                                                ON PartyMaster.PartyID = Locations.PartyID
                                                   AND 'CMA' = Locations.LocationType
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactDefaults
                                                ON Locations.LocationID = ContactDefaults.LocationID
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactBase
                                                ON ContactDefaults.LocationID = ContactBase.LocationID
                                                   AND ContactDefaults.Department = ContactBase.Department
                                                   AND ContactDefaults.ContactType = ContactBase.ContactType
                                                   AND ContactDefaults.ContactID = ContactBase.ContactID
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactMaster
                                                ON ContactDefaults.ContactID = ContactMaster.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Phone'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Phone
                                                ON ContactDefaults.LocationID = Phone.LocationID
                                                   AND ContactDefaults.Department = Phone.Department
                                                   AND ContactDefaults.ContactType = Phone.ContactType
                                                   AND ContactDefaults.ContactID = Phone.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Fax'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Fax
                                                ON ContactDefaults.LocationID = Fax.LocationID
                                                   AND ContactDefaults.Department = Fax.Department
                                                   AND ContactDefaults.ContactType = Fax.ContactType
                                                   AND ContactDefaults.ContactID = Fax.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Email'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Email
                                                ON ContactDefaults.LocationID = Email.LocationID
                                                   AND ContactDefaults.Department = Email.Department
                                                   AND ContactDefaults.ContactType = Email.ContactType
                                                   AND ContactDefaults.ContactID = Email.ContactID
                                    WHERE
                                            ContactDefaults.IsReceivingDefault = 1
                                    GROUP BY
                                            AccountMaster.CustomerNumber
                                )                 BTRec
                                    ON AccountMaster.CustomerNumber = BTRec.CustomerNumber
                            LEFT JOIN
                                (
                                    SELECT
                                            ShippingLocations.CustomerNumber AS CustomerNumber,
                                            ShippingLocations.ShiptoNumber   AS ShiptoNumber,
                                            MAX(ContactMaster.FullName)      AS FullName,
                                            MAX(Phone.CommunicationValue)    AS PhoneNumber,
                                            MAX(Fax.CommunicationValue)      AS FaxNumber,
                                            MAX(Email.CommunicationValue)    AS Email
                                    FROM
                                            [$(Wholesale_Warehouse)].Customers.ShippingLocations
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactDefaults
                                                ON ShippingLocations.PartyLocationID = ContactDefaults.LocationID
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactBase
                                                ON ContactDefaults.LocationID = ContactBase.LocationID
                                                   AND ContactDefaults.Department = ContactBase.Department
                                                   AND ContactDefaults.ContactType = ContactBase.ContactType
                                                   AND ContactDefaults.ContactID = ContactBase.ContactID
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactMaster
                                                ON ContactDefaults.ContactID = ContactMaster.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Phone'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Phone
                                                ON ContactDefaults.LocationID = Phone.LocationID
                                                   AND ContactDefaults.Department = Phone.Department
                                                   AND ContactDefaults.ContactType = Phone.ContactType
                                                   AND ContactDefaults.ContactID = Phone.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Fax'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Fax
                                                ON ContactDefaults.LocationID = Fax.LocationID
                                                   AND ContactDefaults.Department = Fax.Department
                                                   AND ContactDefaults.ContactType = Fax.ContactType
                                                   AND ContactDefaults.ContactID = Fax.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Email'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Email
                                                ON ContactDefaults.LocationID = Email.LocationID
                                                   AND ContactDefaults.Department = Email.Department
                                                   AND ContactDefaults.ContactType = Email.ContactType
                                                   AND ContactDefaults.ContactID = Email.ContactID
                                    WHERE
                                            ContactDefaults.IsBuyerDefault = 1
                                    GROUP BY
                                            ShippingLocations.CustomerNumber,
                                            ShippingLocations.ShiptoNumber
                                )                 STBuy
                                    ON ShippingLocations.CustomerNumber = STBuy.CustomerNumber
                                       AND ShippingLocations.ShiptoNumber = STBuy.ShiptoNumber
                            LEFT JOIN
                                (
                                    SELECT
                                            ShippingLocations.CustomerNumber AS CustomerNumber,
                                            ShippingLocations.ShiptoNumber   AS ShiptoNumber,
                                            MAX(ContactMaster.FullName)      AS FullName,
                                            MAX(Phone.CommunicationValue)    AS PhoneNumber,
                                            MAX(Fax.CommunicationValue)      AS FaxNumber,
                                            MAX(Email.CommunicationValue)    AS Email
                                    FROM
                                            [$(Wholesale_Warehouse)].Customers.ShippingLocations
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactDefaults
                                                ON ShippingLocations.PartyLocationID = ContactDefaults.LocationID
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactBase
                                                ON ContactDefaults.LocationID = ContactBase.LocationID
                                                   AND ContactDefaults.Department = ContactBase.Department
                                                   AND ContactDefaults.ContactType = ContactBase.ContactType
                                                   AND ContactDefaults.ContactID = ContactBase.ContactID
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactMaster
                                                ON ContactDefaults.ContactID = ContactMaster.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Phone'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Phone
                                                ON ContactDefaults.LocationID = Phone.LocationID
                                                   AND ContactDefaults.Department = Phone.Department
                                                   AND ContactDefaults.ContactType = Phone.ContactType
                                                   AND ContactDefaults.ContactID = Phone.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Fax'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Fax
                                                ON ContactDefaults.LocationID = Fax.LocationID
                                                   AND ContactDefaults.Department = Fax.Department
                                                   AND ContactDefaults.ContactType = Fax.ContactType
                                                   AND ContactDefaults.ContactID = Fax.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Email'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Email
                                                ON ContactDefaults.LocationID = Email.LocationID
                                                   AND ContactDefaults.Department = Email.Department
                                                   AND ContactDefaults.ContactType = Email.ContactType
                                                   AND ContactDefaults.ContactID = Email.ContactID
                                    WHERE
                                            ContactDefaults.IsReceivingDefault = 1
                                    GROUP BY
                                            ShippingLocations.CustomerNumber,
                                            ShippingLocations.ShiptoNumber
                                )                 STRec
                                    ON ShippingLocations.CustomerNumber = STRec.CustomerNumber
                                       AND ShippingLocations.ShiptoNumber = STRec.ShiptoNumber
                            --Added by Amanda Radatz on 11/07/2011
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Customers.CustomerCredit
                                    ON ShippingLocations.CustomerNumber = CustomerCredit.CustomerNumber
                            LEFT JOIN
                                (
                                    SELECT
                                            ShippingLocations.CustomerNumber AS CustomerNumber,
                                            ShippingLocations.ShiptoNumber   AS ShiptoNumber,
                                            MAX(   CASE
                                                       WHEN COALESCE(t3.TransactionType, t4.TransactionType, '') = ''
                                                           THEN
                                                           'P'
                                                       ELSE
                                                           COALESCE(t3.TransactionType, t4.TransactionType, '')
                                                   END
                                               )                             AS InvType
                                    FROM
                                            [$(Wholesale_Warehouse)].Customers.ShippingLocations
                                        LEFT JOIN
                                            (
                                                SELECT
                                                    ProfileDetail.PartnerNo,
                                                    ProfileDetail.PartnerShipto,
                                                    ProfileDetail.TransactionType
                                                FROM
                                                    [$(Wholesale_Warehouse)].PartyContacts.ProfileDetail
                                                -- WHERE ProfileDetail.TransactionCode = '810' and ActiveRecord = 'A') t3
                                                WHERE
                                                    ProfileDetail.TransactionCode = '810'
                                            ) t3
                                                ON ShippingLocations.CustomerNumber = t3.PartnerNo
                                                   AND ShippingLocations.ShiptoNumber = t3.PartnerShipto
                                        LEFT JOIN
                                            (
                                                SELECT
                                                    ProfileDetail.PartnerNo,
                                                    ProfileDetail.PartnerShipto,
                                                    ProfileDetail.TransactionType
                                                FROM
                                                    [$(Wholesale_Warehouse)].PartyContacts.ProfileDetail
                                                -- WHERE ProfileDetail.TransactionCode = '810' and ProfileDetail.AllShiptos = 1 and ActiveRecord = 'A') t4
                                                WHERE
                                                    ProfileDetail.TransactionCode = '810'
                                                    AND ProfileDetail.AllShiptos = 1
                                            ) t4
                                                ON ShippingLocations.CustomerNumber = t4.PartnerNo
                                    GROUP BY
                                            ShippingLocations.CustomerNumber,
                                            ShippingLocations.ShiptoNumber
                                )                 InvTypes
                                    ON ShippingLocations.CustomerNumber = InvTypes.CustomerNumber
                                       AND ShippingLocations.ShiptoNumber = InvTypes.ShiptoNumber
                            --Added by Amanda Radatz on 11/08/2011  
                            LEFT JOIN
                                (
                                    SELECT
                                            AccountMaster.CustomerNumber AS CustomerNumber,
                                            MAX(   CASE
                                                       WHEN EPay.UserLogin IS NULL
                                                           THEN
                                                           'N'
                                                       ELSE
                                                           'Y'
                                                   END
                                               )                         AS EPayAccount
                                    FROM
                                            [$(Wholesale_Warehouse)].Customers.AccountMaster
                                        LEFT OUTER JOIN
                                            (
                                                SELECT
                                                        UserProfile.UserLogin,
                                                        SUBSTRING(UserProfile.UserLogin, 4, LEN(UserProfile.UserLogin)) AS EPayCustomerNumber
                                                FROM
                                                        [$(MasterData_Warehouse)].[Security].GroupPermissions
                                                    INNER JOIN
                                                        [$(MasterData_Warehouse)].[Security].UserProfile
                                                            ON GroupPermissions.UserLogin = UserProfile.UserLogin
                                                    INNER JOIN
                                                        [$(MasterData_Warehouse)].[Security].GroupProfile
                                                            ON GroupPermissions.GroupID = GroupProfile.SecurityID
                                                WHERE
                                                        GroupProfile.GroupID = 'EPAY'
                                                        AND UserProfile.UserLogin LIKE 'AD_%'
                                            ) EPay
                                                ON EPayCustomerNumber = AccountMaster.CustomerNumber
                                    GROUP BY
                                            AccountMaster.CustomerNumber
                                )                 EPayAccts
                                    ON ShippingLocations.CustomerNumber = EPayAccts.CustomerNumber
                        WHERE
                                PresBillToExceptions.CustomerNumber IS NULL
                        UNION
                        SELECT  DISTINCT
                                TRIM(   CASE
                                            WHEN ShippingLocations.ShiptoNumber IS NULL
                                                 OR ShippingLocations.ShiptoNumber = ''
                                                THEN
                                                ShippingLocations.CustomerNumber
                                            ELSE
                                                RTRIM(ShippingLocations.CustomerNumber) + '-'
                                                + LTRIM(ShippingLocations.ShiptoNumber)
                                        END
                                    )                                                                              AS [Account And Shipto Number],
                                TRIM(AccountMaster.CustomerName)                                                   AS [Customer Name],
                                TRIM(ShippingLocations.CustomerNumber)                                             AS [Customer Account Number],
                                TRIM(ShippingLocations.ShiptoNumber)                                               AS [Customer Shipto Number],
                                CASE
                                    WHEN PresBillToExceptions.CustomerNumber IS NULL
                                        THEN
                                        CAST(0 AS INT)
                                    ELSE
                                        CAST(1 AS INT)
                                END                                                                                [Account Exception Flag],
                                TRIM(ShippingLocations.DiscountCode)                                               AS [Discount Code],
                                TRIM(DiscountCodes.Description)                                                    AS [Discount Code Description],
                                TRIM(RTRIM(ShippingLocations.DiscountCode) + ', ' + DiscountCodes.Description)     AS [AFI Discount Code],
                                TRIM(ShippingLocations.PriceCode)                                                  AS [Price Code],
                                TRIM(PriceCode.Description)                                                        AS [Price Code Description],
                                TRIM(RTRIM(ShippingLocations.PriceCode) + ', ' + PriceCode.Description)            AS [AFI Price Code],
                                TRIM(ShippingLocations.FreightCode)                                                AS [Freight Code],
                                TRIM(FreightCodes.Description)                                                     AS [Freight Code Description],
                                TRIM(RTRIM(ShippingLocations.FreightCode) + ', ' + FreightCodes.Description)       AS [AFI Freight Code],
                                TRIM(ShippingLocations.CommissionCode)                                             AS [Commission Code],
                                TRIM(CommissionCodes.Description)                                                  AS [Commission Code Description],
                                TRIM(RTRIM(ShippingLocations.CommissionCode) + ', ' + CommissionCodes.Description) AS [AFI Commission Code],
                                TRIM(ShippingLocations.Name)                                                       AS [Customer Shipto Name],
                                ShippingLocations.CustomerSegment                                                  AS [Customer Segment],
                                TRIM(ShippingLocations.BusinessType)                                               AS [Business Type Code],
                                TRIM(ISNULL(BusinessType.Description, ''))                                         AS [Business Type],
                                BusinessType.RptBusType                                                            AS [Reporting Business Type],
                                TRIM(ISNULL(ServiceRepID.ServiceRepID, ''))                                        AS [Customer Service RepID],
                                TRIM(ISNULL(CRM.ShortFullName, ''))                                                AS [Customer Service Agent Name], 
                                TRIM(ISNULL(ServiceRepID.GroupID, ''))                                             AS [Customer Service Group ID],
                                ISNULL(ServiceRepGroup.UserID, 'N/A')                                              AS [Customer Service Group Leader],
                                ShippingLocations.BuyerAddressID                                                   AS [Store Address ID],
                                ShippingLocations.RouteAddressID                                                   AS [Shipto AddressID],
                                TRIM(AccountMaster.PrimaryTerritory)                                               AS [Primary Sales Territory],
                                TRIM(ShippingLocations.ShippingTerritory)                                          AS [Shipto Sales Territory],
                                AccountMaster.ActiveRecord                                                                AS [Customer Account Status],
                                CASE
                                    WHEN dfi.CustomerNumber IS NULL
                                        THEN
                                        'N'
                                    ELSE
                                        'Y'
                                END                                                                                AS [DFI Account Flag],
                                TRIM(RTRIM(AccountMaster.TermsCode) + ', ' + TermsCode.Description)                         AS [AFI Credit Terms],
                                TRIM(AccountMaster.TermsCode)                                                      AS [Terms Code],
                                AccountMaster.CreditTerritoryID                                                    AS [Credit Territory Code],
                                TRIM(ShippingLocations.DefaultWarehouse)                                           AS [Default Warehouse],
                                TRIM(TermsCode.Description)                                                                 AS [Terms Description],
                                ISNULL(ExtendedCustomerProfile.RouteZone, 'N/A')                                   AS [Route Zone],
                                ISNULL(ExtendedCustomerProfile.RouteRegion, 'N/A')                                 AS [Route Region],
                                TRIM(BillTo.Address1)                                                              AS [Bill To Address 1],
                                TRIM(BillTo.Address2)                                                              AS [Bill To Address 2],
                                TRIM(BillTo.Address3)                                                              AS [Bill To Address 3],
                                TRIM(BillTo.Address4)                                                              AS [Bill To Address 4],
                                TRIM(BillTo.Address5)                                                              AS [Bill To Address 5],
                                TRIM(BillTo.City)                                                                  AS [Bill To City],
                                TRIM(BillTo.State)                                                                 AS [Bill To State],
                                TRIM(BillTo.ZipCode)                                                               AS [Bill To Zip Code],
                                TRIM(BillTo.Country)                                                               AS [Bill To Country],
                                TRIM(BTBuy.FullName)                                                               AS [Bill To-Buyer Name],
                                TRIM(BTBuy.PhoneNumber)                                                            AS [Bill To-Buyer Phone],
                                TRIM(BTBuy.FaxNumber)                                                              AS [Bill To-Buyer Fax],
                                TRIM(BTBuy.Email)                                                                  AS [Bill To-Buyer Email],
                                TRIM(BTRec.FullName)                                                               AS [Bill To-Receiving Name],
                                TRIM(BTRec.PhoneNumber)                                                            AS [Bill To-Receiving Phone],
                                TRIM(BTRec.FaxNumber)                                                              AS [Bill To-Receiving Fax],
                                TRIM(BTRec.Email)                                                                  AS [Bill To-Receiving Email],
                                TRIM(STBuy.FullName)                                                               AS [Ship To-Buyer Name],
                                TRIM(STBuy.PhoneNumber)                                                            AS [Ship To-Buyer Phone],
                                TRIM(STBuy.FaxNumber)                                                              AS [Ship To-Buyer Fax],
                                TRIM(STBuy.Email)                                                                  AS [Ship To-Buyer Email],
                                TRIM(STRec.FullName)                                                               AS [Ship To-Receiving Name],
                                TRIM(STRec.PhoneNumber)                                                            AS [Ship To-Receiving Phone],
                                TRIM(STRec.FaxNumber)                                                              AS [Ship To-Receiving Fax],
                                TRIM(STRec.Email)                                                                  AS [Ship To-Receiving Email],
                                TRIM(RTRIM(ShippingLocations.CustomerNumber) + '-' + RTRIM(ShippingLocations.ShiptoNumber)
                                     + '-' + RTRIM(ShippingLocations.Name) + ', ' + RTRIM(ShippingLocations.Address3)
                                     + ', ' + RTRIM(LTRIM(ShippingLocations.State))
                                    )                                                                              AS [Shipto Details],
                                ISNULL(CustomerCredit.ACI_Amount, 0)                                               AS [ACI Amount],
                                ISNULL(CustomerCredit.OutstandingBalance, 0)                                       AS [Outstanding Balance],
                                ISNULL(CustomerCredit.BeyondTerms_90Days, 0)                                       AS [Days Beyond Terms - 90],
                                ISNULL(CustomerCredit.BeyondTerms_365Days, 0)                                      AS [Days Beyond Terms - 365],
                                ISNULL(CustomerCredit.CreditLimit, 0)                                              AS [Credit Limit],
                                InvType                                                                            AS [Invoice Type],
                                EPayAccts.EPayAccount                                                              AS [EPay Flag],
                                AccountMaster.CurrencyCode                                                         AS [Currency Type],
                                ISNULL(CustomerCredit.HighestCredit,0)                                             AS [Highest Credit],
                                ISNULL(CustomerAccountRating.CurrentYearRating, 'E')                               AS [ABC Account-Current Year],
                                ISNULL(CustomerAccountRating.PreviousYearRating, 'E')                              AS [ABC Account-Previous Year],
                                ISNULL(CustomerAccountRating.SecondYearRating, 'E')                                AS [ABC Account-2 Years Ago],
                                NULL                                                                               AS HSOwner,
                                NULL                                                                               AS [District Manager],
                                RTRIM(AccountMaster.CustomerName) + '-' + LTRIM(ShippingLocations.CustomerNumber)  AS [CustomerandAccountNumber]
                        FROM
                                [$(Wholesale_Warehouse)].Customers.ShippingLocations
                            JOIN
                                [$(Wholesale_Warehouse)].Customers.AccountMaster
                                    ON AccountMaster.CustomerNumber = ShippingLocations.CustomerNumber
                            LEFT JOIN
                                AFISales_Enh.CustomerAccountRating
                                    ON CustomerAccountRating.CustomerNumber = CASE
                                                                                  WHEN ShippingLocations.ShiptoNumber IS NULL
                                                                                       OR ShippingLocations.ShiptoNumber = ''
                                                                                      THEN
                                                                                      ShippingLocations.CustomerNumber
                                                                                  ELSE
                                                                                      RTRIM(ShippingLocations.CustomerNumber)
                                                                                      + '-'
                                                                                      + LTRIM(ShippingLocations.ShiptoNumber)
                                                                              END
                                       AND [Account Exception Flag] = 1
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Marketing.BusinessType
                                    ON BusinessType.BusinessTypeCode = ShippingLocations.BusinessType
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Customers.ServiceRepID
                                    ON ServiceRepID.ServiceRepID = ShippingLocations.ServiceRepID
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].PartyContacts.ContactMaster CRM
                                    ON ServiceRepID.ContactID = CRM.ContactID
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Customers.ServiceRepGroup
                                    ON ServiceRepID.GroupID = ServiceRepGroup.GroupID
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Pricing_AFI.CommissionCodes
                                    ON CommissionCodes.CommissionCode = ShippingLocations.CommissionCode
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Pricing_AFI.DiscountCodes
                                    ON DiscountCodes.DiscountCode = ShippingLocations.DiscountCode
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Pricing_AFI.FreightCodes
                                    ON FreightCodes.FreightCode = ShippingLocations.FreightCode
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Pricing_AFI.PriceCode
                                    ON PriceCode.PriceCode = ShippingLocations.PriceCode
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].CustomerOrders_AFI.TermsCode
                                    ON AccountMaster.TermsCode = TermsCode.MapicsTermsCode
                            LEFT JOIN
                                (
                                    SELECT DISTINCT
                                           ShippingLocations.CustomerNumber ,
                                           ShippingLocations.ShiptoNumber   
                                    FROM
                                           [$(Wholesale_Warehouse)].Customers.ShippingLocations
                                    WHERE
                                           ShippingLocations.DiscountCode IN
                                               (
                                                   SELECT DISTINCT
                                                          DiscountRates.DiscountCode
                                                   FROM
                                                          [$(Wholesale_Warehouse)].Pricing_AFI.DiscountRates
                                                   WHERE
                                                          DiscountRates.Discount6 <> 0
                                               )
                                )                                              dfi
                                    ON ShippingLocations.CustomerNumber = dfi.CustomerNumber
                                       AND ShippingLocations.ShiptoNumber = dfi.ShiptoNumber
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Marketing.PresBillToExceptions
                                    ON PresBillToExceptions.CustomerNumber = ShippingLocations.CustomerNumber
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Customers.ExtendedCustomerProfile
                                    ON ShippingLocations.CustomerNumber = ExtendedCustomerProfile.CustomerNumber
                                       AND ShippingLocations.ShiptoNumber = ExtendedCustomerProfile.ShiptoNumber
                            LEFT JOIN
                                (
                                    SELECT
                                            AccountMaster.CustomerNumber,
                                            AddressMaster.Address1,
                                            AddressMaster.Address2,
                                            AddressMaster.Address3,
                                            AddressMaster.Address4,
                                            AddressMaster.Address5,
                                            AddressMaster.City,
                                            AddressMaster.State,
                                            AddressMaster.ZipCode,
                                            AddressMaster.Country,
                                            ROW_NUMBER() OVER (PARTITION BY
                                                                   AccountMaster.CustomerNumber
                                                               ORDER BY
                                                                   PartyMaster.PartyID DESC
                                                              ) AS RowNumber
                                    FROM
                                            [$(Wholesale_Warehouse)].Customers.AccountMaster
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.PartyMaster
                                                ON AccountMaster.CustomerNumber = PartyMaster.CustomerNumber
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.Locations
                                                ON PartyMaster.PartyID = Locations.PartyID
                                                   AND 'CMA' = Locations.LocationType
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.AddressMaster
                                                ON Locations.AddressID = AddressMaster.AddressID
                                )                                              BillTo
                                    ON AccountMaster.CustomerNumber = BillTo.CustomerNumber
                                       AND BillTo.RowNumber = 1
                            LEFT JOIN
                                (
                                    SELECT
                                            AccountMaster.CustomerNumber  AS CustomerNumber,
                                            MAX(ContactMaster.FullName)   AS FullName,
                                            MAX(Phone.CommunicationValue) AS PhoneNumber,
                                            MAX(Fax.CommunicationValue)   AS FaxNumber,
                                            MAX(Email.CommunicationValue) AS Email
                                    FROM
                                            [$(Wholesale_Warehouse)].Customers.AccountMaster
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.PartyMaster
                                                ON AccountMaster.CustomerNumber = PartyMaster.CustomerNumber
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.Locations
                                                ON PartyMaster.PartyID = Locations.PartyID
                                                   AND 'CMA' = Locations.LocationType
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactDefaults
                                                ON Locations.LocationID = ContactDefaults.LocationID
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactBase
                                                ON ContactDefaults.LocationID = ContactBase.LocationID
                                                   AND ContactDefaults.Department = ContactBase.Department
                                                   AND ContactDefaults.ContactType = ContactBase.ContactType
                                                   AND ContactDefaults.ContactID = ContactBase.ContactID
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactMaster
                                                ON ContactDefaults.ContactID = ContactMaster.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Phone'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Phone
                                                ON ContactDefaults.LocationID = Phone.LocationID
                                                   AND ContactDefaults.Department = Phone.Department
                                                   AND ContactDefaults.ContactType = Phone.ContactType
                                                   AND ContactDefaults.ContactID = Phone.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Fax'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Fax
                                                ON ContactDefaults.LocationID = Fax.LocationID
                                                   AND ContactDefaults.Department = Fax.Department
                                                   AND ContactDefaults.ContactType = Fax.ContactType
                                                   AND ContactDefaults.ContactID = Fax.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Email'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Email
                                                ON ContactDefaults.LocationID = Email.LocationID
                                                   AND ContactDefaults.Department = Email.Department
                                                   AND ContactDefaults.ContactType = Email.ContactType
                                                   AND ContactDefaults.ContactID = Email.ContactID
                                    WHERE
                                            ContactDefaults.IsBuyerDefault = 1
                                    GROUP BY
                                            AccountMaster.CustomerNumber
                                )                                              BTBuy
                                    ON AccountMaster.CustomerNumber = BTBuy.CustomerNumber
                            LEFT JOIN
                                (
                                    SELECT
                                            AccountMaster.CustomerNumber  AS CustomerNumber,
                                            MAX(ContactMaster.FullName)   AS FullName,
                                            MAX(Phone.CommunicationValue) AS PhoneNumber,
                                            MAX(Fax.CommunicationValue)   AS FaxNumber,
                                            MAX(Email.CommunicationValue) AS Email
                                    FROM
                                            [$(Wholesale_Warehouse)].Customers.AccountMaster
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.PartyMaster
                                                ON AccountMaster.CustomerNumber = PartyMaster.CustomerNumber
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.Locations
                                                ON PartyMaster.PartyID = Locations.PartyID
                                                   AND 'CMA' = Locations.LocationType
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactDefaults
                                                ON Locations.LocationID = ContactDefaults.LocationID
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactBase
                                                ON ContactDefaults.LocationID = ContactBase.LocationID
                                                   AND ContactDefaults.Department = ContactBase.Department
                                                   AND ContactDefaults.ContactType = ContactBase.ContactType
                                                   AND ContactDefaults.ContactID = ContactBase.ContactID
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactMaster
                                                ON ContactDefaults.ContactID = ContactMaster.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Phone'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Phone
                                                ON ContactDefaults.LocationID = Phone.LocationID
                                                   AND ContactDefaults.Department = Phone.Department
                                                   AND ContactDefaults.ContactType = Phone.ContactType
                                                   AND ContactDefaults.ContactID = Phone.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Fax'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Fax
                                                ON ContactDefaults.LocationID = Fax.LocationID
                                                   AND ContactDefaults.Department = Fax.Department
                                                   AND ContactDefaults.ContactType = Fax.ContactType
                                                   AND ContactDefaults.ContactID = Fax.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Email'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Email
                                                ON ContactDefaults.LocationID = Email.LocationID
                                                   AND ContactDefaults.Department = Email.Department
                                                   AND ContactDefaults.ContactType = Email.ContactType
                                                   AND ContactDefaults.ContactID = Email.ContactID
                                    WHERE
                                            ContactDefaults.IsReceivingDefault = 1
                                    GROUP BY
                                            AccountMaster.CustomerNumber
                                )                                              BTRec
                                    ON AccountMaster.CustomerNumber = BTRec.CustomerNumber
                            LEFT JOIN
                                (
                                    SELECT
                                            ShippingLocations.CustomerNumber AS CustomerNumber,
                                            ShippingLocations.ShiptoNumber   AS ShiptoNumber,
                                            MAX(ContactMaster.FullName)      AS FullName,
                                            MAX(Phone.CommunicationValue)    AS PhoneNumber,
                                            MAX(Fax.CommunicationValue)      AS FaxNumber,
                                            MAX(Email.CommunicationValue)    AS Email
                                    FROM
                                            [$(Wholesale_Warehouse)].Customers.ShippingLocations
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactDefaults
                                                ON ShippingLocations.PartyLocationID = ContactDefaults.LocationID
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactBase
                                                ON ContactDefaults.LocationID = ContactBase.LocationID
                                                   AND ContactDefaults.Department = ContactBase.Department
                                                   AND ContactDefaults.ContactType = ContactBase.ContactType
                                                   AND ContactDefaults.ContactID = ContactBase.ContactID
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactMaster
                                                ON ContactDefaults.ContactID = ContactMaster.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Phone'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Phone
                                                ON ContactDefaults.LocationID = Phone.LocationID
                                                   AND ContactDefaults.Department = Phone.Department
                                                   AND ContactDefaults.ContactType = Phone.ContactType
                                                   AND ContactDefaults.ContactID = Phone.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Fax'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Fax
                                                ON ContactDefaults.LocationID = Fax.LocationID
                                                   AND ContactDefaults.Department = Fax.Department
                                                   AND ContactDefaults.ContactType = Fax.ContactType
                                                   AND ContactDefaults.ContactID = Fax.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Email'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Email
                                                ON ContactDefaults.LocationID = Email.LocationID
                                                   AND ContactDefaults.Department = Email.Department
                                                   AND ContactDefaults.ContactType = Email.ContactType
                                                   AND ContactDefaults.ContactID = Email.ContactID
                                    WHERE
                                            ContactDefaults.IsBuyerDefault = 1
                                    GROUP BY
                                            ShippingLocations.CustomerNumber,
                                            ShippingLocations.ShiptoNumber
                                )                                              STBuy
                                    ON ShippingLocations.CustomerNumber = STBuy.CustomerNumber
                                       AND ShippingLocations.ShiptoNumber = STBuy.ShiptoNumber
                            LEFT JOIN
                                (
                                    SELECT
                                            ShippingLocations.CustomerNumber AS CustomerNumber,
                                            ShippingLocations.ShiptoNumber   AS ShiptoNumber,
                                            MAX(ContactMaster.FullName)      AS FullName,
                                            MAX(Phone.CommunicationValue)    AS PhoneNumber,
                                            MAX(Fax.CommunicationValue)      AS FaxNumber,
                                            MAX(Email.CommunicationValue)    AS Email
                                    FROM
                                            [$(Wholesale_Warehouse)].Customers.ShippingLocations
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactDefaults
                                                ON ShippingLocations.PartyLocationID = ContactDefaults.LocationID
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactBase
                                                ON ContactDefaults.LocationID = ContactBase.LocationID
                                                   AND ContactDefaults.Department = ContactBase.Department
                                                   AND ContactDefaults.ContactType = ContactBase.ContactType
                                                   AND ContactDefaults.ContactID = ContactBase.ContactID
                                        JOIN
                                            [$(Wholesale_Warehouse)].PartyContacts.ContactMaster
                                                ON ContactDefaults.ContactID = ContactMaster.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Phone'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Phone
                                                ON ContactDefaults.LocationID = Phone.LocationID
                                                   AND ContactDefaults.Department = Phone.Department
                                                   AND ContactDefaults.ContactType = Phone.ContactType
                                                   AND ContactDefaults.ContactID = Phone.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Fax'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Fax
                                                ON ContactDefaults.LocationID = Fax.LocationID
                                                   AND ContactDefaults.Department = Fax.Department
                                                   AND ContactDefaults.ContactType = Fax.ContactType
                                                   AND ContactDefaults.ContactID = Fax.ContactID
                                        LEFT JOIN
                                            (
                                                SELECT
                                                        CommunicationInfo.LocationID,
                                                        CommunicationInfo.Department,
                                                        CommunicationInfo.ContactType,
                                                        CommunicationInfo.ContactID,
                                                        CommunicationInfo.CommunicationType,
                                                        CommunicationInfo.CommunicationValue,
                                                        CommunicationInfo.CommunicationValueExt
                                                FROM
                                                        [$(Wholesale_Warehouse)].PartyContacts.CommunicationInfo
                                                    JOIN
                                                        [$(Wholesale_Warehouse)].PartyContacts.ContactValueList
                                                            ON 'Communication' = ContactValueList.ValueType
                                                               AND CommunicationInfo.CommunicationType = ContactValueList.KeyValue
                                                WHERE
                                                        ContactValueList.ListType = 'Email'
                                                        AND CommunicationInfo.IsDefault = 1
                                            ) Email
                                                ON ContactDefaults.LocationID = Email.LocationID
                                                   AND ContactDefaults.Department = Email.Department
                                                   AND ContactDefaults.ContactType = Email.ContactType
                                                   AND ContactDefaults.ContactID = Email.ContactID
                                    WHERE
                                            ContactDefaults.IsReceivingDefault = 1
                                    GROUP BY
                                            ShippingLocations.CustomerNumber,
                                            ShippingLocations.ShiptoNumber
                                )                                              STRec
                                    ON ShippingLocations.CustomerNumber = STRec.CustomerNumber
                                       AND ShippingLocations.ShiptoNumber = STRec.ShiptoNumber
                            LEFT JOIN
                                [$(Wholesale_Warehouse)].Customers.CustomerCredit
                                    ON ShippingLocations.CustomerNumber = CustomerCredit.CustomerNumber
                            LEFT JOIN
                                (
                                    SELECT
                                            ShippingLocations.CustomerNumber AS CustomerNumber,
                                            ShippingLocations.ShiptoNumber   AS ShiptoNumber,
                                            MAX(   CASE
                                                       WHEN COALESCE(t3.TransactionType, t4.TransactionType, '') = ''
                                                           THEN
                                                           'P'
                                                       ELSE
                                                           COALESCE(t3.TransactionType, t4.TransactionType, '')
                                                   END
                                               )                             AS InvType
                                    FROM
                                            [$(Wholesale_Warehouse)].Customers.ShippingLocations
                                        LEFT JOIN
                                            (
                                                SELECT
                                                    ProfileDetail.PartnerNo,
                                                    ProfileDetail.PartnerShipto,
                                                    ProfileDetail.TransactionType
                                                FROM
                                                    [$(Wholesale_Warehouse)].PartyContacts.ProfileDetail
                                                WHERE
                                                    ProfileDetail.TransactionCode = '810'
                                            ) t3
                                                ON ShippingLocations.CustomerNumber = t3.PartnerNo
                                                   AND ShippingLocations.ShiptoNumber = t3.PartnerShipto
                                        LEFT JOIN
                                            (
                                                SELECT
                                                    ProfileDetail.PartnerNo,
                                                    ProfileDetail.PartnerShipto,
                                                    ProfileDetail.TransactionType
                                                FROM
                                                    [$(Wholesale_Warehouse)].PartyContacts.ProfileDetail
                                                WHERE
                                                    ProfileDetail.TransactionCode = '810'
                                                    AND ProfileDetail.AllShiptos = 1
                                            ) t4
                                                ON ShippingLocations.CustomerNumber = t4.PartnerNo
                                    GROUP BY
                                            ShippingLocations.CustomerNumber,
                                            ShippingLocations.ShiptoNumber
                                )                                              InvTypes
                                    ON ShippingLocations.CustomerNumber = InvTypes.CustomerNumber
                                       AND ShippingLocations.ShiptoNumber = InvTypes.ShiptoNumber
                            LEFT JOIN
                                (
                                    SELECT
                                            AccountMaster.CustomerNumber AS CustomerNumber,
                                            MAX(   CASE
                                                       WHEN EPay.UserLogin IS NULL
                                                           THEN
                                                           'N'
                                                       ELSE
                                                           'Y'
                                                   END
                                               )                         AS EPayAccount
                                    FROM
                                            [$(Wholesale_Warehouse)].Customers.AccountMaster
                                        LEFT OUTER JOIN
                                            (
                                                SELECT
                                                        UserProfile.UserLogin,
                                                        SUBSTRING(UserProfile.UserLogin, 4, LEN(UserProfile.UserLogin)) AS EPayCustomerNumber
                                                FROM
                                                        [$(MasterData_Warehouse)].[Security].GroupPermissions
                                                    INNER JOIN
                                                        [$(MasterData_Warehouse)].[Security].UserProfile
                                                            ON GroupPermissions.UserLogin = UserProfile.UserLogin
                                                    INNER JOIN
                                                        [$(MasterData_Warehouse)].[Security].GroupProfile
                                                            ON GroupPermissions.GroupID = GroupProfile.SecurityID
                                                WHERE
                                                        GroupProfile.GroupID = 'EPAY'
                                                        AND UserProfile.UserLogin LIKE 'AD_%'
                                            ) EPay
                                                ON EPayCustomerNumber = AccountMaster.CustomerNumber
                                    GROUP BY
                                            AccountMaster.CustomerNumber
                                )                                              EPayAccts
                                    ON ShippingLocations.CustomerNumber = EPayAccts.CustomerNumber
                        WHERE
                                PresBillToExceptions.CustomerNumber IS NOT NULL;

            UPDATE
                AFISales_DW.DimCustomers_LOAD
            SET
                [HS Owner] = Final.HSOwner
            FROM
                #ActiveHSOwnerDetails_Final Final
            WHERE
                [Customer Account Number] = Final.AccountNumber;

            UPDATE
                AFISales_DW.DimCustomers_LOAD
            SET
                [HS Owner] = Active.HSOwner
            FROM
                #ActiveHSOwnerDetails_Initial Active
            WHERE
                [Customer Account Number] = Active.AccountNumber
                AND [HS Owner] IS NULL;

            UPDATE
                AFISales_DW.DimCustomers_LOAD
            SET
                [HS Owner] = Inactive.HSOwner
            FROM
                #InactiveHSOwnerDetails_Initial Inactive
            WHERE
                [Customer Account Number] = Inactive.AccountNumber
                AND [HS Owner] IS NULL;

            UPDATE
                AFISales_DW.DimCustomers_LOAD
            SET
                [HS Owner] = Final.HSOwner
            FROM
                #InactiveHSOwnerDetails_Final Final
            WHERE
                [Customer Account Number] = Final.AccountNumber
                AND [HS Owner] IS NULL

            UPDATE
                AFISales_DW.DimCustomers_LOAD
            SET
                [District Manager] = LocationListing_MDA_SharePoint.District_Manager
            FROM
                [$(MasterData_Warehouse)].[Retail].[LocationListing_MDA_SharePoint]
            WHERE
                TRIM([Customer Account Number]) = TRIM([CurrentAccountNumber])
                AND LocationListing_MDA_SharePoint.[District_Manager] <> 'Archived LIC';

            UPDATE
                AFISales_DW.DimCustomers_LOAD
            SET
                [District Manager] = LocationListing_MDA_SharePoint.District_Manager
            FROM
                [$(MasterData_Warehouse)].[Retail].[LocationListing_MDA_SharePoint]
            WHERE
                TRIM([HS Owner]) = TRIM(LocationListing_MDA_SharePoint.[Licensee_Name])
                AND [District Manager] IS NULL
                AND LocationListing_MDA_SharePoint.[District_Manager] <> 'Archived LIC';

            --select * into AFISales_xbk.DimCustomers FROM AFISales_DW.DimCustomers --105589

            -- Test for duplicates, if none exist do the drop/rename to activate the new table.  If errors exist, abort the process and trigger the error

            IF EXISTS
                (
                    SELECT
                        [Account And Shipto Number],
                        COUNT(*) AS cnt
                    FROM
                        AFISales_DW.DimCustomers_LOAD
                    GROUP BY
                        [Account And Shipto Number]
                    HAVING
                        COUNT(*) > 1
                )
                BEGIN
                    RAISERROR('Duplicates Found', 12, 1); --- severity 12 should kick into the Try/Catch functionality
                END;
            ELSE
                BEGIN
                    -- No Duplicates Exist

                    CREATE STATISTICS Stat_DimCustomers_Account_And_Shipto_Number
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Account And Shipto Number]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Account_Number
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Customer Account Number]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Shipto_Number
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Customer Shipto Number]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Shipto_Details
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Shipto Details]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Commission_Code
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Commission Code]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Bill_To_Address_4
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Bill To Address 4]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Bill_To_Zip_Code
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Bill To Zip Code]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Bill_To_City
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Bill To City]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Bill_To_Buyer_Fax
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Bill To-Buyer Fax]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Bill_To_Receiving_Email
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Bill To-Receiving Email]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Ship_To_Receiving_Name
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Ship To-Receiving Name]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Reporting_Business_Type
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Reporting Business Type]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Credit_Limit
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Credit Limit]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Days_Beyond_Terms___365
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Days Beyond Terms - 365]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Currency_Type
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Currency Type]
                        );
                    CREATE STATISTICS Stat_DimCustomers_ABC_Account_Current_Year
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [ABC Account-Current Year]
                        );
                    CREATE STATISTICS Stat_DimCustomers_HS_Owner
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [HS Owner]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Customer_Account_Number
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Customer Account Number]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Business_Type
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Business Type]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Customer_Service_Group_ID
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Customer Service Group ID]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Customer_Account_Status
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Customer Account Status]
                        );
                    CREATE STATISTICS Stat_DimCustomers_DFI_Account_Flag
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [DFI Account Flag]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Freight_Code
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Freight Code]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Price_Code
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Price Code] 
                        );
                    CREATE STATISTICS Stat_DimCustomers_Bill_To_Address_1
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Bill To Address 1]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Bill_To_State
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Bill To State]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Bill_To_Buyer_Phone
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Bill To-Buyer Phone]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Bill_To_Receiving_Fax
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Bill To-Receiving Fax]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Bill_To_Receiving_Name
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Bill To-Receiving Name]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Ship_To_Buyer_Phone
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Ship To-Buyer Phone]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Outstanding_Balance
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Outstanding Balance]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Days_Beyond_Terms___90
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Days Beyond Terms - 90]
                        );

                    CREATE STATISTICS Stat_DimCustomers_Store_Address_ID
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Store Address ID]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Customer_Shipto_Name
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Customer Shipto Name]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Shipto_AddressID
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Shipto AddressID]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Customer_Name
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Customer Name]
                        );
                    CREATE STATISTICS Stat_DimCustomers_AFI_Credit_Terms
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [AFI Credit Terms]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Primary_Sales_Territory
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Primary Sales Territory]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Customer_Segment
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Customer Segment]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Customer_Service_RepID
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Customer Service RepID]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Customer_Service_Group_Leader
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Customer Service Group Leader]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Default_Warehouse
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Default Warehouse]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Discount_Code
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Discount Code]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Account_Exception_Flag
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Account Exception Flag]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Bill_To_Address_2
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Bill To Address 2]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Bill_To_Country
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Bill To Country]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Bill_To_Buyer_Name
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Bill To-Buyer Name]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Ship_To_Buyer_Name
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Ship To-Buyer Name]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Ship_To_Buyer_Fax
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Ship To-Buyer Fax]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Ship_To_Receiving_Fax
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Ship To-Receiving Fax]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Invoice_Type
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Invoice Type]
                        );
                    CREATE STATISTICS Stat_DimCustomers_ACI_Amount
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [ACI Amount]
                        );
                    CREATE STATISTICS Stat_DimCustomers_ABC_Account_Previous_Year
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [ABC Account-Previous Year]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Discount_Code
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Discount Code]
                        );
                    CREATE STATISTICS Stat_DimCustomers_EPay_Flag
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [EPay Flag]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Highest_Credit
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Highest Credit]
                        );
                    CREATE STATISTICS Stat_DimCustomers_ABC_Account_2_Years_Ago
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [ABC Account-2 Years Ago]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Price_Code
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Price Code]
                        );
                    CREATE STATISTICS Stat_DimCustomers_AFI_Commission_Code
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [AFI Commission Code]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Route_Zone
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Route Zone]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Bill_To_Address_3
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Bill To Address 3]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Bill_To_Address_5
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Bill To Address 5]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Bill_To_Buyer_Email
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Bill To-Buyer Email]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Bill_To_Receiving_Phone
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Bill To-Receiving Phone]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Ship_To_Buyer_Email
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Ship To-Buyer Email]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Ship_To_Receiving_Phone
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Ship To-Receiving Phone]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Ship_To_Receiving_Email
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Ship To-Receiving Email]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Shipto_Sales_Territory
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Shipto Sales Territory]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Business_Type_Code
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Business Type Code]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Customer_Service_Agent_Name
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Customer Service Agent Name]
                        );
                    CREATE STATISTICS Stat_DimCustomers_Credit_Territory_Code
                        ON AFISales_DW.DimCustomers_LOAD
                        (
                            [Credit Territory Code]
                        );

                    EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                        'AFISales_DW.DimCustomers';

   
                    EXECUTE sp_rename 'AFISales_DW.DimCustomers_LOAD','DimCustomers'

  

                    EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                        '#HSOwnerDetails_Initial';

                    EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                        '#ActiveLocationDetails';

                    EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                        '#hopProspect';

                    EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                        '#HSOwnerDetails_Final';

                END;

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
            SELECT
                @DateValue = CSTDateValue
            FROM
                [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue);

            INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
            VALUES
                (
                    @String, @DateValue, @User, @ErrorMessage
                );

            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

        END CATCH;


        SET @DateValue = GETDATE();
        SELECT
            @DateValue = CSTDateValue
        FROM
            [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue);


        INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
        VALUES
            (
                @String, @DateValue, @User, 'Process Complete'
            );

        -- Update last modified in Table Dictionary 
        INSERT INTO [$(ETL_Framework)].DW_Developer.TableDictionary_UpdateLog
        VALUES
            (
                'AFISales_DW', 'AFISales_DW', 'DimCustomers', @DateValue
            );




    END;



