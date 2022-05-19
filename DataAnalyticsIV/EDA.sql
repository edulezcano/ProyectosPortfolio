USE dataAnalytics4
GO

SELECT *
 FROM dbo.Parlamentarios
WHERE inicioPeriodoLegislativo = 2018 
AND tipoParlamentario like 'Titular'
AND camaraParlamentario like 'Camara de Senadores';

SELECT TOP 100 *
FROM dbo.Gastos
WHERE anio like '2021'
AND montoEjecutado NOT LIKE '0'

SELECT CASE WHEN ISNUMERIC(apellidos) = 1 THEN CAST(apellidos AS INT) ELSE NULL END
FROM dbo.Parlamentarios

-- Análisis exploratorio de diferentes columnas
SELECT DISTINCT
	--descEntidad, 
	--desUnidadResponsable,
	categoriaEconomica
 FROM dbo.Gastos

-- Borramos las columnas que contienen info que no necesitamos
ALTER TABLE Gastos
DROP COLUMN 
	--idSubgrupoObjetoGasto, subgrupoObjetoGasto
	--idObjetoGasto, idOrganismoFinanciador, organismoFinanciador
	--idUAF, UAF, idClasificacion, clasificacion, mesCorte, anioCorte, fechaCorte
	idUnidadResponsable, desUnidadResponsable

/** Esta vista de la tabla de gastos se va a pasar a PowerQuery para terminar
	de realizar la limpieza de los datos **/

-- Vamos a modificar algunas columnas para que el formato se adapte mejor para las visualizaciones

SELECT *
 FROM Gastos_bkp2;
 -- 
SELECT DISTINCT categoriaEconomica
FROM Gastos

-- Actualizaremos valores de texto, por unos más comprensibles

UPDATE Gastos_bkp2
--SET categoriaEconomica = 'Activos Intangibles'
--WHERE categoriaEconomica LIKE '"214%'
SET categoriaEconomica = 'Bienes y Servicios'
WHERE categoriaEconomica LIKE '"122%'
--SET categoriaEconomica = 'Al Sector Externo'
--WHERE categoriaEconomica LIKE '"163%'

-- A partir de acá trabajamos en la copia para evitar comprometer información importante
SELECT DISTINCT categoriaEconomica
FROM Gastos_bkp2

SELECT DISTINCT grupoEconomico
FROM Gastos_bkp2

--Actualiza varios registros a la vez
UPDATE Gastos_bkp2
SET categoriaEconomica = (
CASE
	WHEN categoriaEconomica LIKE '"112%' THEN 'Bienes y Servicios'
	WHEN categoriaEconomica LIKE '"211%' THEN 'Formacion Bruta de Capital Fijo'
	WHEN categoriaEconomica LIKE '"161%' THEN 'Al Sector Privado'
	WHEN categoriaEconomica LIKE '123%' THEN 'Impuestos'
	WHEN categoriaEconomica LIKE '121%' THEN 'Remuneraciones'
	WHEN categoriaEconomica LIKE '11' THEN 'Legislativa'
	ELSE categoriaEconomica
END)

UPDATE Gastos_bkp2
SET descNivel = 'Poder Legislativo'

UPDATE Gastos_bkp2
SET descEntidad = (
CASE
	WHEN idEntidad LIKE '1' THEN 'Congreso Nacional'
	WHEN idEntidad LIKE '2' THEN 'Camara de Senadores'
	WHEN idEntidad LIKE '3' THEN 'Camara de Diputados'
END)

UPDATE Gastos_bkp2
SET grupoEconomico = (
CASE
	WHEN grupoEconomico LIKE '"11%' THEN 'Legislativa'
	WHEN grupoEconomico LIKE '"10%' THEN 'Gastos Corrientes'
	WHEN grupoEconomico LIKE '"2%' THEN 'Gastos de Capital'
END)

UPDATE Gastos_bkp2
SET descFuenteFinanciamiento = (
CASE
	WHEN descFuenteFinanciamiento LIKE '"30%' THEN 'Recursos Institucionales'
	WHEN descFuenteFinanciamiento LIKE '"21%' THEN 'Inversion Real Directa e Indirecta'
	WHEN descFuenteFinanciamiento LIKE '"10%' THEN 'Recursos del Tesoro'
END)

-- En esta columna empiezan a haber incongruencias, revisar.

