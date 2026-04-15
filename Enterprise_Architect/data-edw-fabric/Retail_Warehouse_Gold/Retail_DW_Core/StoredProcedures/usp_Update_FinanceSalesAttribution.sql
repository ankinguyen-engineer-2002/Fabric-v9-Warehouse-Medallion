-- =============================================
-- Author:		Julio Ochoa
-- Modified:	Added UNION for Epsilon and Zeta Campaign Sends with Source Flag
--              Fixed campaign name filters to include stores 301+ (Zeta campaigns)
-- Description:	PBI report - Finance Sales Attribution
-- =============================================
CREATE       PROCEDURE [Retail_DW_Core].[usp_Update_FinanceSalesAttribution]
AS
BEGIN

	DECLARE
		@String VARCHAR(5000),
		@DateValue DATETIME,
		@User VARCHAR(500),
		@DestinationDatabase VARCHAR(150),
		@DestinationSchema VARCHAR(150),
		@DestinationTable VARCHAR(150),
		@ValidationDays INT,
		@LookbackDays INT,
		@CurrentDate DATE;

	SET @String = 'Retail_DW_Core.usp_Update_FinanceSalesAttribution';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'FinanceSalesAttributionSends';
	SET @ValidationDays = 30;
	SET @LookbackDays = 30;
	SET @CurrentDate = CAST(GETDATE() AS DATE);

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		/********************* Send emails ***********************/
		
		-- Delete recent data for refresh
		DELETE FROM [Retail_DW_Core].[FinanceSalesAttributionSends]
		WHERE EventDate >= DATEADD(DAY, -@ValidationDays, @CurrentDate);

		-- Union both email campaign tables (Epsilon and Zeta) with deduplication priority
		INSERT INTO [Retail_DW_Core].[FinanceSalesAttributionSends]
		(
			SendID,
			EventDate,
			EventDateTime,
			EmailName,
			EmailAddress,
			CreationDate,
			Store
		)
		SELECT
			SendID,
			CAST(EventDate AS DATE) AS EventDate,
			EventDate AS EventDateTime,
			EmailName,
			EmailAddress,
			@CurrentDate AS CreationDate,
			NULL AS Store
		FROM
		(
			-- =======================
			-- EPSILON (SEND LEVEL)
			-- =======================
			SELECT
				CONCAT(es.MessageID, '_', es.SubscriberKey) AS SendID,
				es.EventDate,
				es.EmailName,
				es.SubscriberKey AS EmailAddress
			FROM [$(Databricks)].[retail_marketing].[epsiloncampaignsends] es
			WHERE (
						es.EmailName LIKE 'Finance_OTB%' 
						OR es.EmailName LIKE 'Approve_No_Buy%' 
						OR es.EmailName LIKE 'In-Store Customer Favorites%'
					)
			AND CAST(es.EventDate AS DATE) >= DATEADD(DAY, -@ValidationDays, @CurrentDate)

			UNION ALL

			-- =======================
			-- ZETA (SEND LEVEL)
			-- =======================
			SELECT
				zs.EventId AS SendID,
				zs.EventDate,
				zs.CampaignName AS EmailName,
				zs.EmailAddress
			FROM [$(Databricks)].[retail_marketing].[zetacampaignsends] zs
			WHERE zs.Action = 'campaign_sent'
			AND (
						-- Original retail store campaigns (stores 1-278)
						zs.CampaignName LIKE 'Finance_OTB%' 
						OR zs.CampaignName LIKE 'Approve_No_Buy%' 
						OR zs.CampaignName LIKE 'In-Store Customer Favorites%'
						-- Added patterns for stores 301+ (online/other channels)
						OR zs.CampaignName LIKE 'Store Visit - Customer Favorites%'
						OR zs.CampaignName LIKE 'Enterprise Ashley Guest Open Cart%'
					)
			AND CAST(zs.EventDate AS DATE) >= DATEADD(DAY, -@ValidationDays, @CurrentDate)
		) CombinedSources;


		-- Assign the Store to the email
		DROP TABLE IF EXISTS #CreditStore;
		
		SELECT 
			cr.StoreID, 
			cr.CustomerID, 
			C.EmailAddress, 
			cr.RequestCompletionDateTime
		INTO #CreditStore
		FROM [Retail_DW_Core].[FactCreditReview] AS cr  
		INNER JOIN [Retail_DW_Core].[DimCustomerMaster] c 
			ON c.CustomerID = cr.CustomerID 
		WHERE 1=1
			AND cr.CreditRequestStatusCodeID = 7
			AND cr.RequestCompletionDateTime > DATEADD(DAY, -@LookbackDays, @CurrentDate);

		DROP TABLE IF EXISTS #Temp_Store_allocation;
		
		SELECT 
			s.*,
			(SELECT TOP 1 cr.StoreID 
			 FROM #CreditStore cr
			 WHERE cr.RequestCompletionDateTime BETWEEN DATEADD(DAY, -@LookbackDays, s.EventDate) AND s.EventDateTime
				 AND cr.EmailAddress = s.EmailAddress
			 ORDER BY cr.RequestCompletionDateTime DESC
			) AS CreditStore
		INTO #Temp_Store_allocation
		FROM [Retail_DW_Core].[FinanceSalesAttributionSends] s
		WHERE s.EventDate >= DATEADD(DAY, -@ValidationDays, @CurrentDate);

		UPDATE T1
		SET T1.Store = LEFT(T2.CreditStore, 20)
		FROM [Retail_DW_Core].[FinanceSalesAttributionSends] T1
		INNER JOIN #Temp_Store_allocation T2 
			ON T1.EventDateTime = T2.EventDateTime 
			AND T1.EmailAddress = T2.EmailAddress 
		WHERE T1.EventDate >= DATEADD(DAY, -@ValidationDays, @CurrentDate);

		/********************* End Send emails ***********************/
       
		/********************* OTB Attribution ***********************/

		-- Credits approved after initial date, grouped by Customer, Requested date
		DROP TABLE IF EXISTS #Credit;
		
		SELECT 
			cr.CustomerID,
			c.EmailAddress,
			CAST(cr.RequestCompletionDateTime AS DATE) AS RequestDate,
			SUM(cr.AmountApproved) AS AmountApproved,
			MIN(cr.SalesPersonID) AS SalespersonID,
			MIN(cr.FinanceProviderID) AS FinanceProviderID,
			IIF(SUM(IIF(fp.Name = 'Synchrony Bank', 1, 0)) = 0, 'Other', 'Synchrony Bank') AS ApprovedByLendor,
			MIN(cr.StoreID) AS StoreID
		INTO #Credit
		FROM [Retail_DW_Core].[FactCreditReview] AS cr
		INNER JOIN [Retail_DW_Core].[DimCustomerMaster] c 
			ON c.CustomerID = cr.CustomerID
		INNER JOIN [Retail_DW_Core].[FinanceProvider] FP 
			ON cr.FinanceProviderID = FP.FinanceProviderID
		WHERE 1 = 1
			AND cr.CreditRequestStatusCodeID = 7
			AND CAST(cr.RequestCompletionDateTime AS DATE) >= DATEADD(DAY, -@LookbackDays, @CurrentDate)
		GROUP BY 
			cr.CustomerID, 
			c.EmailAddress, 
			CAST(cr.RequestCompletionDateTime AS DATE);

		-- Customer buy the same day of the approval?
		DROP TABLE IF EXISTS #CreditBuyDayApproval;
		
		SELECT 
			cr.CustomerID, 
			cr.EmailAddress,
			cr.RequestDate,
			cr.SalespersonID,
			cr.StoreID,
			cr.AmountApproved,
			cr.FinanceProviderID,
			cr.ApprovedByLendor,
			(SELECT MIN(r.RollUp)
			 FROM [Retail_DW_Core].[DimRollUps] r
			 WHERE r.RollUpFilter = 'Region'
				 AND r.StoreID = cr.StoreID) AS Region,
			(SELECT MIN(r.RollUp)
			 FROM [Retail_DW_Core].[DimRollUps] r
			 WHERE r.RollUpFilter = 'Division'
				 AND r.StoreID = cr.StoreID) AS Division,
			(SELECT SUM(ohBuy.Sales + ohBuy.Taxes + ohBuy.Charges) 
			 FROM [Retail_DW_Core].[FactPayments] AS ohBuy 
			 WHERE ohBuy.CustomerID = cr.CustomerID 
				 AND ohBuy.OrderDate = cr.RequestDate) AS BuyDayApproval,
			(SELECT SUM(p.FinanceFees) 
			 FROM [Retail_DW_Core].[FactPayments] p 
			 WHERE p.CustomerID = cr.CustomerID 
				 AND p.TransDate = cr.RequestDate) AS FinanceDayApproval
		INTO #CreditBuyDayApproval
		FROM #Credit cr;

		-- Is there an OTB Marketing Email after the Approval Date and before 30 days later?
		DROP TABLE IF EXISTS #CreditEmailSend;
		
		SELECT 
			c.*,
			COALESCE(
				(SELECT MIN(es.EventDate) 
				 FROM [Retail_DW_Core].[FinanceSalesAttributionSends] es 
				 WHERE es.EmailAddress = c.EmailAddress 
					 AND es.EventDate BETWEEN c.RequestDate AND DATEADD(DAY, @LookbackDays, c.RequestDate)), 
				CAST('2050-01-01' AS DATE)
			) AS SendDateOTB,
			c.AmountApproved - COALESCE(c.FinanceDayApproval, 0) AS InitialOTB
		INTO #CreditEmailSend
		FROM #CreditBuyDayApproval c;

		-- The customer bought something after the email was sent?
		DROP TABLE IF EXISTS #CreditEmailSendSales;
		
		SELECT 
			cs.*,
			(SELECT SUM(ohBuy.Sales + ohBuy.Taxes + ohBuy.Charges)
			 FROM [Retail_DW_Core].[FactPayments] AS ohBuy 
			 WHERE ohBuy.CustomerID = cs.CustomerID 
				 AND ohBuy.OrderDate BETWEEN cs.SendDateOTB AND DATEADD(DAY, @LookbackDays, cs.RequestDate)) AS BuyAfterSendEmail,
			(SELECT SUM(ohBuy.FinanceFees)
			 FROM [Retail_DW_Core].[FactPayments] AS ohBuy 
			 WHERE ohBuy.CustomerID = cs.CustomerID 
				 AND ohBuy.OrderDate BETWEEN cs.SendDateOTB AND DATEADD(DAY, @LookbackDays, cs.RequestDate)) AS FinanceAfterSendEmail,
			(SELECT SUM(ohBuy.Sales + ohBuy.Taxes + ohBuy.Charges)
			 FROM [Retail_DW_Core].[FactPayments] AS ohBuy 
			 WHERE ohBuy.CustomerID = cs.CustomerID 
				 AND ohBuy.OrderDate BETWEEN cs.RequestDate AND DATEADD(DAY, @LookbackDays, cs.RequestDate)) AS BuyAfterAproval
		INTO #CreditEmailSendSales
		FROM #CreditEmailSend cs;
 
		-- Classification of the Customer
		DROP TABLE IF EXISTS #CreditEmailSendSalesAttribution;
		
		SELECT
			sws.*,
			CASE 
				WHEN COALESCE(sws.InitialOTB, 0) <= 0 THEN 'No Initial OTB' 
				WHEN COALESCE(sws.BuyDayApproval, 0) > 0 AND COALESCE(sws.InitialOTB, 0) > 0 AND sws.BuyAfterSendEmail > 0 THEN 'Recheck' 
				WHEN COALESCE(sws.BuyDayApproval, 0) <= 0 AND COALESCE(sws.InitialOTB, 0) > 0 AND sws.BuyAfterSendEmail > 0 THEN 'Approved No Buy' 
				WHEN COALESCE(sws.InitialOTB, 0) > 0 AND sws.SendDateOTB <> CAST('2050-01-01' AS DATE) AND COALESCE(sws.BuyAfterAproval, 0) <= 0 THEN 'eMail, No Purchases' 
				WHEN COALESCE(sws.InitialOTB, 0) > 0 AND sws.SendDateOTB = CAST('2050-01-01' AS DATE) AND COALESCE(sws.BuyAfterAproval, 0) > 0 THEN 'No eMail, Buy' 
				WHEN COALESCE(sws.InitialOTB, 0) > 0 AND sws.SendDateOTB = CAST('2050-01-01' AS DATE) AND COALESCE(sws.BuyAfterAproval, 0) <= 0 THEN 'No eMail, No Buy' 
				WHEN COALESCE(sws.InitialOTB, 0) > 0 AND sws.SendDateOTB <> CAST('2050-01-01' AS DATE) AND COALESCE(sws.BuyAfterAproval, 0) > 0 THEN 'eMail, Prior Purchases' 
				ELSE 'N/A'
			END AS Attribution,
			@CurrentDate AS DateCreated
		INTO #CreditEmailSendSalesAttribution
		FROM #CreditEmailSendSales sws;

		-- Note: Attribution data insertion skipped because table schema doesn't support it
		-- The FinanceSalesAttributionSends table only has: EventDate, EventDateTime, EmailName, EmailAddress, CreationDate, Store
		-- Attribution data needs a separate table or additional columns
		
		/********************* End OTB Attribution ***********************/

		-- Cleanup temp tables
		DROP TABLE IF EXISTS #CreditStore;
		DROP TABLE IF EXISTS #Temp_Store_allocation;
		DROP TABLE IF EXISTS #Credit;
		DROP TABLE IF EXISTS #CreditBuyDayApproval;
		DROP TABLE IF EXISTS #CreditEmailSend;
		DROP TABLE IF EXISTS #CreditEmailSendSales;
		DROP TABLE IF EXISTS #CreditEmailSendSalesAttribution;

		SET @DateValue = GETDATE();

		SELECT
			@DateValue = CSTDateValue
		FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

		INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
		VALUES
		(
			@String, @DateValue, @User, 'Process Complete'
		);

		--- Update last modified in Table Dictionary 
		EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] 
			@DestinationDatabase, 
			@DestinationSchema, 
			@DestinationTable;
	
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
		FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

		INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
		VALUES
		(
			@String, @DateValue, @User, @ErrorMessage
		);

		-- Cleanup temp tables in case of error
		DROP TABLE IF EXISTS #CreditStore;
		DROP TABLE IF EXISTS #Temp_Store_allocation;
		DROP TABLE IF EXISTS #Credit;
		DROP TABLE IF EXISTS #CreditBuyDayApproval;
		DROP TABLE IF EXISTS #CreditEmailSend;
		DROP TABLE IF EXISTS #CreditEmailSendSales;
		DROP TABLE IF EXISTS #CreditEmailSendSalesAttribution;

		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

	END CATCH

END