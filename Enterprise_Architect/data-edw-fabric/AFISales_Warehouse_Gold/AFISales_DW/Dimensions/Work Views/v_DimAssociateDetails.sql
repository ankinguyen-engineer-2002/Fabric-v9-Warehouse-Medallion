CREATE VIEW AFISales_DW_Wrk.v_DimAssociateDetails
AS
    SELECT
        CAST(ROW_NUMBER() OVER (ORDER BY
                                    MarketingSpecialist
                               ) AS BIGINT) RowNumber,
        MarketingSpecialist                            AS [Salesman Number],
        SalesmanName                     AS [Salesman Name]
    FROM
        [$(Wholesale_Warehouse)].Marketing.MrktSpclstMaster
    WHERE
        MarketingSpecialist LIKE 'A%';

