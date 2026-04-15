CREATE VIEW [PowerBI_Retail_Wrk].[v_CoSales_PortalUsers]
AS
SELECT [Operation],
			[user_id],
			[user_name],
			[user_brand],
			[Location_ID],
			[Employee_Number],
			[People_ID],
			[active_status],
			[EmailAddress]
			 from [$(Source_data)].[Retail_Miniapps].[Portal_Users]
GO

