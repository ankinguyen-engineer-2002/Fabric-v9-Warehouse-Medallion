CREATE TABLE [Email_Marketing].[DimMessage]
    (
        [MessageName]           [VARCHAR](250)  NULL,
        [DeviceCategory]        [VARCHAR](150)  NULL,
        [DeviceType]            [VARCHAR](150)  NULL,
        [EventName]             [VARCHAR](1000) NULL,
        [Email_Prod_Cat]        [VARCHAR](150)  NULL,
        [Audience]              [VARCHAR](150)  NULL,
        [ConversionCategory]    [VARCHAR](200)  NULL,
        [ConversionSubcategory] [VARCHAR](200)  NULL,
        [Type]                  [VARCHAR](13)   NOT NULL,
        [Year]                  [INT]           NULL,
        [Month]                 [INT]           NULL,
        [Week]                  [INT]           NULL,
        [DateKey]               [VARCHAR](36)   NOT NULL,
        [Date]                  [DATE]          NULL
    );




