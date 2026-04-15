
CREATE VIEW [CustomerOrders_AFI_Wrk].[v_DashboardValueList]
AS
    SELECT
    [dbvValueListType]
      ,[dbvValueListValue]
      ,[dbvValueListValue2]
      ,[dbvDescription]
      ,[dbvSecurityTag]
      ,[dbvSequence]
      ,[dbvProgram]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
    FROM
           [$(Source_Data)].[Wholesale_Codis_AFI].[DashboardValuelist]
     
	 