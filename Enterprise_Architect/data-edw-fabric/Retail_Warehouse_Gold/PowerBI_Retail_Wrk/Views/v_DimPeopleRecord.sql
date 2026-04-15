-- Auto Generated (Do not modify) 5858F5CA867100903928D24B1DD97F62E5DB8FB8684A8808F4FE7684220D0477
CREATE VIEW [PowerBI_Retail_Wrk].[v_DimPeopleRecord]
AS
select pr.JobID,hj.JobName, s.SalesPersonName,pr.PeopleID,s.SalesPersonID,s.ActiveStatus
  from [Retail_DW_Core].[DimSalesPerson] s
left join [Retail_DW_Core].[DimHRJobs] hj
left join  [PowerBI_Retail].[PeopleRecord] pr
  ON PR.JobID = HJ.JobID
ON S.PeopleID = PR.PeopleID