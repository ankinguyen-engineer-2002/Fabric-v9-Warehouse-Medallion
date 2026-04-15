
CREATE TABLE [Email_Marketing].[UniqueEmails]
(
	[Year]           [int]  NULL,
	[Month]          [int]  NULL,
	[Week]           [int]  NULL,
	[Type]           [varchar](13)  NOT NULL,
	[MessageName]    [varchar](250)  NULL,
	[Audience]       [varchar](150)  NULL,
	[Email_Prod_Cat] [varchar](150)  NULL,
	[emails]         [int]  NULL
)