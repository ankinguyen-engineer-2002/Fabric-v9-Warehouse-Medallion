CREATE PROCEDURE [dbo].[usp_Portal_UpdateUserparams]
  @user_objid int = 0,
  @user_id Varchar(2000),
  @user_prmname Varchar(3000), 
  @user_prmval int=1
AS
  SELECT @user_prmname, @user_prmval
RETURN 0