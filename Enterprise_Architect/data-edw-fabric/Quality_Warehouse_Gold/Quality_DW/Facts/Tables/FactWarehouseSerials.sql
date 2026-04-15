
CREATE table Quality_DW.FactWarehouseSerials (
	[Warehouse] [char](5) NOT NULL,
	[SerialNumber] [varchar](30) NOT NULL,
	[ItemNumber] [varchar](30) NOT NULL,
	[SerialStatus] [varchar](12) NULL,
	[MasterStatus] [varchar](12) NULL,
	[TransferTripNumber] [varchar](30) NULL,
	[MasterMOPO] [varchar](30) NULL,
	[VendorNumber] [char](7) NULL,
	[VendorName] [varchar](25) NULL,
	[Location] [varchar](50) NULL,
	[LicensePlate] [varchar](22) NULL,
	[ReceivedDate] [datetime2](6) NULL,
	[TripNumber] [varchar](50) NULL,
	[ShipDate] [char](1) NOT NULL,
	[CarbLevel] [char](1) NOT NULL,
	[RotationSequence] [char](1) NOT NULL,
	[BornOnDate] [datetime2](6) NULL,
	[POReceiptToStockDate] [date] NULL
)
go
CREATE STATISTICS [stat_FactWarehouseSerials_ItemNumber] ON Quality_DW.FactWarehouseSerials([ItemNumber]);
go
CREATE STATISTICS [stat_FactWarehouseSerials_SerialNumber] ON [Quality_DW].FactWarehouseSerials([SerialNumber]);
go
CREATE STATISTICS [stat_FactWarehouseSerials_TripNumber] ON [Quality_DW].FactWarehouseSerials([TripNumber]);
go
CREATE STATISTICS [stat_FactWarehouseSerials_TransferTripNumber] ON [Quality_DW].FactWarehouseSerials([TransferTripNumber]);
go
CREATE STATISTICS [stat_FactWarehouseSerials_SerialStatus] ON [Quality_DW].FactWarehouseSerials([SerialStatus]);
go