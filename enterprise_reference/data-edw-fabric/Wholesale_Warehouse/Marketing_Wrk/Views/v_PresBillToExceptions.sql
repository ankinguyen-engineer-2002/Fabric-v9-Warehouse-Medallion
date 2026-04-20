CREATE VIEW [Marketing_Wrk].[v_PresBillToExceptions]
AS
SELECT  [pbeCusno]
      ,[acrec]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
  FROM [$(Source_Data)].[Wholesale_Marketing].[PresBillToExceptions]