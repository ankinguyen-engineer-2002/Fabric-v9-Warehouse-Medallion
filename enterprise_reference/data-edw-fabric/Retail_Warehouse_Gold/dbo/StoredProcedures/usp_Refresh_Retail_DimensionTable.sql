CREATE PROCEDURE [dbo].[usp_Refresh_Retail_DimensionTable] 
AS

BEGIN 

EXEC [Retail_DW_Core].[usp_Refresh_DimCustomerMaster];

EXEC [Retail_DW_Core].[usp_Refresh_DimFRLocationMap];

EXEC [Retail_DW_Core].[usp_Refresh_DimGroupMaster];

EXEC [Retail_DW_Core].[usp_Refresh_DimPaymentType];

EXEC [Retail_DW_Core].[usp_Refresh_DimProductMaster];

EXEC [Retail_DW_Core].[usp_Refresh_DimReasonCode];

EXEC [Retail_DW_Core].[usp_Refresh_DimSalesPerson];

EXEC [Retail_DW_Core].[usp_Refresh_DimStoreLocation];

EXEC [Retail_DW_Core].[usp_Refresh_DimStoreLocationGroup];

EXEC [Retail_DW_Core].[usp_Refresh_DimStoreLocationCalendar];

EXEC [Retail_DW_Core].[usp_Refresh_DimVendorMaster];

END