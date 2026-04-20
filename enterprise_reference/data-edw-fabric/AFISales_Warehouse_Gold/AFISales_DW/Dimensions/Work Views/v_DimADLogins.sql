CREATE VIEW AFISales_DW_Wrk.v_DimADLogins
AS
    SELECT
        CAST(ROW_NUMBER() OVER (ORDER BY
                                    UserLogin
                               ) AS BIGINT) RowNumber,
        UserLogin                        AS [ADLogins],
        MHS                              AS [Customer Profile]
    FROM
        [$(MasterData_Warehouse)].[Security].UserProfile
    WHERE
        ISNULL(MHS, '') NOT IN (
                                      '', 'MASTERXX'
                                  );



