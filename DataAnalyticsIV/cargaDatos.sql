/** 
Se crea una tabla temporal que contiene los nombres de los archivos CSV y su path
dentro de la carpeta que los contiene 
**/

IF OBJECT_ID('TEMPDB..#TEMP_FILES') IS NOT NULL DROP TABLE #TEMP_FILES

CREATE TABLE #TEMP_FILES
(
FileName VARCHAR(MAX),
DEPTH VARCHAR(MAX),
[FILE] VARCHAR(MAX)
)
 
INSERT INTO #TEMP_FILES
EXEC master.dbo.xp_DirTree 'C:\Users\julezcano\Documents\Proyectos Activos\Data Analytics IV\PGN\',1,1

/** 
Se crea una tabla temporal donde se insertarán todos los registros existentes en nuestros 
archivos CSV
**/

IF OBJECT_ID('TEMPDB..#TEMP_RESULTS') IS NOT NULL DROP TABLE #TEMP_RESULTS

CREATE TABLE #TEMP_RESULTS
(
     anio text,
	 mes text,
	 idNivel text,
	 descNivel varchar(255),
	 idEntidad text,
	 descEntidad varchar(255),
	 idUnidadResponsable text,
	 desUnidadResponsable varchar(255),
	 idTipoPresupuesto text,
	 descTipoPresupuesto varchar(255),
	 idPrograma text,
	 descPrograma varchar(255),
	 idSubprograma text,
	 descSubprograma varchar(255),
	 idProyectoActividad text,
	 descProyectoActividad varchar(255),
	 idFinalidad text,
	 descFinalidad varchar(255),
	 idFuncion text,
	 descFuncion varchar(255),
	 idSubfuncion text,
	 descSubfuncion varchar(255),
	 grupoEconomico varchar(255),
	 subgrupoEconomico varchar(255),
	 categoriaEconomica varchar(255),
	 idFuenteFinanciamiento text,
	 descFuenteFinanciamiento varchar(255),
	 idGrupoObjetoGasto text,
	 descGrupoObjetoGasto varchar(255),
	 idSubgrupoObjetoGasto text,
	 subgrupoObjetoGasto varchar(255),
	 idObjetoGasto text,
	 objetoGasto varchar(255),
	 idOrganismoFinanciador text,
	 organismoFinanciador varchar(255),
	 idDepartamento text,
	 departamento varchar(255),
	 idUAF text,
	 UAF varchar(255),
	 idNivelFinanciero text,
	 nombrenivelFinanciero varchar(255),
	 idClasificación text,
	 clasificacion text,
	 presupuestoInicialAprobado text,
	 montoVigente text,
	 montoPlanFinancieroVigente text,
	 montoEjecutado text,
	 montoTransferido text,
	 montoPagado text,
	 mesCorte text,
	 anioCorte text,
	 fechaCorte text
)
--
DECLARE @FILENAME VARCHAR(MAX),@SQL VARCHAR(MAX)
 
WHILE EXISTS(SELECT * FROM #TEMP_FILES)
BEGIN
   SET @FILENAME = (SELECT TOP 1 FileName FROM #TEMP_FILES)
   SET @SQL = 'BULK INSERT #TEMP_RESULTS
   FROM ''C:\Users\julezcano\Documents\Proyectos Activos\Data Analytics IV\PGN\' + @FILENAME +'''
   WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'');'
  
   PRINT @SQL
   EXEC(@SQL)
  
   DELETE FROM #TEMP_FILES WHERE FileName = @FILENAME
 
END

-- Verificamos la carga de registros
SELECT TOP 50 * FROM #TEMP_RESULTS

-- Se comprueban los campos que son de nuestro interés
SELECT TOP 100
	anio,
	mes,
	idNivel,
	descNivel,
	idEntidad,
	descEntidad,
	idUnidadResponsable,
	desUnidadResponsable,
	grupoEconomico,
	categoriaEconomica,
	idFuenteFinanciamiento,
	descFuenteFinanciamiento,
	idGrupoObjetoGasto,
	descGrupoObjetoGasto,
	objetoGasto,
	idDepartamento,
	departamento,
	idNivelFinanciero,
	nombrenivelFinanciero,
	presupuestoInicialAprobado,
	montoVigente,
	montoPlanFinancieroVigente,
	montoEjecutado,
	montoTransferido,
	montoPagado
 FROM
	#TEMP_RESULTS

-- Tomo los valores distintos de las categorías del un solo año.
SELECT DISTINCT descNivel
 FROM #TEMP_RESULTS
WHERE anio like '2018'

-- Se insertan en nuestra tabla objetivo los registros del rubro que nos interesa.
INSERT INTO Gastos (
	anio,
	mes,
	idNivel,
	descNivel,
	idEntidad,
	descEntidad,
	idUnidadResponsable,
	desUnidadResponsable,
	grupoEconomico,
	categoriaEconomica,
	idFuenteFinanciamiento,
	descFuenteFinanciamiento,
	idGrupoObjetoGasto,
	descGrupoObjetoGasto,
	objetoGasto,
	idDepartamento,
	departamento,
	idNivelFinanciero,
	nombrenivelFinanciero,
	presupuestoInicialAprobado,
	montoVigente,
	montoPlanFinancieroVigente,
	montoEjecutado,
	montoTransferido,
	montoPagado)
SELECT
	anio,
	mes,
	idNivel,
	descNivel,
	idEntidad,
	descEntidad,
	idUnidadResponsable,
	desUnidadResponsable,
	grupoEconomico,
	categoriaEconomica,
	idFuenteFinanciamiento,
	descFuenteFinanciamiento,
	idGrupoObjetoGasto,
	descGrupoObjetoGasto,
	objetoGasto,
	idDepartamento,
	departamento,
	idNivelFinanciero,
	nombrenivelFinanciero,
	presupuestoInicialAprobado,
	montoVigente,
	montoPlanFinancieroVigente,
	montoEjecutado,
	montoTransferido,
	montoPagado
 FROM #TEMP_RESULTS
WHERE idNivel like '11'