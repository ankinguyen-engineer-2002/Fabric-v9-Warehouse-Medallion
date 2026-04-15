

CREATE PROCEDURE [DW_Developer].[usp_UpdateTableDictionary_UpdateLog_RadarSync]
    @DestinationDatabase NVARCHAR(128),
    @SchemaName NVARCHAR(128),
    @TableName NVARCHAR(128)
AS
BEGIN
DECLARE @DateValue DATETIME;
DECLARE @EnhDatabaseName NVARCHAR(128);
DECLARE @EnhSchemaName NVARCHAR(128);
DECLARE @EnhTableName NVARCHAR(128);
SET @DateValue = GETDATE();
        SELECT
            @DateValue = CSTDateValue
        FROM
            DW_Developer.fn_GetDate(@DateValue);

SELECT @EnhDatabaseName=DatabaseName ,@EnhSchemaName = SchemaName, 
           @EnhTableName = TableName 
    FROM   DW_Developer.TableDictionary  
    WHERE   ReplicatedSource = ''+@SchemaName+ '.'+@TableName+''

 Insert into [DW_Developer].[TableDictionary_UpdateLog_RadarSync] (DatabaseName,SchemaName,TableName,LastUpdated)
 values (@EnhDatabaseName,@EnhSchemaName,@EnhTableName,@DateValue)
 
END;