UPDATE Gastos_bkp2
SET descGrupoObjetoGasto = (
CASE 
	WHEN descGrupoObjetoGasto LIKE '8%' THEN 'Transferencias'
	WHEN descGrupoObjetoGasto LIKE '"9%' THEN 'Otros gastos'
	WHEN descGrupoObjetoGasto LIKE '"1%' THEN 'Servicios personales'
	WHEN descGrupoObjetoGasto LIKE '"5%' THEN 'Inversion fisica'
	WHEN descGrupoObjetoGasto LIKE '"2%' THEN 'Servicios no personales'
	WHEN descGrupoObjetoGasto LIKE '"3%' THEN 'Bienes de Consumo e Insumos'
	ELSE NULL
END)

SELECT *
 FROM Gastos_bkp2
 WHERE objetoGasto like '330';

 -- Acá es donde está la mayor información de los gastos (objetoGasto)
/** Como son demasiadas categorías, se van a tomar en cuenta las 10 primeras categorías
con mayor cantida de registros para nuestras visualizaciones, al resto se le va asignar su mismo nomrbe **/
SELECT 
	ObjetoGasto,
	COUNT(*) as Cantidas_Registros
 FROM Gastos_bkp2
GROUP BY objetoGasto
ORDER BY 2 DESC;

 UPDATE Gastos_bkp2
 SET ObjetoGasto = (
 CASE
	WHEN ObjetoGasto LIKE '"341%' THEN 'Elementos de Limpieza'
	WHEN ObjetoGasto LIKE '"264%' THEN 'Primas y Gastos de Seguros'
	WHEN ObjetoGasto LIKE '"262%' THEN 'Imprenta'
	WHEN ObjetoGasto LIKE '"842%' THEN 'Entidades educativas e Instituciones sin fines de lucro'
	WHEN ObjetoGasto LIKE '"123%' THEN 'Remuneracion Extraordinaria'
	WHEN ObjetoGasto LIKE '"123%' THEN 'Remuneracion Extraordinaria'
	WHEN ObjetoGasto LIKE '"590%' THEN 'Otros gastos de inversión y reparaciones mayores'
	WHEN ObjetoGasto LIKE '"199%' THEN 'Otros gastos de personal'
	WHEN ObjetoGasto LIKE '"250%' THEN 'Alquileres y derechos'
	WHEN ObjetoGasto LIKE '"145%' THEN 'Honorarios profesionales'
	WHEN ObjetoGasto LIKE '"210%' THEN 'Servicios básicos'
	WHEN ObjetoGasto LIKE '"541%' THEN 'Adquisiciones de inmuebles y enseres'
	WHEN ObjetoGasto LIKE '"%' THEN ''
END)
------------------------------------------------------------------------------------------------------------------------
UPDATE Gastos_bkp2
SET departamento = (
CASE
	WHEN departamento LIKE '"1%' THEN 'Genuino'
	WHEN departamento LIKE '"509%' THEN 'República de China'
	WHEN departamento LIKE '"3%' THEN 'FONACIDE'
	WHEN departamento LIKE '"530%' THEN 'Aquisiciones de maquinarias'
	WHEN departamento LIKE '"1%' THEN 'Genuino'
	WHEN departamento LIKE '99%' THEN 'Alcance Nacional'
	ELSE departamento
END)

SELECT DISTINCT departamento
 FROM Gastos_bkp2

 ----------------------------------------------------------------------
 SELECT DISTINCT nombrenivelFinanciero
 FROM Gastos_bkp2;

 UPDATE Gastos_bkp2
 SET nombrenivelFinanciero = (
 CASE
	WHEN nombrenivelFinanciero LIKE '"12%' THEN 'Remuneraciones varias'
	WHEN nombrenivelFinanciero LIKE '"19%' THEN 'Otros servicios personales'
	WHEN nombrenivelFinanciero LIKE '"63%' THEN 'Combustibles y lubricantes'
	WHEN nombrenivelFinanciero LIKE '"61%' THEN 'Productos Alimenticios'
	WHEN nombrenivelFinanciero LIKE '"11%' THEN 'Remuneraciones básicas'
	WHEN nombrenivelFinanciero LIKE '"50%' THEN 'Inversiones'
	WHEN nombrenivelFinanciero LIKE '"99%' THEN 'Alcance nacional'
	WHEN nombrenivelFinanciero LIKE '"62%' THEN 'Medicamentos y otros'
	WHEN nombrenivelFinanciero LIKE '"20%' THEN 'Servicios básicos'
	WHEN nombrenivelFinanciero LIKE '"101%'THEN 'Cámara de Senadores'
	ELSE nombrenivelFinanciero
END)

SELECT * FROM Gastos_bkp2;