CREATE      VIEW [Retail_DW_Core_Wrk].[v_Leadsv2]
AS
Select
     LocationId,StaffId SalePersonID, FullName LeadName, Email, CustomerId, PhoneNumber,
     RelationshipId
	,LeadLastActivity ActivityDate
	,[LastActivity] LastActivity
	,Null StorisAppUserId
	,CartId
	,DateCreated rel_created
	,StaffIDs
 FROM  [Retail_DW_Core].[RelationshipActivities] r
 WHERE 1=1 ;
GO

