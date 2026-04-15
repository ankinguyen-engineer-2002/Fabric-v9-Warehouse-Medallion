CREATE TABLE [SupplyChain_Enh].[ForecastCommonContainer_Logility] (
    [Item-Lvl1]          VARCHAR (15)    NULL,
    [Location]           VARCHAR (3)     NULL,
    [Field-21]           VARCHAR (40)    NULL,
    [Collective Class]   VARCHAR (40)    NULL,
    [PermanentComponent] DECIMAL (11, 2) NULL,
    [ForeCastType]       VARCHAR (1)     NULL,
    [Derived_FCST_FTR]   DECIMAL (5, 3)  NULL,
    [ValDemand]          DECIMAL (3)     NULL,
    [Planning Vendor]    CHAR     (8)    NULL,
    [DRPPlanner]         VARCHAR (40)    NULL,
    [Source]             VARCHAR (40)    NULL,
    [On_hand_Qty]        DECIMAL (9)     NULL,
    [IP_ABC_Code]        VARCHAR (1)     NULL,
    [ABCALT3]            VARCHAR (1)     NULL,
    [ALTERN_ABC]         VARCHAR (1)     NULL,
    [MK_BuyCODE]         VARCHAR (1)     NULL,
    [ForecastLevel]      VARCHAR (100)   NULL,
    [Result_Fc_0]        DECIMAL (9)     NULL,
    [Result_Fc_1]        DECIMAL (9)     NULL,
    [Result_Fc_2]        DECIMAL (9)     NULL,
    [Result_Fc_3]        DECIMAL (9)     NULL,
    [Result_Fc_4]        DECIMAL (9)     NULL,
    [Result_Fc_5]        DECIMAL (9)     NULL,
    [Result_Fc_6]        DECIMAL (9)     NULL,
    [Result_Fc_7]        DECIMAL (9)     NULL,
    [Result_Fc_8]        DECIMAL (9)     NULL,
    [Result_Fc_9]        DECIMAL (9)     NULL,
    [Result_Fc_10]       DECIMAL (9)     NULL,
    [Result_Fc_11]       DECIMAL (9)     NULL,
    [Result_PROL_0]      DECIMAL (9)     NULL,
    [Result_PROL_1]      DECIMAL (9)     NULL,
    [Result_PROL_2]      DECIMAL (9)     NULL,
    [Result_PROL_3]      DECIMAL (9)     NULL,
    [Result_PROL_4]      DECIMAL (9)     NULL,
    [Result_PROL_5]      DECIMAL (9)     NULL,
    [Result_PROL_6]      DECIMAL (9)     NULL,
    [Result_PROL_7]      DECIMAL (9)     NULL,
    [Result_PROL_8]      DECIMAL (9)     NULL,
    [Result_PROL_9]      DECIMAL (9)     NULL,
    [Result_PROL_10]     DECIMAL (9)     NULL,
    [Result_PROL_11]     DECIMAL (9)     NULL,
    [Result_FFSF_0]      DECIMAL (9)     NULL,
    [Result_FFSF_1]      DECIMAL (9)     NULL,
    [Result_FFSF_2]      DECIMAL (9)     NULL,
    [Result_FFSF_3]      DECIMAL (9)     NULL,
    [Result_FFSF_4]      DECIMAL (9)     NULL,
    [Result_FFSF_5]      DECIMAL (9)     NULL,
    [Result_FFSF_6]      DECIMAL (9)     NULL,
    [Result_FFSF_7]      DECIMAL (9)     NULL,
    [Result_FFSF_8]      DECIMAL (9)     NULL,
    [Result_FFSF_9]      DECIMAL (9)     NULL,
    [Result_FFSF_10]     DECIMAL (9)     NULL,
    [Result_FFSF_11]     DECIMAL (9)     NULL,
    [ACT_DEMD_0]         DECIMAL (9)     NULL,
    [ACT_DEMD_1]         DECIMAL (9)     NULL,
    [ACT_DEMD_2]         DECIMAL (9)     NULL,
    [ACT_DEMD_3]         DECIMAL (9)     NULL,
    [ACT_DEMD_4]         DECIMAL (9)     NULL,
    [ACT_DEMD_5]         DECIMAL (9)     NULL,
    [ACT_DEMD_6]         DECIMAL (9)     NULL,
    [ACT_DEMD_7]         DECIMAL (9)     NULL,
    [ACT_DEMD_8]         DECIMAL (9)     NULL,
    [ACT_DEMD_9]         DECIMAL (9)     NULL,
    [ACT_DEMD_10]        DECIMAL (9)     NULL,
    [ACT_DEMD_11]        DECIMAL (9)     NULL,
    [FileDate]           DATETIME2 (7)   NULL,
    [ForecastPlanner]    VARCHAR (11)    NULL,
    [UNIT CST]           DECIMAL (11, 5) NULL,
    [UnitPrice]          DECIMAL (11, 5) NULL,
    [CubicFeet]          DECIMAL (9, 4)  NULL,
    [Derived_FCST_key]   VARCHAR (60)    NULL,
    [TrendComponent]     DECIMAL (11, 2) NULL,
    [ProductGroup]       VARCHAR (10)    NULL,
    [Field1]             VARCHAR (2)     NULL,
    [Field8]             VARCHAR (5)     NULL,
    [Field9]             VARCHAR (25)    NULL,
    [Field10]            VARCHAR (2)     NULL,
    [SuperGroup]         VARCHAR (40)    NULL,
    [Field-17]           VARCHAR (38)    NULL,
    [Field-35]           VARCHAR (2)     NULL,
    [ForcedSys_STD_Dev]  VARCHAR (10)    NULL,
    [Field-19]           VARCHAR (1)     NULL,
    [Item_ID]            VARCHAR (18)    NULL,
    [Whse]               VARCHAR (8)     NULL,
    [Country]            VARCHAR (2)    NULL,
    [Company]            VARCHAR (3)    NULL,
    [MgmtValidDemand]    DECIMAL (3)     NULL,
    [Filename]           VARCHAR (100)   NULL,
    [OFQ_0]              INT             NULL,
    [OFQ_1]              INT             NULL,
    [OFQ_2]              INT             NULL,
    [OFQ_3]              INT             NULL,
    [OFQ_4]              INT             NULL,
    [OFQ_5]              INT             NULL,
    [OFQ_6]              INT             NULL,
    [OFQ_7]              INT             NULL,
    [OFQ_8]              INT             NULL,
    [OFQ_9]              INT             NULL,
    [OFQ_10]             INT             NULL,
    [OFQ_11]             INT             NULL,
    [Usr25Text]          VARCHAR (40)    NULL,
    [Usr32Text]          VARCHAR (40)    NULL,
    [MgmtCode]           CHAR (1)        NULL,
    [ParameterKey]       VARCHAR (36)    NULL,
    [ADJ_DEMD_0]         DECIMAL (9)     NULL,
    [ADJ_DEMD_1]         DECIMAL (9)     NULL,
    [ADJ_DEMD_2]         DECIMAL (9)     NULL,
    [ADJ_DEMD_3]         DECIMAL (9)     NULL,
    [ADJ_DEMD_4]         DECIMAL (9)     NULL,
    [ADJ_DEMD_5]         DECIMAL (9)     NULL,
    [ADJ_DEMD_6]         DECIMAL (9)     NULL,
    [ADJ_DEMD_7]         DECIMAL (9)     NULL,
    [ADJ_DEMD_8]         DECIMAL (9)     NULL,
    [ADJ_DEMD_9]         DECIMAL (9)     NULL,
    [ADJ_DEMD_10]        DECIMAL (9)     NULL,
    [ADJ_DEMD_11]        DECIMAL (9)     NULL,
    [DfcCustomergroups] varchar(100) NULL
);






GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCIX_ForecastCommonContainer_Logility]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility];


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Whse]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Whse]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_UnitPrice]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([UnitPrice]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_UNIT_CST]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([UNIT CST]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_SuperGroup]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([SuperGroup]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Source]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Source]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_PROL_9]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_PROL_9]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_PROL_8]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_PROL_8]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_PROL_7]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_PROL_7]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_PROL_6]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_PROL_6]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_PROL_5]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_PROL_5]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_PROL_4]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_PROL_4]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_PROL_3]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_PROL_3]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_PROL_2]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_PROL_2]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_PROL_11]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_PROL_11]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_PROL_10]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_PROL_10]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_PROL_1]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_PROL_1]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_PROL_0]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_PROL_0]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_FFSF_4]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_FFSF_4]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_FFSF_3]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_FFSF_3]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_FFSF_2]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_FFSF_2]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_FFSF_1]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_FFSF_1]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_FFSF_0]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_FFSF_0]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_Fc_9]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_Fc_9]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_Fc_8]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_Fc_8]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_Fc_7]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_Fc_7]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_Fc_6]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_Fc_6]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_Fc_5]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_Fc_5]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_Fc_4]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_Fc_4]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_Fc_3]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_Fc_3]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_Fc_2]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_Fc_2]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_Fc_11]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_Fc_11]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_Fc_10]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_Fc_10]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_Fc_1]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_Fc_1]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_Fc_0]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_Fc_0]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ProductGroup]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ProductGroup]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Planning_Vendor]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Planning Vendor]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_PermanentComponent]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([PermanentComponent]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ParameterKey]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ParameterKey]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_OFQ_4]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([OFQ_4]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_OFQ_3]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([OFQ_3]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_OFQ_2]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([OFQ_2]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_OFQ_1]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([OFQ_1]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_OFQ_0]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([OFQ_0]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_MK_BuyCODE]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([MK_BuyCODE]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_MgmtValidDemand]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([MgmtValidDemand]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Location]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Location]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ItemLvl1]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Item-Lvl1]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Item_ID]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Item_ID]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_IP_ABC_Code]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([IP_ABC_Code]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ForeCastType]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ForeCastType]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ForecastPlanner]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ForecastPlanner]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ForecastLevel]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ForecastLevel]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ForcedSys_STD_Dev]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ForcedSys_STD_Dev]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Filename]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Filename]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_FileDate]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([FileDate]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Field9]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Field9]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Field8]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Field8]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Field10]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Field10]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Field1]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Field1]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Field_21]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Field-21]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Field_19]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Field-19]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Field_17]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Field-17]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_DRPPlanner]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([DRPPlanner]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_CubicFeet]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([CubicFeet]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Country]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Country]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Company]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Company]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Collective_Class]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Collective Class]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ACT_DEMD_0]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ACT_DEMD_0]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ABCALT3]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ABCALT3]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ValDemand]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ValDemand]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Usr32Text]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Usr32Text]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Usr25Text]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Usr25Text]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_TrendComponent]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([TrendComponent]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_FFSF_9]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_FFSF_9]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_FFSF_8]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_FFSF_8]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_FFSF_7]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_FFSF_7]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_FFSF_6]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_FFSF_6]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_FFSF_5]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_FFSF_5]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_FFSF_11]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_FFSF_11]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Result_FFSF_10]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Result_FFSF_10]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_On_hand_Qty]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([On_hand_Qty]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_OFQ_9]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([OFQ_9]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_OFQ_8]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([OFQ_8]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_OFQ_7]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([OFQ_7]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_OFQ_6]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([OFQ_6]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_OFQ_5]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([OFQ_5]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_OFQ_11]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([OFQ_11]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_OFQ_10]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([OFQ_10]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_MgmtCode]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([MgmtCode]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Field_35]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Field-35]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Derived_FCST_key]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Derived_FCST_key]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_Derived_FCST_FTR]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([Derived_FCST_FTR]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ALTERN_ABC]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ALTERN_ABC]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ADJ_DEMD_9]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ADJ_DEMD_9]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ADJ_DEMD_8]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ADJ_DEMD_8]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ADJ_DEMD_7]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ADJ_DEMD_7]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ADJ_DEMD_6]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ADJ_DEMD_6]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ADJ_DEMD_5]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ADJ_DEMD_5]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ADJ_DEMD_4]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ADJ_DEMD_4]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ADJ_DEMD_3]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ADJ_DEMD_3]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ADJ_DEMD_2]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ADJ_DEMD_2]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ADJ_DEMD_11]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ADJ_DEMD_11]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ADJ_DEMD_10]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ADJ_DEMD_10]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ADJ_DEMD_1]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ADJ_DEMD_1]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ADJ_DEMD_0]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ADJ_DEMD_0]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ACT_DEMD_9]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ACT_DEMD_9]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ACT_DEMD_8]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ACT_DEMD_8]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ACT_DEMD_7]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ACT_DEMD_7]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ACT_DEMD_6]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ACT_DEMD_6]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ACT_DEMD_5]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ACT_DEMD_5]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ACT_DEMD_4]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ACT_DEMD_4]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ACT_DEMD_3]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ACT_DEMD_3]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ACT_DEMD_2]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ACT_DEMD_2]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ACT_DEMD_11]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ACT_DEMD_11]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ACT_DEMD_10]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ACT_DEMD_10]);


GO
CREATE STATISTICS [Stat_ForecastCommonContainer_Logility_ACT_DEMD_1]
    ON [SupplyChain_Enh].[ForecastCommonContainer_Logility]([ACT_DEMD_1]);

