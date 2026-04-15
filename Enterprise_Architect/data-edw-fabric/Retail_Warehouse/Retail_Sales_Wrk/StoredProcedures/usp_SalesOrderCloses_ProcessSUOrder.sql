CREATE PROCEDURE [Retail_Sales_Wrk].[usp_SalesOrderCloses_ProcessSUOrder]
(
    @SUOrderID VARCHAR(50) ,
    @TransDateKey INT 
)
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Wrk.usp_SalesOrderCloses_ProcessSUOrder';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		DECLARE @ChangeCount INT = 0,
				@CountTypeID VARCHAR(10) = 'ORD';

		--SELECT TOP 10* FROM [Retail_Sales_Enh].[SalesOrderLineHistory]

		SELECT 
			SuperOrderID,
			sdt.CustomerID,
			sdt.StoreID,
			--OrderID,
			CONVERT(VARCHAR(8), sdt.OrderDate, 112) AS OrderDateKey,
			sdt.SalesPersonID,
			SUM(COALESCE(sdt.NetPrice, 0)) AS Sales,
			SIGN(SUM(COALESCE(sdt.NetPrice, 0))) AS SPClose,
			CAST(0.0 AS DECIMAL(18, 2)) AS SUClose,
			--CAST(0.0 AS DECIMAL(18, 2)) AS SOClose,
			CAST(0.0 AS DECIMAL(18, 2)) AS SUOpp,
			CAST(0.0 AS DECIMAL(18, 2)) AS SOOpp,
			1 AS CurrentRec
		INTO #SDT
		FROM [Retail_Sales_Enh].[SalesOrderLineHistory] AS sdt
		WHERE sdt.SuperOrderID = @SUOrderID
		AND CONVERT(VARCHAR(8), sdt.OrderDate, 112) <= @TransDateKey
		AND sdt.Source = 'W'
		GROUP BY sdt.SuperOrderID,
					sdt.CustomerID,
					sdt.StoreID,
					--sdt.OrderID,
					CONVERT(VARCHAR(8), sdt.OrderDate, 112),
					sdt.SalesPersonID;

		SELECT *
		INTO #SOC
		FROM [Retail_Sales_Enh].[SalesOrderCloses] AS soc
		WHERE soc.SuperOrderID = @SUOrderID
		AND soc.CountTypeID = @CountTypeID
		AND soc.CurrentRec = 1;

		SELECT @ChangeCount = COUNT(*)
		FROM
		(
			SELECT *
			FROM
			(
				SELECT 
					sdt.SuperOrderID,
					sdt.SalesPersonID,
					sdt.Sales
				FROM #SDT AS sdt

				EXCEPT

				SELECT 
					soc.SuperOrderID,
					soc.SalesPersonID,
					soc.SPSales AS Sales
				FROM #SOC AS soc
			) a

			UNION

			SELECT *
			FROM
			(
				SELECT 
					soc.SuperOrderID,
					--soc.OrderID,
					soc.SalesPersonID,
					soc.SPSales AS Sales
				FROM #SOC AS soc

				EXCEPT

				SELECT 
					sdt.SuperOrderID,
					--sdt.OrderID,
					sdt.SalesPersonID,
					sdt.Sales
				FROM #SDT AS sdt
			) b
		) sp;

		--PRINT 'Change Count ' + CAST(@ChangeCount AS VARCHAR(100));

		IF @ChangeCount > 0

		BEGIN

			IF EXISTS (SELECT * FROM #SOC AS s)

			BEGIN

				UPDATE [Retail_Sales_Enh].[SalesOrderCloses]
				SET CurrentRec = 0
				WHERE SuperOrderID = @SUOrderID
				AND CurrentRec = 1
				AND CountTypeID = @CountTypeID;

				INSERT INTO [Retail_Sales_Enh].[SalesOrderCloses]
				(
					SuperOrderID,
					CountTypeID,
					CustomerID,
					LocationID,
					SalesPersonID,
					OrderDateKey,
					TransDateKey,
					--OrderID,
					SPSales,
					SPClose,
					SUClose,
					--SOClose,
					SUOpp,
					SOOpp,
					CurrentRec,
					DateChanged
				)

				SELECT 
					s.SUOrderID,
					s.CountTypeID,
					s.CustomerKey,
					s.LocationKey,
					s.SalesPersonKey,
					s.OrderDateKey,
					@TransDateKey AS TransDateKey,
					-- s.OrderID,
					s.SPSales * -1,
					s.SPClose * -1,
					s.SUClose * -1,
					--s.SOClose * -1,
					0 AS SUOpp,
					0 AS SOOpp,
					0 AS CurrentRec,
					GETDATE()
				FROM #SOC AS s;

			END

			UPDATE soc
			SET soc.SUClose = CASE WHEN cls.SUTot = 0 THEN 0 ELSE soc.SPClose / ABS(cls.SUTot) END
			FROM #SDT AS soc
			INNER JOIN
			(
				SELECT 
					soc.SuperOrderID,
					--soc.OrderID,
					soc.SalesPersonID,
					SUM(soc.SPClose) OVER (PARTITION BY soc.SuperOrderID) AS SUTot
					-- SUM(soc.SPClose) OVER (PARTITION BY soc.OrderID) AS SOTot
					FROM #SDT AS soc
			) cls
			ON cls.SuperOrderID = soc.SuperOrderID
			--AND cls.OrderID = soc.OrderID
			AND cls.SalesPersonID = soc.SalesPersonID;

			INSERT INTO [Retail_Sales_Enh].[SalesOrderCloses]
			(
				SuperOrderID,
				CountTypeID,
				CustomerID,
				LocationID,
				SalesPersonID,
				OrderDateKey,
				TransDateKey,
				--OrderID,
				SPSales,
				SPClose,
				SUClose,
				--SOClose,
				SUOpp,
				SOOpp,
				CurrentRec,
				[DateChanged]
			)

			SELECT 
				s.SuperOrderID,
				@CountTypeID,
				s.CustomerID,
				s.StoreID,
				s.SalesPersonID,
				s.OrderDateKey,
				@TransDateKey,
				-- s.OrderID,
				s.Sales,
				COALESCE(SPClose, 0) AS SPClose,
				SUClose,
				--SOClose,
				SUOpp,
				SOOpp,
				CurrentRec,
				GETDATE()
			FROM #SDT AS s;

		END

		DROP TABLE #SDT;

		DROP TABLE #SOC;

		SET @DateValue = GETDATE();

		SELECT
			@DateValue = CSTDateValue
		FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

		INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
		VALUES
		(
			@String, @DateValue, @User, 'Process Complete'
		);
	
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

		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

	END CATCH

END