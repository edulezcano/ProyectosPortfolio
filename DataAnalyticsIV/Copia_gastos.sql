USE [dataAnalytics4]
GO

/****** Object:  Table [dbo].[Gastos]    Script Date: 03/05/2022 15:03:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Gastos_bkp2](
	[anio] [varchar](max) NULL,
	[mes] [varchar](max) NULL,
	[descNivel] [varchar](max) NULL,
	[idEntidad] [varchar](max) NULL,
	[descEntidad] [varchar](max) NULL,
	[grupoEconomico] [varchar](max) NULL,
	[categoriaEconomica] [varchar](max) NULL,
	[idFuenteFinanciamiento] [varchar](max) NULL,
	[descFuenteFinanciamiento] [varchar](max) NULL,
	[idGrupoObjetoGasto] [varchar](max) NULL,
	[descGrupoObjetoGasto] [varchar](max) NULL,
	[objetoGasto] [varchar](max) NULL,
	[idDepartamento] [varchar](max) NULL,
	[departamento] [varchar](max) NULL,
	[idNivelFinanciero] [varchar](max) NULL,
	[nombrenivelFinanciero] [varchar](max) NULL,
	[presupuestoInicialAprobado] [varchar](max) NULL,
	[montoVigente] [varchar](max) NULL,
	[montoPlanFinancieroVigente] [varchar](max) NULL,
	[montoEjecutado] [varchar](max) NULL,
	[montoTransferido] [varchar](max) NULL,
	[montoPagado] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


INSERT INTO Gastos_bkp2
SELECT * FROM Gastos