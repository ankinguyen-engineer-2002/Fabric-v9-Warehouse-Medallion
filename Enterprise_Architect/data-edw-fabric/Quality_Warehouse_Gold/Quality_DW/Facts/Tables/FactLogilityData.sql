
CREATE TABLE [Quality_DW].[FactLogilityData]
(
	[ItemLvl1] [varchar](15) NULL,
	[Location] [char](3) NULL,
	[Field21] [varchar](40) NULL,
	[CollectiveClass] [varchar](40) NULL,
	[PermanentComponent] [decimal](11, 2) NULL,
	[ForeCastType] [char](1) NULL,
	[DerivedFcstFtr] [decimal](5, 3) NULL,
	[ValDemand] [decimal](3, 0) NULL,
	[PlanningVendor] [char](8) NULL,
	[DRPPlanner] [varchar](40) NULL,
	[Source] [varchar](40) NULL,
	[OnHandQty] [decimal](9, 0) NULL,
	[IpAbcCode] [char](1) NULL,
	[ABCALT3] [char](1) NULL,
	[ALTERNABC] [char](1) NULL,
	[MKBuyCODE] [char](1) NULL,
	[ForecastLevel] [varchar](100) NULL,
	[ResultFc0] [decimal](9, 0) NULL,
	[ResultFc1] [decimal](9, 0) NULL,
	[ResultFc2] [decimal](9, 0) NULL,
	[ResultFc3] [decimal](9, 0) NULL,
	[ResultFc4] [decimal](9, 0) NULL,
	[ResultFc5] [decimal](9, 0) NULL,
	[ResultFc6] [decimal](9, 0) NULL,
	[ResultFc7] [decimal](9, 0) NULL,
	[ResultFc8] [decimal](9, 0) NULL,
	[ResultFc9] [decimal](9, 0) NULL,
	[ResultFc10] [decimal](9, 0) NULL,
	[ResultFc11] [decimal](9, 0) NULL,
	[ResultPROL0] [decimal](9, 0) NULL,
	[ResultPROL1] [decimal](9, 0) NULL,
	[ResultPROL2] [decimal](9, 0) NULL,
	[ResultPROL3] [decimal](9, 0) NULL,
	[ResultPROL4] [decimal](9, 0) NULL,
	[ResultPROL5] [decimal](9, 0) NULL,
	[ResultPROL6] [decimal](9, 0) NULL,
	[ResultPROL7] [decimal](9, 0) NULL,
	[ResultPROL8] [decimal](9, 0) NULL,
	[ResultPROL9] [decimal](9, 0) NULL,
	[ResultPROL10] [decimal](9, 0) NULL,
	[ResultPROL11] [decimal](9, 0) NULL,
	[ResultFFSF0] [decimal](9, 0) NULL,
	[ResultFFSF1] [decimal](9, 0) NULL,
	[ResultFFSF2] [decimal](9, 0) NULL,
	[ResultFFSF3] [decimal](9, 0) NULL,
	[ResultFFSF4] [decimal](9, 0) NULL,
	[ResultFFSF5] [decimal](9, 0) NULL,
	[ResultFFSF6] [decimal](9, 0) NULL,
	[ResultFFSF7] [decimal](9, 0) NULL,
	[ResultFFSF8] [decimal](9, 0) NULL,
	[ResultFFSF9] [decimal](9, 0) NULL,
	[ResultFFSF10] [decimal](9, 0) NULL,
	[ResultFFSF11] [decimal](9, 0) NULL,
	[ACTDEMD1] [decimal](9, 0) NULL,
	[ACTDEMD0] [decimal](9, 0) NULL,
	[ACTDEMD2] [decimal](9, 0) NULL,
	[ACTDEMD3] [decimal](9, 0) NULL,
	[ACTDEMD4] [decimal](9, 0) NULL,
	[ACTDEMD5] [decimal](9, 0) NULL,
	[ACTDEMD6] [decimal](9, 0) NULL,
	[ACTDEMD7] [decimal](9, 0) NULL,
	[ACTDEMD8] [decimal](9, 0) NULL,
	[ACTDEMD9] [decimal](9, 0) NULL,
	[ACTDEMD10] [decimal](9, 0) NULL,
	[ACTDEMD11] [decimal](9, 0) NULL,
	[FileDate] [datetime2](6) NULL,
	[ForecastPlanner] [varchar](11) NULL,
	[UnitCST] [decimal](11, 5) NULL,
	[UnitPrice] [decimal](11, 5) NULL,
	[CubicFeet] [decimal](9, 4) NULL,
	[DerivedFCSTkey] [varchar](60) NULL,
	[TrendComponent] [decimal](11, 2) NULL,
	[ProductGroup] [varchar](10) NULL,
	[Field1] [char](2) NULL,
	[Field8] [char](5) NULL,
	[Field9] [varchar](25) NULL,
	[Field10] [char](2) NULL,
	[SuperGroup] [varchar](40) NULL,
	[Field17] [varchar](38) NULL,
	[Field35] [char](2) NULL,
	[ForcedSysSTDDev] [varchar](10) NULL,
	[Field19] [char](1) NULL,
	[ItemID] [varchar](18) NULL,
	[Whse] [char](8) NULL,
	[Country] [char](2) NULL,
	[Company] [char](3) NULL,
	[MgmtValidDemand] [decimal](3, 0) NULL,
	[Filename] [varchar](100) NULL,
	[AvgWeeklyFcst] decimal(13,0) Null
)

