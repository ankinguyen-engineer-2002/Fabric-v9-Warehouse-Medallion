create view [PartyContacts_Wrk].[v_ContactMaster]
as
SELECT [pctContactID]
      ,[pctFullName]
      ,[pctFirstName]
      ,[pctMiddleName]
      ,[pctLastName]
      ,[pctPreferredName]
      ,[pctPreferredLanguage]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
      ,[pctLastUserChanged]
      ,cast([pctShortFullName] as varchar(25)) as [pctShortFullName]
  FROM [$(Source_Data)].[Wholesale_PartyContacts].[ContactMaster]
GO

