-- Auto Generated (Do not modify) 12BA178E7EA217F0C368DBF54B3CED91512512C34E000001EEC054160B759B03
/*
2025-08-26 || Harshit S

*/

CREATE     VIEW [Retail_DW_Core_Wrk].[v_SMQQ_FactRSADetails] AS
SELECT D.LocationID
     , D.TransDate
     , E.EmployeeNumber
     , LTRIM(RTRIM(E.LastName)) + ', ' + LTRIM(RTRIM(E.FirstName)) AS EmployeeName
     , E.JobID
     , J.JobName
     , SUM(D.EmployeeHours)                                        AS EmployeeHours
     , SUM(DT.WrittenSales)                                        AS TotalSales
     , SUM(C.SuperOrderClose)                                      AS RSATransCount
FROM
(
    SELECT D.LocationID
         , D.TransDate
         , D.EmployeeNumber
         , SUM(D.MinutesWorked) / 60.0 AS EmployeeHours
    FROM [Retail_DW_Core].[DMTimeSheetHours]           D
        LEFT JOIN [$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory] E
            ON D.EmployeeNumber = E.EmployeeNumber
               AND D.TransDate = E.TransDate
    WHERE D.TransDate >= '2019-01-01'
          AND D.IsOpen = 1
          AND E.EmployeeNumber IS NOT NULL
          AND CAST(D.TransHour AS TIME) >= '10:00:00'
          AND CAST(D.TransHour AS TIME) <= '20:00:00'
          AND E.JobID IN ( '108', '128', '129', '130', '160', '179', '294', '295', '296', '297',
			'308', '309', '310', '311', '338', '339', '340' )
    GROUP BY D.LocationID
           , D.TransDate
           , D.EmployeeNumber
)                                    D
    LEFT JOIN [$(Source_data)].[Retail_Miniapps].[PeopleRecords] E
        ON D.EmployeeNumber = E.EmployeeNumber
           AND D.TransDate = E.CreatedDate
    LEFT JOIN [Retail_DW_Core].[DimHRJobs]     J
        ON E.JobID = J.JobID
    LEFT JOIN [$(Source_data)].[Retail_Miniapps].[PeopleRecords]  P
        ON E.EmployeeNumber = P.EmployeeNumber
    LEFT JOIN [Retail_DW_Core].[DimSalesPerson]       SP
        ON P.PeopleID = SP.PeopleID
    LEFT JOIN
    (
        SELECT T.SalesPersonKey
             , T.TransDateTime
             , SUM(T.Sales) AS WrittenSales
        FROM [Retail_DW_Core].[FactSales] T
        WHERE T.TransDateTime >= '2020-01-01'
        GROUP BY T.SalesPersonKey
               , T.TransDateTime
    )                                DT
        ON SP.SalesPersonID = DT.SalesPersonKey
           AND D.TransDate = DT.TransDateTime
    LEFT JOIN
    (
        SELECT C.SalesPersonKey
             , dam.DateID AS TransDate
             , C.LocationKey
             , SUM(C.SuperOrderClose) AS SuperOrderClose
        FROM [Retail_DW_Core].[FactCloses]  C
        LEFT JOIN [Retail_DW_Core].[DimDate] as dam
        on dam.DateKey = C.TransDateKey
        WHERE dam.DateID >= '2020-01-01'
        GROUP BY C.SalesPersonKey
               , dam.DateID
               , C.LocationKey
    )                                C
        ON SP.SalesPersonID = C.SalesPersonKey
           AND D.TransDate = C.TransDate
           AND D.LocationID = C.LocationKey
WHERE D.TransDate >= '2019-12-29'
      AND E.EmployeeNumber IS NOT NULL
      AND E.JobID IN ( '108', '128', '129', '130', '160', '179', '294', '295', '296', '297',
			'308', '309', '310', '311', '338', '339', '340' )
GROUP BY D.LocationID
       , D.TransDate
       , E.EmployeeNumber
       , LTRIM(RTRIM(E.LastName)) + ', ' + LTRIM(RTRIM(E.FirstName))
       , E.JobID
       , J.JobName;