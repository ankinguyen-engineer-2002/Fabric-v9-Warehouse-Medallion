CREATE view ProductKnowledge_Wrk.v_RetailSalesCategory
as
SELECT [rtcRetailCat]
      ,[rtcDescription]
      ,[rtcDivision]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
  FROM [$(Databricks)].[masterdata_productknowledge].[retailsalescategory]