Go


CREATE STATISTICS [Stat_FactLogilityData_Whse]
    ON Quality_DW.FactLogilityData([Whse])  
GO

CREATE STATISTICS [Stat_FactLogilityData_UnitPrice]
    ON Quality_DW.FactLogilityData([UnitPrice]) 
GO

CREATE STATISTICS [Stat_FactLogilityData_UNIT_CST]
    ON Quality_DW.FactLogilityData([UnitCST])  
GO

CREATE STATISTICS [Stat_FactLogilityData_SuperGroup]
    ON Quality_DW.FactLogilityData([SuperGroup])  
GO

CREATE STATISTICS [Stat_FactLogilityData_Source]
    ON Quality_DW.FactLogilityData([Source]) 
GO

CREATE STATISTICS [Stat_FactLogilityData_ResultPROL9]
    ON Quality_DW.FactLogilityData([ResultPROL9]) 
GO

CREATE STATISTICS [Stat_FactLogilityData_ResultPROL8]
    ON Quality_DW.FactLogilityData([ResultPROL8]) 
GO

CREATE STATISTICS [Stat_FactLogilityData_ResultPROL7]
    ON Quality_DW.FactLogilityData([ResultPROL7])  
GO

CREATE STATISTICS [Stat_FactLogilityData_ResultPROL6]
    ON Quality_DW.FactLogilityData([ResultPROL6]) 
GO

CREATE STATISTICS [Stat_FactLogilityData_ResultPROL5]
    ON Quality_DW.FactLogilityData([ResultPROL5]) 
GO

CREATE STATISTICS [Stat_FactLogilityData_ResultPROL4]
    ON Quality_DW.FactLogilityData([ResultPROL4])  
GO

CREATE STATISTICS [Stat_FactLogilityData_ResultPROL3]
    ON Quality_DW.FactLogilityData([ResultPROL3])  
GO

CREATE STATISTICS [Stat_FactLogilityData_ResultPROL2]
    ON Quality_DW.FactLogilityData([ResultPROL2]) 
GO

CREATE STATISTICS [Stat_FactLogilityData_ResultPROL11]
    ON Quality_DW.FactLogilityData([ResultPROL11]) 
GO


CREATE STATISTICS [Stat_FactLogilityData_ResultPROL10]
    ON Quality_DW.FactLogilityData([ResultPROL10])  
GO

CREATE STATISTICS [Stat_FactLogilityData_ResultPROL1]
    ON Quality_DW.FactLogilityData([ResultPROL1])  
GO



CREATE STATISTICS [Stat_FactLogilityData_Result_PROL_0]
    ON Quality_DW.FactLogilityData([ResultPROL0])  
GO





CREATE STATISTICS [Stat_FactLogilityData_ResultFc9]
    ON Quality_DW.FactLogilityData([ResultFc9])  
GO



CREATE STATISTICS [Stat_FactLogilityData_ResultFc8]
    ON Quality_DW.FactLogilityData([ResultFc8])  
GO



CREATE STATISTICS [Stat_FactLogilityData_ResultFc7]
    ON Quality_DW.FactLogilityData([ResultFc7]) 
GO



CREATE STATISTICS [Stat_FactLogilityData_ResultFc6]
    ON Quality_DW.FactLogilityData([ResultFc6])  
GO



CREATE STATISTICS [Stat_FactLogilityData_ResultFc5]
    ON Quality_DW.FactLogilityData([ResultFc5])  
GO



CREATE STATISTICS [Stat_FactLogilityData_ResultFc4]
    ON Quality_DW.FactLogilityData([ResultFc4])  
GO



CREATE STATISTICS [Stat_FactLogilityData_ResultFc3]
    ON Quality_DW.FactLogilityData([ResultFc3]) 
GO



CREATE STATISTICS [Stat_FactLogilityData_ResultFc2]
    ON Quality_DW.FactLogilityData([ResultFc2])  
GO



CREATE STATISTICS [Stat_FactLogilityData_ResultFc11]
    ON Quality_DW.FactLogilityData([ResultFc11]) 
GO



CREATE STATISTICS [Stat_FactLogilityData_ResultFc10]
    ON Quality_DW.FactLogilityData([ResultFc10])  
GO



CREATE STATISTICS [Stat_FactLogilityData_ResultFc1]
    ON Quality_DW.FactLogilityData([ResultFc1])  
GO



CREATE STATISTICS [Stat_FactLogilityData_ResultFc0]
    ON Quality_DW.FactLogilityData([ResultFc0])  
GO



CREATE STATISTICS [Stat_FactLogilityData_ProductGroup]
    ON Quality_DW.FactLogilityData([ProductGroup])  
GO



