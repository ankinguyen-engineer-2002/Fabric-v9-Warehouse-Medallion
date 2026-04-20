CREATE VIEW [CostAccounting_DW_Wrk].[v_DimCustomerDetails]
AS
    SELECT DISTINCT
           [CustomerDetailKey] = CAST(ROW_NUMBER() OVER (ORDER BY
                                                             [Customer Number]
                                                        ) AS BIGINT),
           [Customer Number],
           [Ship To Number],
           [Bill To Status],
           [Ship To Status],
           [Business Type],
           [Homestore Flag],
           [Customer Terms Description] = CAST([Customer Terms Description]  AS VARCHAR(20)),
           [Bill To Name],
           [Bill To Address 1] = CAST([Bill To Address 1] AS VARCHAR(25)),
           [Bill To Address 2] = CAST([Bill To Address 2] AS VARCHAR(25)),
           [Bill To City] = CAST([Bill To City] AS VARCHAR(25)),
           [Bill To State],
           [Bill To Zip Code],
           [Bill To Country],
           [Ship To Name] = CAST([Ship To Name] AS VARCHAR(25)),
           [Ship To Address 1] = CAST([Ship To Address 1] AS VARCHAR(25)),
           [Ship To Address 2] = CAST([Ship To Address 2] AS VARCHAR(25)),
           [Ship To City] = CAST([Ship To City] AS VARCHAR(25)),
           [Ship To State],
           [Ship To Zip Code],
           [Ship To Country],
           [Commission Code],
           [Price Code],
           [Freight Code],
           [Freigth Code Description] = CAST([Freigth Code Description] AS VARCHAR(30)),
           [Item Discount Code],
           [Discount Code Description] = CAST([Discount Code Description] AS VARCHAR(30))
    FROM
           (
              
              
               SELECT DISTINCT
                      [Customer Number]            = CAST(CAST(FIF244.SHCCUSTOMERNUMBER AS INT) AS CHAR (8)),
                      [Ship To Number]             = TRIM(FIF244.SHCSHIPTONUMBER),
                      [Bill To Status]             = TRIM(FIF244.SHCBILLTOSTATUS),
                      [Ship To Status]             = TRIM(FIF244.SHCSHIPTOSTATUS),
                      [Business Type]              = TRIM(FIF244.SHCBUSINESSTYPE),
                      [Homestore Flag]             = FIF244.SHCHOMESTOREFLAG,
                      [Customer Terms Description] = TRIM(FIF244.SHCCUSTOMERTERMSDESCRIPTION),
                      [Bill To Name]               = TRIM(FIF244.SHCBILLTONAME),
                      [Bill To Address 1]          = TRIM(FIF244.SHCBILLTOADDRESS1),
                      [Bill To Address 2]          = TRIM(FIF244.SHCBILLTOADDRESS2),
                      [Bill To City]               = TRIM(FIF244.SHCBILLTOCITY),
                      [Bill To State]              = TRIM(FIF244.SHCBILLTOSTATE),
                      [Bill To Zip Code]           = TRIM(FIF244.SHCBILLTOZIPCODE),
                      [Bill To Country]            = TRIM(FIF244.SHCBILLTOCOUNTRY),
                      [Ship To Name]               = TRIM(FIF244.SHCSHIPTONAME),
                      [Ship To Address 1]          = REPLACE(LTRIM(RTRIM(FIF244.SHCSHIPTOADDRESS1)), CHAR(9), ''),
                      [Ship To Address 2]          = REPLACE(LTRIM(RTRIM(FIF244.SHCSHIPTOADDRESS2)), CHAR(9), ''),
                      [Ship To City]               = REPLACE(LTRIM(RTRIM(FIF244.SHCSHIPTOCITY)), CHAR(9), ''),
                      [Ship To State]              = TRIM(FIF244.SHCSHIPTOSTATE),
                      [Ship To Zip Code]           = TRIM(FIF244.SHCSHIPTOZIPCODE),
                      [Ship To Country]            = TRIM(FIF244.SHCSHIPTOCOUNTRY),
                      [Commission Code]            = TRIM(FIF244.SHCCOMMISSIONCODE),
                      [Price Code]                 = TRIM(FIF244.SHCPRICECODE),
                      [Freight Code]               = TRIM(FIF244.SHCFREIGHTCODE),
                      [Freigth Code Description]   = TRIM(FIF244.SHCFREIGHTCODEDESCRIPTION),
                      [Item Discount Code]         = TRIM(FIF244.SHCITEMDISCOUNTCODE),
                      [Discount Code Description]  = TRIM(FIF244.SHCDISCOUNTCODEDESCRIPTION)
               FROM
                      [$(Databricks)].costaccounting.fif244 FIF244
                  UNION ALL    SELECT
                   [Customer Number]            = '0',
                   [Ship To Number]             = '',
                   [Bill To Status]             = '',
                   [Ship To Status]             = '',
                   [Business Type]              = '',
                   [Homestore Flag]             = '',
                   [Customer Terms Description] = '',
                   [Bill To Name]               = '',
                   [Bill To Address 1]          = '',
                   [Bill To Address 2]          = '',
                   [Bill To City]               = '',
                   [Bill To State]              = '',
                   [Bill To Zip Code]           = '',
                   [Bill To Country]            = '',
                   [Ship To Name]               = '',
                   [Ship To Address 1]          = '',
                   [Ship To Address 2]          = '',
                   [Ship To City]               = '',
                   [Ship To State]              = '',
                   [Ship To Zip Code]           = '',
                   [Ship To Country]            = '',
                   [Commission Code]            = '',
                   [Price Code]                 = '',
                   [Freight Code]               = '',
                   [Freigth Code Description]   = '',
                   [Item Discount Code]         = '',
                   [Discount Code Description]  = ''
               
           ) CubeData;





