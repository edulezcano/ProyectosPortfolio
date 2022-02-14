/*
    Exploración de datos sobre el COVID-19
    Autor: Eduardo Lezcano
    Fecha: 12-02-2022
*/

-- Corregimos el formato de las fechas para SQLite3
UPDATE covidvacunas /* lo mismo para la tabla covidmuertes */
   SET date = substr(date, -4) || '-' || substr('0' || substr(date, instr(date, '/') + 1, length(date) - 5 - instr(date, '/') ), -2) || '-' || substr('0' || substr(date, 1, instr(date, '/') - 1), -2) 
 WHERE date LIKE '_%/_%/____';

-- Seleccionamos los datos que vamos a utilizar

SELECT location,
       date,
       total_cases,
       new_cases,
       total_deaths,
       population
  FROM covidmuertes
 WHERE continent IS NOT NULL
 ORDER BY 1,
          2;
          
-- Casos Totales vs Muertes Totales en Paraguay

SELECT location,
       date,
       total_cases,
       total_deaths,
       (total_deaths / total_cases) * 100 AS [Tasa de mortalidad]
  FROM covidmuertes
 WHERE location = "Paraguay"
 ORDER BY 1,
          2;
 
/* Casos Totales VS Población en Paraguay
    Esto nos muestra qué porcentaje de nuestra población ya ha contraído COVID-19
*/
SELECT location,
       date,
       population,
       total_cases,
       (total_cases / population) * 100 AS [Porcentaje infectado]
  FROM covidmuertes
 WHERE location = "Paraguay"
 ORDER BY 1,
          2;

CREATE VIEW CasosParaguay AS
    SELECT location,
           date,
           population,
           total_cases,
           (total_cases / population) * 100 AS [Porcentaje infectado]
      FROM covidmuertes
     WHERE location = "Paraguay"
     ORDER BY 1,
              2;

-- Paises con mayor tasa de infección

SELECT location,
       population,
       max(total_cases) AS [Casos en Total],
       max( (total_cases / population) ) * 100 AS [Porcentaje de la población infectada]
  FROM covidmuertes
 WHERE continent IS NOT NULL
 GROUP BY location,
          population
 ORDER BY 4 DESC;

-- Países con mayor cantidad de fallecidos

SELECT location,
       continent,
       max(total_deaths) AS [Total de fallecidos]
  FROM covidmuertes
 WHERE continent IS NOT NULL
 GROUP BY location
 ORDER BY 3 DESC;

-- Continentes con mayor cantidad de fallecidos

-- Opción 1
SELECT continent,
       sum(TF) AS [Total de fallecidos]
  FROM (
           SELECT location,
                  continent,
                  max(total_deaths) AS TF
             FROM covidmuertes
            WHERE continent IS NOT NULL
            GROUP BY location
       )
 WHERE continent IS NOT NULL
 GROUP BY continent
 ORDER BY 2 DESC;
 
-- Opción 2
SELECT location as Continente,
       max(total_deaths) AS [Total de fallecidos]
  FROM covidmuertes
 WHERE location IN ('Europe','North America','Asia','Oceania','South America','Africa')
 GROUP BY location
 ORDER BY 2 DESC;
 
CREATE VIEW FallecidosPorContinente AS
    SELECT location AS Continente,
           max(total_deaths) AS [Total de fallecidos]
      FROM covidmuertes
     WHERE location IN ('Europe', 'North America', 'Asia', 'Oceania', 'South America', 'Africa') 
     GROUP BY location
     ORDER BY 2 DESC;
 
--  Números Globales
-- Por fecha
SELECT date,
       total_cases AS [Casos totales],
       new_cases AS [Casos nuevos],
       total_deaths AS [Muertes totales],
       new_deaths AS [Muertes nuevas],
       total_deaths / total_cases * 100 AS [Tasa de mortalidad]
  FROM covidmuertes
 WHERE location = 'World'
 GROUP BY date;

-- Total
SELECT max(total_cases) AS [Casos totales],
       max(total_deaths) AS [Muertes totales],
       max(total_deaths) / max(total_cases) * 100 AS [Tasa de mortalidad]
  FROM covidmuertes
 WHERE location = 'World';

