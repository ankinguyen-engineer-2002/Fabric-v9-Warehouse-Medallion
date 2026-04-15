Create view ProductKnowledge_Wrk.v_ItemCodeMaster
As
SELECT [icmItemCodeId]
      ,[icmDescription]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
  FROM [$(Databricks)].[masterdata_productknowledge].[itemcodemaster]