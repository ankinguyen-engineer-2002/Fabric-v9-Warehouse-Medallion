CREATE view ProductKnowledge_Wrk.v_SetDetail
as
SELECT [sdeCustomerNumber]
      ,[sdeSetNumber]
      ,[sdeItemNumber]
      ,[sdeQuantity]
      ,[sdeKey]
      ,[sdeOption]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
  FROM [$(Databricks)].[masterdata_productknowledge].[setdetail]