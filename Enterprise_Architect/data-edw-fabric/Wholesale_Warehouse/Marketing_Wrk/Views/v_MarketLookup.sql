
create view [Marketing_Wrk].v_MarketLookup
AS
SELECT [Mktid]
      ,[Mktcode]
      ,[Mktsdate]
      ,[Mktedate]
      ,[Usra]
      ,[Dtea]
      ,[Usrc]
      ,[Dtec]
  FROM [$(Source_Data)].[Wholesale_Marketing].[MarketLookUp]



