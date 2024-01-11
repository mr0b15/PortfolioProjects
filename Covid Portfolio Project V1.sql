/* Covid 19 Dataset from: https://ourworldindata.org/covid-deaths
Dates from Janurary 2020 to April 2021

Skills used: Join, CTE, Window Functions, Aggregate Function, Creating Views, Converting Data Types

*/

--Cases vs Deaths
--Percent of people who died after getting Infected with COVID

SELECT
	continent,
	location,
	date,
	total_cases,
	total_deaths,
	CAST(total_deaths AS float)/CAST(total_cases AS float) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL


--Cases vs Population
--Percent of population who got COVID

SELECT
	continent,
	location,
	date,
	population,
	total_cases,
	CAST(total_cases AS float)/CAST(population AS float)*100 AS InfectedPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL


--Death Count per Population
--Ordered by Country with highest percentage

SELECT
	continent,
	location,
	population,
	MAX(total_deaths) as deaths,
	CAST(MAX(total_deaths) AS float)/CAST(MAX(population) AS float)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, population, continent
ORDER BY DeathPercentage DESC


--Death Count per Continent
--Ordered by Continent with the most deaths

SELECT
	continent,
	SUM(population) as continentPopulation,
	SUM(deaths) AS continentDeaths
FROM (
	SELECT
		continent,
		location,
		population,
		MAX(total_deaths) as deaths,
		CAST(MAX(total_deaths) AS float)/CAST(MAX(population) AS float)*100 AS DeathPercentage
	FROM CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY continent, location, population) AS subq
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY continentDeaths DESC


--Vaccinations vs Population
--Percent of country population that is vaccinated by date

WITH popVsVac AS (
SELECT
	CovidDeaths.continent,
	CovidDeaths.location,
	CovidDeaths.date,
	CovidDeaths.population,
	CovidVaccinations.new_vaccinations,
	SUM(CAST(CovidVaccinations.new_vaccinations AS int)) OVER(PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) as rollingVaccinations
FROM CovidDeaths
JOIN CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location
	AND CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent IS NOT NULL
)

SELECT
	*,
	CAST(rollingVaccinations AS float)/CAST(population AS float)*100 AS percentVaccinated
FROM popVsVac