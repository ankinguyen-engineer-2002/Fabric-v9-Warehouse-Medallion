create view PowerBI_Retail_Wrk.v_TD_DCSalesBudget
as
SELECT Value as amount, SUBSTRING(Period,0,CHARINDEX('/',Period)) as FisPeriod, SUBSTRING(Period,CHARINDEX('/',Period)+1,len(Period)) as FisYear,  GLCostCenterID, Parent_GLAccountID 
FROM [$(Source_Data)].[Retail_Dart].[AdaptiveBudget] AS gb
  where gb.Root_GLAccountID in ('2998','2994', '2996')
 and GLCostCenterID in ('401', '444', '902','904','906','910','911','912','913','915','917','919',
'921','924','929','933','939','941','944','945','954','972','981','983')
GO

