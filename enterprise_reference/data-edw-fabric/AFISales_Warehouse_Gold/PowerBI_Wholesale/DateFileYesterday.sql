CREATE VIEW [PowerBI_Wholesale].[DateFile_Yesterday]
AS
    SELECT
        [Transaction Date],
        [Fiscal Year],
        [Fiscal Week],
        [Fiscal Month],
        [Fiscal Quarter],
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
        )   [CY CD],
        (
            SELECT
                [Transaction Date]
            FROM
                AFISales_DW.DimDateFile
            WHERE
                [Fiscal Year] = [PY]
                AND [Fiscal Week] = [CW]
                AND [WeekdayID] = [CWDN]
        )   [PY CD],
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
                 AND ([Fiscal Year] = [PY])
                THEN
                1
            ELSE
                0
        END [PY YTD Flag],
        CASE
            WHEN [Transaction Date] <= [CD]
                 AND [Fiscal Year] = [CY]
                THEN
                1
            ELSE
                0
        END [CY YTD Flag],
        CASE
            WHEN [Transaction Date] <= [CD]
                 AND [Fiscal Year] = [CY]
                 AND [Fiscal Month] = [CM]
                THEN
                1
            ELSE
                0
        END [CY MTD Flag],
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
        END [PY MTD Flag],
        CASE
            WHEN [Transaction Date] <= [CD]
                 AND [Fiscal Year] = [CY]
                 AND [Fiscal Month] = [CM]
                 AND [Fiscal Week] = [CW]
                THEN
                1
            ELSE
                0
        END [CY WTD Flag],
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
        END [PY WTD Flag],
        CASE
            WHEN [CY_LW] = 53
                 OR [PY_LW] = 53
                THEN
        (CASE
             WHEN [Transaction Date] < DATEADD("dd", -CAST(CWDN AS INT), GETDATE() - 372)
                  AND [Transaction Date] >= DATEADD("dd", -CAST(CWDN AS INT) - 7, GETDATE() - 372)
                 THEN
                 1
             ELSE
                 0
         END
        )
            ELSE
        (CASE
             WHEN [Transaction Date] < DATEADD("dd", -CAST(CWDN AS INT), GETDATE() - 365)
                  AND [Transaction Date] >= DATEADD("dd", -CAST(CWDN AS INT) - 7, GETDATE() - 365)
                 THEN
                 1
             ELSE
                 0
         END
        )
        END AS [PY Last Week Flag],
        CASE
            WHEN [CY_LW] = 53
                 OR [PY_LW] = 53
                THEN
        (CASE
             WHEN [Transaction Date] < DATEADD("dd", -CAST(CWDN AS INT), GETDATE() - 372)
                  AND [Transaction Date] >= DATEADD("dd", -CAST(CWDN AS INT) - 42, GETDATE() - 372)
                 THEN
                 1
             ELSE
                 0
         END
        )
            ELSE
        (CASE
             WHEN [Transaction Date] < DATEADD("dd", -CAST(CWDN AS INT), GETDATE() - 365)
                  AND [Transaction Date] >= DATEADD("dd", -CAST(CWDN AS INT) - 42, GETDATE() - 365)
                 THEN
                 1
             ELSE
                 0
         END
        )
        END AS [PY Last 6 Weeks],
        CASE
            WHEN [CY_LW] = 53
                 OR [PY_LW] = 53
                THEN
        (CASE
             WHEN [Transaction Date] < DATEADD("dd", -CAST(CWDN AS INT), GETDATE() - 372)
                  AND [Transaction Date] >= DATEADD("dd", -CAST(CWDN AS INT) - 364, GETDATE() - 372)
                 THEN
                 1
             ELSE
                 0
         END
        )
            ELSE
        (CASE
             WHEN [Transaction Date] < DATEADD("dd", -CAST(CWDN AS INT), GETDATE() - 365)
                  AND [Transaction Date] >= DATEADD("dd", -CAST(CWDN AS INT) - 364, GETDATE() - 365)
                 THEN
                 1
             ELSE
                 0
         END
        )
        END AS [PY Last 52 Weeks],
        CASE
            WHEN [Transaction Date] < DATEADD("dd", -CAST(CWDN AS INT), GETDATE() - 1)
                 AND [Transaction Date] >= DATEADD("dd", -CAST(CWDN AS INT) - 7, GETDATE() - 1)
                THEN
                1
            ELSE
                0
        END [Last Week Flag],
        CASE
            WHEN [Transaction Date] < DATEADD("dd", -CAST(CWDN AS INT), GETDATE() - 1)
                 AND [Transaction Date] >= DATEADD("dd", -CAST(CWDN AS INT) - 42, GETDATE() - 1)
                THEN
                1
            ELSE
                0
        END [Last 6 Weeks],
        CASE
            WHEN [Transaction Date] < DATEADD("dd", -CAST(CWDN AS INT), GETDATE() - 1)
                 AND [Transaction Date] >= DATEADD("dd", -CAST(CWDN AS INT) - 364, GETDATE() - 1)
                THEN
                1
            ELSE
                0
        END [Last 52 Weeks],
        CASE
            WHEN [Transaction Date] < [CD]
                 AND [Transaction Date] > DATEADD("dd", -14, [CD])
                THEN
                1
            ELSE
                0
        END [Last 14 Days],
        CASE
            WHEN [Transaction Date] < [CD]
                 AND [Transaction Date] > DATEADD("dd", -30, [CD])
                THEN
                1
            ELSE
                0
        END [Last 30 Days],
        CASE
            WHEN [Transaction Date] < [CD]
                 AND [Transaction Date] > DATEADD("dd", -90, [CD])
                THEN
                1
            ELSE
                0
        END [Last 90 Days],
        CASE
            WHEN [Transaction Date] < [CD]
                 AND [Transaction Date] > DATEADD("dd", -365, [CD])
                THEN
                1
            ELSE
                0
        END [Last 365 Days],
        (
            SELECT TOP 1
                   [Fiscal Month]
            FROM
                   AFISales_DW.DimDateFile
            WHERE
                   [Fiscal Week] = [LW]
        )   AS [LWM],
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
        )   AS [LWM-1],
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
        )   AS [LWM-2],
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
        )   AS [LWM-3],
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
        )   AS [LWM-1_PY],
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
        )   AS [LWM-1_CY],
        CASE
            WHEN [CW] = 1
                THEN
                [PY] - 1
            ELSE
                [PY]
        END AS [LWPY],
        CASE
            WHEN [CW] = 1
                THEN
                [PY]
            ELSE
                [CY]
        END AS [LWCY],
        (
            SELECT
                MAX([Fiscal Week])
            FROM
                AFISales_DW.DimDateFile
            WHERE
                [Fiscal Year] = [CY]
                AND [Fiscal Month] = [CM]
        )   AS [LWCM]
    FROM
        (
            SELECT
                [Transaction Date],
                [Fiscal Year],
                [Fiscal Week],
                [Fiscal Month],
                [Fiscal Quarter],
                --(SELECT  CASE WHEN [Fiscal Week] = 1 THEN 52 ELSE [Fiscal Week]-1 END FROM AFISales_DW.DimDateFile where [Transaction Date]=left(getdate()-1,11)) [LW]
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
                        [Transaction Date] = LEFT(GETDATE() - 1, 11)
                )             [LW],
                (
                    SELECT
                        [Fiscal Week]
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] = LEFT(GETDATE() - 1, 11)
                )             [CW],
                (
                    SELECT
                        [WeekdayID]
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] = LEFT(GETDATE() - 1, 11)
                )             [CWDN],
                (
                    SELECT
                        [Fiscal Year]
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] = LEFT(GETDATE() - 1, 11)
                )             [CY],
                (
                    SELECT
                        [Fiscal Year] - 1
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] = LEFT(GETDATE() - 1, 11)
                )             [PY],
                (
                    SELECT
                        [Fiscal Month]
                    FROM
                        AFISales_DW.DimDateFile
                    WHERE
                        [Transaction Date] = LEFT(GETDATE() - 1, 11)
                )             [CM],
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
                )             [PY_LW],
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
                )             [CY_LW],
                GETDATE() - 1 [CD]
            FROM
                AFISales_DW.DimDateFile
            WHERE
                [Fiscal Year Indicator] <= 1
                AND [Fiscal Year Indicator] >= -4
        ) A;
