CREATE TABLE [Email_Marketing].[TotalAccountDateLevel]

  (
    [ActionTimestamp]       [DATETIME2](6) NULL,
    [DeviceType]            [VARCHAR](150) NULL,
    [ConversionCategory]    [VARCHAR](200) NULL,
    [ConversionSubcategory] [VARCHAR](200) NULL,
    [SpamComplaint]         [INT]          NULL,
    [ISPLinkUnsubscribe]    [INT]          NULL,
    [Delivered]             [INT]          NULL,
    [Undelivered]           [INT]          NULL,
    [ReplyUnsubscribe]      [INT]          NULL,
    [Open]                  [INT]          NULL,
    [EmailLinkUnsubscribe]  [INT]          NULL,
    [Click]                 [INT]          NULL,
    [Conversion]            [INT]          NULL,
    [AbandonedCart]         [INT]          NULL,
    [Purchase]              [INT]          NULL,
    [Revenue]               [FLOAT]        NULL,
    [Quantity]              [FLOAT]        NULL
)