CREATE STATISTICS [Stat_FactLogilityData_PlanningVendor]
    ON Quality_DW.FactLogilityData([PlanningVendor])  
GO



CREATE STATISTICS [Stat_FactLogilityData_PermanentComponent]
    ON Quality_DW.FactLogilityData([PermanentComponent])  
GO




CREATE STATISTICS [Stat_FactLogilityData_MgmtValidDemand]
    ON Quality_DW.FactLogilityData([MgmtValidDemand])  
GO



CREATE STATISTICS [Stat_FactLogilityData_Location]
    ON Quality_DW.FactLogilityData([Location])  
GO



CREATE STATISTICS [Stat_FactLogilityData_ItemLvl1]
    ON Quality_DW.FactLogilityData([ItemLvl1])  
GO



CREATE STATISTICS [Stat_FactLogilityData_ItemID]
    ON Quality_DW.FactLogilityData([ItemID])  
	
GO



CREATE STATISTICS [Stat_FactLogilityData_IpAbcCode]
    ON Quality_DW.FactLogilityData([IpAbcCode]) 
GO



CREATE STATISTICS [Stat_FactLogilityData_ForeCastType]
    ON Quality_DW.FactLogilityData([ForeCastType])  
GO



CREATE STATISTICS [Stat_FactLogilityData_ForecastPlanner]
    ON Quality_DW.FactLogilityData([ForecastPlanner])  
GO



CREATE STATISTICS [Stat_FactLogilityData_ForecastLevel]
    ON Quality_DW.FactLogilityData([ForecastLevel])  
GO



CREATE STATISTICS [Stat_FactLogilityData_ForcedSysSTDDev]
    ON Quality_DW.FactLogilityData([ForcedSysSTDDev])  
GO



CREATE STATISTICS [Stat_FactLogilityData_Filename]
    ON Quality_DW.FactLogilityData([Filename])  
GO



CREATE STATISTICS [Stat_FactLogilityData_FileDate]
    ON Quality_DW.FactLogilityData([FileDate]) 
GO



CREATE STATISTICS [Stat_FactLogilityData_Field9]
    ON Quality_DW.FactLogilityData([Field9])  
GO



CREATE STATISTICS [Stat_FactLogilityData_Field8]
    ON Quality_DW.FactLogilityData([Field8])  
GO



CREATE STATISTICS [Stat_FactLogilityData_Field10]
    ON Quality_DW.FactLogilityData([Field10])  
GO



CREATE STATISTICS [Stat_FactLogilityData_Field1]
    ON Quality_DW.FactLogilityData([Field1])  
GO



CREATE STATISTICS [Stat_FactLogilityData_Field21]
    ON Quality_DW.FactLogilityData([Field21])  
GO



CREATE STATISTICS [Stat_FactLogilityData_Field19]
    ON Quality_DW.FactLogilityData([Field19]) 
GO



CREATE STATISTICS [Stat_FactLogilityData_Field17]
    ON Quality_DW.FactLogilityData([Field17]) 
GO



CREATE STATISTICS [Stat_FactLogilityData_DRPPlanner]
    ON Quality_DW.FactLogilityData([DRPPlanner])  
GO



CREATE STATISTICS [Stat_FactLogilityData_CubicFeet]
    ON Quality_DW.FactLogilityData([CubicFeet])  
GO



CREATE STATISTICS [Stat_FactLogilityData_Country]
    ON Quality_DW.FactLogilityData([Country])  
GO



CREATE STATISTICS [Stat_FactLogilityData_Company]
    ON Quality_DW.FactLogilityData([Company])  
GO



CREATE STATISTICS [Stat_FactLogilityData_CollectiveClass]
    ON Quality_DW.FactLogilityData([CollectiveClass])  
GO



CREATE STATISTICS [Stat_FactLogilityData_ACTDEMD0]
    ON Quality_DW.FactLogilityData([ACTDEMD0])  
GO



CREATE STATISTICS [Stat_FactLogilityData_ABCALT3]
    ON Quality_DW.FactLogilityData([ABCALT3])  
GO



CREATE STATISTICS [Stat_FactLogilityData_ValDemand]
    ON Quality_DW.FactLogilityData([ValDemand]) 
GO


	


CREATE STATISTICS [Stat_FactLogilityData_TrendComponent]
    ON Quality_DW.FactLogilityData([TrendComponent])  
GO



CREATE STATISTICS [Stat_FactLogilityData_OnHandQty]
    ON Quality_DW.FactLogilityData([OnHandQty])  
GO

	



CREATE STATISTICS [Stat_FactLogilityData_Field35]
    ON Quality_DW.FactLogilityData([Field35]) 
GO



CREATE STATISTICS [Stat_FactLogilityData_DerivedFCSTkey]
    ON Quality_DW.FactLogilityData([DerivedFCSTkey])  
GO



CREATE STATISTICS [Stat_FactLogilityData_DerivedFcstFtr]
    ON Quality_DW.FactLogilityData([DerivedFcstFtr])  
GO



CREATE STATISTICS [Stat_FactLogilityData_ALTERNABC]
    ON Quality_DW.FactLogilityData([ALTERNABC])  
GO