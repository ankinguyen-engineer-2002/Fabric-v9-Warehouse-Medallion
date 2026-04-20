
CREATE TABLE [Email_Marketing].[UniquePromotionalSegment]
(
	[Delivered_Startdate] [datetime2](6)  NULL,
	[Audience]            [varchar](150)  NULL,
	[MessageName]         [varchar](250)  NULL,
	[Email_Msg_Typ]       [varchar](150)  NULL,
	[Email_Prod_Cat]      [varchar](150)  NULL,
	[Unique_Open]         [int]  NULL,
	[Unique_Clicks]       [int]  NULL
)