CREATE TABLE [Email_Marketing].[TotalTransactionalSegment]
(
        [Email_Date]           [DATETIME2](6) NULL,
        [Audience]             [VARCHAR](150) NULL,
        [MessageName]          [VARCHAR](250) NULL,
        [Email_MSG_TYP]        [VARCHAR](150) NULL,
        [Email_PROD_CAT]       [VARCHAR](150) NULL,
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
