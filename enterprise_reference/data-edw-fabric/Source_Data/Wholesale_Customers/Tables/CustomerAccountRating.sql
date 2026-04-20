CREATE TABLE [Wholesale_Customers].[CustomerAccountRating] (

	[CustomerNumber] char(13) NOT NULL, 
	[CurrentYearRating] char(1) NULL, 
	[PreviousYearRating] char(1) NULL, 
	[SecondYearRating] char(1) NULL, 
	[Account Exception Flag] bit NOT NULL
);