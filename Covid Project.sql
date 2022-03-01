-- Verifying data sources

SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM CovidVaccinations
ORDER BY 3,4

-- Select the data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in US

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percentage
FROM CovidDeaths
WHERE location LIKE '%Canada%'
AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at the total cases vs population
-- Shows percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population) * 100 AS percent_population_infected
FROM CovidDeaths
WHERE location LIKE '%Canada%'
AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS high_infection_count, MAX((total_cases/population)) * 100 AS percent_population_infected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_population_infected DESC


-- Showing countries with highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

-- Showing same results broken down by continent

SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC

-- Showing contienents with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

-- Global Numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2


-- Looking at total population vs vaccinations

SELECT dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations, 
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- CTE

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated) AS
(
SELECT dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations, 
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (rolling_people_vaccinated/population) * 100 AS rolling_people_vaccinated_percentage
FROM pop_vs_vac

-- Create view to store data for visualizations

CREATE VIEW percent_population_vaccinated AS
SELECT dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations, 
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
