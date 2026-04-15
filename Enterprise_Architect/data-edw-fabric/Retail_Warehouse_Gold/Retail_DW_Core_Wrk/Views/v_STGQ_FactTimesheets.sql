-- Auto Generated (Do not modify) 12169D37B5C9E59DA7A9397E8328DE81D79E633657B08698E72434D053BAFE85
/*
2025-09-08 || Harshit S:  Created View
*/

CREATE       VIEW [Retail_DW_Core_Wrk].[v_STGQ_FactTimesheets] AS
SELECT t.TimeSheetID
     , t.PayCodeName
     , t.TaskCodeName
     , t.LocationKey as LocationID
     , dat.DateID AS TransDate
     , YEAR(dat.DateID) AS Year  -- Added Year column
     , CASE
           WHEN t.LocationKey IN ( '017', '018', '019', '020', '021', '022', '023', '032', '038', '039', '040', '071'
                                , '076', '077'
                                ) THEN
               DATEADD(HOUR, 1, t.TimeIn)
           ELSE
               t.TimeIn
       END TimeIn
     , CASE
           WHEN t.LocationKey IN ( '017', '018', '019', '020', '021', '022', '023', '032', '038', '039', '040', '071'
                                , '076', '077'
                                ) THEN
               DATEADD(HOUR, 1, t.TimeOut)
           ELSE
               t.TimeOut
       END TimeOut
     , p.EmployeeNumber
     , j.JobName
     , e.FirstName
     , e.LastName
     , CONCAT(e.FirstName, ' ', e.LastName) AS Name  -- Added Name column
--     , t.[TimeIn]
--     , t.[TimeOut]
FROM [$(Databricks)].[masterdata_hr_ukg_dsg].[peopletimesheet]   t
    LEFT JOIN [Retail_DW_Core].[DimDate]  dat on t.TransDateKey= dat.DateKey
    LEFT JOIN [$(Source_data)].[Retail_Miniapps].[PeopleRecords]    p ON t.PeopleID = p.PeopleID
    LEFT JOIN [$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory] e ON dat.DateID = e.TransDate AND p.EmployeeNumber = e.EmployeeNumber
    LEFT JOIN [Retail_DW_Core].[DimHRJobs]    j ON e.JobID = j.JobID
WHERE dat.DateID >= DATEFROMPARTS(YEAR(GETDATE()) - 1, 1, 1)
      AND j.JobID IN ( 307,366,367,83,256,322,150,369)