CREATE PROCEDURE [DW_Developer].[usp_UpdateTableDictionaryModified]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Update the main table with max lastUpdated from the update log
        UPDATE td
        SET td.Modified = ul.MaxLastUpdated
        FROM DW_Developer.TableDictionary AS td
        INNER JOIN (
            select SchemaName,TableName,MAX(MaxLastUpdated) as MaxLastUpdated from (
SELECT 
                SchemaName,
                TableName,
                MAX(LastUpdated) AS MaxLastUpdated
            FROM DW_Developer.TableDictionary_UpdateLog 
			--where DatabaseName='Source_Data'
            GROUP BY SchemaName, TableName
union 
SELECT 
                SchemaName,
                TableName,
                MAX(LastUpdated) AS MaxLastUpdated
            FROM DW_Developer.TableDictionary_UpdateLog_RadarSync 
			--where DatabaseName='Source_Data'
            GROUP BY SchemaName, TableName
) sdf 
group by SchemaName,TableName
        ) AS ul
            ON td.SchemaName = ul.SchemaName
            AND td.TableName = ul.TableName

        WHERE td.Modified <> ul.MaxLastUpdated 
           OR td.Modified IS NULL;


        COMMIT TRANSACTION;

        -- Return summary of updated rows
        --SELECT 
        --    @@ROWCOUNT AS RowsUpdated,
        --    GETDATE() AS ExecutionTime;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Throw error details
        THROW;
    END CATCH;
END;
