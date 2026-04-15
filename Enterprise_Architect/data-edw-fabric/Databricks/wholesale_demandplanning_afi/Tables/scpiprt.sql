CREATE TABLE [wholesale_demandplanning_afi].[scpiprt] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[Scp_Seq_Nbr] decimal(38,18) NULL, 
	[Mk_Buy_Code] varchar(8000) NULL, 
	[Ord_Mult_Qty] decimal(38,18) NULL, 
	[Drp_Plnr_Id] varchar(8000) NULL, 
	[Routing_Code] varchar(8000) NULL, 
	[Ctl_Subst_Text] varchar(8000) NULL, 
	[Scp_Sel_Set_Id] varchar(8000) NULL, 
	[Plan_Time_Fnc_Days] decimal(38,18) NULL, 
	[Ss_Qty] decimal(38,18) NULL, 
	[Ss_Max_Qty] decimal(38,18) NULL, 
	[Ss_MnMx_Type] varchar(8000) NULL, 
	[Ss_MnMx_Inhbt_Code] varchar(8000) NULL, 
	[Ss_Meth] varchar(8000) NULL, 
	[Oh_Qty] decimal(38,18) NULL, 
	[Src1_Id] varchar(8000) NULL, 
	[Src2_Id] varchar(8000) NULL, 
	[Min_Ord_Qty] decimal(38,18) NULL, 
	[vendor_id] varchar(8000) NULL
);

