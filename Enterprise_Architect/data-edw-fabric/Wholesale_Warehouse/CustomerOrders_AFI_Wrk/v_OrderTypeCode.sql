
CREATE VIEW [CustomerOrders_AFI_Wrk].v_OrderTypeCode
AS
    SELECT
            [OTCODE],
            [OTDES1],
            [OTDES2],
            [OTUSER],
            CASE WHEN CAST([OTDATE] as INT) = 0 THEN NULL ELSE CAST(CAST(CAST([OTDATE] as INT) AS CHAR(8)) AS DATE) END AS [OTDATE],
            [OORDCL],
            [OROUTE],
            [OOTCAT],
            [OADCHG],
            [OARFLG],
            [OWNEXP],
            [OMINEXC],
            [OREQMNT],
            [OFDESCH],
            [OFDRIMS],
            [OTRPTYP],
            [OZNLTIM],
            [OSPECHND],
            [OAUTORSCH],
            [OUSRDFN]
    FROM
            [$(Source_Data)].[Wholesale_Codis_AFI].[AAORDTYP]
