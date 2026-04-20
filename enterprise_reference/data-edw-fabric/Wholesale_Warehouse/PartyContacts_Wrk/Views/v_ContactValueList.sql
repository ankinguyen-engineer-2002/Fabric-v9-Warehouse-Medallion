
create view [PartyContacts_Wrk].[v_ContactValueList]
as
SELECT  [pvlValueType]
      ,[pvlKeyValue]
      ,[pvlDescription]
      ,[pvlListType]
      ,[pvlSortSequence]
      ,[pvlSecurityTag]
      ,[pvlKeyDateValue]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
  FROM [$(Source_Data)].[Wholesale_PartyContacts].[ContactValueList]
GO