-- Población vs Población vacunada en el mundo y en Paraguay
-- Muestra el porcentaje de la población que recibió al menos una dosis de la vacuna contra el COVID-19
SELECT cm.continent,
       cm.location,
       cm.date,
       cm.population,
       cv.people_vaccinated,
       cv.new_vaccinations,
       sum(cv.new_vaccinations) OVER (PARTITION BY cm.location ORDER BY cm.location,
       cm.date) AS [Vacunas administradas],
       cv.people_vaccinated / cm.population * 100 AS [Porcentaje vacunado]
  FROM covidmuertes AS cm
       JOIN
       covidvacunas AS cv ON cm.location = cv.location AND 
                             cm.date = cv.date
-- WHERE cm.continent IS NOT NULL
 WHERE cm.location = 'Paraguay'
 ORDER BY 2,
          3;

/*
Usamos una CTE para realizar un cálculo a partir del PARTITION BY de la consulta anterior,
el cálculo realizado es erróneo ya que no considera las dosis de refuerzo por persona. Sin embargo, a efectos prácticos de mostrar el uso
de las CTE lo realizaremos de la siguiente manera:
*/

WITH PervsVac (
    continent,
    location,
    date,
    population,
    people_vaccinated,
    new_vaccinations,
    [Vacunas administradas],
    [Porcentaje vacunado]
)
AS (
    SELECT cm.continent,
           cm.location,
           cm.date,
           cm.population,
           cv.people_vaccinated,
           cv.new_vaccinations,
           sum(cv.new_vaccinations) OVER (PARTITION BY cm.location ORDER BY cm.location,
           cm.date) AS [Vacunas administradas],
           cv.people_vaccinated / cm.population * 100 AS [Porcentaje vacunado]
      FROM covidmuertes AS cm
           JOIN
           covidvacunas AS cv ON cm.location = cv.location AND 
                                 cm.date = cv.date
--     WHERE cm.continent IS NOT NULL
     WHERE cm.location = 'Paraguay'
)
SELECT *,
       [Vacunas administradas] / population * 100 AS [Porcentaje vacunado 2]
  FROM PervsVac;
  
/*
Usamos una Tabla Temporal para realizar un cálculo a partir del PARTITION BY de la consulta anterior,
el cálculo realizado es erróneo ya que no considera las dosis de refuerzo por persona. Sin embargo, a efectos prácticos de mostrar el uso
de las Tablas temporales lo realizaremos de la siguiente manera:
*/
DROP TABLE IF EXISTS PorcentajePersonasVacunadas;

CREATE TEMP TABLE PorcentajePersonasVacunadas (
    continente            NVARCHAR (255),
    ubicacion             NVARCHAR (255),
    fecha                 DATETIME,
    poblacion             DOUBLE,
    nuevas_vacunas        DOUBLE,
    vacunas_administradas DOUBLE
);

INSERT INTO PorcentajePersonasVacunadas SELECT cm.continent,
                                               cm.location,
                                               cm.date,
                                               cm.population,
                                               cv.new_vaccinations,
                                               sum(cv.new_vaccinations) OVER (PARTITION BY cm.location ORDER BY cm.location,
                                               cm.date) AS [Vacunas administradas]
                                          FROM covidmuertes AS cm
                                               JOIN
                                               covidvacunas AS cv ON cm.location = cv.location AND 
                                                                     cm.date = cv.date
-- WHERE cm.continent IS NOT NULL
-- WHERE cm.location = 'Paraguay'
;

SELECT *,
       vacunas_administradas / poblacion * 100 AS [Porcentaje vacunado]
  FROM PorcentajePersonasVacunadas
-- WHERE continente IS NOT NULL
 WHERE ubicacion = 'Paraguay' 
;

-- Creamos una vista para guardar los datos para posterior utilización
CREATE VIEW PorcentajePersonasVacunadas AS
    SELECT cm.continent,
           cm.location,
           cm.date,
           cm.population,
           cv.people_vaccinated,
           cv.new_vaccinations,
           sum(cv.new_vaccinations) OVER (PARTITION BY cm.location ORDER BY cm.location,
           cm.date) AS [Vacunas administradas],
           cv.people_vaccinated / cm.population * 100 AS [Porcentaje vacunado]
      FROM covidmuertes AS cm
           JOIN
           covidvacunas AS cv ON cm.location = cv.location AND 
                                 cm.date = cv.date
     WHERE cm.continent IS NOT NULL
--     WHERE cm.location = 'Paraguay'
;