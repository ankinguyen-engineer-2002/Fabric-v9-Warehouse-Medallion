CREATE VIEW Transportation_Wrk.v_Truckloads
AS
SELECT
        A.BHTRPNO         AS TripNumber,
        A.BHWHSNO         AS Warehouse,
        A.BHTRPS          AS TripStatus,
        A.Container       AS Container,
        A.BHCNTI          AS ContainerID,
        A.BHCNTN          AS ContainerNumber,
        A.BHDOOR          AS DoorNumber,
        A.BHTITM          AS PiecesRouted,
        A.BHTDRP          AS Drops,
        A.BHTCUB          AS Cubes,
        A.BHTSNS          AS TotScanSerNumber,
        A.BHTSNN          AS TotScanNoTag,
        CAST(CAST(CAST(A.BHCDAT AS INT) AS CHAR(8)) AS DATE) AS CreatedDate,
        A.BHCTIM          AS CreatedTime,
        C.TTYPE           AS TripType,
        A.PctComplete     AS PercentComplete,
        A.PiecesLoaded    AS PiecesLoaded,
        A.PiecesRemaining AS PiecesRemaining,
        C.CARRIR          AS Carrier,    
        CAST(CAST(CAST(C.DSPDAT AS INT) AS CHAR(8)) AS DATE)  AS DispatchDate,
        C.DSPTIM          AS DispatchTime,
        CAST(CAST(CAST(C.LSCHDT AS INT) AS CHAR(8)) AS DATE)  AS LatestDeliverDate,
        C.STATE1          AS State1,
        C.STATE2          AS State2,
        C.STATE3          AS State3,
        CAST(CAST(CAST(C.ENTDAT AS INT) AS CHAR(8)) AS DATE)  AS TripCreateDate,
        C.ENTTIM          AS TripCreateTime,
        C.USERS           AS TrailerType,
        C.TONO7           AS TripNumber7
FROM
        (
            SELECT
                B.BHTRPNO,
                B.BHWHSNO,
                B.BHTRPS,
                CONCAT(LTRIM(RTRIM(B.BHCNTI)), LTRIM(RTRIM(B.BHCNTN))) AS Container,
                B.BHCNTI,
                B.BHCNTN,
                B.BHDOOR,
                B.BHTITM,
                B.BHTDRP,
                B.BHTCUB,
                B.BHTSNS,
                B.BHTSNN,
                B.BHCDAT,
                B.BHCTIM,
                B.BHLTYP,
                ((B.BHTSNN + B.BHTSNS) / CASE WHEN ISNULL(B.BHTITM,0) = 0 THEN 1 ELSE B.BHTITM END)  AS PctComplete,
                (B.BHTSNN + B.BHTSNS)                                  AS PiecesLoaded,
                (B.BHTITM - (B.BHTSNN + B.BHTSNS))                     AS PiecesRemaining
            FROM
                 [$(Source_Data)].[Wholesale_Codis_AFI].[Bttriph] B
            WHERE
                B.BHLTYP NOT IN (
                                    'U', 'W'
                                )
                AND B.BHTRPS IS NOT NULL
                AND B.BHWHSNO NOT IN (
                                        '232', '335'
                                    )
        )                A
    INNER JOIN
            [$(Databricks)].wholesale_codis.atofile C
                ON C.TONO = A.BHTRPNO


