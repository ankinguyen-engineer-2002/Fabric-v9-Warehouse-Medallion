CREATE PROCEDURE [dbo].[usp_Portal_UserParams_GetParamValue]
	@Obj_ID int,
	@User_ID varchar(10),
	@ParamName varchar(20),
	@ParamValue varchar(50) OUTPUT
AS
Select @Obj_ID