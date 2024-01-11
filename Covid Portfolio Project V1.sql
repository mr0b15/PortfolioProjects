--Percent of people who died after getting COVID
SELECT
	continent,
	location,
	date,
	total_cases,
	total_deaths,
	CAST(total_deaths AS float)/CAST(total_cases AS float) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL

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

--Highest Death Count per Population
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

--Highest Death Count per Continent
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
WHERE location LIKE 'United States'