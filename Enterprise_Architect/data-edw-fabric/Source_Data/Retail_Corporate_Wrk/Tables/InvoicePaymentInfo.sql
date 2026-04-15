CREATE TABLE [Retail_Corporate_Wrk].[InvoicePaymentInfo]
(
	[Operation] [VARCHAR](15) NULL,
	[AuthNbr] [VARCHAR](50) NULL,
	[CompanyID] [VARCHAR](50) NOT NULL,
	[DateChanged] [DATETIME2](6) NULL,
	[DateCreated] [DATETIME2](6) NULL,
	[DrvLicExpDate] [VARCHAR](50) NULL,
	[OrderID] [VARCHAR](50) NOT NULL,
	[PaymentAmt] [DECIMAL] (19,4) NULL,
	[PaymentNbr] [INT] NOT NULL,
	[PaymentTypeID] [VARCHAR](50) NOT NULL,
	[PostDate] [DATETIME2](6) NULL,
	[PostTime] [DATETIME2](6) NULL,
	[RecStatus] [CHAR](1) NULL,
	[ReferenceNbr] [VARCHAR](255) NULL,
	[SourceID] [VARCHAR](50) NOT NULL,
	[TransDate] [DATETIME2](6) NULL
)
Go