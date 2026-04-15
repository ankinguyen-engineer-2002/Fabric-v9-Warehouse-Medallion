CREATE  TABLE  CostAccounting_Enh.DC_LaborRollups_BaseData
(
       [Warehouse] varchar(10) NULL
     , [Warehouse_Desc] Varchar(20) NULL
     , [Whse_SortOrder] int NULL
     , [Department] varchar(10) NULL
     , [Department_Desc] varchar(100) NULL
     , [Activity_Desc] varchar(100) NULL
     , [WeekEnding] date NULL
     , [Units_BED] int NULL
     , [Units_DOM] int NULL
     , [Units_IMP] int NULL
     , [Units_IMPUP] int NULL
     , [Units_UPH] int NULL
     , [Units_RTA] int NULL
     , [Units_Gross] int NULL
     , [Yard_DirMovesFrom] int NULL
     , [Yard_DirMovesTo] int NULL
     , [Yard_UndirMoves] int NULL
     , [Yard_TotalMoves] int NULL
     , [GrossAmount_WithFreight] Decimal(16,4) NULL
	 , [GrossAmount_NoFreight] Decimal(16,4) NULL
     , [FinProll_HeadCount] int NULL
     , [FinProll_Hours_Regular] Decimal(16,8) NULL
     , [FinProll_Hours_OT] Decimal(16,8) NULL
     , [FinProll_Hours_Total] Decimal(16,8) NULL
	 ,[FinProll_Hours_Other] Decimal(16,8) NULL
     , [FinProll_Pay_Regular] Decimal(16,8) NULL
     , [FinProll_Pay_OT] Decimal(16,8) NULL
     , [FinProll_LaborDollars_Total] Decimal(16,8) NULL
     , [FinProll_Direct_Percentage] Decimal(16,8) NULL
     , [Avg_Reg_Rate_Prev] float NULL
     , [Avg_OT_Rate_Prev] float NULL
     , [PreProll_HeadCount] int NULL
     , [PreProll_Reg_Hours] float NULL
     , [PreProll_OT_Hours] float NULL
     , [PreProll_Hours_Total] float NULL
	 ,[PreProll_Other_Hours] float NULL
     , [PreProll_Pay_Regular] float NULL
     , [PreProll_Pay_OT] float NULL
     , [PreProll_LaborDollarsTotal] float NULL
     , [PreProll_Direct_Percentage] float NULL
     , [FiscalWeekIndicator] int NULL
     , [FiscalMonthIndicator] int NULL
     , [FiscalYearIndicator] int NULL
     , [FiscalYear] int NULL
     , [FiscalMonthYearName] varchar(30) NULL
     , [NonYard_SalesPerLaborHour] float NULL
     , [NonYard_SalesPerUnit] float NULL
     , [NonYard_PPH] float NULL
     , [NonYard_PPH_NoOtherHrs] float NULL
     , [NonYard_CostPerPiece] float NULL
     , [NonYard_SalesPerEmployee] float NULL
     , [NonYard_Pieces/HC_Ratio] float NULL
     , [Yard_MPH] float NULL
     , [Yard_MPH_NoOtherHrs] float NULL
     , [Yard_CostPerMove] float NULL
     , [Yard_Moves/HC_Ratio]  float NULL
     , [Yard_SalesPerMove] float NULL
     , [Yard_UnitsSoldPerMove] float NULL
	      , [Flag_MostRecent_WeekEnding] varchar(50) NULL
	 , [RunChartCalcs_Units_Gross] int NULL
	 , [RunChartCalcs_CostPerPiece] float NULL
	 , [RunChartCalcs_PPH] float NULL
	 , [RunChartCalcs_OTLaborDollars] float NULL
     , [RunChartCalcs_TotalLaborDollars] float NULL
     , [RunChartCalcs_PiecesPerHC_Ratio] float NULL
	 , [RunChartCalcs_TotalYardMoves] float NULL
	 , [Hours_Moved_Out] float NULL
	 , [Hours_Moved_In] float NULL
	 , [Hours_TempLumper_In] float NULL
)


