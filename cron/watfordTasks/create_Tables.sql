USE [VESAGEFAVOURITES]
GO
/****** Object:  User [sagews]    Script Date: 06/18/2008 11:41:12 ******/
CREATE USER [sagews] FOR LOGIN [sagews] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  Table [dbo].[tblSOPItem]    Script Date: 06/18/2008 11:41:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSOPItem](
	[ORDER_NUMBER] [nchar](10) NOT NULL,
	[STOCK_CODE] [nvarchar](50) NOT NULL,
	[DESCRIPTION] [nvarchar](max) NULL,
	[QTY_ORDER] [smallint] NOT NULL,
	[ORDER_ID] [nchar](10) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblOrderItem]    Script Date: 06/18/2008 11:41:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblOrderItem](
	[ACCOUNT_REF] [nvarchar](50) NOT NULL,
	[ORDER_NUMBER] [nchar](10) NOT NULL,
	[STOCK_CODE] [nvarchar](50) NOT NULL,
	[ORDER_DATE] [datetime] NOT NULL,
	[DESCRIPTION] [nvarchar](max) NOT NULL,
	[QTY_ORDER] [smallint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFavourite]    Script Date: 06/18/2008 11:41:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFavourite](
	[ACCOUNT_REF] [nvarchar](50) NOT NULL,
	[STOCK_CODE] [nvarchar](50) NOT NULL,
	[ORDER_COUNT] [smallint] NULL,
	[QTYTODATE] [smallint] NULL,
	[LASTORDERDATE] [datetime] NOT NULL,
	[LASTORDERQUANTITY] [smallint] NULL,
 CONSTRAINT [PK_tblFavourite] PRIMARY KEY CLUSTERED 
(
	[ACCOUNT_REF] ASC,
	[STOCK_CODE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSOPOrder]    Script Date: 06/18/2008 11:41:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSOPOrder](
	[ORDER_NUMBER] [nvarchar](50) NOT NULL,
	[ACCOUNT_REF] [nvarchar](50) NOT NULL,
	[ORDER_DATE] [datetime] NOT NULL,
	[DESPATCH_STATUS] [nvarchar](50) NOT NULL,
	[ORDER_ID] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tblSOPOrder] PRIMARY KEY CLUSTERED 
(
	[ORDER_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
