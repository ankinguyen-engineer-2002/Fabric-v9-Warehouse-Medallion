CREATE VIEW AFISales_DW_Wrk.v_DimMarketingSpecialists
AS
    SELECT
        [Salesman Number]       = [MarketingSpecialist],
        [Salesman Name]         = [SalesmanName],
        [Saleman Business Name] = [BusinessName],
        [Sales Position]        = CASE [Position]
                                      WHEN 'T'
                                          THEN
                                          'Team'
                                      WHEN 'P'
                                          THEN
                                          'President'
                                      WHEN 'X'
                                          THEN
                                          'Inactive'
                                      WHEN 'A'
                                          THEN
                                          'Associate'
                                      WHEN 'M'
                                          THEN
                                          'Marketing Specialist'
                                      ELSE
                                          'Unknown'
                                  END
    FROM
        [$(Wholesale_Warehouse)].Marketing.MrktSpclstMaster;
