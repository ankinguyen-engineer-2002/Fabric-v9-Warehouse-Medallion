create view PartyContacts_Wrk.v_PartyMaster
as
SELECT  [pymPartyID]
      ,[pymPartyName]
      ,[pymCustomerNumber]
      ,[pymVendorID]
      ,[pymExportID]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
      ,[pymActiveEndDate]
      ,[pymPartyType]
      ,[pymShortName]
  FROM [$(Source_Data)].[Wholesale_PartyContacts].[PartyMaster]
GO

