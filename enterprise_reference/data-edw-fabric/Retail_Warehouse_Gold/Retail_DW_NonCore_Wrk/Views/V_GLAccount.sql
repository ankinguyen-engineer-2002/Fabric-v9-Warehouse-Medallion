-- Auto Generated (Do not modify) 3C6414E2F3E13DE21CE9378F79B70DD65BB4916ED2BECE9FB91F214582221AC5
CREATE VIEW [Retail_DW_NonCore_Wrk].[V_GLAccount] AS
SELECT [Operation]
,DateChanged
,DateCreated
,Description
,GLAccountID
,GLAccountTypeID
,GLClassID
,GLCostCenterID
,GLGroupID
,GLSubAccountID
,GLSubClassID
,IsInactive
,LastBatchID
,Parent_GLAccountID
,RecStatus
,Root_GLAccountID
,SourceID
 FROM [$(Source_Data)].[Retail_Corporate].[GLAccount]