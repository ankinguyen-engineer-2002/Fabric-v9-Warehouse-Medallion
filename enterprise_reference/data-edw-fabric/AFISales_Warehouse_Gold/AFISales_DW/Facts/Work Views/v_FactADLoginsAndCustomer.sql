CREATE VIEW [AFISales_DW_Wrk].[v_FactADLoginsAndCustomer]
AS
    SELECT
            UserLogin AS [ADLogins],
            CASE
                WHEN Customer.ShiptoNumber IS NULL
                     OR Customer.ShiptoNumber = ''
                    THEN
                    Customer.CustomerNumber
                ELSE
                    RTRIM(Customer.CustomerNumber) + '-' + LTRIM(Customer.ShiptoNumber)
            END       AS [Account And Shipto Number]
    FROM
            [$(MasterData_Warehouse)].[Security].Customer
        JOIN
            [$(MasterData_Warehouse)].[Security].UserProfile
                ON Customer.MHS_Name = UserProfile.MHS
        JOIN
            AFISales_DW.DimCustomers
                ON Customer.CustomerNumber = [Customer Account Number]
                   AND Customer.ShiptoNumber = [Customer Shipto Number] -- Inner join throws out invalid customer IDs

    WHERE
            Customer.MHS_Name NOT IN (
                                         '', 'MASTERXX'
                                     );
