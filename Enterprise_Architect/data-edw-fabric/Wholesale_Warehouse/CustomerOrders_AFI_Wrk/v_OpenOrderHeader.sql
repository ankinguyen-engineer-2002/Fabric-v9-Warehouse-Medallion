
create VIEW [CustomerOrders_AFI_Wrk].v_OpenOrderHeader
AS
    SELECT
        [ACREC],
        [ORDNO] ,
        [CUSNO],
        [CUSPO] ,
        CASE WHEN CAST([ORDTE] as INT) = 0 THEN NULL ELSE CAST(CAST(CAST([ORDTE] as INT) AS CHAR(8)) AS DATE) END AS [OrderDate],
        [MPROR],
        [CMEMO] ,
        [HOUSE],
        [SLSNO],
        [ORVAL],
        [SHPNO],
        CASE WHEN CAST([RQDTE] as INT) = 0 THEN NULL ELSE CAST(CAST(CAST([RQDTE] as INT) AS CHAR(8)) AS DATE) END AS [RequestDate],
        [SHLTC],
        [SHINS],
        CASE WHEN CAST([CUSPD] as INT) = 0 THEN NULL ELSE CAST(CAST(CAST([CUSPD] as INT) AS CHAR(8)) AS DATE) END AS [PurchaseOrderDate]
    FROM
            [$(Source_Data)].[Wholesale_Codis_AFI].[COMAST]
