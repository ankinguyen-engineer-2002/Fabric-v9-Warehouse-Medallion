CREATE VIEW AFISales_DW_Wrk.v_FactAssociateAccounts
AS
    SELECT
            CAST(ROW_NUMBER() OVER (ORDER BY
                                        CustomerList.SalesCode
                                   ) AS BIGINT) RowID,
            CustomerList.SalesCode                            AS [Salesman Number],
            [Account And Shipto Number]
    FROM
            [$(MasterData_Warehouse)].[Security].CustomerList
        JOIN
            AFISales_DW.DimCustomers
                ON CustomerList.CustomerNumber = [Customer Account Number]
                   AND CustomerList.ShiptoNumber = [Customer Shipto Number]
    WHERE
            CustomerList.SalesCode LIKE 'A%';
