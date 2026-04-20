CREATE PROC [Quality_DW].[usp_Update_FactReplacementPartHistory] AS

BEGIN

DECLARE @IncrementalDateFrom AS DATETIME
DECLARE @IncrementalDateTo AS DATETIME
DECLARE @CSTDate DATETIME
DECLARE @DateValue DATETIME


         SET @DateValue = GETDATE();
        SELECT
            @CSTDate = CSTDateValue
        FROM
            [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue);

SELECT @IncrementalDateFrom = DATEADD(dd, DATEDIFF(dd, 0, @CSTDate) , -2)
SELECT @IncrementalDateTo = DATEADD(dd, DATEDIFF(dd, 0, @CSTDate), 0)


DECLARE @String VARCHAR(5000), @User VARCHAR(500)
SET @DateValue = GETDATE();
SET @String = 'Quality_DW.usp_Update_FactReplacementPartHistory'
SET @User = SYSTEM_USER

INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog 
	 VALUES
            (
                @String, @DateValue, @User, 'Process Start'
            )

BEGIN TRY

DELETE FROM Quality_DW.FactReplacementPartHistory
WHERE  [Ship Date] BETWEEN @IncrementalDateFrom AND @IncrementalDateTo

INSERT INTO Quality_DW.FactReplacementPartHistory
(
	   [RPKey],
	   [Item Sequence],
	   [Part Number],
	   [Serial Number],
	   [Scrap Code],
	   [Item SKU],
	   [Warehouse],
	   [Location Code],
	   [Mfg Warehouse Code],
	   [Invoice Number],
	   [Invoice Date],
	   [Vendor Number],
	   [Account And ShipTo Number],
	   [Ship Date],
	   [Shipto AddressID],
	   [Replacement Part Order Count],
	   [Replacement Part Incidents],
	   [Parts Shipped Quantity - No Charge],
	   [Parts Shipped Quantity - Charged Back],
	   [Parts Cost - No Charge],
	   [Parts Cost - Charged Back],
	   [Shipping Cost - No Charge],
	   [Shipping Cost - Charged Back],
	   [Allocated],
	   [Scrap Code with CS Control Code],
	   [Days - Entered to Shipped],
	   [Primary Site ID]
)

  SELECT 
 [RPKey] ,  
 [Item Sequence],  
 [Part Number],  
 [Serial Number] ,  
 [Scrap Code],  
 [Item SKU]  ,  
 [Warehouse] ,  
 [Location Code],  
 [Mfg Warehouse Code] , 
 [Invoice Number],  
 [Invoice Date],  
 [Vendor Number],  
 [Account And Shipto Number] ,  
 [Ship Date] ,
 [Shipto AddressID], 
 [Replacement Part Order Count],    
 [Replacement Part Incidents] ,  
 [Parts Shipped Quantity - No Charge] ,  
 [Parts Shipped Quantity - Charged Back] ,  
 [Parts Cost - No Charge],  
 [Parts Cost - Charged Back] ,  
 [Shipping Cost - No Charge],
 [Shipping Cost - Charged Back] ,   
 [Allocated] ,  
 [Scrap Code with CS Control Code] ,  
 [Days - Entered to Shipped],
 [Primary Site ID]  
 FROM [$(Quality_Warehouse)].Quality_Enh.ReplacementPartHistory
 WHERE [Ship Date] BETWEEN @IncrementalDateFrom AND @IncrementalDateTo

END TRY

 BEGIN CATCH
DECLARE
                @ErrorMessage  VARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState    INT;
            SET @ErrorMessage = ERROR_MESSAGE();
            SET @ErrorSeverity = ISNULL(ERROR_SEVERITY(), 16);
            SET @ErrorState = ISNULL(ERROR_STATE(), 0);

            SET @DateValue = GETDATE();
            SELECT
                @DateValue = CSTDateValue
            FROM
                 [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue);

END CATCH

INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog 
	VALUES (@String, @DateValue, @User, 'Process Complete')

	-- Update last modified in Table Dictionary 
INSERT INTO [$(ETL_Framework)].DW_Developer.TableDictionary_UpdateLog
VALUES ( 'Quality_Warehouse','Quality_DW' , 'FactReplacementPartHistory', @DateValue )



END

