CREATE TABLE [Marketing].[AdNotice]
    (
        [Key]                INT          NULL,
        [CustomerNumber]     CHAR(8)      NULL,
        [ShipNumber]         CHAR(4)      NULL,
        [UserLogin]          VARCHAR(35)  NULL,
        [StartDate]          DATE         NULL, --- DATETIME2(6)
        [EndDate]            DATE         NULL, --- DATETIME2(6)
        [Description]        VARCHAR(100) NULL,
        [Comments]           VARCHAR(500) NULL,
        [EmailTime]          DATETIME2(6) NULL, --- DATETIME2(6)
        [AddedByUser]               VARCHAR(30)  NULL,
        [DateAdded]               DATETIME2(6) NULL, --- DATETIME2(6)
        [ChangeByUser]               VARCHAR(30)  NULL,
        [DateChange]               DATETIME2(6) NULL, --- DATETIME2(6)
        [SpecialDescription] VARCHAR(25)  NULL,
        [Status]             CHAR(1)      NULL,
        [NoticeType]         CHAR(1)      NULL,
        [RequestDate]        DATE         NULL, --- DATETIME2(6)
        [SubmitDate]         DATETIME2(6) NULL, --- DATETIME2(6)
        [ApprovalDate]       DATETIME2(6) NULL, --- DATETIME2(6)
        [UserEdited]         VARCHAR(30)  NULL,
        [ResponseDate]       DATETIME2(6) NULL, --- DATETIME2(6)
        [AllShiptos]         BIT          NULL,
        [OrderFulfilled]     BIT          NULL
    );


