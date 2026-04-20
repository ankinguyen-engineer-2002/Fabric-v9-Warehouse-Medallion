CREATE TABLE [AFISales_Enh].[WarRoomData] (
    [ID]            INT            NULL,
    [Results]       VARCHAR (60)   NOT NULL,
    [TemplateID]    VARCHAR (15)   NOT NULL,
    [Series]        VARCHAR (16)   NOT NULL,
    [SeriesName]    VARCHAR (100)  NOT NULL,
    [SerDisco]      BIT            NOT NULL,
    [Showroom]      VARCHAR (25)   NOT NULL,
    [Source]        VARCHAR (50)   NOT NULL,
    [Group]         VARCHAR (26)   NOT NULL,
    [IntroDate]     DATE           NULL,
    [ParStyle]      VARCHAR (65)   NOT NULL,
    [ChildStyle]    VARCHAR (65)   NOT NULL,
    [KeyItem]       VARCHAR (15)   NOT NULL,
    [ItmDisco]      BIT            NOT NULL,
    [Descr]         VARCHAR (200)  NOT NULL,
    [Image]         VARCHAR (60)   NOT NULL,
    [FOBOrig]       INT            NOT NULL,
    [MinMU]         INT            NOT NULL,
    [FOBDisc]       BIT            NOT NULL,
    [RetPrPt]       INT            NOT NULL,
    [RetMU]         INT            NOT NULL,
    [MnthAveHis3]   NUMERIC (10)   NOT NULL,
    [MnthAveOrd3]   NUMERIC (10)   NOT NULL,
    [MnthAveHis]    NUMERIC (10)   NOT NULL,
    [MnthAvePro]    NUMERIC (10)   NOT NULL,
    [DirArrow]      VARCHAR (50)   NOT NULL,
    [MnthAveHisDol] NUMERIC (10)   NOT NULL,
    [MnthAveProDol] NUMERIC (10)   NOT NULL,
    [HardPlcmt]     INT            NOT NULL,
    [RkdMUfob]      INT            NOT NULL,
    [RkdMUact]      INT            NOT NULL,
    [PrfCntHis]     NUMERIC (10)   NOT NULL,
    [PrfCntPro]     NUMERIC (10)   NOT NULL,
    [PrfCntHisStd]  NUMERIC (10)   NOT NULL,
    [PrfCntProStd]  NUMERIC (10)   NOT NULL,
    [PrfCntHisAct]  NUMERIC (10)   NOT NULL,
    [PrfCntProAct]  NUMERIC (10)   NOT NULL,
    [ABC]           CHAR (2)       NOT NULL,
    [GMROI]         NUMERIC (6, 1) NOT NULL,
    [Key]           BIT            NOT NULL,
    [SetNumber]     VARCHAR (15)   NOT NULL,
    [Rental]        BIT            NOT NULL,
    [RkdMUCur]      INT            NOT NULL,
    [MoSeriesAmt]   NUMERIC (10)   NOT NULL,
    [FutStatus]     CHAR (1)       NOT NULL
)

GO
CREATE STATISTICS [Stat_WarRoomData_TemplateID]
    ON [AFISales_Enh].[WarRoomData]([TemplateID]);


GO
CREATE STATISTICS [Stat_WarRoomData_SetNumber]
    ON [AFISales_Enh].[WarRoomData]([SetNumber]);


GO
CREATE STATISTICS [Stat_WarRoomData_Series]
    ON [AFISales_Enh].[WarRoomData]([Series]);


GO
CREATE STATISTICS [Stat_WarRoomData_ParStyle]
    ON [AFISales_Enh].[WarRoomData]([ParStyle]);


GO
CREATE STATISTICS [Stat_WarRoomData_MinMU]
    ON [AFISales_Enh].[WarRoomData]([MinMU]);


GO
CREATE STATISTICS [Stat_WarRoomData_KeyItem]
    ON [AFISales_Enh].[WarRoomData]([KeyItem]);


GO
CREATE STATISTICS [Stat_WarRoomData_Key]
    ON [AFISales_Enh].[WarRoomData]([Key]);


GO
CREATE STATISTICS [Stat_WarRoomData_ItmDisco]
    ON [AFISales_Enh].[WarRoomData]([ItmDisco]);


GO
CREATE STATISTICS [Stat_WarRoomData_IntroDate]
    ON [AFISales_Enh].[WarRoomData]([IntroDate]);


GO
CREATE STATISTICS [Stat_WarRoomData_ID]
    ON [AFISales_Enh].[WarRoomData]([ID]);


GO
CREATE STATISTICS [Stat_WarRoomData_Group]
    ON [AFISales_Enh].[WarRoomData]([Group]);


GO
CREATE STATISTICS [Stat_WarRoomData_GMROI]
    ON [AFISales_Enh].[WarRoomData]([GMROI]);


GO
CREATE STATISTICS [Stat_WarRoomData_FutStatus]
    ON [AFISales_Enh].[WarRoomData]([FutStatus]);


GO
CREATE STATISTICS [Stat_WarRoomData_FOBDisc]
    ON [AFISales_Enh].[WarRoomData]([FOBDisc]);


GO
CREATE STATISTICS [Stat_WarRoomData_ChildStyle]
    ON [AFISales_Enh].[WarRoomData]([ChildStyle]);


GO
CREATE STATISTICS [Stat_WarRoomData_ABC]
    ON [AFISales_Enh].[WarRoomData]([ABC]);


