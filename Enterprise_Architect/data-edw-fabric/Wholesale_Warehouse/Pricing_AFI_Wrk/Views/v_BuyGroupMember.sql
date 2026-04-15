CREATE VIEW [Pricing_AFI_Wrk].[v_BuyGroupMember]
AS
SELECT [bmeCusno]
      ,[bmeShpno]
      ,[bmeSdate]
      ,[bmeEdate]
      ,[bmeBgcode]
      ,[commaudit]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
      ,[acrec]
      ,[bmeUseDiscountProgram]
  FROM [$(Source_Data)].[wholesale_pricing_afi].[BuyGroupMember]
GO

