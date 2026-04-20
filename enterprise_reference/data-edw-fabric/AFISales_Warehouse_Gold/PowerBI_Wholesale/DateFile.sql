CREATE VIEW [PowerBI_Wholesale].[DateFile]
AS
    SELECT
        [Transaction Date],
        [Fiscal Year],
        [Fiscal Week],
        [Fiscal Month],
        [Fiscal Quarter],
        [Fiscal Month Desc ID],
        [LW],
        [CW],
        [CWDN],
        [CY],
        [PY],
        [CM],
        [CD],
        [PY_LW],
        [CY_LW],
        (
            SELECT
                [Transaction Date]
            FROM
                AFISales_DW.DimDateFile
            WHERE
                [Fiscal Year] = [CY]
                AND [Fiscal Week] = [CW]
                AND [WeekdayID] = [CWDN]
        )                       [CY CD],
        (
            SELECT
                [Transaction Date]
            FROM
                AFISales_DW.DimDateFile
            WHERE
                [Fiscal Year] = [PY]
                AND [Fiscal Week] = [CW]
                AND [WeekdayID] = [CWDN]
        )                       [PY CD],
        CASE
            WHEN [Transaction Date] <=
                (
                    SELECT
                        [Transaction Date]
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Fiscal Year] = [PY]
                        AND [Fiscal Week] = [CW]
                        AND [WeekdayID] = [CWDN]
                )
                 AND [Fiscal Year] = [PY]
                THEN
                1
            ELSE
                0
        END                     [PY YTD Flag],
        CASE
            WHEN [Transaction Date] <= [CD]
                 AND [Fiscal Year] = [CY]
                THEN
                1
            ELSE
                0
        END                     [CY YTD Flag],
        CASE
            WHEN [Transaction Date] <= [CD]
                 AND [Fiscal Year] = [CY]
                 AND [Fiscal Month] = [CM]
                THEN
                1
            ELSE
                0
        END                     [CY MTD Flag],
        CASE
            WHEN [Transaction Date] <=
                (
                    SELECT
                        [Transaction Date]
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Fiscal Year] = [PY]
                        AND [Fiscal Week] = [CW]
                        AND [WeekdayID] = [CWDN]
                )
                 AND
                     (
                         [Fiscal Year] = [PY]
                         AND [Fiscal Month] = [CM]
                     )
                THEN
                1
            ELSE
                0
        END                     [PY MTD Flag],
        CASE
            WHEN [Transaction Date] <= [CD]
                 AND [Fiscal Year] = [CY]
                 AND [Fiscal Month] = [CM]
                 AND [Fiscal Week] = [CW]
                THEN
                1
            ELSE
                0
        END                     [CY WTD Flag],
        CASE
            WHEN [Transaction Date] <=
                (
                    SELECT
                        [Transaction Date]
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Fiscal Year] = [PY]
                        AND [Fiscal Week] = [CW]
                        AND [WeekdayID] = [CWDN]
                )
                 AND [Fiscal Year] = [PY]
                 AND [Fiscal Month] = [CM]
                 AND [Fiscal Week] = [CW]
                THEN
                1
            ELSE
                0
        END                     [PY WTD Flag],
        --case when [Transaction Date]< dateadd("dd", -cast(CWDN as int), getdate()-364) and [Transaction Date] >= dateadd("dd", -cast(CWDN as int)-6, getdate()-365) then 1 else 0 end [PY Last Week Flag],
        --case when [Transaction Date]< dateadd("dd", -cast(CWDN as int), getdate()-364) and [Transaction Date] >= dateadd("dd", -cast(CWDN as int)-41, getdate()-365) then 1 else 0 end [PY Last 6 Weeks],
        --case when [Transaction Date]< dateadd("dd", -cast(CWDN as int), getdate()-364) and [Transaction Date] >= dateadd("dd", -cast(CWDN as int)-363, getdate()-365) then 1 else 0 end [PY Last 52 Weeks],

        CASE
            WHEN [CY_LW] = 53
                 OR [PY_LW] = 53
                THEN
        (CASE
             WHEN [Transaction Date] < DATEADD("dd", -CAST(CWDN AS INT), GETDATE() - 371)
                  AND [Transaction Date] >= DATEADD("dd", -CAST(CWDN AS INT) - 6, GETDATE() - 372)
                 THEN
                 1
             ELSE
                 0
         END
        )
            ELSE
        (CASE
             WHEN [Transaction Date] < DATEADD("dd", -CAST(CWDN AS INT), GETDATE() - 364)
                  AND [Transaction Date] >= DATEADD("dd", -CAST(CWDN AS INT) - 6, GETDATE() - 365)
                 THEN
                 1
             ELSE
                 0
         END
        )
        END                     AS [PY Last Week Flag],
        CASE
            WHEN [CY_LW] = 53
                 OR [PY_LW] = 53
                THEN
        (CASE
             WHEN [Transaction Date] < DATEADD("dd", -CAST(CWDN AS INT), GETDATE() - 371)
                  AND [Transaction Date] >= DATEADD("dd", -CAST(CWDN AS INT) - 41, GETDATE() - 372)
                 THEN
                 1
             ELSE
                 0
         END
        )
            ELSE
        (CASE
             WHEN [Transaction Date] < DATEADD("dd", -CAST(CWDN AS INT), GETDATE() - 364)
                  AND [Transaction Date] >= DATEADD("dd", -CAST(CWDN AS INT) - 41, GETDATE() - 365)
                 THEN
                 1
             ELSE
                 0
         END
        )
        END                     AS [PY Last 6 Weeks],
        CASE
            WHEN [CY_LW] = 53
                 OR [PY_LW] = 53
                THEN
        (CASE
             WHEN [Transaction Date] < DATEADD("dd", -CAST(CWDN AS INT), GETDATE() - 371)
                  AND [Transaction Date] >= DATEADD("dd", -CAST(CWDN AS INT) - 363, GETDATE() - 372)
                 THEN
                 1
             ELSE
                 0
         END
        )
            ELSE
        (CASE
             WHEN [Transaction Date] < DATEADD("dd", -CAST(CWDN AS INT), GETDATE() - 364)
                  AND [Transaction Date] >= DATEADD("dd", -CAST(CWDN AS INT) - 363, GETDATE() - 365)
                 THEN
                 1
             ELSE
                 0
         END
        )
        END                     AS [PY Last 52 Weeks],
        CASE
            WHEN [Transaction Date] < DATEADD("dd", -CAST(CWDN AS INT), GETDATE())
                 AND [Transaction Date] >= DATEADD("dd", -CAST(CWDN AS INT) - 7, GETDATE())
                THEN
                1
            ELSE
                0
        END                     [Last Week Flag],
        CASE
            WHEN [Transaction Date] < DATEADD("dd", -CAST(CWDN AS INT), GETDATE())
                 AND [Transaction Date] >= DATEADD("dd", -CAST(CWDN AS INT) - 42, GETDATE())
                THEN
                1
            ELSE
                0
        END                     [Last 6 Weeks],
        CASE
            WHEN [Transaction Date] < DATEADD("dd", -CAST(CWDN AS INT), GETDATE())
                 AND [Transaction Date] >= DATEADD("dd", -CAST(CWDN AS INT) - 364, GETDATE())
                THEN
                1
            ELSE
                0
        END                     [Last 52 Weeks],
        CASE
            WHEN [Transaction Date] < [CD]
                 AND [Transaction Date] > DATEADD("dd", -30, [CD])
                THEN
                1
            ELSE
                0
        END                     [Last 30 Days],
        CASE
            WHEN [Transaction Date] < [CD]
                 AND [Transaction Date] > DATEADD("dd", -90, [CD])
                THEN
                1
            ELSE
                0
        END                     [Last 90 Days],
        CASE
            WHEN [Transaction Date] < [CD]
                 AND [Transaction Date] > DATEADD("dd", -180, [CD])
                THEN
                1
            ELSE
                0
        END                     [Last 180 Days],
        CASE
            WHEN [Transaction Date] < [CD]
                 AND [Transaction Date] > DATEADD("dd", -365, [CD])
                THEN
                1
            ELSE
                0
        END                     [Last 365 Days],
        ---case when [CW] = 1 then 52 else [CW]-1 end as [LW],
        --case when [CW] = 1 then 12 else [CM] end 
        --1 as [LWM],
        (
            SELECT TOP 1
                   [Fiscal Month]
            FROM
                   AFISales_DW.DimDateFile
            WHERE
                   [Fiscal Week] = [LW]
        )                       AS [LWM],
        --case when [CM] = 1 then 12 else [CM]-1 end 
        (
            SELECT TOP 1
                   CASE
                       WHEN [Fiscal Month] - 1 = 0
                           THEN
                           12
                       WHEN [Fiscal Month] - 1 = -1
                           THEN
                           11
                       WHEN [Fiscal Month] - 1 = -2
                           THEN
                           10
                       ELSE
                           [Fiscal Month] - 1
                   END
            FROM
                   AFISales_DW.DimDateFile
            WHERE
                   [Fiscal Week] = [LW]
        )                       AS [LWM-1],
        --case when [CM] = 1 then 11 else [CM]-2 end 
        (
            SELECT TOP 1
                   CASE
                       WHEN [Fiscal Month] - 2 = 0
                           THEN
                           12
                       WHEN [Fiscal Month] - 2 = -1
                           THEN
                           11
                       WHEN [Fiscal Month] - 2 = -2
                           THEN
                           10
                       ELSE
                           [Fiscal Month] - 2
                   END
            FROM
                   AFISales_DW.DimDateFile
            WHERE
                   [Fiscal Week] = [LW]
        )                       AS [LWM-2],
        --case when [CM] = 1 then 10 else [CM]-3 end 
        (
            SELECT TOP 1
                   CASE
                       WHEN [Fiscal Month] - 3 = 0
                           THEN
                           12
                       WHEN [Fiscal Month] - 3 = -1
                           THEN
                           11
                       WHEN [Fiscal Month] - 3 = -2
                           THEN
                           10
                       ELSE
                           [Fiscal Month] - 3
                   END
            FROM
                   AFISales_DW.DimDateFile
            WHERE
                   [Fiscal Week] = [LW]
        )                       AS [LWM-3],
        (
            SELECT TOP 1
                   CASE
                       WHEN [Fiscal Month] - 1 = 0
                           THEN
                           PY - 1
                       ELSE
                           PY
                   END
            FROM
                   AFISales_DW.DimDateFile
            WHERE
                   [Fiscal Week] = [LW]
        )                       AS [LWM-1_PY],
        (
            SELECT TOP 1
                   CASE
                       WHEN [Fiscal Month] - 1 = 0
                           THEN
                           PY
                       ELSE
                           CY
                   END
            FROM
                   AFISales_DW.DimDateFile
            WHERE
                   [Fiscal Week] = [LW]
        )                       AS [LWM-1_CY],
        CASE
            WHEN [CW] = 1
                THEN
                [PY] - 1
            ELSE
                [PY]
        END                     AS [LWPY],
        CASE
            WHEN [CW] = 1
                THEN
                [PY]
            ELSE
                [CY]
        END                     AS [LWCY],
        (
            SELECT
                MAX([Fiscal Week])
            FROM
                AFISales_DW.DimDateFile
            WHERE
                [Fiscal Year] = [CY]
                AND [Fiscal Month] = [CM]
        )                       AS [LWCM],
        [LM],
        (
            SELECT
                MAX([Fiscal Week])
            FROM
                AFISales_DW.DimDateFile
            WHERE
                [Fiscal Year] = [CY]
                AND [Fiscal Month] = [LM]
        )                       AS [LWLM],
        [LMM-1],
        (
            SELECT
                MAX([Fiscal Week])
            FROM
                AFISales_DW.DimDateFile
            WHERE
                [Fiscal Month] = [LMM-1]
        )                       AS [LWLMM-1],
        (
            SELECT DISTINCT
                   [Fiscal Month Desc ID]
            FROM
                   AFISales_DW.DimDateFile
            WHERE
                   [Fiscal Month Indicator] = -1
        )                       [CMM1],
        (
            SELECT DISTINCT
                   [Fiscal Month Desc ID]
            FROM
                   AFISales_DW.DimDateFile
            WHERE
                   [Fiscal Month Indicator] = -2
        )                       [CMM2],
        (
            SELECT DISTINCT
                   [Fiscal Month Desc ID]
            FROM
                   AFISales_DW.DimDateFile
            WHERE
                   [Fiscal Month Indicator] = -3
        )                       [CMM3],
        (
            SELECT DISTINCT
                   [Fiscal Month Desc ID]
            FROM
                   AFISales_DW.DimDateFile
            WHERE
                   [Fiscal Month Indicator] = -4
        )                       [CMM4],
        (
            SELECT DISTINCT
                   [Fiscal Month Desc ID]
            FROM
                   AFISales_DW.DimDateFile
            WHERE
                   [Fiscal Month Indicator] = -5
        )                       [CMM5],
        (
            SELECT DISTINCT
                   [Fiscal Month Desc ID]
            FROM
                   AFISales_DW.DimDateFile
            WHERE
                   [Fiscal Month Indicator] = -6
        )                       [CMM6],
        (
            SELECT DISTINCT
                   [Fiscal Month Desc ID]
            FROM
                   AFISales_DW.DimDateFile
            WHERE
                   [Fiscal Month Indicator] = -7
        )                       [CMM7],
        (
            SELECT DISTINCT
                   [Fiscal Month Desc ID]
            FROM
                   AFISales_DW.DimDateFile
            WHERE
                   [Fiscal Month Indicator] = -8
        )                       [CMM8],
        [Fiscal Month Indicator],
        [Fiscal Week Indicator]
    FROM
        (
            SELECT
                [Transaction Date],
                [Fiscal Year],
                [Fiscal Week],
                [Fiscal Month],
                [Fiscal Quarter],
                [Fiscal Month Desc ID],
                [Fiscal Month Indicator],
                [Fiscal Week Indicator],
                --(SELECT  CASE WHEN [Fiscal Week] = 1 THEN 52 ELSE [Fiscal Week]-1 END FROM AFISales_DW.DimDateFile where [Transaction Date] = left(getdate(), 11)) [LW]
                (
                    SELECT
                        CASE
                            WHEN [Fiscal Week] = 1
                                THEN
                                (
                                    SELECT
                                        MAX([Fiscal Week])
                                    FROM
                                        AFISales_DW.DimDateFile
                                    WHERE
                                        [Fiscal Year Indicator] = -1
                                )
                            ELSE
                                [Fiscal Week] - 1
                        END
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] = LEFT(GETDATE(), 11)
                )         [LW],
                (
                    SELECT
                        [Fiscal Week]
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] = LEFT(GETDATE(), 11)
                )         [CW],
                (
                    SELECT
                        [WeekdayID]
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] = LEFT(GETDATE(), 11)
                )         [CWDN],
                (
                    SELECT
                        [Fiscal Year]
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] = LEFT(GETDATE(), 11)
                )         [CY],
                (
                    SELECT
                        [Fiscal Year] - 1
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] = LEFT(GETDATE(), 11)
                )         [PY],
                (
                    SELECT
                        [Fiscal Month]
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] = LEFT(GETDATE(), 11)
                )         [CM],
                (
                    SELECT
                        CASE
                            WHEN [Fiscal Month] = 1
                                THEN
                                12
                            ELSE
                                [Fiscal Month] - 1
                        END
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] = LEFT(GETDATE(), 11)
                )         [LM],
                (
                    SELECT
                        CASE
                            WHEN [Fiscal Month] = 2
                                THEN
                                12
                            WHEN [Fiscal Month] = 1
                                THEN
                                11
                            ELSE
                                [Fiscal Month] - 2
                        END
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] = LEFT(GETDATE(), 11)
                )         [LMM-1],
                (
                    SELECT
                        [Fiscal Week]
                    FROM
                        (
                            SELECT
                                MAX([Fiscal Week]) AS [Fiscal Week]
                            FROM
                                AFISales_DW.DimDateFile
                            WHERE
                                [Fiscal Year Indicator] = -1
                        ) AS SQ
                )         [PY_LW],
                (
                    SELECT
                        [Fiscal Week]
                    FROM
                        (
                            SELECT
                                MAX([Fiscal Week]) AS [Fiscal Week]
                            FROM
                                AFISales_DW.DimDateFile
                            WHERE
                                [Fiscal Year Indicator] = 0
                        ) AS SQ
                )         [CY_LW],
                GETDATE() [CD]
            FROM
                AFISales_DW.DimDateFile
            WHERE
                [Fiscal Year Indicator] <= 1
                AND [Fiscal Year Indicator] >= -4
        ) A;
GO