CREATE TABLE [Retail_Miniapps].[TRAFFIC_GOAL] (

	[Operation] varchar(50) NOT NULL, 
	[TRPC] varchar(5) NOT NULL, 
	[TRDATE] datetime2(0) NOT NULL, 
	[TRYYYYMM] varchar(6) NOT NULL, 
	[TRGLD] float NULL, 
	[BudgetID] int NULL, 
	[WebsitePageViews] float NULL, 
	[Chats] float NULL, 
	[WebsitePageViewsWrittenBudget] float NULL, 
	[ChatsWrittenBudget] float NULL
);