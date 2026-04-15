CREATE TABLE [Email_Marketing].[TotalPromotionalCampaign]
(
        [Delivered Start Date] [DATETIME2](6) NULL,
        [MessageName]          [VARCHAR](250) NULL,
        [SpamComplaint]        [INT]          NULL,
        [ISPLinkUnsubscribe]   [INT]          NULL,
        [Delivered]            [INT]          NULL,
        [Undelivered]          [INT]          NULL,
        [ReplyUnsubscribe]     [INT]          NULL,
        [Open]                 [INT]          NULL,
        [EmailLinkUnsubscribe] [INT]          NULL,
        [Click]                [INT]          NULL,
        [Conversion]           [INT]          NULL,
        [AbandonedCart]        [INT]          NULL,
        [Purchase]             [INT]          NULL,
        [Revenue]              [FLOAT]        NULL,
        [Quantity]             [FLOAT]        NULL
)
