CREATE TABLE [wholesale_codis].[bttripd] (
    [BDTRP#] NUMERIC (5)     NOT NULL,
    [BDDRP#] NUMERIC (2)     NOT NULL,
    [BDORD#] CHAR (7)        NOT NULL,
    [BDISEQ] NUMERIC (7)     NOT NULL,
    [BDITM#] CHAR (15)       NOT NULL,
    [BDITMD] CHAR (20)       NOT NULL,
    [BDCITM] CHAR (15)       NOT NULL,
    [BDINVN] NUMERIC (9)     NOT NULL,
    [BDREF#] NUMERIC (6)     NOT NULL,
    [BDCUS#] NUMERIC (8)     NOT NULL,
    [BDCTL#] NUMERIC (7)     NOT NULL,
    [BDICLS] CHAR (4)        NOT NULL,
    [BDCCLS] CHAR (5)        NOT NULL,
    [BDITQT] NUMERIC (5)     NOT NULL,
    [BDITCT] NUMERIC (10, 2) NOT NULL,
    [BDITWT] NUMERIC (10, 2) NOT NULL,
    [BDCUSR] CHAR (10)       NOT NULL,
    [BDCDAT] NUMERIC (8)     NOT NULL,
    [BDCTIM] NUMERIC (6)     NOT NULL,
    [BDCPGM] CHAR (10)       NOT NULL
)

